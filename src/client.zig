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
