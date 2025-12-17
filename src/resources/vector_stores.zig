const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");

pub const ListParams = struct {
    limit: ?u32 = null,
    order: ?[]const u8 = null,
    after: ?[]const u8 = null,
    before: ?[]const u8 = null,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn appendListParams(writer: anytype, params: ListParams, sep_start: []const u8) !void {
        var sep = sep_start;
        if (params.limit) |limit| {
            try writer.print("{s}limit={d}", .{ sep, limit });
            sep = "&";
        }
        if (params.order) |order| {
            try writer.print("{s}order={s}", .{ sep, order });
            sep = "&";
        }
        if (params.after) |after| {
            try writer.print("{s}after={s}", .{ sep, after });
            sep = "&";
        }
        if (params.before) |before| {
            try writer.print("{s}before={s}", .{ sep, before });
        }
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

        const parsed = std.json.parseFromSlice(T, allocator, body, .{}) catch {
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

        const parsed = std.json.parseFromSlice(T, allocator, body, .{}) catch {
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
        try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ListVectorStoresResponse);
    }

    pub fn create_vector_store(self: *const Resource, allocator: std.mem.Allocator, body: gen.CreateVectorStoreRequest) errors.Error!std.json.Parsed(gen.VectorStoreObject) {
        return self.sendJsonTyped(allocator, .POST, "/vector_stores", body, gen.VectorStoreObject);
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

    pub fn list_files_in_vector_store_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        batch_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        var buf: [340]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/vector_stores/{s}/file_batches/{s}/files", .{ vector_store_id, batch_id });
        try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.VectorStoreFileObject);
    }

    /// Files
    pub fn list_vector_store_files(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.VectorStoreFileObject) {
        var buf: [260]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/vector_stores/{s}/files", .{vector_store_id});
        try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
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

    /// Search
    pub fn search_vector_store(
        self: *const Resource,
        allocator: std.mem.Allocator,
        vector_store_id: []const u8,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [260]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/vector_stores/{s}/search", .{vector_store_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, body);
    }
};
