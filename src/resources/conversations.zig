const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

pub const ListParams = struct {
    limit: ?u32 = null,
    order: ?[]const u8 = null,
    after: ?[]const u8 = null,
    before: ?[]const u8 = null,
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

    /// Conversations
    pub fn create_conversation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJson(allocator, .POST, "/conversations", body);
    }

    pub fn get_conversation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/conversations/{s}", .{conversation_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn delete_conversation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/conversations/{s}", .{conversation_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .DELETE, path);
    }

    pub fn update_conversation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/conversations/{s}", .{conversation_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, body);
    }

    /// Conversation items
    pub fn create_conversation_item(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/conversations/{s}/items", .{conversation_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, body);
    }

    pub fn list_conversation_items(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [280]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/conversations/{s}/items", .{conversation_id});
        try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn get_conversation_item(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        item_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/conversations/{s}/items/{s}", .{ conversation_id, item_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn delete_conversation_item(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        item_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/conversations/{s}/items/{s}", .{ conversation_id, item_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .DELETE, path);
    }
};
