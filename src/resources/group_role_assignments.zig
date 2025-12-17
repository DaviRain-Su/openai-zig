const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");

pub const AssignRoleRequest = struct {
    role_id: []const u8,
};

pub const ListAssignmentsParams = struct {
    limit: ?u32 = null,
    after: ?[]const u8 = null,
    order: ?[]const u8 = null,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn buildListPath(buf: []u8, group_id: []const u8, params: ListAssignmentsParams) ![]const u8 {
        var fbs = std.io.fixedBufferStream(buf);
        const writer = fbs.writer();
        try writer.print("/organization/groups/{s}/roles", .{group_id});
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
        return fbs.getWritten();
    }

    fn sendAssign(
        self: *const Resource,
        allocator: std.mem.Allocator,
        path: []const u8,
        req: AssignRoleRequest,
    ) errors.Error!std.json.Parsed(gen.GroupRoleAssignment) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        const resp = try self.transport.request(.POST, path, &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = "application/json" },
        }, payload);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.GroupRoleAssignment, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// GET /organization/groups/{group_id}/roles
    pub fn list_group_role_assignments(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        params: ListAssignmentsParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [256]u8 = undefined;
        const path = buildListPath(&buf, group_id, params) catch {
            return errors.Error.SerializeError;
        };

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

    /// POST /organization/groups/{group_id}/roles
    pub fn assign_group_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        req: AssignRoleRequest,
    ) errors.Error!std.json.Parsed(gen.GroupRoleAssignment) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/groups/{s}/roles", .{group_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendAssign(allocator, path, req);
    }

    /// DELETE /organization/groups/{group_id}/roles/{role_id}
    pub fn unassign_group_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        role_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.GroupRoleAssignment) {
        var path_buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/groups/{s}/roles/{s}", .{ group_id, role_id }) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.DELETE, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.GroupRoleAssignment, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }
};
