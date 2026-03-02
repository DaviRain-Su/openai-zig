const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const ListParams = struct {
    limit: ?u32 = null,
    after: ?[]const u8 = null,
    pub fn list(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ProjectListResponse) {
        return self.list_projects(allocator, params);
    }

    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.ProjectCreateRequest,
    ) errors.Error!std.json.Parsed(gen.Project) {
        return self.create_project(allocator, body);
    }

    pub fn retrieve(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Project) {
        return self.retrieve_project(allocator, project_id);
    }

    pub fn modify(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        body: gen.ProjectCreateRequest,
    ) errors.Error!std.json.Parsed(gen.Project) {
        return self.modify_project(allocator, project_id, body);
    }

    pub fn archive(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Project) {
        return self.archive_project(allocator, project_id);
    }

    pub fn list_api_keys(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
    ) errors.Error!std.json.Parsed(gen.ProjectApiKeyListResponse) {
        return self.list_project_api_keys(allocator, project_id, params);
    }

    pub fn retrieve_api_key(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        key_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectApiKey) {
        return self.retrieve_project_api_key(allocator, project_id, key_id);
    }

    pub fn delete_api_key(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        key_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectApiKeyDeleteResponse) {
        return self.delete_project_api_key(allocator, project_id, key_id);
    }

    pub fn list_rate_limits(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
    ) errors.Error!std.json.Parsed(gen.ProjectRateLimitListResponse) {
        return self.list_project_rate_limits(allocator, project_id, params);
    }

    pub fn update_rate_limits(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        rate_limit_id: []const u8,
        body: gen.ProjectRateLimit,
    ) errors.Error!std.json.Parsed(gen.ProjectRateLimit) {
        return self.update_project_rate_limits(allocator, project_id, rate_limit_id, body);
    }

    pub fn list_service_accounts(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
    ) errors.Error!std.json.Parsed(gen.ProjectServiceAccountListResponse) {
        return self.list_project_service_accounts(allocator, project_id, params);
    }

    pub fn create_service_account(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        body: gen.ProjectServiceAccount,
    ) errors.Error!std.json.Parsed(gen.ProjectServiceAccount) {
        return self.create_project_service_account(allocator, project_id, body);
    }

    pub fn retrieve_service_account(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        service_account_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectServiceAccount) {
        return self.retrieve_project_service_account(allocator, project_id, service_account_id);
    }

    pub fn delete_service_account(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        service_account_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectServiceAccount) {
        return self.delete_project_service_account(allocator, project_id, service_account_id);
    }

    pub fn list_users(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
    ) errors.Error!std.json.Parsed(gen.ProjectUserListResponse) {
        return self.list_project_users(allocator, project_id, params);
    }

    pub fn create_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        body: gen.ProjectUserCreateRequest,
    ) errors.Error!std.json.Parsed(gen.ProjectUser) {
        return self.create_project_user(allocator, project_id, body);
    }

    pub fn retrieve_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        user_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectUser) {
        return self.retrieve_project_user(allocator, project_id, user_id);
    }

    pub fn modify_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        user_id: []const u8,
        body: gen.ProjectUser,
    ) errors.Error!std.json.Parsed(gen.ProjectUser) {
        return self.modify_project_user(allocator, project_id, user_id, body);
    }

    pub fn delete_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        user_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectUser) {
        return self.delete_project_user(allocator, project_id, user_id);
    }
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

    fn appendListParams(writer: anytype, params: ListParams, first: *bool) !void {
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, first, "limit", @as(u64, limit));
        }
        try common.appendOptionalQueryParam(writer, first, "after", params.after);
    }

    fn appendListOrderParams(writer: anytype, params: ListOrderParams, first: *bool) !void {
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, first, "limit", @as(u64, limit));
        }
        try common.appendOptionalQueryParam(writer, first, "order", params.order);
        try common.appendOptionalQueryParam(writer, first, "after", params.after);
    }

    fn sendJsonTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendJsonTyped(self.transport, allocator, method, path, value, T);
    }

    fn sendJsonTypedWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
        comptime T: type,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            method,
            path,
            value,
            T,
            request_opts,
        );
    }

    fn sendNoBodyTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendNoBodyTyped(self.transport, allocator, method, path, T);
    }

    fn sendNoBodyTypedWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            method,
            path,
            T,
            request_opts,
        );
    }

    /// Projects
    pub fn list_projects(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ProjectListResponse) {
        return self.list_projects_with_options(allocator, params, null);
    }

    pub fn list_projects_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectListResponse) {
        var buf: [200]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/organization/projects");
        var first = true;
        try appendListParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ProjectListResponse,
            request_opts,
        );
    }

    pub fn create_project(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.ProjectCreateRequest,
    ) errors.Error!std.json.Parsed(gen.Project) {
        return self.create_project_with_options(allocator, body, null);
    }

    pub fn create_project_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.ProjectCreateRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Project) {
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            "/organization/projects",
            body,
            gen.Project,
            request_opts,
        );
    }

    pub fn retrieve_project(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Project) {
        return self.retrieve_project_with_options(allocator, project_id, null);
    }

    pub fn retrieve_project_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Project) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.Project,
            request_opts,
        );
    }

    pub fn modify_project(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        body: gen.ProjectCreateRequest,
    ) errors.Error!std.json.Parsed(gen.Project) {
        return self.modify_project_with_options(allocator, project_id, body, null);
    }

    pub fn modify_project_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        body: gen.ProjectCreateRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Project) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.Project,
            request_opts,
        );
    }

    pub fn archive_project(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Project) {
        return self.archive_project_with_options(allocator, project_id, null);
    }

    pub fn archive_project_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Project) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/archive", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .POST,
            path,
            gen.Project,
            request_opts,
        );
    }

    /// API keys
    pub fn list_project_api_keys(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
    ) errors.Error!std.json.Parsed(gen.ProjectApiKeyListResponse) {
        return self.list_project_api_keys_with_options(allocator, project_id, params, null);
    }

    pub fn list_project_api_keys_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectApiKeyListResponse) {
        var buf: [240]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/organization/projects/{s}/api_keys", .{project_id});
        var first = true;
        try appendListOrderParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ProjectApiKeyListResponse,
            request_opts,
        );
    }

    pub fn retrieve_project_api_key(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        key_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectApiKey) {
        return self.retrieve_project_api_key_with_options(allocator, project_id, key_id, null);
    }

    pub fn retrieve_project_api_key_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        key_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectApiKey) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/api_keys/{s}", .{ project_id, key_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ProjectApiKey,
            request_opts,
        );
    }

    pub fn delete_project_api_key(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        key_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectApiKeyDeleteResponse) {
        return self.delete_project_api_key_with_options(allocator, project_id, key_id, null);
    }

    pub fn delete_project_api_key_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        key_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectApiKeyDeleteResponse) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/api_keys/{s}", .{ project_id, key_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .DELETE,
            path,
            gen.ProjectApiKeyDeleteResponse,
            request_opts,
        );
    }

    /// Rate limits
    pub fn list_project_rate_limits(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
    ) errors.Error!std.json.Parsed(gen.ProjectRateLimitListResponse) {
        return self.list_project_rate_limits_with_options(allocator, project_id, params, null);
    }

    pub fn list_project_rate_limits_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectRateLimitListResponse) {
        var buf: [240]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/organization/projects/{s}/rate_limits", .{project_id});
        var first = true;
        try appendListOrderParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ProjectRateLimitListResponse,
            request_opts,
        );
    }

    pub fn update_project_rate_limits(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        rate_limit_id: []const u8,
        body: gen.ProjectRateLimit,
    ) errors.Error!std.json.Parsed(gen.ProjectRateLimit) {
        return self.update_project_rate_limits_with_options(allocator, project_id, rate_limit_id, body, null);
    }

    pub fn update_project_rate_limits_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        rate_limit_id: []const u8,
        body: gen.ProjectRateLimit,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectRateLimit) {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/rate_limits/{s}", .{ project_id, rate_limit_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.ProjectRateLimit,
            request_opts,
        );
    }

    /// Service accounts
    pub fn list_project_service_accounts(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
    ) errors.Error!std.json.Parsed(gen.ProjectServiceAccountListResponse) {
        return self.list_project_service_accounts_with_options(allocator, project_id, params, null);
    }

    pub fn list_project_service_accounts_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectServiceAccountListResponse) {
        var buf: [240]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/organization/projects/{s}/service_accounts", .{project_id});
        var first = true;
        try appendListOrderParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ProjectServiceAccountListResponse,
            request_opts,
        );
    }

    pub fn create_project_service_account(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        body: gen.ProjectServiceAccount,
    ) errors.Error!std.json.Parsed(gen.ProjectServiceAccount) {
        return self.create_project_service_account_with_options(allocator, project_id, body, null);
    }

    pub fn create_project_service_account_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        body: gen.ProjectServiceAccount,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectServiceAccount) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/service_accounts", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.ProjectServiceAccount,
            request_opts,
        );
    }

    pub fn retrieve_project_service_account(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        service_account_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectServiceAccount) {
        return self.retrieve_project_service_account_with_options(allocator, project_id, service_account_id, null);
    }

    pub fn retrieve_project_service_account_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        service_account_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectServiceAccount) {
        var buf: [300]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/service_accounts/{s}", .{ project_id, service_account_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ProjectServiceAccount,
            request_opts,
        );
    }

    pub fn delete_project_service_account(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        service_account_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectServiceAccount) {
        return self.delete_project_service_account_with_options(allocator, project_id, service_account_id, null);
    }

    pub fn delete_project_service_account_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        service_account_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectServiceAccount) {
        var buf: [300]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/service_accounts/{s}", .{ project_id, service_account_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .DELETE,
            path,
            gen.ProjectServiceAccount,
            request_opts,
        );
    }

    /// Project users
    pub fn list_project_users(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
    ) errors.Error!std.json.Parsed(gen.ProjectUserListResponse) {
        return self.list_project_users_with_options(allocator, project_id, params, null);
    }

    pub fn list_project_users_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListOrderParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectUserListResponse) {
        var buf: [240]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/organization/projects/{s}/users", .{project_id});
        var first = true;
        try appendListOrderParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ProjectUserListResponse,
            request_opts,
        );
    }

    pub fn create_project_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        body: gen.ProjectUserCreateRequest,
    ) errors.Error!std.json.Parsed(gen.ProjectUser) {
        return self.create_project_user_with_options(allocator, project_id, body, null);
    }

    pub fn create_project_user_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        body: gen.ProjectUserCreateRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectUser) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/users", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.ProjectUser,
            request_opts,
        );
    }

    pub fn retrieve_project_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        user_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectUser) {
        return self.retrieve_project_user_with_options(allocator, project_id, user_id, null);
    }

    pub fn retrieve_project_user_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        user_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectUser) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/users/{s}", .{ project_id, user_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ProjectUser,
            request_opts,
        );
    }

    pub fn modify_project_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        user_id: []const u8,
        body: gen.ProjectUser,
    ) errors.Error!std.json.Parsed(gen.ProjectUser) {
        return self.modify_project_user_with_options(allocator, project_id, user_id, body, null);
    }

    pub fn modify_project_user_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        user_id: []const u8,
        body: gen.ProjectUser,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectUser) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/users/{s}", .{ project_id, user_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.ProjectUser,
            request_opts,
        );
    }

    pub fn delete_project_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        user_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ProjectUser) {
        return self.delete_project_user_with_options(allocator, project_id, user_id, null);
    }

    pub fn delete_project_user_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        user_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ProjectUser) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/users/{s}", .{ project_id, user_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .DELETE,
            path,
            gen.ProjectUser,
            request_opts,
        );
    }
};
