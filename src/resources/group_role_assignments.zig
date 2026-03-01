const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const AssignRoleRequest = struct {
    role_id: []const u8,
    pub fn list(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        params: ListAssignmentsParams,
    ) errors.Error!std.json.Parsed(gen.RoleListResource) {
        return self.list_group_role_assignments(allocator, group_id, params);
    }

    pub fn assign(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        req: AssignRoleRequest,
    ) errors.Error!std.json.Parsed(gen.GroupRoleAssignment) {
        return self.assign_group_role(allocator, group_id, req);
    }

    pub fn unassign(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        role_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeletedRoleAssignmentResource) {
        return self.unassign_group_role(allocator, group_id, role_id);
    }
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
        var first = true;
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, &first, "limit", @as(u64, limit));
        }
        try common.appendOptionalQueryParam(writer, &first, "after", params.after);
        try common.appendOptionalQueryParam(writer, &first, "order", params.order);
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

        const parsed = std.json.parseFromSlice(gen.GroupRoleAssignment, allocator, body, .{ .ignore_unknown_fields = true }) catch {
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
    ) errors.Error!std.json.Parsed(gen.RoleListResource) {
        var buf: [256]u8 = undefined;
        const path = buildListPath(&buf, group_id, params) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.GET, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.RoleListResource, allocator, body, .{ .ignore_unknown_fields = true }) catch {
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
    ) errors.Error!std.json.Parsed(gen.DeletedRoleAssignmentResource) {
        var path_buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/groups/{s}/roles/{s}", .{ group_id, role_id }) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.DELETE, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.DeletedRoleAssignmentResource, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }
};
