const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const ListGroupUsersParams = struct {
    limit: ?u32 = null,
    after: ?[]const u8 = null,
    order: ?[]const u8 = null,
    pub fn list(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        params: ListGroupUsersParams,
    ) errors.Error!std.json.Parsed(gen.UserListResource) {
        return self.list_group_users(allocator, group_id, params);
    }

    pub fn add(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        req: CreateGroupUserRequest,
    ) errors.Error!std.json.Parsed(gen.GroupUserAssignment) {
        return self.add_group_user(allocator, group_id, req);
    }

    pub fn remove(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        user_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.GroupUserDeletedResource) {
        return self.remove_group_user(allocator, group_id, user_id);
    }
};

pub const CreateGroupUserRequest = struct {
    user_id: []const u8,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn sendJsonTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        return self.sendJsonTypedWithOptions(allocator, method, path, value, T, null);
    }

    fn sendJsonTypedWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
        comptime T: type,
        req_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            method,
            path,
            value,
            T,
            req_opts,
        );
    }

    fn sendNoBodyTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        return self.sendNoBodyTypedWithOptions(allocator, method, path, T, null);
    }

    fn sendNoBodyTypedWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
        req_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            method,
            path,
            T,
            req_opts,
        );
    }

    /// GET /organization/groups/{group_id}/users
    pub fn list_group_users(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        params: ListGroupUsersParams,
    ) errors.Error!std.json.Parsed(gen.UserListResource) {
        return self.list_group_users_with_options(allocator, group_id, params, null);
    }

    pub fn list_group_users_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        params: ListGroupUsersParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UserListResource) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const writer = fbs.writer();
        try writer.print("/organization/groups/{s}/users", .{group_id});
        var first = true;
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, &first, "limit", @as(u64, limit));
        }
        try common.appendOptionalQueryParam(writer, &first, "after", params.after);
        try common.appendOptionalQueryParam(writer, &first, "order", params.order);
        const path = fbs.getWritten();

        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.UserListResource, request_opts);
    }

    /// POST /organization/groups/{group_id}/users
    pub fn add_group_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        req: CreateGroupUserRequest,
    ) errors.Error!std.json.Parsed(gen.GroupUserAssignment) {
        return self.add_group_user_with_options(allocator, group_id, req, null);
    }

    pub fn add_group_user_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        req: CreateGroupUserRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.GroupUserAssignment) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/groups/{s}/users", .{group_id}) catch {
            return errors.Error.SerializeError;
        };

        return self.sendJsonTypedWithOptions(allocator, .POST, path, req, gen.GroupUserAssignment, request_opts);
    }

    /// DELETE /organization/groups/{group_id}/users/{user_id}
    pub fn remove_group_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        user_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.GroupUserDeletedResource) {
        return self.remove_group_user_with_options(allocator, group_id, user_id, null);
    }

    pub fn remove_group_user_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        user_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.GroupUserDeletedResource) {
        var path_buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/groups/{s}/users/{s}", .{ group_id, user_id }) catch {
            return errors.Error.SerializeError;
        };

        return self.sendNoBodyTypedWithOptions(allocator, .DELETE, path, gen.GroupUserDeletedResource, request_opts);
    }

    pub fn list_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        params: ListGroupUsersParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UserListResource) {
        return self.list_group_users_with_options(allocator, group_id, params, request_opts);
    }

    pub fn add_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        req: CreateGroupUserRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.GroupUserAssignment) {
        return self.add_group_user_with_options(allocator, group_id, req, request_opts);
    }

    pub fn remove_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        user_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.GroupUserDeletedResource) {
        return self.remove_group_user_with_options(allocator, group_id, user_id, request_opts);
    }
};
