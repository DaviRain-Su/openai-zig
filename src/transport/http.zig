const std = @import("std");
const errors = @import("../errors.zig");

pub const Transport = struct {
    allocator: std.mem.Allocator,
    client: std.http.Client,
    base_url: []const u8,
    api_key: ?[]const u8,
    timeout_ms: ?u64 = null,
    extra_headers: []const std.http.Header,
    owns_extra_headers: bool,
    proxy_http: ?*std.http.Client.Proxy = null,
    proxy_https: ?*std.http.Client.Proxy = null,

    pub const Options = struct {
        base_url: []const u8,
        api_key: ?[]const u8 = null,
        extra_headers: ?[]const std.http.Header = null,
        proxy: ?[]const u8 = null,
        timeout_ms: ?u64 = null,
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

        var transport = Transport{
            .allocator = allocator,
            .client = http_client,
            .base_url = opts.base_url,
            .api_key = opts.api_key,
            .timeout_ms = opts.timeout_ms,
            .extra_headers = extra_config.headers,
            .owns_extra_headers = extra_config.owns,
            .proxy_http = null,
            .proxy_https = null,
        };

        if (opts.proxy) |proxy_url| {
            if (try parseProxy(allocator, proxy_url)) |proxy| {
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
        if (self.owns_extra_headers) {
            self.allocator.free(self.extra_headers);
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
        return self.requestInternal(method, path, headers, body) catch {
            return errors.Error.HttpError;
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
        return self.requestStreamInternal(method, path, headers, body, on_chunk, chunk_ctx);
    }

    fn requestInternal(
        self: *Transport,
        method: std.http.Method,
        path: []const u8,
        headers: []const std.http.Header,
        body: ?[]const u8,
    ) !Response {
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();
        const alloc = arena.allocator();

        const url = try buildUrl(alloc, self.base_url, path);

        var header_list = try std.ArrayList(std.http.Header).initCapacity(alloc, 0);
        defer header_list.deinit(alloc);
        if (self.extra_headers.len > 0) {
            try header_list.appendSlice(alloc, self.extra_headers);
        }
        if (headers.len > 0) {
            try header_list.appendSlice(alloc, headers);
        }

        if (self.api_key) |raw_key| {
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

        var body_writer = std.io.Writer.Allocating.init(alloc);
        defer body_writer.deinit();

        const fetch_result = try self.client.fetch(.{
            .location = .{ .url = url },
            .method = method,
            .payload = body,
            .extra_headers = header_list.items,
            .response_writer = &body_writer.writer,
            .keep_alive = false,
        });

        const status = @intFromEnum(fetch_result.status);
        const written = body_writer.written();
        const response_bytes = try self.allocator.alloc(u8, written.len);
        @memcpy(response_bytes, written);

        if (status < 200 or status >= 300) {
            defer self.allocator.free(response_bytes);
            return errors.unexpectedStatus(.{ .status = status, .body = response_bytes });
        }

        return Response{ .status = status, .body = response_bytes };
    }

    fn requestStreamInternal(
        self: *Transport,
        method: std.http.Method,
        path: []const u8,
        headers: []const std.http.Header,
        body: ?[]const u8,
        on_chunk: StreamChunk,
        chunk_ctx: ?*anyopaque,
    ) errors.Error!void {
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();
        const alloc = arena.allocator();

        const url = buildUrl(alloc, self.base_url, path) catch {
            return errors.Error.HttpError;
        };

        var header_list = std.ArrayList(std.http.Header).initCapacity(alloc, 0) catch {
            return errors.Error.HttpError;
        };
        defer header_list.deinit(alloc);
        if (self.extra_headers.len > 0) {
            header_list.appendSlice(alloc, self.extra_headers) catch {
                return errors.Error.HttpError;
            };
        }
        if (headers.len > 0) {
            header_list.appendSlice(alloc, headers) catch {
                return errors.Error.HttpError;
            };
        }

        if (self.api_key) |raw_key| {
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

        var error_capture = std.ArrayList(u8).initCapacity(alloc, 0) catch {
            return errors.Error.HttpError;
        };
        defer error_capture.deinit(alloc);

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

        const fetch_result = self.client.fetch(.{
            .location = .{ .url = url },
            .method = method,
            .payload = body,
            .extra_headers = header_list.items,
            .response_writer = &adapter.new_interface,
            .keep_alive = false,
        }) catch |err| {
            if (err == error.WriteFailed and stream_ctx.err != null) {
                return stream_ctx.err.?;
            }
            return errors.Error.HttpError;
        };

        const status = @intFromEnum(fetch_result.status);
        if (status < 200 or status >= 300) {
            return errors.unexpectedStatus(.{
                .status = status,
                .body = error_capture.items,
            });
        }
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
