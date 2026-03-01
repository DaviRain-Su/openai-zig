const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const ListProjectGroupsParams = struct {
    limit: ?u32 = null,
    after: ?[]const u8 = null,
    order: ?[]const u8 = null,
    pub fn list(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListProjectGroupsParams,
    ) errors.Error!std.json.Parsed(gen.ProjectGroupListResource) {
        return self.list_project_groups(allocator, project_id, params);
    }

    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        req: InviteProjectGroupRequest,
    ) errors.Error!std.json.Parsed(gen.ProjectGroup) {
        return self.add_project_group(allocator, project_id, req);
    }

    pub fn remove(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        group_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectGroupDeletedResource) {
        return self.remove_project_group(allocator, project_id, group_id);
    }
};

pub const InviteProjectGroupRequest = struct {
    group_id: []const u8,
    role: []const u8,
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

    /// GET /organization/projects/{project_id}/groups
    pub fn list_project_groups(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListProjectGroupsParams,
    ) errors.Error!std.json.Parsed(gen.ProjectGroupListResource) {
        return self.list_project_groups_with_options(allocator, project_id, params, null);
    }

    pub fn list_project_groups_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListProjectGroupsParams,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectGroupListResource) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const writer = fbs.writer();
        try writer.print("/organization/projects/{s}/groups", .{project_id});
        var first = true;
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, &first, "limit", @as(u64, limit));
        }
        try common.appendOptionalQueryParam(writer, &first, "after", params.after);
        try common.appendOptionalQueryParam(writer, &first, "order", params.order);
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.ProjectGroupListResource, request_opts);
    }

    /// POST /organization/projects/{project_id}/groups
    pub fn add_project_group(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        req: InviteProjectGroupRequest,
    ) errors.Error!std.json.Parsed(gen.ProjectGroup) {
        return self.add_project_group_with_options(allocator, project_id, req, null);
    }

    pub fn add_project_group_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        req: InviteProjectGroupRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectGroup) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/projects/{s}/groups", .{project_id}) catch {
            return errors.Error.SerializeError;
        };

        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            req,
            gen.ProjectGroup,
            request_opts,
        );
    }

    /// DELETE /organization/projects/{project_id}/groups/{group_id}
    pub fn remove_project_group(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        group_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectGroupDeletedResource) {
        return self.remove_project_group_with_options(allocator, project_id, group_id, null);
    }

    pub fn remove_project_group_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        group_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectGroupDeletedResource) {
        var path_buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/projects/{s}/groups/{s}", .{ project_id, group_id }) catch {
            return errors.Error.SerializeError;
        };

        return self.sendNoBodyTypedWithOptions(allocator, .DELETE, path, gen.ProjectGroupDeletedResource, request_opts);
    }

    pub fn list_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListProjectGroupsParams,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectGroupListResource) {
        return self.list_project_groups_with_options(allocator, project_id, params, request_opts);
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        req: InviteProjectGroupRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectGroup) {
        return self.add_project_group_with_options(allocator, project_id, req, request_opts);
    }

    pub fn remove_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        group_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectGroupDeletedResource) {
        return self.remove_project_group_with_options(allocator, project_id, group_id, request_opts);
    }
};
