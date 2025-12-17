const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");

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

    fn sendJsonTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
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

        const parsed = std.json.parseFromSlice(T, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    fn sendNoBodyTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        const resp = try self.transport.request(method, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(T, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// Projects
    pub fn list_projects(self: *const Resource, allocator: std.mem.Allocator, params: ListParams) errors.Error!std.json.Parsed(gen.ProjectListResponse) {
        var buf: [200]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/organization/projects");
        try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ProjectListResponse);
    }

    pub fn create_project(self: *const Resource, allocator: std.mem.Allocator, body: gen.ProjectCreateRequest) errors.Error!std.json.Parsed(gen.Project) {
        return self.sendJsonTyped(allocator, .POST, "/organization/projects", body, gen.Project);
    }

    pub fn retrieve_project(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Project) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .GET, path, gen.Project);
    }

    pub fn modify_project(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        body: gen.ProjectCreateRequest,
    ) errors.Error!std.json.Parsed(gen.Project) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.Project);
    }

    pub fn archive_project(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Project) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/archive", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .POST, path, gen.Project);
    }

    /// API keys
    pub fn list_project_api_keys(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
    ) errors.Error!std.json.Parsed(gen.ProjectApiKeyListResponse) {
        var buf: [240]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/organization/projects/{s}/api_keys", .{project_id});
        try appendListOrderParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ProjectApiKeyListResponse);
    }

    pub fn retrieve_project_api_key(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        key_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectApiKey) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/api_keys/{s}", .{ project_id, key_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ProjectApiKey);
    }

    pub fn delete_project_api_key(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        key_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectApiKeyDeleteResponse) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/api_keys/{s}", .{ project_id, key_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .DELETE, path, gen.ProjectApiKeyDeleteResponse);
    }

    /// Rate limits
    pub fn list_project_rate_limits(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
    ) errors.Error!std.json.Parsed(gen.ProjectRateLimitListResponse) {
        var buf: [240]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/organization/projects/{s}/rate_limits", .{project_id});
        try appendListOrderParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ProjectRateLimitListResponse);
    }

    pub fn update_project_rate_limits(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        rate_limit_id: []const u8,
        body: gen.ProjectRateLimit,
    ) errors.Error!std.json.Parsed(gen.ProjectRateLimit) {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/rate_limits/{s}", .{ project_id, rate_limit_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.ProjectRateLimit);
    }

    /// Service accounts
    pub fn list_project_service_accounts(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
    ) errors.Error!std.json.Parsed(gen.ProjectServiceAccountListResponse) {
        var buf: [240]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/organization/projects/{s}/service_accounts", .{project_id});
        try appendListOrderParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ProjectServiceAccountListResponse);
    }

    pub fn create_project_service_account(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        body: gen.ProjectServiceAccount,
    ) errors.Error!std.json.Parsed(gen.ProjectServiceAccount) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/service_accounts", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.ProjectServiceAccount);
    }

    pub fn retrieve_project_service_account(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        service_account_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectServiceAccount) {
        var buf: [300]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/service_accounts/{s}", .{ project_id, service_account_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ProjectServiceAccount);
    }

    pub fn delete_project_service_account(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        service_account_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectServiceAccount) {
        var buf: [300]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/service_accounts/{s}", .{ project_id, service_account_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .DELETE, path, gen.ProjectServiceAccount);
    }

    /// Project users
    pub fn list_project_users(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
    ) errors.Error!std.json.Parsed(gen.ProjectUserListResponse) {
        var buf: [240]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/organization/projects/{s}/users", .{project_id});
        try appendListOrderParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ProjectUserListResponse);
    }

    pub fn create_project_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        body: gen.ProjectUserCreateRequest,
    ) errors.Error!std.json.Parsed(gen.ProjectUser) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/users", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.ProjectUser);
    }

    pub fn retrieve_project_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        user_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectUser) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/users/{s}", .{ project_id, user_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ProjectUser);
    }

    pub fn modify_project_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        user_id: []const u8,
        body: gen.ProjectUser,
    ) errors.Error!std.json.Parsed(gen.ProjectUser) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/users/{s}", .{ project_id, user_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.ProjectUser);
    }

    pub fn delete_project_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        user_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectUser) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/users/{s}", .{ project_id, user_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .DELETE, path, gen.ProjectUser);
    }
};
