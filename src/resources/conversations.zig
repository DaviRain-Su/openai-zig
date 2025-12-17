const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

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

    fn sendJsonTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendJsonTyped(self.transport, allocator, method, path, value, T);
    }

    fn sendNoBodyTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendNoBodyTyped(self.transport, allocator, method, path, T);
    }

    /// Conversations
    pub fn create_conversation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateConversationBody,
    ) errors.Error!std.json.Parsed(gen.ConversationResource) {
        return self.sendJsonTyped(allocator, .POST, "/conversations", body, gen.ConversationResource);
    }

    pub fn get_conversation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ConversationResource) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/conversations/{s}", .{conversation_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ConversationResource);
    }

    pub fn delete_conversation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeletedConversationResource) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/conversations/{s}", .{conversation_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .DELETE, path, gen.DeletedConversationResource);
    }

    pub fn update_conversation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        body: gen.CreateConversationBody,
    ) errors.Error!std.json.Parsed(gen.ConversationResource) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/conversations/{s}", .{conversation_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.ConversationResource);
    }

    /// Conversation items
    pub fn create_conversation_item(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        body: gen.ConversationItem,
    ) errors.Error!std.json.Parsed(gen.ConversationItem) {
        var path_buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/conversations/{s}/items", .{conversation_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.ConversationItem);
    }

    pub fn list_conversation_items(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ConversationItemList) {
        var buf: [280]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/conversations/{s}/items", .{conversation_id});
        try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ConversationItemList);
    }

    pub fn get_conversation_item(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        item_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ConversationItem) {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/conversations/{s}/items/{s}", .{ conversation_id, item_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ConversationItem);
    }

    pub fn delete_conversation_item(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        item_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeletedConversationResource) {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/conversations/{s}/items/{s}", .{ conversation_id, item_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .DELETE, path, gen.DeletedConversationResource);
    }
};
