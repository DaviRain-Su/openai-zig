const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const CreateRoleRequest = gen.PublicCreateOrganizationRoleBody;

pub const UpdateRoleRequest = gen.PublicUpdateOrganizationRoleBody;

pub const ListRolesParams = struct {
    limit: ?u32 = null,
    after: ?[]const u8 = null,
    order: ?[]const u8 = null,
    pub fn list(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListRolesParams,
    ) errors.Error!std.json.Parsed(gen.PublicRoleListResource) {
        return self.list_roles(allocator, params);
    }

    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateRoleRequest,
    ) errors.Error!std.json.Parsed(gen.Role) {
        return self.create_role(allocator, req);
    }

    pub fn update(
        self: *const Resource,
        allocator: std.mem.Allocator,
        role_id: []const u8,
        req: UpdateRoleRequest,
    ) errors.Error!std.json.Parsed(gen.Role) {
        return self.update_role(allocator, role_id, req);
    }

    pub fn delete(
        self: *const Resource,
        allocator: std.mem.Allocator,
        role_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.RoleDeletedResource) {
        return self.delete_role(allocator, role_id);
    }

    pub fn list_project(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListRolesParams,
    ) errors.Error!std.json.Parsed(gen.PublicRoleListResource) {
        return self.list_project_roles(allocator, project_id, params);
    }

    pub fn create_project(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        req: CreateRoleRequest,
    ) errors.Error!std.json.Parsed(gen.Role) {
        return self.create_project_role(allocator, project_id, req);
    }

    pub fn update_project(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        role_id: []const u8,
        req: UpdateRoleRequest,
    ) errors.Error!std.json.Parsed(gen.Role) {
        return self.update_project_role(allocator, project_id, role_id, req);
    }

    pub fn delete_project(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        role_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.RoleDeletedResource) {
        return self.delete_project_role(allocator, project_id, role_id);
    }
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn buildListPath(buf: []u8, base: []const u8, params: ListRolesParams) ![]const u8 {
        var fbs = std.io.fixedBufferStream(buf);
        const writer = fbs.writer();
        try writer.writeAll(base);
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

    /// GET /organization/roles
    pub fn list_roles(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListRolesParams,
    ) errors.Error!std.json.Parsed(gen.PublicRoleListResource) {
        return self.list_roles_with_options(allocator, params, null);
    }

    pub fn list_roles_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListRolesParams,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.PublicRoleListResource) {
        var buf: [256]u8 = undefined;
        const path = buildListPath(&buf, "/organization/roles", params) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.PublicRoleListResource, request_opts);
    }

    /// POST /organization/roles
    pub fn create_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateRoleRequest,
    ) errors.Error!std.json.Parsed(gen.Role) {
        return self.create_role_with_options(allocator, req, null);
    }

    pub fn create_role_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateRoleRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Role) {
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            "/organization/roles",
            req,
            gen.Role,
            request_opts,
        );
    }

    /// POST /organization/roles/{role_id}
    pub fn update_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        role_id: []const u8,
        req: UpdateRoleRequest,
    ) errors.Error!std.json.Parsed(gen.Role) {
        return self.update_role_with_options(allocator, role_id, req, null);
    }

    pub fn update_role_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        role_id: []const u8,
        req: UpdateRoleRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Role) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/roles/{s}", .{role_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(allocator, .POST, path, req, gen.Role, request_opts);
    }

    /// DELETE /organization/roles/{role_id}
    pub fn delete_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        role_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.RoleDeletedResource) {
        return self.delete_role_with_options(allocator, role_id, null);
    }

    pub fn delete_role_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        role_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.RoleDeletedResource) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/roles/{s}", .{role_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .DELETE, path, gen.RoleDeletedResource, request_opts);
    }

    /// GET /projects/{project_id}/roles
    pub fn list_project_roles(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListRolesParams,
    ) errors.Error!std.json.Parsed(gen.PublicRoleListResource) {
        return self.list_project_roles_with_options(allocator, project_id, params, null);
    }

    pub fn list_project_roles_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListRolesParams,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.PublicRoleListResource) {
        var path_buf: [256]u8 = undefined;
        const base = std.fmt.bufPrint(&path_buf, "/projects/{s}/roles", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        var buf: [256]u8 = undefined;
        const path = buildListPath(&buf, base, params) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.PublicRoleListResource, request_opts);
    }

    /// POST /projects/{project_id}/roles
    pub fn create_project_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        req: CreateRoleRequest,
    ) errors.Error!std.json.Parsed(gen.Role) {
        return self.create_project_role_with_options(allocator, project_id, req, null);
    }

    pub fn create_project_role_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        req: CreateRoleRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Role) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/projects/{s}/roles", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(allocator, .POST, path, req, gen.Role, request_opts);
    }

    /// POST /projects/{project_id}/roles/{role_id}
    pub fn update_project_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        role_id: []const u8,
        req: UpdateRoleRequest,
    ) errors.Error!std.json.Parsed(gen.Role) {
        return self.update_project_role_with_options(allocator, project_id, role_id, req, null);
    }

    pub fn update_project_role_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        role_id: []const u8,
        req: UpdateRoleRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Role) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/projects/{s}/roles/{s}", .{ project_id, role_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(allocator, .POST, path, req, gen.Role, request_opts);
    }

    /// DELETE /projects/{project_id}/roles/{role_id}
    pub fn delete_project_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        role_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.RoleDeletedResource) {
        return self.delete_project_role_with_options(allocator, project_id, role_id, null);
    }

    pub fn delete_project_role_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        role_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.RoleDeletedResource) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/projects/{s}/roles/{s}", .{ project_id, role_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .DELETE, path, gen.RoleDeletedResource, request_opts);
    }

    pub fn list_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListRolesParams,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.PublicRoleListResource) {
        return self.list_roles_with_options(allocator, params, request_opts);
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateRoleRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Role) {
        return self.create_role_with_options(allocator, req, request_opts);
    }

    pub fn update_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        role_id: []const u8,
        req: UpdateRoleRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Role) {
        return self.update_role_with_options(allocator, role_id, req, request_opts);
    }

    pub fn delete_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        role_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.RoleDeletedResource) {
        return self.delete_role_with_options(allocator, role_id, request_opts);
    }

    pub fn list_project_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListRolesParams,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.PublicRoleListResource) {
        return self.list_project_roles_with_options(allocator, project_id, params, request_opts);
    }

    pub fn create_project_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        req: CreateRoleRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Role) {
        return self.create_project_role_with_options(allocator, project_id, req, request_opts);
    }

    pub fn update_project_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        role_id: []const u8,
        req: UpdateRoleRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Role) {
        return self.update_project_role_with_options(allocator, project_id, role_id, req, request_opts);
    }

    pub fn delete_project_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        role_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.RoleDeletedResource) {
        return self.delete_project_role_with_options(allocator, project_id, role_id, request_opts);
    }
};
