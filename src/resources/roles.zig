const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

pub const CreateRoleRequest = struct {
    role_name: []const u8,
    permissions: []const []const u8,
    description: ?[]const u8 = null,
};

pub const UpdateRoleRequest = struct {
    role_name: ?[]const u8 = null,
    permissions: ?[]const []const u8 = null,
    description: ?[]const u8 = null,
};

pub const ListRolesParams = struct {
    limit: ?u32 = null,
    after: ?[]const u8 = null,
    order: ?[]const u8 = null,
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

    fn sendJson(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
    ) errors.Error!std.json.Parsed(std.json.Value) {
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

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// GET /organization/roles
    pub fn list_roles(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListRolesParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [256]u8 = undefined;
        const path = buildListPath(&buf, "/organization/roles", params) catch {
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

    /// POST /organization/roles
    pub fn create_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateRoleRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJson(allocator, .POST, "/organization/roles", req);
    }

    /// POST /organization/roles/{role_id}
    pub fn update_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        role_id: []const u8,
        req: UpdateRoleRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/roles/{s}", .{role_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, req);
    }

    /// DELETE /organization/roles/{role_id}
    pub fn delete_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        role_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/roles/{s}", .{role_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.DELETE, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// GET /projects/{project_id}/roles
    pub fn list_project_roles(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListRolesParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [256]u8 = undefined;
        const base = std.fmt.bufPrint(&path_buf, "/projects/{s}/roles", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        var buf: [256]u8 = undefined;
        const path = buildListPath(&buf, base, params) catch {
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

    /// POST /projects/{project_id}/roles
    pub fn create_project_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        req: CreateRoleRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/projects/{s}/roles", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, req);
    }

    /// POST /projects/{project_id}/roles/{role_id}
    pub fn update_project_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        role_id: []const u8,
        req: UpdateRoleRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/projects/{s}/roles/{s}", .{ project_id, role_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, req);
    }

    /// DELETE /projects/{project_id}/roles/{role_id}
    pub fn delete_project_role(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        role_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/projects/{s}/roles/{s}", .{ project_id, role_id }) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.DELETE, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }
};
