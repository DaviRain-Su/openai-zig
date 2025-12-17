const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");

pub const ListGroupUsersParams = struct {
    limit: ?u32 = null,
    after: ?[]const u8 = null,
    order: ?[]const u8 = null,
};

pub const CreateGroupUserRequest = struct {
    user_id: []const u8,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    /// GET /organization/groups/{group_id}/users
    pub fn list_group_users(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        params: ListGroupUsersParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const writer = fbs.writer();
        try writer.print("/organization/groups/{s}/users", .{group_id});
        var sep: []const u8 = "?";
        if (params.limit) |limit| {
            try writer.print("{s}limit={d}", .{ sep, limit });
            sep = "&";
        }
        if (params.after) |after| {
            try writer.print("{s}after={s}", .{ sep, after });
            sep = "&";
        }
        if (params.order) |order| {
            try writer.print("{s}order={s}", .{ sep, order });
        }
        const path = fbs.getWritten();

        const resp = try self.transport.request(.GET, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /organization/groups/{group_id}/users
    pub fn add_group_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        req: CreateGroupUserRequest,
    ) errors.Error!std.json.Parsed(gen.GroupUserAssignment) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/groups/{s}/users", .{group_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.POST, path, &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = "application/json" },
        }, payload);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.GroupUserAssignment, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// DELETE /organization/groups/{group_id}/users/{user_id}
    pub fn remove_group_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        user_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.GroupUserDeletedResource) {
        var path_buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/groups/{s}/users/{s}", .{ group_id, user_id }) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.DELETE, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.GroupUserDeletedResource, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }
};
