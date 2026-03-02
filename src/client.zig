const std = @import("std");
const errors = @import("errors.zig");
const transport_mod = @import("transport/http.zig");
const resources = @import("resources.zig");

pub const Client = struct {
    /// Core resources owned by the client are stored inside transport.
    /// The client value itself is immutable by convention, and per-request overrides
    /// are produced by cloning with `withOptions` / `with_options`.
    allocator: std.mem.Allocator,
    transport: transport_mod.Transport,

    pub const Options = struct {
        /// Transport base URL used for all outgoing requests.
        base_url: []const u8,
        /// Optional API key. When null, requests are sent without Authorization header.
        api_key: ?[]const u8 = null,
        /// Optional organization header (`OpenAI-Organization`).
        organization: ?[]const u8 = null,
        /// Optional project header (`OpenAI-Project`).
        project: ?[]const u8 = null,
        /// Extra default headers merged into every request.
        extra_headers: ?[]const std.http.Header = null,
        /// Optional proxy URL.
        proxy: ?[]const u8 = null,
        /// Optional timeout in milliseconds; if null, transport uses default behavior.
        timeout_ms: ?u64 = null,
        /// Retry attempts for transient failures.
        max_retries: u8 = 2,
        /// Exponential retry base delay (milliseconds).
        retry_base_delay_ms: u64 = 500,
    };

    /// Per-call override options. Null fields inherit from the existing client transport.
    pub const RequestOptions = struct {
        base_url: ?[]const u8 = null,
        api_key: ?[]const u8 = null,
        organization: ?[]const u8 = null,
        project: ?[]const u8 = null,
        extra_headers: ?[]const std.http.Header = null,
        proxy: ?[]const u8 = null,
        timeout_ms: ?u64 = null,
        max_retries: ?u8 = null,
        retry_base_delay_ms: ?u64 = null,
    };

    /// Create a new client from explicit options.
    ///
    /// `opts` are fully applied to the returned client and copied into transport-owned
    /// memory, so callers keep ownership of their original buffers.
    pub fn init(allocator: std.mem.Allocator, opts: Options) !Client {
        const transport = try transport_mod.Transport.init(allocator, .{
            .base_url = opts.base_url,
            .api_key = opts.api_key,
            .organization = opts.organization,
            .project = opts.project,
            .extra_headers = opts.extra_headers,
            .proxy = opts.proxy,
            .timeout_ms = opts.timeout_ms,
            .max_retries = opts.max_retries,
            .retry_base_delay_ms = opts.retry_base_delay_ms,
        });
        return Client{
            .allocator = allocator,
            .transport = transport,
        };
    }

    /// Clone this client while applying per-request overrides.
    ///
    /// Non-null override fields replace existing values; null fields keep the current
    /// client's transport setting. This matches the common OpenAI client pattern where
    /// a call like `client.with_options(... )` returns a new configured client and
    /// leaves the original untouched.
    pub fn withOptions(
        self: *const Client,
        allocator: std.mem.Allocator,
        overrides: RequestOptions,
    ) !Client {
        const base_url = overrides.base_url orelse self.transport.base_url;
        const api_key = overrides.api_key orelse self.transport.api_key;
        const organization_id = overrides.organization orelse self.transport.organization;
        const project_id = overrides.project orelse self.transport.project;
        const extra_headers = overrides.extra_headers orelse self.transport.extra_headers;
        const proxy_url = overrides.proxy orelse self.transport.proxy_url;
        const transport = try transport_mod.Transport.init(allocator, .{
            .base_url = base_url,
            .api_key = api_key,
            .organization = organization_id,
            .project = project_id,
            .extra_headers = extra_headers,
            .proxy = proxy_url,
            .timeout_ms = overrides.timeout_ms orelse self.transport.timeout_ms,
            .max_retries = overrides.max_retries orelse self.transport.max_retries,
            .retry_base_delay_ms = overrides.retry_base_delay_ms orelse self.transport.retry_base_delay_ms,
        });
        return Client{
            .allocator = allocator,
            .transport = transport,
        };
    }

    pub fn with_options(
        self: *const Client,
        allocator: std.mem.Allocator,
        overrides: RequestOptions,
    ) !Client {
        return self.withOptions(allocator, overrides);
    }

    pub fn deinit(self: *Client) void {
        self.transport.deinit();
    }

    pub fn audio(self: *Client) resources.AudioResource {
        return resources.AudioResource.init(&self.transport);
    }

    pub fn audios(self: *Client) resources.AudioResource {
        return self.audio();
    }

    pub fn chat(self: *Client) resources.ChatResource {
        return resources.ChatResource.init(&self.transport);
    }

    pub fn chat_completion(self: *Client) resources.ChatResource {
        return self.chat();
    }

    pub fn chat_completions(self: *Client) resources.ChatResource {
        return self.chat();
    }

    pub fn models(self: *Client) resources.ModelsResource {
        return resources.ModelsResource.init(&self.transport);
    }

    pub fn model(self: *Client) resources.ModelsResource {
        return self.models();
    }

    pub fn files(self: *Client) resources.FilesResource {
        return resources.FilesResource.init(&self.transport);
    }

    pub fn file(self: *Client) resources.FilesResource {
        return self.files();
    }

    pub fn completions(self: *Client) resources.CompletionsResource {
        return resources.CompletionsResource.init(&self.transport);
    }

    pub fn completion(self: *Client) resources.CompletionsResource {
        return self.completions();
    }

    pub fn images(self: *Client) resources.ImagesResource {
        return resources.ImagesResource.init(&self.transport);
    }

    pub fn image(self: *Client) resources.ImagesResource {
        return self.images();
    }

    pub fn embeddings(self: *Client) resources.EmbeddingsResource {
        return resources.EmbeddingsResource.init(&self.transport);
    }

    pub fn embedding(self: *Client) resources.EmbeddingsResource {
        return self.embeddings();
    }

    pub fn moderations(self: *Client) resources.ModerationsResource {
        return resources.ModerationsResource.init(&self.transport);
    }

    pub fn moderation(self: *Client) resources.ModerationsResource {
        return self.moderations();
    }

    pub fn usage(self: *Client) resources.UsageResource {
        return resources.UsageResource.init(&self.transport);
    }

    pub fn uploads(self: *Client) resources.UploadsResource {
        return resources.UploadsResource.init(&self.transport);
    }

    pub fn upload(self: *Client) resources.UploadsResource {
        return self.uploads();
    }

    pub fn responses(self: *Client) resources.ResponsesResource {
        return resources.ResponsesResource.init(&self.transport);
    }

    pub fn response(self: *Client) resources.ResponsesResource {
        return self.responses();
    }

    pub fn batch(self: *Client) resources.BatchResource {
        return resources.BatchResource.init(&self.transport);
    }

    pub fn batches(self: *Client) resources.BatchResource {
        return resources.BatchResource.init(&self.transport);
    }

    pub fn audit_logs(self: *Client) resources.AuditLogsResource {
        return resources.AuditLogsResource.init(&self.transport);
    }

    pub fn auditlogs(self: *Client) resources.AuditLogsResource {
        return self.audit_logs();
    }

    pub fn invites(self: *Client) resources.InvitesResource {
        return resources.InvitesResource.init(&self.transport);
    }

    pub fn invite(self: *Client) resources.InvitesResource {
        return self.invites();
    }

    pub fn roles(self: *Client) resources.RolesResource {
        return resources.RolesResource.init(&self.transport);
    }

    pub fn role(self: *Client) resources.RolesResource {
        return self.roles();
    }

    pub fn users(self: *Client) resources.UsersResource {
        return resources.UsersResource.init(&self.transport);
    }

    pub fn user(self: *Client) resources.UsersResource {
        return self.users();
    }

    pub fn user_role_assignments(self: *Client) resources.UserRoleAssignmentsResource {
        return resources.UserRoleAssignmentsResource.init(&self.transport);
    }

    pub fn user_role_assignment(self: *Client) resources.UserRoleAssignmentsResource {
        return self.user_role_assignments();
    }

    pub fn group_users(self: *Client) resources.GroupUsersResource {
        return resources.GroupUsersResource.init(&self.transport);
    }

    pub fn group_user(self: *Client) resources.GroupUsersResource {
        return self.group_users();
    }

    pub fn groups(self: *Client) resources.GroupsResource {
        return resources.GroupsResource.init(&self.transport);
    }

    pub fn group(self: *Client) resources.GroupsResource {
        return self.groups();
    }

    pub fn group_role_assignments(self: *Client) resources.GroupRoleAssignmentsResource {
        return resources.GroupRoleAssignmentsResource.init(&self.transport);
    }

    pub fn group_role_assignment(self: *Client) resources.GroupRoleAssignmentsResource {
        return self.group_role_assignments();
    }

    pub fn project_groups(self: *Client) resources.ProjectGroupsResource {
        return resources.ProjectGroupsResource.init(&self.transport);
    }

    pub fn project_group(self: *Client) resources.ProjectGroupsResource {
        return self.project_groups();
    }

    pub fn project_group_role_assignments(self: *Client) resources.ProjectGroupRoleAssignmentsResource {
        return resources.ProjectGroupRoleAssignmentsResource.init(&self.transport);
    }

    pub fn project_group_role_assignment(self: *Client) resources.ProjectGroupRoleAssignmentsResource {
        return self.project_group_role_assignments();
    }

    pub fn project_user_role_assignments(self: *Client) resources.ProjectUserRoleAssignmentsResource {
        return resources.ProjectUserRoleAssignmentsResource.init(&self.transport);
    }

    pub fn project_user_role_assignment(self: *Client) resources.ProjectUserRoleAssignmentsResource {
        return self.project_user_role_assignments();
    }

    pub fn assistants(self: *Client) resources.AssistantsResource {
        return resources.AssistantsResource.init(&self.transport);
    }

    pub fn assistant(self: *Client) resources.AssistantsResource {
        return self.assistants();
    }

    pub fn threads(self: *Client) resources.AssistantsResource {
        return resources.AssistantsResource.init(&self.transport);
    }

    pub fn videos(self: *Client) resources.VideosResource {
        return resources.VideosResource.init(&self.transport);
    }

    pub fn video(self: *Client) resources.VideosResource {
        return self.videos();
    }

    pub fn fine_tuning(self: *Client) resources.FineTuningResource {
        return resources.FineTuningResource.init(&self.transport);
    }

    pub fn fine_tunings(self: *Client) resources.FineTuningResource {
        return self.fine_tuning();
    }

    pub fn defaults(self: *Client) resources.DefaultResource {
        return resources.DefaultResource.init(&self.transport);
    }

    pub fn default(self: *Client) resources.DefaultResource {
        return self.defaults();
    }

    pub fn containers(self: *Client) resources.DefaultResource {
        return self.defaults();
    }

    pub fn container(self: *Client) resources.DefaultResource {
        return self.defaults();
    }

    pub fn organization(self: *Client) resources.DefaultResource {
        return self.defaults();
    }

    pub fn org(self: *Client) resources.DefaultResource {
        return self.organization();
    }

    pub fn admin(self: *Client) resources.DefaultResource {
        return self.defaults();
    }

    pub fn admin_api_keys(self: *Client) resources.DefaultResource {
        return self.defaults();
    }

    pub fn admin_api_key(self: *Client) resources.DefaultResource {
        return self.admin_api_keys();
    }

    pub fn organization_audit_logs(self: *Client) resources.AuditLogsResource {
        return self.audit_logs();
    }

    pub fn organization_audit_log(self: *Client) resources.AuditLogsResource {
        return self.organization_audit_logs();
    }

    pub fn organization_certificates(self: *Client) resources.CertificatesResource {
        return self.certificates();
    }

    pub fn organization_certificate(self: *Client) resources.CertificatesResource {
        return self.organization_certificates();
    }

    pub fn organization_invites(self: *Client) resources.InvitesResource {
        return self.invites();
    }

    pub fn organization_invite(self: *Client) resources.InvitesResource {
        return self.organization_invites();
    }

    pub fn organization_groups(self: *Client) resources.GroupsResource {
        return self.groups();
    }

    pub fn organization_group(self: *Client) resources.GroupsResource {
        return self.organization_groups();
    }

    pub fn organization_roles(self: *Client) resources.RolesResource {
        return self.roles();
    }

    pub fn organization_role(self: *Client) resources.RolesResource {
        return self.organization_roles();
    }

    pub fn organization_users(self: *Client) resources.UsersResource {
        return self.users();
    }

    pub fn organization_user(self: *Client) resources.UsersResource {
        return self.organization_users();
    }

    pub fn organization_projects(self: *Client) resources.ProjectsResource {
        return self.projects();
    }

    pub fn organization_project(self: *Client) resources.ProjectsResource {
        return self.organization_projects();
    }

    pub fn organization_usage(self: *Client) resources.UsageResource {
        return self.usage();
    }

    pub fn organization_costs(self: *Client) resources.UsageResource {
        return self.usage();
    }

    pub fn beta(self: *Client) resources.DefaultResource {
        return self.defaults();
    }

    pub fn chatkit(self: *Client) resources.DefaultResource {
        return self.defaults();
    }

    pub fn conversations(self: *Client) resources.ConversationsResource {
        return resources.ConversationsResource.init(&self.transport);
    }

    pub fn conversation(self: *Client) resources.ConversationsResource {
        return self.conversations();
    }

    pub fn realtime(self: *Client) resources.RealtimeResource {
        return resources.RealtimeResource.init(&self.transport);
    }

    pub fn certificates(self: *Client) resources.CertificatesResource {
        return resources.CertificatesResource.init(&self.transport);
    }

    pub fn certificate(self: *Client) resources.CertificatesResource {
        return self.certificates();
    }

    pub fn evals(self: *Client) resources.EvalsResource {
        return resources.EvalsResource.init(&self.transport);
    }

    pub fn eval(self: *Client) resources.EvalsResource {
        return self.evals();
    }

    pub fn projects(self: *Client) resources.ProjectsResource {
        return resources.ProjectsResource.init(&self.transport);
    }

    pub fn project(self: *Client) resources.ProjectsResource {
        return self.projects();
    }

    pub fn vector_stores(self: *Client) resources.VectorStoresResource {
        return resources.VectorStoresResource.init(&self.transport);
    }

    pub fn vector_store(self: *Client) resources.VectorStoresResource {
        return self.vector_stores();
    }

    pub fn vectorstores(self: *Client) resources.VectorStoresResource {
        return self.vector_stores();
    }

    /// Backward-compatible snake_case transport accessor.
    pub fn raw_transport(self: *Client) *transport_mod.Transport {
        return &self.transport;
    }

    /// Backward-compatible camelCase transport accessor.
    pub fn rawTransport(self: *Client) *transport_mod.Transport {
        return self.raw_transport();
    }

    /// Simple helper to validate connectivity by calling GET /models.
    pub fn ping(self: *Client) !void {
        return self.pingWithOptions(null);
    }

    /// Validate connectivity with request overrides.
    pub fn pingWithOptions(self: *Client, request_opts: ?RequestOptions) !void {
        const transport_opts: ?transport_mod.Transport.RequestOptions = if (request_opts) |opts|
            .{
                .base_url = opts.base_url,
                .api_key = opts.api_key,
                .organization = opts.organization,
                .project = opts.project,
                .timeout_ms = opts.timeout_ms,
                .max_retries = opts.max_retries,
                .retry_base_delay_ms = opts.retry_base_delay_ms,
                .extra_headers = opts.extra_headers,
            }
        else
            null;

        const resp = try self.transport.requestWithOptions(.GET, "/models", &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null, transport_opts);
        self.transport.allocator.free(resp.body);
    }

    /// Backward-compatible snake_case name for `pingWithOptions`.
    pub fn ping_with_options(self: *Client, request_opts: ?RequestOptions) !void {
        return self.pingWithOptions(request_opts);
    }
};

test "with_options overrides selected transport fields" {
    const gpa = std.heap.page_allocator;

    var base_client = try Client.init(gpa, .{
        .base_url = "https://api.openai.com/v1",
        .api_key = "base-key",
        .organization = "org-base",
        .project = "project-base",
        .timeout_ms = 111,
        .max_retries = 3,
        .retry_base_delay_ms = 200,
    });
    defer base_client.deinit();

    var with_override = try base_client.with_options(gpa, .{
        .base_url = "https://api.deepseek.com/v1",
        .api_key = "override-key",
        .organization = "org-override",
        .project = "project-override",
        .max_retries = 7,
    });
    defer with_override.deinit();

    const base_transport = base_client.transport;
    const override_transport = with_override.transport;

    try std.testing.expectEqualStrings("https://api.openai.com/v1", base_transport.base_url);
    try std.testing.expectEqualStrings("base-key", base_transport.api_key.?);
    try std.testing.expectEqualStrings("org-base", base_transport.organization.?);
    try std.testing.expectEqualStrings("project-base", base_transport.project.?);
    try std.testing.expectEqual(@as(u8, 3), base_transport.max_retries);
    try std.testing.expectEqual(@as(u64, 200), base_transport.retry_base_delay_ms);

    try std.testing.expectEqualStrings("https://api.deepseek.com/v1", override_transport.base_url);
    try std.testing.expectEqualStrings("override-key", override_transport.api_key.?);
    try std.testing.expectEqualStrings("org-override", override_transport.organization.?);
    try std.testing.expectEqualStrings("project-override", override_transport.project.?);
    try std.testing.expectEqual(@as(u8, 7), override_transport.max_retries);
    try std.testing.expectEqual(@as(u64, 200), override_transport.retry_base_delay_ms);

    var with_fallback = try base_client.with_options(gpa, .{
        .base_url = null,
        .api_key = null,
        .organization = null,
        .project = null,
        .max_retries = null,
    });
    defer with_fallback.deinit();

    const fallback_transport = with_fallback.transport;
    try std.testing.expectEqualStrings(base_transport.base_url, fallback_transport.base_url);
    try std.testing.expectEqualStrings(base_transport.api_key.?, fallback_transport.api_key.?);
    try std.testing.expectEqual(base_transport.max_retries, fallback_transport.max_retries);
}
