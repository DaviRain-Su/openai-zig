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
        proxy: ?[]const u8 = null,
        timeout_ms: ?u64 = null,
    };

    pub fn init(allocator: std.mem.Allocator, opts: Options) !Client {
        const transport = try transport_mod.Transport.init(allocator, .{
            .base_url = opts.base_url,
            .api_key = opts.api_key,
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

    pub fn chat(self: *Client) resources.ChatResource {
        return resources.ChatResource.init(&self.transport);
    }

    pub fn models(self: *Client) resources.ModelsResource {
        return resources.ModelsResource.init(&self.transport);
    }

    pub fn files(self: *Client) resources.FilesResource {
        return resources.FilesResource.init(&self.transport);
    }

    pub fn completions(self: *Client) resources.CompletionsResource {
        return resources.CompletionsResource.init(&self.transport);
    }

    pub fn embeddings(self: *Client) resources.EmbeddingsResource {
        return resources.EmbeddingsResource.init(&self.transport);
    }

    pub fn images(self: *Client) resources.ImagesResource {
        return resources.ImagesResource.init(&self.transport);
    }

    pub fn moderations(self: *Client) resources.ModerationsResource {
        return resources.ModerationsResource.init(&self.transport);
    }

    pub fn usage(self: *Client) resources.UsageResource {
        return resources.UsageResource.init(&self.transport);
    }

    pub fn uploads(self: *Client) resources.UploadsResource {
        return resources.UploadsResource.init(&self.transport);
    }

    pub fn responses(self: *Client) resources.ResponsesResource {
        return resources.ResponsesResource.init(&self.transport);
    }

    pub fn batch(self: *Client) resources.BatchResource {
        return resources.BatchResource.init(&self.transport);
    }

    pub fn audit_logs(self: *Client) resources.AuditLogsResource {
        return resources.AuditLogsResource.init(&self.transport);
    }

    pub fn invites(self: *Client) resources.InvitesResource {
        return resources.InvitesResource.init(&self.transport);
    }

    pub fn roles(self: *Client) resources.RolesResource {
        return resources.RolesResource.init(&self.transport);
    }

    pub fn users(self: *Client) resources.UsersResource {
        return resources.UsersResource.init(&self.transport);
    }

    pub fn user_role_assignments(self: *Client) resources.UserRoleAssignmentsResource {
        return resources.UserRoleAssignmentsResource.init(&self.transport);
    }

    pub fn group_users(self: *Client) resources.GroupUsersResource {
        return resources.GroupUsersResource.init(&self.transport);
    }

    pub fn groups(self: *Client) resources.GroupsResource {
        return resources.GroupsResource.init(&self.transport);
    }

    pub fn group_role_assignments(self: *Client) resources.GroupRoleAssignmentsResource {
        return resources.GroupRoleAssignmentsResource.init(&self.transport);
    }

    pub fn project_groups(self: *Client) resources.ProjectGroupsResource {
        return resources.ProjectGroupsResource.init(&self.transport);
    }

    pub fn project_group_role_assignments(self: *Client) resources.ProjectGroupRoleAssignmentsResource {
        return resources.ProjectGroupRoleAssignmentsResource.init(&self.transport);
    }

    pub fn project_user_role_assignments(self: *Client) resources.ProjectUserRoleAssignmentsResource {
        return resources.ProjectUserRoleAssignmentsResource.init(&self.transport);
    }

    pub fn assistants(self: *Client) resources.AssistantsResource {
        return resources.AssistantsResource.init(&self.transport);
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
