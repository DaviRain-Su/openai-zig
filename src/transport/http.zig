const std = @import("std");
const errors = @import("../errors.zig");

pub const Transport = struct {
    allocator: std.mem.Allocator,
    client: std.http.Client,
    base_url: []const u8,
    api_key: ?[]const u8,

    pub const Options = struct {
        base_url: []const u8,
        api_key: ?[]const u8 = null,
        proxy: ?[]const u8 = null,
        timeout_ms: ?u64 = null,
    };

    pub fn init(allocator: std.mem.Allocator, opts: Options) !Transport {
        const http_client = std.http.Client{ .allocator = allocator };
        // TODO: honor proxy/timeout options; this is a minimal placeholder transport.
        return Transport{
            .allocator = allocator,
            .client = http_client,
            .base_url = opts.base_url,
            .api_key = opts.api_key,
        };
    }

    pub fn deinit(self: *Transport) void {
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

        var url_builder = try std.ArrayList(u8).initCapacity(alloc, self.base_url.len + path.len + 1);
        defer url_builder.deinit(alloc);
        try url_builder.writer(alloc).print("{s}{s}", .{ self.base_url, path });
        const url = try url_builder.toOwnedSlice(alloc);

        var header_list = try std.ArrayList(std.http.Header).initCapacity(alloc, 0);
        defer header_list.deinit(alloc);
        if (headers.len > 0) {
            try header_list.appendSlice(alloc, headers);
        }

        if (self.api_key) |key| {
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
};
