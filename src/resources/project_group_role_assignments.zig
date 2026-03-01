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
        project_id: []const u8,
        group_id: []const u8,
        params: ListAssignmentsParams,
    ) errors.Error!std.json.Parsed(gen.RoleListResource) {
        return self.list_project_group_role_assignments(allocator, project_id, group_id, params);
    }

    pub fn assign(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        group_id: []const u8,
        req: AssignRoleRequest,
    ) errors.Error!std.json.Parsed(gen.GroupRoleAssignment) {
        return self.assign_project_group_role(allocator, project_id, group_id, req);
    }

    pub fn unassign(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        group_id: []const u8,
        role_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeletedRoleAssignmentResource) {
        return self.unassign_project_group_role(allocator, project_id, group_id, role_id);
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

    fn buildListPath(buf: []u8, project_id: []const u8, group_id: []const u8, params: ListAssignmentsParams) ![]const u8 {
        var fbs = std.io.fixedBufferStream(buf);
        const writer = fbs.writer();
        try writer.print("/projects/{s}/groups/{s}/roles", .{ project_id, group_id });
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

    /// GET /projects/{project_id}/groups/{group_id}/roles
    pub fn list_project_group_role_assignments(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        group_id: []const u8,
        params: ListAssignmentsParams,
    ) errors.Error!std.json.Parsed(gen.RoleListResource) {
        var buf: [256]u8 = undefined;
        const path = buildListPath(&buf, project_id, group_id, params) catch {
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

    /// POST /projects/{project_id}/groups/{group_id}/roles
    pub fn assign_project_group_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        group_id: []const u8,
        req: AssignRoleRequest,
    ) errors.Error!std.json.Parsed(gen.GroupRoleAssignment) {
        var path_buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/projects/{s}/groups/{s}/roles", .{ project_id, group_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendAssign(allocator, path, req);
    }

    /// DELETE /projects/{project_id}/groups/{group_id}/roles/{role_id}
    pub fn unassign_project_group_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        group_id: []const u8,
        role_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeletedRoleAssignmentResource) {
        var path_buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/projects/{s}/groups/{s}/roles/{s}", .{ project_id, group_id, role_id }) catch {
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
