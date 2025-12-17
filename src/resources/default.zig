const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

pub const MultipartRequest = struct {
    content_type: []const u8,
    body: []const u8,
};

pub const BinaryResponse = struct {
    allocator: std.mem.Allocator,
    data: []u8,

    pub fn deinit(self: *BinaryResponse) void {
        self.allocator.free(self.data);
    }
};

pub const ListParams = struct {
    limit: ?u32 = null,
    order: ?[]const u8 = null,
    after: ?[]const u8 = null,
    before: ?[]const u8 = null,
    user: ?[]const u8 = null,
};

pub const CreateAdminApiKeyRequest = struct {
    name: []const u8,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn appendListParams(writer: anytype, params: ListParams, sep_start: []const u8) !void {
        var sep = sep_start;
        if (params.limit) |limit| {
            try writer.print("{s}limit={d}", .{ sep, limit });
            sep = "&";
        }
        if (params.order) |order| {
            try writer.print("{s}order={s}", .{ sep, order });
            sep = "&";
        }
        if (params.after) |after| {
            try writer.print("{s}after={s}", .{ sep, after });
            sep = "&";
        }
        if (params.before) |before| {
            try writer.print("{s}before={s}", .{ sep, before });
            sep = "&";
        }
        if (params.user) |user| {
            try writer.print("{s}user={s}", .{ sep, user });
        }
    }

    fn sendJson(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(value) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        const resp = try self.transport.request(method, path, &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = "application/json" },
        }, payload);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    fn sendNoBody(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        const resp = try self.transport.request(method, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// Containers
    pub fn list_containers(self: *const Resource, allocator: std.mem.Allocator, params: ListParams) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/containers");
        try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn create_container(self: *const Resource, allocator: std.mem.Allocator, body: std.json.Value) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJson(allocator, .POST, "/containers", body);
    }

    pub fn retrieve_container(self: *const Resource, allocator: std.mem.Allocator, container_id: []const u8) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/containers/{s}", .{container_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn delete_container(self: *const Resource, allocator: std.mem.Allocator, container_id: []const u8) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/containers/{s}", .{container_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .DELETE, path);
    }

    pub fn create_container_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        container_id: []const u8,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/containers/{s}/files", .{container_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.POST, path, &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = payload.content_type },
        }, payload.body);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    pub fn list_container_files(
        self: *const Resource,
        allocator: std.mem.Allocator,
        container_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/containers/{s}/files", .{container_id});
        try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn retrieve_container_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        container_id: []const u8,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/containers/{s}/files/{s}", .{ container_id, file_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn delete_container_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        container_id: []const u8,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/containers/{s}/files/{s}", .{ container_id, file_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .DELETE, path);
    }

    pub fn retrieve_container_file_content(
        self: *const Resource,
        container_id: []const u8,
        file_id: []const u8,
    ) errors.Error!BinaryResponse {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/containers/{s}/files/{s}/content", .{ container_id, file_id }) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.GET, path, &.{}, null);
        return BinaryResponse{
            .allocator = self.transport.allocator,
            .data = resp.body,
        };
    }

    /// Admin API keys
    pub fn list_admin_api_keys(self: *const Resource, allocator: std.mem.Allocator) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendNoBody(allocator, .GET, "/organization/admin_api_keys");
    }

    pub fn create_admin_api_key(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateAdminApiKeyRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJson(allocator, .POST, "/organization/admin_api_keys", req);
    }

    pub fn get_admin_api_key(
        self: *const Resource,
        allocator: std.mem.Allocator,
        key_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/admin_api_keys/{s}", .{key_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn delete_admin_api_key(
        self: *const Resource,
        allocator: std.mem.Allocator,
        key_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/admin_api_keys/{s}", .{key_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .DELETE, path);
    }

    /// Responses helpers
    pub fn get_input_token_counts(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJson(allocator, .POST, "/responses/input_tokens", body);
    }

    pub fn compact_conversation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJson(allocator, .POST, "/responses/compact", body);
    }

    /// ChatKit sessions and threads
    pub fn create_chat_session(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJson(allocator, .POST, "/chatkit/sessions", body);
    }

    pub fn cancel_chat_session(
        self: *const Resource,
        allocator: std.mem.Allocator,
        session_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/chatkit/sessions/{s}/cancel", .{session_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .POST, path);
    }

    pub fn list_threads(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/chatkit/threads");
        try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn get_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/chatkit/threads/{s}", .{thread_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn delete_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/chatkit/threads/{s}", .{thread_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .DELETE, path);
    }

    pub fn list_thread_items(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [280]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/chatkit/threads/{s}/items", .{thread_id});
        try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }
};
