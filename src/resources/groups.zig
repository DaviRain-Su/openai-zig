const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const ListGroupsParams = struct {
    limit: ?u32 = null,
    after: ?[]const u8 = null,
    order: ?[]const u8 = null,
    pub fn list(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListGroupsParams,
    ) errors.Error!std.json.Parsed(gen.GroupListResource) {
        return self.list_groups(allocator, params);
    }

    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateGroupRequest,
    ) errors.Error!std.json.Parsed(gen.GroupResponse) {
        return self.create_group(allocator, req);
    }

    pub fn update(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        req: UpdateGroupRequest,
    ) errors.Error!std.json.Parsed(gen.GroupResponse) {
        return self.update_group(allocator, group_id, req);
    }

    pub fn delete(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.GroupDeletedResource) {
        return self.delete_group(allocator, group_id);
    }
};

pub const CreateGroupRequest = struct {
    name: []const u8,
};

pub const UpdateGroupRequest = struct {
    name: []const u8,
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

    /// GET /organization/groups
    pub fn list_groups(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListGroupsParams,
    ) errors.Error!std.json.Parsed(gen.GroupListResource) {
        return self.list_groups_with_options(allocator, params, null);
    }

    pub fn list_groups_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListGroupsParams,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.GroupListResource) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const writer = fbs.writer();
        try writer.writeAll("/organization/groups");
        var first = true;
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, &first, "limit", @as(u64, limit));
        }
        try common.appendOptionalQueryParam(writer, &first, "after", params.after);
        try common.appendOptionalQueryParam(writer, &first, "order", params.order);
        const path = fbs.getWritten();

        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.GroupListResource, request_opts);
    }

    /// POST /organization/groups
    pub fn create_group(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateGroupRequest,
    ) errors.Error!std.json.Parsed(gen.GroupResponse) {
        return self.create_group_with_options(allocator, req, null);
    }

    pub fn create_group_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateGroupRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.GroupResponse) {
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            "/organization/groups",
            req,
            gen.GroupResponse,
            request_opts,
        );
    }

    /// POST /organization/groups/{group_id}
    pub fn update_group(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        req: UpdateGroupRequest,
    ) errors.Error!std.json.Parsed(gen.GroupResponse) {
        return self.update_group_with_options(allocator, group_id, req, null);
    }

    pub fn update_group_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        req: UpdateGroupRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.GroupResponse) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/groups/{s}", .{group_id}) catch {
            return errors.Error.SerializeError;
        };

        return self.sendJsonTypedWithOptions(allocator, .POST, path, req, gen.GroupResponse, request_opts);
    }

    /// DELETE /organization/groups/{group_id}
    pub fn delete_group(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.GroupDeletedResource) {
        return self.delete_group_with_options(allocator, group_id, null);
    }

    pub fn delete_group_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.GroupDeletedResource) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/groups/{s}", .{group_id}) catch {
            return errors.Error.SerializeError;
        };

        return self.sendNoBodyTypedWithOptions(allocator, .DELETE, path, gen.GroupDeletedResource, request_opts);
    }

    pub fn list_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListGroupsParams,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.GroupListResource) {
        return self.list_groups_with_options(allocator, params, request_opts);
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateGroupRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.GroupResponse) {
        return self.create_group_with_options(allocator, req, request_opts);
    }

    pub fn update_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        req: UpdateGroupRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.GroupResponse) {
        return self.update_group_with_options(allocator, group_id, req, request_opts);
    }

    pub fn delete_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        group_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.GroupDeletedResource) {
        return self.delete_group_with_options(allocator, group_id, request_opts);
    }
};
