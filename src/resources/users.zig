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

        const parsed = std.json.parseFromSlice(T, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// GET /organization/users
    pub fn list_users(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListUsersParams,
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

        const resp = try self.transport.request(.GET, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.UserListResponse, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// GET /organization/users/{user_id}
    pub fn retrieve_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        user_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.User) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/users/{s}", .{user_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.GET, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.User, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /organization/users/{user_id}
    pub fn modify_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        user_id: []const u8,
        req: UpdateUserRoleRequest,
    ) errors.Error!std.json.Parsed(gen.User) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/users/{s}", .{user_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, req, gen.User);
    }

    /// DELETE /organization/users/{user_id}
    pub fn delete_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        user_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.User) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/users/{s}", .{user_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.DELETE, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.User, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }
};
