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
        return self.sendJsonTypedWithOptions(allocator, method, path, value, T, null);
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
        return common.sendJsonTypedWithOptions(self.transport, allocator, method, path, value, T, request_opts);
    }

    fn sendNoBodyTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        return self.sendNoBodyTypedWithOptions(allocator, method, path, T, null);
    }

    fn sendNoBodyTypedWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendNoBodyTypedWithOptions(self.transport, allocator, method, path, T, request_opts);
    }

    fn sendBinary(
        self: *const Resource,
        method: std.http.Method,
        path: []const u8,
    ) errors.Error![]u8 {
        return self.sendBinaryWithOptions(method, path, null);
    }

    fn sendBinaryWithOptions(
        self: *const Resource,
        method: std.http.Method,
        path: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error![]u8 {
        return try common.sendBinaryWithOptions(
            self.transport,
            method,
            path,
            &.{},
            null,
            request_opts,
        );
    }

    /// Vector stores
    pub fn list_vector_stores(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ListVectorStoresResponse) {
        return self.list_vector_stores_with_options(allocator, params, null);
    }

    pub fn list_vector_stores_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListVectorStoresResponse) {
        var path_writer = std.io.Writer.Allocating.init(allocator);
        defer path_writer.deinit();

        path_writer.writer.writeAll("/vector_stores") catch {
            return errors.Error.SerializeError;
        };
        var first = true;
        appendListParams(&path_writer.writer, params, &first) catch {
            return errors.Error.SerializeError;
        };
        const path = path_writer.written();
        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.ListVectorStoresResponse, request_opts);
    }

    /// Vector stores
    pub fn list(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ListVectorStoresResponse) {
        return self.list_vector_stores(allocator, params);
    }

    pub fn list_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListVectorStoresResponse) {
        return self.list_vector_stores_with_options(allocator, params, request_opts);
    }

    pub fn create_vector_store(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateVectorStoreRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.create_vector_store_with_options(allocator, body, null);
    }

    pub fn create_vector_store_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateVectorStoreRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.sendJsonTypedWithOptions(allocator, .POST, "/vector_stores", body, gen.VectorStoreObject, request_opts);
    }

    /// Vector stores
    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateVectorStoreRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.create_vector_store(allocator, body);
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateVectorStoreRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.create_vector_store_with_options(allocator, body, request_opts);
    }

    pub fn get_vector_store(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.get_vector_store_with_options(allocator, vector_store_id, null);
    }

    pub fn get_vector_store_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}", .{vector_store_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.VectorStoreObject, request_opts);
    }

    /// Vector stores
    pub fn get(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.get_vector_store(allocator, vector_store_id);
    }

    pub fn get_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.get_vector_store_with_options(allocator, vector_store_id, request_opts);
    }

    pub fn retrieve(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.get_vector_store(allocator, vector_store_id);
    }

    pub fn retrieve_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.get_vector_store_with_options(allocator, vector_store_id, request_opts);
    }

    pub fn modify_vector_store(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.UpdateVectorStoreRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.modify_vector_store_with_options(allocator, vector_store_id, body, null);
    }

    pub fn modify_vector_store_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.UpdateVectorStoreRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}", .{vector_store_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(allocator, .POST, path, body, gen.VectorStoreObject, request_opts);
    }

    /// Vector stores
    pub fn modify(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.UpdateVectorStoreRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.modify_vector_store(allocator, vector_store_id, body);
    }

    pub fn modify_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.UpdateVectorStoreRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.modify_vector_store_with_options(allocator, vector_store_id, body, request_opts);
    }

    pub fn delete_vector_store(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteVectorStoreResponse) {
        return self.delete_vector_store_with_options(allocator, vector_store_id, null);
    }

    pub fn delete_vector_store_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeleteVectorStoreResponse) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}", .{vector_store_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .DELETE, path, gen.DeleteVectorStoreResponse, request_opts);
    }

    /// Vector stores
    pub fn delete(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteVectorStoreResponse) {
        return self.delete_vector_store(allocator, vector_store_id);
    }

    pub fn delete_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeleteVectorStoreResponse) {
        return self.delete_vector_store_with_options(allocator, vector_store_id, request_opts);
    }

    /// File batches
    pub fn create_vector_store_file_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.CreateVectorStoreFileBatchRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileBatchObject) {
        return self.create_vector_store_file_batch_with_options(allocator, vector_store_id, body, null);
    }

    pub fn create_vector_store_file_batch_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.CreateVectorStoreFileBatchRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileBatchObject) {
        var buf: [260]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/file_batches", .{vector_store_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.VectorStoreFileBatchObject,
            request_opts,
        );
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

    pub fn create_file_batch_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.CreateVectorStoreFileBatchRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileBatchObject) {
        return self.create_vector_store_file_batch_with_options(allocator, vector_store_id, body, request_opts);
    }

    pub fn get_vector_store_file_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        batch_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileBatchObject) {
        return self.get_vector_store_file_batch_with_options(allocator, vector_store_id, batch_id, null);
    }

    pub fn get_vector_store_file_batch_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        batch_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileBatchObject) {
        var buf: [300]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/file_batches/{s}", .{ vector_store_id, batch_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.VectorStoreFileBatchObject, request_opts);
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

    pub fn get_file_batch_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        batch_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileBatchObject) {
        return self.get_vector_store_file_batch_with_options(allocator, vector_store_id, batch_id, request_opts);
    }

    pub fn cancel_vector_store_file_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        batch_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileBatchObject) {
        return self.cancel_vector_store_file_batch_with_options(allocator, vector_store_id, batch_id, null);
    }

    pub fn cancel_vector_store_file_batch_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        batch_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileBatchObject) {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/file_batches/{s}/cancel", .{ vector_store_id, batch_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .POST, path, gen.VectorStoreFileBatchObject, request_opts);
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

    pub fn cancel_file_batch_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        batch_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileBatchObject) {
        return self.cancel_vector_store_file_batch_with_options(allocator, vector_store_id, batch_id, request_opts);
    }

    pub fn list_files_in_vector_store_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        batch_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ListVectorStoreFilesResponse) {
        return self.list_files_in_vector_store_batch_with_options(allocator, vector_store_id, batch_id, params, null);
    }

    pub fn list_files_in_vector_store_batch_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        batch_id: []const u8,
        params: ListParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListVectorStoreFilesResponse) {
        var buf: [340]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/vector_stores/{s}/file_batches/{s}/files", .{ vector_store_id, batch_id });
        var first = true;
        try appendListParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.ListVectorStoreFilesResponse, request_opts);
    }

    pub fn list_files_in_vector_store_batch_with_options_alias(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        batch_id: []const u8,
        params: ListParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListVectorStoreFilesResponse) {
        return self.list_files_in_vector_store_batch_with_options(allocator, vector_store_id, batch_id, params, request_opts);
    }

    /// Files
    pub fn list_vector_store_files(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        params: ListVectorStoreFilesParams,
    ) errors.Error!std.json.Parsed(gen.ListVectorStoreFilesResponse) {
        return self.list_vector_store_files_with_options(allocator, vector_store_id, params, null);
    }

    pub fn list_vector_store_files_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        params: ListVectorStoreFilesParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListVectorStoreFilesResponse) {
        var buf: [260]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/vector_stores/{s}/files", .{vector_store_id});
        var first = true;
        try appendListVectorStoreFilesParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.ListVectorStoreFilesResponse, request_opts);
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

    pub fn list_files_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        params: ListVectorStoreFilesParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListVectorStoreFilesResponse) {
        return self.list_vector_store_files_with_options(allocator, vector_store_id, params, request_opts);
    }

    pub fn create_vector_store_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.CreateVectorStoreFileRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        return self.create_vector_store_file_with_options(allocator, vector_store_id, body, null);
    }

    pub fn create_vector_store_file_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.CreateVectorStoreFileRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        var buf: [260]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/files", .{vector_store_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(allocator, .POST, path, body, gen.VectorStoreFileObject, request_opts);
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

    pub fn create_file_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.CreateVectorStoreFileRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        return self.create_vector_store_file_with_options(allocator, vector_store_id, body, request_opts);
    }

    pub fn get_vector_store_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        return self.get_vector_store_file_with_options(allocator, vector_store_id, file_id, null);
    }

    pub fn get_vector_store_file_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        var buf: [300]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/files/{s}", .{ vector_store_id, file_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.VectorStoreFileObject, request_opts);
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

    pub fn get_file_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        return self.get_vector_store_file_with_options(allocator, vector_store_id, file_id, request_opts);
    }

    pub fn retrieve_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        return self.get_vector_store_file(allocator, vector_store_id, file_id);
    }

    pub fn retrieve_file_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        return self.get_vector_store_file_with_options(allocator, vector_store_id, file_id, request_opts);
    }

    pub fn delete_vector_store_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteVectorStoreFileResponse) {
        return self.delete_vector_store_file_with_options(allocator, vector_store_id, file_id, null);
    }

    pub fn delete_vector_store_file_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeleteVectorStoreFileResponse) {
        var buf: [300]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/files/{s}", .{ vector_store_id, file_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .DELETE, path, gen.DeleteVectorStoreFileResponse, request_opts);
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

    pub fn delete_file_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeleteVectorStoreFileResponse) {
        return self.delete_vector_store_file_with_options(allocator, vector_store_id, file_id, request_opts);
    }

    pub fn update_vector_store_file_attributes(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
        body: gen.UpdateVectorStoreFileRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        return self.update_vector_store_file_attributes_with_options(allocator, vector_store_id, file_id, body, null);
    }

    pub fn update_vector_store_file_attributes_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
        body: gen.UpdateVectorStoreFileRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/files/{s}", .{ vector_store_id, file_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(allocator, .POST, path, body, gen.VectorStoreFileObject, request_opts);
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

    pub fn update_file_attributes_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
        body: gen.UpdateVectorStoreFileRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        return self.update_vector_store_file_attributes_with_options(allocator, vector_store_id, file_id, body, request_opts);
    }

    pub fn update_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
        body: gen.UpdateVectorStoreFileRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        return self.update_vector_store_file_attributes(allocator, vector_store_id, file_id, body);
    }

    pub fn update_file_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        file_id: []const u8,
        body: gen.UpdateVectorStoreFileRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        return self.update_vector_store_file_attributes_with_options(allocator, vector_store_id, file_id, body, request_opts);
    }

    pub fn retrieve_vector_store_file_content(
        self: *const Resource,
        vector_store_id: []const u8,
        file_id: []const u8,
    ) errors.Error![]u8 {
        return self.retrieve_vector_store_file_content_with_options(vector_store_id, file_id, null);
    }

    pub fn retrieve_vector_store_file_content_with_options(
        self: *const Resource,
        vector_store_id: []const u8,
        file_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error![]u8 {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/files/{s}/content", .{ vector_store_id, file_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendBinaryWithOptions(.GET, path, request_opts);
    }

    /// Files
    pub fn retrieve_file_content(
        self: *const Resource,
        vector_store_id: []const u8,
        file_id: []const u8,
    ) errors.Error![]u8 {
        return self.retrieve_vector_store_file_content(vector_store_id, file_id);
    }

    pub fn retrieve_file_content_with_options(
        self: *const Resource,
        vector_store_id: []const u8,
        file_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error![]u8 {
        return self.retrieve_vector_store_file_content_with_options(vector_store_id, file_id, request_opts);
    }

    /// Files
    pub fn content(
        self: *const Resource,
        vector_store_id: []const u8,
        file_id: []const u8,
    ) errors.Error![]u8 {
        return self.retrieve_vector_store_file_content(vector_store_id, file_id);
    }

    pub fn content_with_options(
        self: *const Resource,
        vector_store_id: []const u8,
        file_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error![]u8 {
        return self.retrieve_vector_store_file_content_with_options(vector_store_id, file_id, request_opts);
    }

    /// Search
    pub fn search_vector_store(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.VectorStoreSearchRequest,
    ) errors.Error!std.json.Parsed(gen.VectorStoreSearchResultsPage) {
        return self.search_vector_store_with_options(allocator, vector_store_id, body, null);
    }

    pub fn search_vector_store_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.VectorStoreSearchRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreSearchResultsPage) {
        var buf: [260]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/search", .{vector_store_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.VectorStoreSearchResultsPage,
            request_opts,
        );
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

    pub fn search_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: gen.VectorStoreSearchRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VectorStoreSearchResultsPage) {
        return self.search_vector_store_with_options(allocator, vector_store_id, body, request_opts);
    }
};
