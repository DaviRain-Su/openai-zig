const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const CreateBatchRequest = struct {
    input_file_id: []const u8,
    endpoint: []const u8,
    completion_window: []const u8 = "24h",
    metadata: ?std.json.Value = null,
    output_expires_after: ?std.json.Value = null,
    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateBatchRequest,
    ) errors.Error!std.json.Parsed(gen.Batch) {
        return self.create_batch(allocator, req);
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateBatchRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Batch) {
        return self.create_batch_with_options(allocator, req, request_opts);
    }

    pub fn list(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListBatchesParams,
    ) errors.Error!std.json.Parsed(gen.ListBatchesResponse) {
        return self.list_batches(allocator, params);
    }

    pub fn list_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListBatchesParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListBatchesResponse) {
        return self.list_batches_with_options(allocator, params, request_opts);
    }

    pub fn retrieve(
        self: *const Resource,
        allocator: std.mem.Allocator,
        batch_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Batch) {
        return self.retrieve_batch(allocator, batch_id);
    }

    pub fn retrieve_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        batch_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Batch) {
        return self.retrieve_batch_with_options(allocator, batch_id, request_opts);
    }

    pub fn cancel(
        self: *const Resource,
        allocator: std.mem.Allocator,
        batch_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Batch) {
        return self.cancel_batch(allocator, batch_id);
    }

    pub fn cancel_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        batch_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Batch) {
        return self.cancel_batch_with_options(allocator, batch_id, request_opts);
    }
};

pub const ListBatchesParams = struct {
    after: ?[]const u8 = null,
    limit: ?u32 = null,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    /// POST /batches
    pub fn create_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateBatchRequest,
    ) errors.Error!std.json.Parsed(gen.Batch) {
        return self.create_batch_with_options(allocator, req, null);
    }

    pub fn create_batch_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateBatchRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Batch) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            "/batches",
            req,
            gen.Batch,
            request_opts,
        );
    }

    /// GET /batches
    pub fn list_batches(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListBatchesParams,
    ) errors.Error!std.json.Parsed(gen.ListBatchesResponse) {
        return self.list_batches_with_options(allocator, params, null);
    }

    pub fn list_batches_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListBatchesParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListBatchesResponse) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const writer = fbs.writer();
        writer.writeAll("/batches") catch {
            return errors.Error.SerializeError;
        };

        var first = true;
        try common.appendOptionalQueryParam(writer, &first, "after", params.after);
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, &first, "limit", @as(u64, limit));
        }
        const path = fbs.getWritten();

        return common.sendNoBodyTypedWithOptions(self.transport, allocator, .GET, path, gen.ListBatchesResponse, request_opts);
    }

    /// GET /batches/{batch_id}
    pub fn retrieve_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        batch_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Batch) {
        return self.retrieve_batch_with_options(allocator, batch_id, null);
    }

    pub fn retrieve_batch_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        batch_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Batch) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/batches/{s}", .{batch_id}) catch {
            return errors.Error.SerializeError;
        };
        return common.sendNoBodyTypedWithOptions(self.transport, allocator, .GET, path, gen.Batch, request_opts);
    }

    /// POST /batches/{batch_id}/cancel
    pub fn cancel_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        batch_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Batch) {
        return self.cancel_batch_with_options(allocator, batch_id, null);
    }

    pub fn cancel_batch_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        batch_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Batch) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/batches/{s}/cancel", .{batch_id}) catch {
            return errors.Error.SerializeError;
        };
        return common.sendNoBodyTypedWithOptions(self.transport, allocator, .POST, path, gen.Batch, request_opts);
    }
};
