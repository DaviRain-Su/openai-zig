const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const ListParams = struct {
    limit: ?u32 = null,
    order: ?[]const u8 = null,
    after: ?[]const u8 = null,
    before: ?[]const u8 = null,
};

pub const ListVectorStoreFilesParams = struct {
    limit: ?u32 = null,
    order: ?[]const u8 = null,
    after: ?[]const u8 = null,
    before: ?[]const u8 = null,
    filter: ?[]const u8 = null,
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
        try common.appendOptionalQueryParam(writer, first, "order", params.order);
        try common.appendOptionalQueryParam(writer, first, "after", params.after);
        try common.appendOptionalQueryParam(writer, first, "before", params.before);
    }

    fn appendListVectorStoreFilesParams(writer: anytype, params: ListVectorStoreFilesParams, first: *bool) !void {
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, first, "limit", @as(u64, limit));
        }
        try common.appendOptionalQueryParam(writer, first, "order", params.order);
        try common.appendOptionalQueryParam(writer, first, "after", params.after);
        try common.appendOptionalQueryParam(writer, first, "before", params.before);
        try common.appendOptionalQueryParam(writer, first, "filter", params.filter);
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

        const parsed = std.json.parseFromSlice(T, allocator, body, .{ .ignore_unknown_fields = true }) catch {
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

        const parsed = std.json.parseFromSlice(T, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// Vector stores
    pub fn list_vector_stores(self: *const Resource, allocator: std.mem.Allocator, params: ListParams) errors.Error!std.json.Parsed(gen.ListVectorStoresResponse) {
        var buf: [200]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/vector_stores");
        var first = true;
        try appendListParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ListVectorStoresResponse);
    }

    /// Vector stores
    pub fn list(self: *const Resource, allocator: std.mem.Allocator, params: ListParams) errors.Error!std.json.Parsed(gen.ListVectorStoresResponse) {
        return self.list_vector_stores(allocator, params);
    }

    pub fn create_vector_store(self: *const Resource, allocator: std.mem.Allocator, body: gen.CreateVectorStoreRequest) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.sendJsonTyped(allocator, .POST, "/vector_stores", body, gen.VectorStoreObject);
    }

    /// Vector stores
    pub fn create(self: *const Resource, allocator: std.mem.Allocator, body: gen.CreateVectorStoreRequest) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.create_vector_store(allocator, body);
    }

    pub fn get_vector_store(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}", .{vector_store_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .GET, path, gen.VectorStoreObject);
    }

    /// Vector stores
    pub fn get(self: *const Resource, allocator: std.mem.Allocator, vector_store_id: []const u8) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.get_vector_store(allocator, vector_store_id);
    }

    /// Vector stores
    pub fn retrieve(self: *const Resource, allocator: std.mem.Allocator, vector_store_id: []const u8) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.get_vector_store(allocator, vector_store_id);
    }

    pub fn modify_vector_store(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.UpdateVectorStoreRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}", .{vector_store_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.VectorStoreObject);
    }

    /// Vector stores
    pub fn modify(self: *const Resource, allocator: std.mem.Allocator, vector_store_id: []const u8, body: gen.UpdateVectorStoreRequest) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.modify_vector_store(allocator, vector_store_id, body);
    }

    pub fn delete_vector_store(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteVectorStoreResponse) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}", .{vector_store_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .DELETE, path, gen.DeleteVectorStoreResponse);
    }

    /// Vector stores
    pub fn delete(self: *const Resource, allocator: std.mem.Allocator, vector_store_id: []const u8) errors.Error!std.json.Parsed(gen.DeleteVectorStoreResponse) {
        return self.delete_vector_store(allocator, vector_store_id);
    }

    /// File batches
    pub fn create_vector_store_file_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.CreateVectorStoreFileBatchRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileBatchObject) {
        var buf: [260]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/file_batches", .{vector_store_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.VectorStoreFileBatchObject);
    }

    /// File batches
    pub fn create_file_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.CreateVectorStoreFileBatchRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileBatchObject) {
        return self.create_vector_store_file_batch(allocator, vector_store_id, body);
    }

    pub fn get_vector_store_file_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        batch_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileBatchObject) {
        var buf: [300]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/file_batches/{s}", .{ vector_store_id, batch_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .GET, path, gen.VectorStoreFileBatchObject);
    }

    /// File batches
    pub fn get_file_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        batch_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileBatchObject) {
        return self.get_vector_store_file_batch(allocator, vector_store_id, batch_id);
    }

    pub fn cancel_vector_store_file_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        batch_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileBatchObject) {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/file_batches/{s}/cancel", .{ vector_store_id, batch_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .POST, path, gen.VectorStoreFileBatchObject);
    }

    /// File batches
    pub fn cancel_file_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        batch_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileBatchObject) {
        return self.cancel_vector_store_file_batch(allocator, vector_store_id, batch_id);
    }

    pub fn list_files_in_vector_store_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        batch_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ListVectorStoreFilesResponse) {
        var buf: [340]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/vector_stores/{s}/file_batches/{s}/files", .{ vector_store_id, batch_id });
        var first = true;
        try appendListParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ListVectorStoreFilesResponse);
    }

    /// Files
    pub fn list_vector_store_files(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        params: ListVectorStoreFilesParams,
    ) errors.Error!std.json.Parsed(gen.ListVectorStoreFilesResponse) {
        var buf: [260]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/vector_stores/{s}/files", .{vector_store_id});
        var first = true;
        try appendListVectorStoreFilesParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ListVectorStoreFilesResponse);
    }

    /// Files
    pub fn list_files(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        params: ListVectorStoreFilesParams,
    ) errors.Error!std.json.Parsed(gen.ListVectorStoreFilesResponse) {
        return self.list_vector_store_files(allocator, vector_store_id, params);
    }

    pub fn create_vector_store_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.CreateVectorStoreFileRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        var buf: [260]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/files", .{vector_store_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.VectorStoreFileObject);
    }

    /// Files
    pub fn create_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.CreateVectorStoreFileRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        return self.create_vector_store_file(allocator, vector_store_id, body);
    }

    pub fn get_vector_store_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        var buf: [300]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/files/{s}", .{ vector_store_id, file_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .GET, path, gen.VectorStoreFileObject);
    }

    /// Files
    pub fn get_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        return self.get_vector_store_file(allocator, vector_store_id, file_id);
    }

    /// Files
    pub fn retrieve_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        return self.get_vector_store_file(allocator, vector_store_id, file_id);
    }

    pub fn delete_vector_store_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteVectorStoreFileResponse) {
        var buf: [300]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/files/{s}", .{ vector_store_id, file_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .DELETE, path, gen.DeleteVectorStoreFileResponse);
    }

    /// Files
    pub fn delete_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteVectorStoreFileResponse) {
        return self.delete_vector_store_file(allocator, vector_store_id, file_id);
    }

    pub fn update_vector_store_file_attributes(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
        body: gen.UpdateVectorStoreFileRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/files/{s}", .{ vector_store_id, file_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.VectorStoreFileObject);
    }

    /// Files
    pub fn update_file_attributes(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
        body: gen.UpdateVectorStoreFileRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        return self.update_vector_store_file_attributes(allocator, vector_store_id, file_id, body);
    }

    /// Files
    pub fn update_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
        body: gen.UpdateVectorStoreFileRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        return self.update_vector_store_file_attributes(allocator, vector_store_id, file_id, body);
    }

    pub fn retrieve_vector_store_file_content(
        self: *const Resource,
        vector_store_id: []const u8,
        file_id: []const u8,
    ) errors.Error![]u8 {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/files/{s}/content", .{ vector_store_id, file_id }) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.GET, path, &.{}, null);
        return resp.body; // caller owns the body
    }

    /// Files
    pub fn retrieve_file_content(
        self: *const Resource,
        vector_store_id: []const u8,
        file_id: []const u8,
    ) errors.Error![]u8 {
        return self.retrieve_vector_store_file_content(vector_store_id, file_id);
    }

    /// Files
    pub fn content(
        self: *const Resource,
        vector_store_id: []const u8,
        file_id: []const u8,
    ) errors.Error![]u8 {
        return self.retrieve_vector_store_file_content(vector_store_id, file_id);
    }

    /// Search
    pub fn search_vector_store(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.VectorStoreSearchRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreSearchResultsPage) {
        var buf: [260]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/search", .{vector_store_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.VectorStoreSearchResultsPage);
    }

    /// Search
    pub fn search(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.VectorStoreSearchRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreSearchResultsPage) {
        return self.search_vector_store(allocator, vector_store_id, body);
    }
};
