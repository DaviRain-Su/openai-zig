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

    fn appendListParams(writer: anytype, params: ListParams, first: *bool) !void {
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, first, "limit", @as(u64, limit));
        }
        try common.appendOptionalQueryParam(writer, first, "order", params.order);
        try common.appendOptionalQueryParam(writer, first, "after", params.after);
        try common.appendOptionalQueryParam(writer, first, "before", params.before);
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

    fn sendJsonTypedWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
        comptime T: type,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            method,
            path,
            value,
            T,
            request_opts,
        );
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

    fn sendNoBodyTypedWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            method,
            path,
            T,
            request_opts,
        );
    }

    /// Conversations
    pub fn create_conversation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateConversationBody,
    ) errors.Error!std.json.Parsed(gen.ConversationResource) {
        return self.sendJsonTyped(allocator, .POST, "/conversations", body, gen.ConversationResource);
    }

    pub fn create_conversation_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateConversationBody,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ConversationResource) {
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            "/conversations",
            body,
            gen.ConversationResource,
            request_opts,
        );
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

    pub fn get_conversation_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ConversationResource) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/conversations/{s}", .{conversation_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ConversationResource,
            request_opts,
        );
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

    pub fn delete_conversation_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeletedConversationResource) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/conversations/{s}", .{conversation_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .DELETE,
            path,
            gen.DeletedConversationResource,
            request_opts,
        );
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

    pub fn update_conversation_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        body: gen.CreateConversationBody,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ConversationResource) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/conversations/{s}", .{conversation_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.ConversationResource,
            request_opts,
        );
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

    pub fn create_conversation_item_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        body: gen.ConversationItem,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ConversationItem) {
        var path_buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/conversations/{s}/items", .{conversation_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.ConversationItem,
            request_opts,
        );
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
        var first = true;
        try appendListParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ConversationItemList);
    }

    pub fn list_conversation_items_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        params: ListParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ConversationItemList) {
        var buf: [280]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/conversations/{s}/items", .{conversation_id});
        var first = true;
        try appendListParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ConversationItemList,
            request_opts,
        );
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

    pub fn get_conversation_item_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        item_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ConversationItem) {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/conversations/{s}/items/{s}", .{ conversation_id, item_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ConversationItem,
            request_opts,
        );
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

    pub fn delete_conversation_item_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        item_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeletedConversationResource) {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/conversations/{s}/items/{s}", .{ conversation_id, item_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .DELETE,
            path,
            gen.DeletedConversationResource,
            request_opts,
        );
    }

    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateConversationBody,
    ) errors.Error!std.json.Parsed(gen.ConversationResource) {
        return self.create_conversation(allocator, body);
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateConversationBody,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ConversationResource) {
        return self.create_conversation_with_options(allocator, body, request_opts);
    }

    pub fn get(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ConversationResource) {
        return self.get_conversation(allocator, conversation_id);
    }

    pub fn get_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ConversationResource) {
        return self.get_conversation_with_options(allocator, conversation_id, request_opts);
    }

    pub fn create_conversation_items(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        body: gen.ConversationItem,
    ) errors.Error!std.json.Parsed(gen.ConversationItem) {
        return self.create_conversation_item(allocator, conversation_id, body);
    }

    pub fn update(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        body: gen.CreateConversationBody,
    ) errors.Error!std.json.Parsed(gen.ConversationResource) {
        return self.update_conversation(allocator, conversation_id, body);
    }

    pub fn update_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        body: gen.CreateConversationBody,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ConversationResource) {
        return self.update_conversation_with_options(allocator, conversation_id, body, request_opts);
    }

    pub fn delete(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeletedConversationResource) {
        return self.delete_conversation(allocator, conversation_id);
    }

    pub fn delete_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeletedConversationResource) {
        return self.delete_conversation_with_options(allocator, conversation_id, request_opts);
    }

    pub fn create_item(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        body: gen.ConversationItem,
    ) errors.Error!std.json.Parsed(gen.ConversationItem) {
        return self.create_conversation_item(allocator, conversation_id, body);
    }

    pub fn create_item_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        body: gen.ConversationItem,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ConversationItem) {
        return self.create_conversation_item_with_options(allocator, conversation_id, body, request_opts);
    }

    pub fn list_items(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ConversationItemList) {
        return self.list_conversation_items(allocator, conversation_id, params);
    }

    pub fn list_items_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        params: ListParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ConversationItemList) {
        return self.list_conversation_items_with_options(allocator, conversation_id, params, request_opts);
    }

    pub fn get_item(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        item_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ConversationItem) {
        return self.get_conversation_item(allocator, conversation_id, item_id);
    }

    pub fn get_item_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        item_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ConversationItem) {
        return self.get_conversation_item_with_options(allocator, conversation_id, item_id, request_opts);
    }

    pub fn delete_item(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        item_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeletedConversationResource) {
        return self.delete_conversation_item(allocator, conversation_id, item_id);
    }

    pub fn delete_item_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        conversation_id: []const u8,
        item_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeletedConversationResource) {
        return self.delete_conversation_item_with_options(
            allocator,
            conversation_id,
            item_id,
            request_opts,
        );
    }
};
