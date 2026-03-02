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

    /// GET /organization/groups/{group_id}/roles
    pub fn list_group_role_assignments(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        params: ListAssignmentsParams,
    ) errors.Error!std.json.Parsed(gen.RoleListResource) {
        return self.list_group_role_assignments_with_options(allocator, group_id, params, null);
    }

    pub fn list_group_role_assignments_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        params: ListAssignmentsParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.RoleListResource) {
        var buf: [256]u8 = undefined;
        const path = buildListPath(&buf, group_id, params) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.RoleListResource, request_opts);
    }

    /// POST /organization/groups/{group_id}/roles
    pub fn assign_group_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        req: AssignRoleRequest,
    ) errors.Error!std.json.Parsed(gen.GroupRoleAssignment) {
        return self.assign_group_role_with_options(allocator, group_id, req, null);
    }

    pub fn assign_group_role_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        req: AssignRoleRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.GroupRoleAssignment) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/groups/{s}/roles", .{group_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(allocator, .POST, path, req, gen.GroupRoleAssignment, request_opts);
    }

    /// DELETE /organization/groups/{group_id}/roles/{role_id}
    pub fn unassign_group_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        role_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeletedRoleAssignmentResource) {
        return self.unassign_group_role_with_options(allocator, group_id, role_id, null);
    }

    pub fn unassign_group_role_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        role_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeletedRoleAssignmentResource) {
        var path_buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/groups/{s}/roles/{s}", .{ group_id, role_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .DELETE, path, gen.DeletedRoleAssignmentResource, request_opts);
    }

    pub fn list_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        params: ListAssignmentsParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.RoleListResource) {
        return self.list_group_role_assignments_with_options(allocator, group_id, params, request_opts);
    }

    pub fn assign_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        req: AssignRoleRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.GroupRoleAssignment) {
        return self.assign_group_role_with_options(allocator, group_id, req, request_opts);
    }

    pub fn unassign_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        role_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeletedRoleAssignmentResource) {
        return self.unassign_group_role_with_options(allocator, group_id, role_id, request_opts);
    }
};
