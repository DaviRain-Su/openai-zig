const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const ListUsersParams = struct {
    limit: ?u32 = null,
    after: ?[]const u8 = null,
    emails: ?[]const []const u8 = null,
    pub fn list(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListUsersParams,
    ) errors.Error!std.json.Parsed(gen.UserListResponse) {
        return self.list_users(allocator, params);
    }

    pub fn retrieve(
        self: *const Resource,
        allocator: std.mem.Allocator,
        user_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.User) {
        return self.retrieve_user(allocator, user_id);
    }

    pub fn modify(
        self: *const Resource,
        allocator: std.mem.Allocator,
        user_id: []const u8,
        req: UpdateUserRoleRequest,
    ) errors.Error!std.json.Parsed(gen.User) {
        return self.modify_user(allocator, user_id, req);
    }

    pub fn delete(
        self: *const Resource,
        allocator: std.mem.Allocator,
        user_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.User) {
        return self.delete_user(allocator, user_id);
    }
};

pub const UpdateUserRoleRequest = gen.UpdateUserRoleRequest;

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

    /// GET /organization/users
    pub fn list_users(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListUsersParams,
    ) errors.Error!std.json.Parsed(gen.UserListResponse) {
        return self.list_users_with_options(allocator, params, null);
    }

    pub fn list_users_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListUsersParams,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UserListResponse) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const writer = fbs.writer();
        try writer.writeAll("/organization/users");

        var first = true;
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, &first, "limit", @as(u64, limit));
        }
        try common.appendOptionalQueryParam(writer, &first, "after", params.after);
        if (params.emails) |emails| {
            for (emails) |email| {
                try common.appendQueryParam(writer, &first, "emails[]", email);
            }
        }
        const path = fbs.getWritten();

        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.UserListResponse, request_opts);
    }

    /// GET /organization/users/{user_id}
    pub fn retrieve_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        user_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.User) {
        return self.retrieve_user_with_options(allocator, user_id, null);
    }

    pub fn retrieve_user_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        user_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.User) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/users/{s}", .{user_id}) catch {
            return errors.Error.SerializeError;
        };

        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.User, request_opts);
    }

    /// POST /organization/users/{user_id}
    pub fn modify_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        user_id: []const u8,
        req: UpdateUserRoleRequest,
    ) errors.Error!std.json.Parsed(gen.User) {
        return self.modify_user_with_options(allocator, user_id, req, null);
    }

    pub fn modify_user_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        user_id: []const u8,
        req: UpdateUserRoleRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.User) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/users/{s}", .{user_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(allocator, .POST, path, req, gen.User, request_opts);
    }

    /// DELETE /organization/users/{user_id}
    pub fn delete_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        user_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.User) {
        return self.delete_user_with_options(allocator, user_id, null);
    }

    pub fn delete_user_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        user_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.User) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/users/{s}", .{user_id}) catch {
            return errors.Error.SerializeError;
        };

        return self.sendNoBodyTypedWithOptions(allocator, .DELETE, path, gen.User, request_opts);
    }

    pub fn list_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListUsersParams,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UserListResponse) {
        return self.list_users_with_options(allocator, params, request_opts);
    }

    pub fn retrieve_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        user_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.User) {
        return self.retrieve_user_with_options(allocator, user_id, request_opts);
    }

    pub fn modify_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        user_id: []const u8,
        req: UpdateUserRoleRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.User) {
        return self.modify_user_with_options(allocator, user_id, req, request_opts);
    }

    pub fn delete_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        user_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.User) {
        return self.delete_user_with_options(allocator, user_id, request_opts);
    }
};
