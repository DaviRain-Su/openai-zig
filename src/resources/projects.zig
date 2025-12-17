const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

pub const ListParams = struct {
    limit: ?u32 = null,
    after: ?[]const u8 = null,
};

pub const ListOrderParams = struct {
    limit: ?u32 = null,
    order: ?[]const u8 = null,
    after: ?[]const u8 = null,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn appendListParams(writer: anytype, params: ListParams, sep_start: []const u8) !void {
        var sep = sep_start;
        if (params.limit) |limit| {
            try writer.print("{s}limit={d}", .{ sep, limit });
            sep = "&";
        }
        if (params.after) |after| {
            try writer.print("{s}after={s}", .{ sep, after });
        }
    }

    fn appendListOrderParams(writer: anytype, params: ListOrderParams, sep_start: []const u8) !void {
        var sep = sep_start;
        if (params.limit) |limit| {
            try writer.print("{s}limit={d}", .{ sep, limit });
            sep = "&";
        }
        if (params.order) |order| {
            try writer.print("{s}order={s}", .{ sep, order });
            sep = "&";
        }
        if (params.after) |after| {
            try writer.print("{s}after={s}", .{ sep, after });
        }
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

    fn sendNoBody(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        const resp = try self.transport.request(method, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// Projects
    pub fn list_projects(self: *const Resource, allocator: std.mem.Allocator, params: ListParams) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/organization/projects");
        try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn create_project(self: *const Resource, allocator: std.mem.Allocator, body: std.json.Value) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJson(allocator, .POST, "/organization/projects", body);
    }

    pub fn retrieve_project(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn modify_project(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, body);
    }

    pub fn archive_project(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/archive", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .POST, path);
    }

    /// API keys
    pub fn list_project_api_keys(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [240]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/organization/projects/{s}/api_keys", .{project_id});
        try appendListOrderParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn retrieve_project_api_key(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        key_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/api_keys/{s}", .{ project_id, key_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn delete_project_api_key(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        key_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/api_keys/{s}", .{ project_id, key_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .DELETE, path);
    }

    /// Rate limits
    pub fn list_project_rate_limits(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [240]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/organization/projects/{s}/rate_limits", .{project_id});
        try appendListOrderParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn update_project_rate_limits(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        rate_limit_id: []const u8,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/rate_limits/{s}", .{ project_id, rate_limit_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, body);
    }

    /// Service accounts
    pub fn list_project_service_accounts(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [240]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/organization/projects/{s}/service_accounts", .{project_id});
        try appendListOrderParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn create_project_service_account(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/service_accounts", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, body);
    }

    pub fn retrieve_project_service_account(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        service_account_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [300]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/service_accounts/{s}", .{ project_id, service_account_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn delete_project_service_account(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        service_account_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [300]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/service_accounts/{s}", .{ project_id, service_account_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .DELETE, path);
    }

    /// Project users
    pub fn list_project_users(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [240]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/organization/projects/{s}/users", .{project_id});
        try appendListOrderParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn create_project_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/users", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, body);
    }

    pub fn retrieve_project_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        user_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/users/{s}", .{ project_id, user_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn modify_project_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        user_id: []const u8,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/users/{s}", .{ project_id, user_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, body);
    }

    pub fn delete_project_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        user_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/users/{s}", .{ project_id, user_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .DELETE, path);
    }
};
