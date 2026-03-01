const std = @import("std");
const errors = @import("errors.zig");
const transport_mod = @import("transport/http.zig");
const resources = @import("resources.zig");

pub const Client = struct {
    allocator: std.mem.Allocator,
    transport: transport_mod.Transport,

    pub const Options = struct {
        base_url: []const u8,
        api_key: ?[]const u8 = null,
        extra_headers: ?[]const std.http.Header = null,
        proxy: ?[]const u8 = null,
        timeout_ms: ?u64 = null,
    };

    pub fn init(allocator: std.mem.Allocator, opts: Options) !Client {
        const transport = try transport_mod.Transport.init(allocator, .{
            .base_url = opts.base_url,
            .api_key = opts.api_key,
            .extra_headers = opts.extra_headers,
            .proxy = opts.proxy,
            .timeout_ms = opts.timeout_ms,
        });
        return Client{
            .allocator = allocator,
            .transport = transport,
        };
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

    pub fn rawTransport(self: *Client) *transport_mod.Transport {
        return &self.transport;
    }

    /// Simple helper to validate connectivity by calling GET /models (stubbed).
    pub fn ping(self: *Client) !void {
        const resp = try self.transport.request(.GET, "/models", &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        self.transport.allocator.free(resp.body);
    }
};
