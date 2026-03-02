const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    /// POST /moderations -> dynamic JSON
    pub fn create_moderation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: gen.CreateModerationRequest,
    ) errors.Error!std.json.Parsed(gen.CreateModerationResponse) {
        return common.sendJsonTyped(
            self.transport,
            allocator,
            .POST,
            "/moderations",
            req,
            gen.CreateModerationResponse,
        );
    }

    pub fn create_moderation_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: gen.CreateModerationRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CreateModerationResponse) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            "/moderations",
            req,
            gen.CreateModerationResponse,
            request_opts,
        );
    }

    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: gen.CreateModerationRequest,
    ) errors.Error!std.json.Parsed(gen.CreateModerationResponse) {
        return self.create_moderation(allocator, req);
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: gen.CreateModerationRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CreateModerationResponse) {
        return self.create_moderation_with_options(allocator, req, request_opts);
    }
};
