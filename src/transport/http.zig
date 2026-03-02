const std = @import("std");
const errors = @import("../errors.zig");

pub const Transport = struct {
    allocator: std.mem.Allocator,
    client: std.http.Client,
    base_url: []const u8,
    api_key: ?[]const u8,
    organization: ?[]const u8,
    project: ?[]const u8,
    proxy_url: ?[]const u8,
    owns_base_url: bool,
    owns_api_key: bool,
    owns_organization: bool,
    owns_project: bool,
    timeout_ms: ?u64 = null,
    max_retries: u8 = 2,
    retry_base_delay_ms: u64 = 500,
    extra_headers: []const std.http.Header,
    owns_extra_headers: bool,
    proxy_http: ?*std.http.Client.Proxy = null,
    proxy_https: ?*std.http.Client.Proxy = null,

    pub const Options = struct {
        base_url: []const u8,
        api_key: ?[]const u8 = null,
        organization: ?[]const u8 = null,
        project: ?[]const u8 = null,
        extra_headers: ?[]const std.http.Header = null,
        proxy: ?[]const u8 = null,
        timeout_ms: ?u64 = null,
        max_retries: u8 = 2,
        retry_base_delay_ms: u64 = 500,
    };

    pub const RequestOptions = struct {
        base_url: ?[]const u8 = null,
        api_key: ?[]const u8 = null,
        organization: ?[]const u8 = null,
        project: ?[]const u8 = null,
        timeout_ms: ?u64 = null,
        max_retries: ?u8 = null,
        retry_base_delay_ms: ?u64 = null,
        extra_headers: ?[]const std.http.Header = null,
    };

    const ActiveRequestOptions = struct {
        base_url: []const u8,
        api_key: ?[]const u8,
        organization: ?[]const u8,
        project: ?[]const u8,
        timeout_ms: ?u64,
        max_retries: u8,
        retry_base_delay_ms: u64,
        extra_headers: ?[]const std.http.Header,
    };

    pub fn init(allocator: std.mem.Allocator, opts: Options) !Transport {
        const http_client = std.http.Client{ .allocator = allocator };
        const ExtraConfig = struct { headers: []const std.http.Header, owns: bool };
        const extra_config = if (opts.extra_headers) |headers| blk: {
            const duped = try allocator.dupe(std.http.Header, headers);
            break :blk ExtraConfig{ .headers = duped, .owns = true };
        } else blk: {
            break :blk ExtraConfig{ .headers = &.{}, .owns = false };
        };

        const base_url = try allocator.dupe(u8, opts.base_url);
        const api_key = if (opts.api_key) |key| try allocator.dupe(u8, key) else null;
        const organization = if (opts.organization) |organization| try allocator.dupe(u8, organization) else null;
        const project = if (opts.project) |project| try allocator.dupe(u8, project) else null;
        const proxy_url = if (opts.proxy) |url| try allocator.dupe(u8, url) else null;

        var transport = Transport{
            .allocator = allocator,
            .client = http_client,
            .base_url = base_url,
            .api_key = api_key,
            .organization = organization,
            .project = project,
            .owns_base_url = true,
            .owns_api_key = api_key != null,
            .owns_organization = organization != null,
            .owns_project = project != null,
            .proxy_url = proxy_url,
            .timeout_ms = opts.timeout_ms,
            .max_retries = opts.max_retries,
            .retry_base_delay_ms = opts.retry_base_delay_ms,
            .extra_headers = extra_config.headers,
            .owns_extra_headers = extra_config.owns,
            .proxy_http = null,
            .proxy_https = null,
        };
        errdefer transport.deinit();

        if (proxy_url) |url| {
            if (try parseProxy(allocator, url)) |proxy| {
                switch (proxy.protocol) {
                    .plain => transport.proxy_http = proxy,
                    .tls => transport.proxy_https = proxy,
                }
                transport.client.http_proxy = transport.proxy_http;
                transport.client.https_proxy = transport.proxy_https;
            }
        }
        return transport;
    }

    pub fn deinit(self: *Transport) void {
        if (self.owns_base_url) {
            self.allocator.free(self.base_url);
        }
        if (self.owns_api_key) {
            if (self.api_key) |api_key| {
                self.allocator.free(api_key);
            }
        }
        if (self.owns_organization) {
            if (self.organization) |organization| {
                self.allocator.free(organization);
            }
        }
        if (self.owns_project) {
            if (self.project) |project| {
                self.allocator.free(project);
            }
        }
        if (self.owns_extra_headers) {
            self.allocator.free(self.extra_headers);
        }
        if (self.proxy_url) |url| {
            self.allocator.free(url);
        }
        if (self.proxy_http) |proxy| {
            self.allocator.free(proxy.host);
            if (proxy.authorization) |auth| {
                self.allocator.free(auth);
            }
            self.allocator.destroy(proxy);
        }
        if (self.proxy_https) |proxy| {
            self.allocator.free(proxy.host);
            if (proxy.authorization) |auth| {
                self.allocator.free(auth);
            }
            self.allocator.destroy(proxy);
        }
        self.client.deinit();
    }

    pub const Response = struct {
        status: u16,
        body: []u8,
    };

    pub fn request(
        self: *Transport,
        method: std.http.Method,
        path: []const u8,
        headers: []const std.http.Header,
        body: ?[]const u8,
    ) errors.Error!Response {
        return self.requestInternal(method, path, headers, body, null) catch |err| {
            return mapTransportError(err);
        };
    }

    pub fn requestWithOptions(
        self: *Transport,
        method: std.http.Method,
        path: []const u8,
        headers: []const std.http.Header,
        body: ?[]const u8,
        req_opts: ?RequestOptions,
    ) errors.Error!Response {
        return self.requestInternal(method, path, headers, body, req_opts) catch |err| {
            return mapTransportError(err);
        };
    }

    fn resolveRequestOptions(
        self: *const Transport,
        req_opts: ?RequestOptions,
    ) ActiveRequestOptions {
        if (req_opts) |opts| {
            return ActiveRequestOptions{
                .base_url = opts.base_url orelse self.base_url,
                .api_key = opts.api_key orelse self.api_key,
                .organization = opts.organization orelse self.organization,
                .project = opts.project orelse self.project,
                .timeout_ms = opts.timeout_ms orelse self.timeout_ms,
                .max_retries = opts.max_retries orelse self.max_retries,
                .retry_base_delay_ms = opts.retry_base_delay_ms orelse self.retry_base_delay_ms,
                .extra_headers = opts.extra_headers,
            };
        }

        return ActiveRequestOptions{
            .base_url = self.base_url,
            .api_key = self.api_key,
            .organization = self.organization,
            .project = self.project,
            .timeout_ms = self.timeout_ms,
            .max_retries = self.max_retries,
            .retry_base_delay_ms = self.retry_base_delay_ms,
            .extra_headers = null,
        };
    }

    pub const StreamChunk = *const fn (ctx: ?*anyopaque, chunk: []const u8) errors.Error!void;

    pub fn requestStream(
        self: *Transport,
        method: std.http.Method,
        path: []const u8,
        headers: []const std.http.Header,
        body: ?[]const u8,
        on_chunk: StreamChunk,
        chunk_ctx: ?*anyopaque,
    ) errors.Error!void {
        return self.requestStreamInternal(method, path, headers, body, on_chunk, chunk_ctx, null);
    }

    pub fn requestStreamWithOptions(
        self: *Transport,
        method: std.http.Method,
        path: []const u8,
        headers: []const std.http.Header,
        body: ?[]const u8,
        on_chunk: StreamChunk,
        chunk_ctx: ?*anyopaque,
        req_opts: ?RequestOptions,
    ) errors.Error!void {
        return self.requestStreamInternal(method, path, headers, body, on_chunk, chunk_ctx, req_opts);
    }

    fn requestInternal(
        self: *Transport,
        method: std.http.Method,
        path: []const u8,
        headers: []const std.http.Header,
        body: ?[]const u8,
        req_opts: ?RequestOptions,
    ) !Response {
        const active_opts = self.resolveRequestOptions(req_opts);
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();
        const alloc = arena.allocator();

        const url = try buildUrl(alloc, active_opts.base_url, path);
        const uri = try std.Uri.parse(url);

        var attempt: u8 = 0;
        while (attempt <= active_opts.max_retries) : (attempt += 1) {
            var header_list = try std.ArrayList(std.http.Header).initCapacity(alloc, 0);
            defer header_list.deinit(alloc);
            if (self.extra_headers.len > 0) {
                try header_list.appendSlice(alloc, self.extra_headers);
            }
            if (active_opts.extra_headers) |extra_headers| {
                try header_list.appendSlice(alloc, extra_headers);
            }
            if (headers.len > 0) {
                try header_list.appendSlice(alloc, headers);
            }

            if (active_opts.api_key) |raw_key| {
                const key = std.mem.trim(u8, raw_key, " ");
                const bearer_prefix = "Bearer ";
                const header_value = if (std.mem.startsWith(u8, key, bearer_prefix))
                    key
                else blk: {
                    var auth_buf = try std.ArrayList(u8).initCapacity(alloc, bearer_prefix.len + key.len);
                    defer auth_buf.deinit(alloc);
                    try auth_buf.appendSlice(alloc, bearer_prefix);
                    try auth_buf.appendSlice(alloc, key);
                    break :blk try auth_buf.toOwnedSlice(alloc);
                };
                try header_list.append(alloc, .{ .name = "Authorization", .value = header_value });
            }
            if (active_opts.organization) |org| {
                const value = std.mem.trim(u8, org, " ");
                if (value.len > 0) {
                    try header_list.append(alloc, .{ .name = "OpenAI-Organization", .value = value });
                }
            }
            if (active_opts.project) |project| {
                const value = std.mem.trim(u8, project, " ");
                if (value.len > 0) {
                    try header_list.append(alloc, .{ .name = "OpenAI-Project", .value = value });
                }
            }

            var req = self.client.request(method, uri, .{
                .extra_headers = header_list.items,
                .keep_alive = false,
            }) catch |err| {
                if (!isRetryableFetchError(err) or attempt == active_opts.max_retries or !isRetryableMethod(method)) {
                    return err;
                }
                sleepForRetry(attempt, null, active_opts);
                continue;
            };
            defer req.deinit();

            if (body) |payload| {
                req.transfer_encoding = .{ .content_length = payload.len };
                var body_writer = req.sendBodyUnflushed(&.{}) catch |err| {
                    if (!isRetryableFetchError(err) or attempt == active_opts.max_retries or !isRetryableMethod(method)) {
                        return err;
                    }
                    sleepForRetry(attempt, null, active_opts);
                    continue;
                };
                body_writer.writer.writeAll(payload) catch |err| {
                    if (!isRetryableFetchError(err) or attempt == active_opts.max_retries or !isRetryableMethod(method)) {
                        return err;
                    }
                    sleepForRetry(attempt, null, active_opts);
                    continue;
                };
                body_writer.end() catch |err| {
                    if (!isRetryableFetchError(err) or attempt == active_opts.max_retries or !isRetryableMethod(method)) {
                        return err;
                    }
                    sleepForRetry(attempt, null, active_opts);
                    continue;
                };
                req.connection.?.flush() catch |err| {
                    if (!isRetryableFetchError(err) or attempt == active_opts.max_retries or !isRetryableMethod(method)) {
                        return err;
                    }
                    sleepForRetry(attempt, null, active_opts);
                    continue;
                };
            } else {
                req.sendBodiless() catch |err| {
                    if (!isRetryableFetchError(err) or attempt == active_opts.max_retries or !isRetryableMethod(method)) {
                        return err;
                    }
                    sleepForRetry(attempt, null, active_opts);
                    continue;
                };
            }

            var redirect_buffer: [8 * 1024]u8 = undefined;
            var response = req.receiveHead(&redirect_buffer) catch |err| {
                if (!isRetryableFetchError(err) or attempt == active_opts.max_retries or !isRetryableMethod(method)) {
                    return err;
                }
                sleepForRetry(attempt, null, active_opts);
                continue;
            };

            const status = @intFromEnum(response.head.status);
            const retry_after_ms = parseRetryAfterSeconds(&response.head);
            const request_id = extractHeaderValue(&response.head, "x-request-id");

            const response_bytes = readResponseBody(self.allocator, alloc, &response) catch |err| {
                if (!isRetryableFetchError(err) or attempt == active_opts.max_retries or !isRetryableMethod(method)) {
                    return err;
                }
                sleepForRetry(attempt, retry_after_ms, active_opts);
                continue;
            };
            errdefer self.allocator.free(response_bytes);

            if (status < 200 or status >= 300) {
                if (isRetryableStatus(status) and attempt < active_opts.max_retries and isRetryableMethod(method)) {
                    self.allocator.free(response_bytes);
                    sleepForRetry(attempt, retry_after_ms, active_opts);
                    continue;
                }
                defer self.allocator.free(response_bytes);
                return errors.unexpectedStatus(.{
                    .status = status,
                    .body = response_bytes,
                    .request_id = request_id,
                });
            }

            return Response{ .status = status, .body = response_bytes };
        }
        return errors.Error.HttpError;
    }

    fn requestStreamInternal(
        self: *Transport,
        method: std.http.Method,
        path: []const u8,
        headers: []const std.http.Header,
        body: ?[]const u8,
        on_chunk: StreamChunk,
        chunk_ctx: ?*anyopaque,
        req_opts: ?RequestOptions,
    ) errors.Error!void {
        const active_opts = self.resolveRequestOptions(req_opts);
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();
        const alloc = arena.allocator();

        const url = buildUrl(alloc, active_opts.base_url, path) catch {
            return errors.Error.HttpError;
        };
        const uri = std.Uri.parse(url) catch {
            return errors.Error.HttpError;
        };

        var attempt: u8 = 0;
        while (attempt <= active_opts.max_retries) : (attempt += 1) {
            var header_list = std.ArrayList(std.http.Header).initCapacity(alloc, 0) catch {
                return errors.Error.HttpError;
            };
            defer header_list.deinit(alloc);
            if (self.extra_headers.len > 0) {
                header_list.appendSlice(alloc, self.extra_headers) catch {
                    return errors.Error.HttpError;
                };
            }
            if (active_opts.extra_headers) |extra_headers| {
                header_list.appendSlice(alloc, extra_headers) catch {
                    return errors.Error.HttpError;
                };
            }
            if (headers.len > 0) {
                header_list.appendSlice(alloc, headers) catch {
                    return errors.Error.HttpError;
                };
            }

            if (active_opts.api_key) |raw_key| {
                const key = std.mem.trim(u8, raw_key, " ");
                const bearer_prefix = "Bearer ";
                const header_value = if (std.mem.startsWith(u8, key, bearer_prefix))
                    key
                else blk: {
                    var auth_buf = std.ArrayList(u8).initCapacity(alloc, bearer_prefix.len + key.len) catch {
                        return errors.Error.HttpError;
                    };
                    defer auth_buf.deinit(alloc);
                    auth_buf.appendSlice(alloc, bearer_prefix) catch {
                        return errors.Error.HttpError;
                    };
                    auth_buf.appendSlice(alloc, key) catch {
                        return errors.Error.HttpError;
                    };
                    break :blk auth_buf.toOwnedSlice(alloc) catch {
                        return errors.Error.HttpError;
                    };
                };
                header_list.append(alloc, .{ .name = "Authorization", .value = header_value }) catch {
                    return errors.Error.HttpError;
                };
            }
            if (active_opts.organization) |org| {
                const value = std.mem.trim(u8, org, " ");
                if (value.len > 0) {
                    header_list.append(alloc, .{ .name = "OpenAI-Organization", .value = value }) catch {
                        return errors.Error.HttpError;
                    };
                }
            }
            if (active_opts.project) |project| {
                const value = std.mem.trim(u8, project, " ");
                if (value.len > 0) {
                    header_list.append(alloc, .{ .name = "OpenAI-Project", .value = value }) catch {
                        return errors.Error.HttpError;
                    };
                }
            }

            var req = self.client.request(method, uri, .{
                .extra_headers = header_list.items,
                .keep_alive = false,
            }) catch |err| {
                if (!isRetryableFetchError(err) or attempt == active_opts.max_retries or !isRetryableMethod(method)) {
                    return errors.Error.HttpError;
                }
                sleepForRetry(attempt, null, active_opts);
                continue;
            };
            defer req.deinit();

            if (body) |payload| {
                req.transfer_encoding = .{ .content_length = payload.len };
                var body_writer = req.sendBodyUnflushed(&.{}) catch |err| {
                    if (!isRetryableFetchError(err) or attempt == active_opts.max_retries or !isRetryableMethod(method)) {
                        return errors.Error.HttpError;
                    }
                    sleepForRetry(attempt, null, active_opts);
                    continue;
                };
                body_writer.writer.writeAll(payload) catch |err| {
                    if (!isRetryableFetchError(err) or attempt == active_opts.max_retries or !isRetryableMethod(method)) {
                        return errors.Error.HttpError;
                    }
                    sleepForRetry(attempt, null, active_opts);
                    continue;
                };
                body_writer.end() catch |err| {
                    if (!isRetryableFetchError(err) or attempt == active_opts.max_retries or !isRetryableMethod(method)) {
                        return errors.Error.HttpError;
                    }
                    sleepForRetry(attempt, null, active_opts);
                    continue;
                };
                req.connection.?.flush() catch |err| {
                    if (!isRetryableFetchError(err) or attempt == active_opts.max_retries or !isRetryableMethod(method)) {
                        return errors.Error.HttpError;
                    }
                    sleepForRetry(attempt, null, active_opts);
                    continue;
                };
            } else {
                req.sendBodiless() catch |err| {
                    if (!isRetryableFetchError(err) or attempt == active_opts.max_retries or !isRetryableMethod(method)) {
                        return errors.Error.HttpError;
                    }
                    sleepForRetry(attempt, null, active_opts);
                    continue;
                };
            }

            var redirect_buffer: [8 * 1024]u8 = undefined;
            var response = req.receiveHead(&redirect_buffer) catch |err| {
                if (!isRetryableFetchError(err) or attempt == active_opts.max_retries or !isRetryableMethod(method)) {
                    return errors.Error.HttpError;
                }
                sleepForRetry(attempt, null, active_opts);
                continue;
            };

            const status = @intFromEnum(response.head.status);
            const retry_after_ms = parseRetryAfterSeconds(&response.head);
            const request_id = extractHeaderValue(&response.head, "x-request-id");

            var error_capture = std.ArrayList(u8).initCapacity(alloc, 0) catch {
                return errors.Error.HttpError;
            };
            defer error_capture.deinit(alloc);

            if (status < 200 or status >= 300) {
                const response_body = readResponseBody(self.allocator, alloc, &response) catch {
                    if (!isRetryableStatus(status) or attempt == active_opts.max_retries or !isRetryableMethod(method)) {
                        return errors.Error.HttpError;
                    }
                    sleepForRetry(attempt, retry_after_ms, active_opts);
                    continue;
                };
                defer self.allocator.free(response_body);

                if (isRetryableStatus(status) and attempt < active_opts.max_retries and isRetryableMethod(method)) {
                    sleepForRetry(attempt, retry_after_ms, active_opts);
                    continue;
                }
                return errors.unexpectedStatus(.{
                    .status = status,
                    .body = response_body,
                    .request_id = request_id,
                });
            }

            var stream_ctx = StreamWriterContext{
                .handler = on_chunk,
                .user_ctx = chunk_ctx,
                .allocator = alloc,
                .capture = &error_capture,
            };

            const Writer = std.io.GenericWriter(
                *StreamWriterContext,
                errors.Error,
                StreamWriterContext.writeChunk,
            );
            var writer = Writer{ .context = &stream_ctx };
            var raw_buf: [8192]u8 = undefined;
            var adapter = writer.adaptToNewApi(&raw_buf);

            readResponseBodyToSink(&response, alloc, &adapter.new_interface) catch {
                if (stream_ctx.err) |callback_err| {
                    return callback_err;
                }
                if (attempt == active_opts.max_retries or !isRetryableMethod(method)) {
                    return errors.Error.HttpError;
                }
                sleepForRetry(attempt, retry_after_ms, active_opts);
                continue;
            };
            if (stream_ctx.err) |callback_err| {
                return callback_err;
            }
            return;
        }
        return errors.Error.HttpError;
    }

    const StreamWriterContext = struct {
        handler: StreamChunk,
        user_ctx: ?*anyopaque,
        allocator: std.mem.Allocator,
        capture: *std.ArrayList(u8),
        err: ?errors.Error = null,

        pub fn writeChunk(context: *StreamWriterContext, chunk: []const u8) errors.Error!usize {
            context.capture.appendSlice(context.allocator, chunk) catch {};
            context.handler(context.user_ctx, chunk) catch |callback_err| {
                context.err = callback_err;
                return callback_err;
            };
            return chunk.len;
        }
    };
};

fn buildUrl(allocator: std.mem.Allocator, base_url: []const u8, path: []const u8) ![]u8 {
    if (std.mem.startsWith(u8, path, "http://") or std.mem.startsWith(u8, path, "https://")) {
        return allocator.dupe(u8, path);
    }

    const trimmed_base = std.mem.trimRight(u8, base_url, "/");
    if (path.len == 0 or std.mem.eql(u8, path, "/")) {
        return allocator.dupe(u8, if (trimmed_base.len == 0) "/" else trimmed_base);
    }

    const cleaned_path = if (path.len > 0 and path[0] == '/')
        path[1..]
    else
        path;

    if (trimmed_base.len == 0) {
        return allocator.dupe(u8, cleaned_path);
    }

    return std.fmt.allocPrint(allocator, "{s}/{s}", .{ trimmed_base, cleaned_path });
}

fn parseProxy(allocator: std.mem.Allocator, raw_proxy_url: []const u8) !?*std.http.Client.Proxy {
    const uri = std.Uri.parse(raw_proxy_url) catch
        std.Uri.parseAfterScheme("http", raw_proxy_url) catch return null;

    const protocol = std.http.Client.Protocol.fromUri(uri) orelse return null;
    const host = try uri.getHostAlloc(allocator);
    const authorization = if (uri.user != null or uri.password != null) blk: {
        const authorization_len = std.http.Client.basic_authorization.valueLengthFromUri(uri);
        const authorization_value = try allocator.alloc(u8, authorization_len);
        _ = std.http.Client.basic_authorization.value(uri, authorization_value);
        break :blk authorization_value;
    } else null;

    const proxy = try allocator.create(std.http.Client.Proxy);
    proxy.* = .{
            .protocol = protocol,
            .host = host,
            .authorization = authorization,
            .port = uriPort(raw_proxy_url, protocol),
            .supports_connect = true,
        };
        return proxy;
}

fn mapTransportError(err: anyerror) errors.Error {
    return switch (err) {
        errors.Error.HttpError => errors.Error.HttpError,
        errors.Error.BadRequestError => errors.Error.BadRequestError,
        errors.Error.AuthenticationError => errors.Error.AuthenticationError,
        errors.Error.PermissionDeniedError => errors.Error.PermissionDeniedError,
        errors.Error.NotFoundError => errors.Error.NotFoundError,
        errors.Error.ConflictError => errors.Error.ConflictError,
        errors.Error.UnprocessableEntityError => errors.Error.UnprocessableEntityError,
        errors.Error.RateLimitError => errors.Error.RateLimitError,
        errors.Error.TimeoutError => errors.Error.TimeoutError,
        errors.Error.InternalServerError => errors.Error.InternalServerError,
        errors.Error.DeserializeError => errors.Error.DeserializeError,
        errors.Error.SerializeError => errors.Error.SerializeError,
        errors.Error.Timeout => errors.Error.Timeout,
        errors.Error.Unimplemented => errors.Error.Unimplemented,
        else => errors.Error.HttpError,
    };
}

fn readResponseBodyToSink(
    response: *std.http.Client.Response,
    allocator: std.mem.Allocator,
    writer: anytype,
) !void {
    const content_encoding = response.head.content_encoding;
    var decompression_buffer: []u8 = &[_]u8{};
    var owns_decompression_buffer = false;

    if (content_encoding == .zstd or content_encoding == .deflate or content_encoding == .gzip) {
        if (content_encoding == .zstd) {
            decompression_buffer = try allocator.alloc(u8, std.compress.zstd.default_window_len);
            owns_decompression_buffer = true;
        } else {
            decompression_buffer = try allocator.alloc(u8, std.compress.flate.max_window_len);
            owns_decompression_buffer = true;
        }
    } else if (content_encoding == .compress) {
        return error.UnsupportedCompressionMethod;
    }
    defer if (owns_decompression_buffer) allocator.free(decompression_buffer);

    var transfer_buffer: [64]u8 = undefined;
    var decompressor: std.http.Decompress = undefined;
    const reader = response.readerDecompressing(&transfer_buffer, &decompressor, decompression_buffer);
    _ = reader.streamRemaining(writer) catch |err| {
        if (err == error.ReadFailed) {
            if (response.bodyErr()) |body_err| {
                return body_err;
            }
            return err;
        }
        return err;
    };
}

fn readResponseBody(
    persistent_allocator: std.mem.Allocator,
    scratch_allocator: std.mem.Allocator,
    response: *std.http.Client.Response,
) ![]u8 {
    var body_writer = std.io.Writer.Allocating.init(scratch_allocator);
    defer body_writer.deinit();

    try readResponseBodyToSink(response, scratch_allocator, &body_writer.writer);
    const data = body_writer.written();
    const owned = try persistent_allocator.alloc(u8, data.len);
    @memcpy(owned, data);
    return owned;
}

fn parseRetryAfterSeconds(head: *const std.http.Client.Response.Head) ?u64 {
    var headers = head.iterateHeaders();
    while (headers.next()) |header| {
        if (!std.ascii.eqlIgnoreCase(header.name, "retry-after")) continue;
        const raw = std.mem.trim(u8, header.value, " \t");
        if (raw.len == 0) return null;
        const seconds = std.fmt.parseInt(u64, raw, 10) catch return null;
        return seconds * std.time.ms_per_s;
    }
    return null;
}

fn extractHeaderValue(
    head: *const std.http.Client.Response.Head,
    name: []const u8,
) ?[]const u8 {
    var headers = head.iterateHeaders();
    while (headers.next()) |header| {
        if (std.ascii.eqlIgnoreCase(header.name, name)) {
            return header.value;
        }
    }
    return null;
}

fn isRetryableMethod(method: std.http.Method) bool {
    return switch (method) {
        .GET, .HEAD, .DELETE, .OPTIONS => true,
        else => false,
    };
}

fn isRetryableStatus(status: u16) bool {
    return switch (status) {
        408, 409, 425, 429, 500, 502, 503, 504 => true,
        else => false,
    };
}

fn isRetryableFetchError(err: anytype) bool {
    return switch (@as(anyerror, err)) {
        error.ConnectionRefused,
        error.NetworkUnreachable,
        error.ConnectionTimedOut,
        error.ConnectionResetByPeer,
        error.TemporaryNameServerFailure,
        error.NameServerFailure,
        error.UnexpectedConnectFailure,
        error.ReadFailed,
        error.WriteFailed,
        error.UnsupportedCompressionMethod => true,
        else => false,
    };
}

fn sleepForRetry(
    attempt: u8,
    retry_after_ms: ?u64,
    request_opts: Transport.ActiveRequestOptions,
) void {
    const capped_delay_ms = nextRetryDelayMs(attempt, retry_after_ms, request_opts);
    if (capped_delay_ms == 0) return;
    std.Thread.sleep(capped_delay_ms * std.time.ns_per_ms);
}

fn nextRetryDelayMs(
    attempt: u8,
    retry_after_ms: ?u64,
    request_opts: Transport.ActiveRequestOptions,
) u64 {
    const attempt_u64: u64 = attempt;
    var delay_ms = request_opts.retry_base_delay_ms;
    var i: u64 = 0;
    while (i < @min(attempt_u64, 10)) : (i += 1) {
        const max_half = std.math.maxInt(u64) >> 1;
        if (delay_ms > max_half) break;
        delay_ms *= 2;
    }
    if (retry_after_ms) |retry_ms| {
        if (retry_ms > delay_ms) delay_ms = retry_ms;
    }
    const capped_delay_ms = if (request_opts.timeout_ms) |timeout_ms|
        @min(delay_ms, timeout_ms)
    else
        delay_ms;

    return capped_delay_ms;
}

fn uriPort(raw_proxy_url: []const u8, protocol: std.http.Client.Protocol) u16 {
    const default_port: u16 = switch (protocol) {
        .plain => 80,
        .tls => 443,
    };
    const scheme_end = std.mem.indexOf(u8, raw_proxy_url, "://") orelse 0;
    const after_scheme = raw_proxy_url[scheme_end + if (scheme_end == 0) @as(usize, 0) else @as(usize, 3)..];
    const authority_end = std.mem.indexOfAny(u8, after_scheme, "/?#") orelse after_scheme.len;
    var authority = after_scheme[0..authority_end];

    if (std.mem.lastIndexOf(u8, authority, "@")) |at| {
        authority = authority[at + 1 ..];
    }

    if (authority.len == 0) {
        return default_port;
    }

    if (std.mem.startsWith(u8, authority, "[")) {
        if (std.mem.lastIndexOf(u8, authority, "]:")) |close| {
            const port_text = authority[close + 2 ..];
            return std.fmt.parseInt(u16, port_text, 10) catch default_port;
        }
        return default_port;
    }

    if (std.mem.lastIndexOf(u8, authority, ":")) |colon| {
        const port_text = authority[colon + 1 ..];
        return std.fmt.parseInt(u16, port_text, 10) catch default_port;
    }

    return default_port;
}

test "uriPort derives explicit and default proxy ports" {
    try std.testing.expectEqual(@as(u16, 80), uriPort("http://proxy.local", .plain));
    try std.testing.expectEqual(@as(u16, 443), uriPort("https://proxy.local", .tls));
    try std.testing.expectEqual(@as(u16, 8080), uriPort("http://proxy.local:8080", .plain));
    try std.testing.expectEqual(@as(u16, 9443), uriPort("https://proxy.local:9443", .tls));
    try std.testing.expectEqual(@as(u16, 8443), uriPort("http://user:pass@[::1]:8443", .plain));
}

test "nextRetryDelayMs uses exponential backoff, retry-after, and timeout cap" {
    var opts = Transport.ActiveRequestOptions{
        .base_url = "https://api.local",
        .api_key = null,
        .organization = null,
        .project = null,
        .timeout_ms = null,
        .max_retries = 3,
        .retry_base_delay_ms = 500,
        .extra_headers = null,
    };

    try std.testing.expectEqual(@as(u64, 500), nextRetryDelayMs(0, null, opts));
    try std.testing.expectEqual(@as(u64, 1000), nextRetryDelayMs(1, null, opts));
    try std.testing.expectEqual(@as(u64, 2000), nextRetryDelayMs(2, null, opts));

    opts.timeout_ms = 700;
    try std.testing.expectEqual(@as(u64, 700), nextRetryDelayMs(1, null, opts));

    opts.timeout_ms = null;
    try std.testing.expectEqual(@as(u64, 2500), nextRetryDelayMs(0, 2500, opts));
    opts.timeout_ms = 700;
    try std.testing.expectEqual(@as(u64, 700), nextRetryDelayMs(0, 200, opts));
}

test "resolveRequestOptions uses transport defaults and per-request override" {
    var transport = try Transport.init(std.testing.allocator, .{
        .base_url = "https://api.local",
        .api_key = "k-default",
        .organization = "org-default",
        .project = "proj-default",
        .timeout_ms = 5000,
        .max_retries = 4,
        .retry_base_delay_ms = 250,
    });
    defer transport.deinit();

    const default_opts = transport.resolveRequestOptions(null);
    try std.testing.expectEqualStrings("https://api.local", default_opts.base_url);
    try std.testing.expectEqual(@as(u64, 5000), default_opts.timeout_ms.?);
    try std.testing.expectEqual(@as(u8, 4), default_opts.max_retries);
    try std.testing.expectEqual(@as(u64, 250), default_opts.retry_base_delay_ms);
    try std.testing.expectEqualStrings("k-default", default_opts.api_key.?);
    try std.testing.expectEqualStrings("org-default", default_opts.organization.?);
    try std.testing.expectEqualStrings("proj-default", default_opts.project.?);
    try std.testing.expectEqual(@as(?[]const std.http.Header, null), default_opts.extra_headers);

    const override_opts = transport.resolveRequestOptions(.{
        .base_url = "https://api.overridden",
        .api_key = "k-override",
        .organization = null,
        .project = null,
        .timeout_ms = 1200,
        .max_retries = 1,
        .retry_base_delay_ms = 80,
        .extra_headers = null,
    });
    try std.testing.expectEqualStrings("https://api.overridden", override_opts.base_url);
    try std.testing.expectEqual(@as(u64, 1200), override_opts.timeout_ms.?);
    try std.testing.expectEqual(@as(u8, 1), override_opts.max_retries);
    try std.testing.expectEqual(@as(u64, 80), override_opts.retry_base_delay_ms);
    try std.testing.expectEqualStrings("k-override", override_opts.api_key.?);
    try std.testing.expectEqualStrings("org-default", override_opts.organization.?);
    try std.testing.expectEqualStrings("proj-default", override_opts.project.?);
}
