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

    /// POST /embeddings -> dynamic JSON
    pub fn create_embedding(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: gen.CreateEmbeddingRequest,
    ) errors.Error!std.json.Parsed(gen.CreateEmbeddingResponse) {
        return common.sendJsonTyped(
            self.transport,
            allocator,
            .POST,
            "/embeddings",
            req,
            gen.CreateEmbeddingResponse,
        );
    }

    pub fn create_embedding_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: gen.CreateEmbeddingRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CreateEmbeddingResponse) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            "/embeddings",
            req,
            gen.CreateEmbeddingResponse,
            request_opts,
        );
    }

    /// POST /embeddings -> dynamic JSON
    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: gen.CreateEmbeddingRequest,
    ) errors.Error!std.json.Parsed(gen.CreateEmbeddingResponse) {
        return self.create_embedding(allocator, req);
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: gen.CreateEmbeddingRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CreateEmbeddingResponse) {
        return self.create_embedding_with_options(allocator, req, request_opts);
    }
};
