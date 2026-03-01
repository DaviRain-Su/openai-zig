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

    /// POST /completions -> dynamic JSON
    pub fn create_completion(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: gen.CreateCompletionRequest,
    ) errors.Error!std.json.Parsed(gen.CreateCompletionResponse) {
        return common.sendJsonTyped(
            self.transport,
            allocator,
            .POST,
            "/completions",
            req,
            gen.CreateCompletionResponse,
        );
    }

    pub fn create_completion_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: gen.CreateCompletionRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CreateCompletionResponse) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            "/completions",
            req,
            gen.CreateCompletionResponse,
            request_opts,
        );
    }

    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: gen.CreateCompletionRequest,
    ) errors.Error!std.json.Parsed(gen.CreateCompletionResponse) {
        return self.create_completion(allocator, req);
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: gen.CreateCompletionRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CreateCompletionResponse) {
        return self.create_completion_with_options(allocator, req, request_opts);
    }
};
