const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const MultipartRequest = struct {
    content_type: []const u8,
    body: []const u8,
};

pub const BinaryResponse = struct {
    allocator: std.mem.Allocator,
    data: []u8,

    pub fn deinit(self: *BinaryResponse) void {
        self.allocator.free(self.data);
    }
};

pub const ListFilesParams = struct {
    purpose: ?[]const u8 = null,
    limit: ?u32 = null,
    order: ?[]const u8 = null,
    after: ?[]const u8 = null,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    /// GET /files
    pub fn list_files(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListFilesParams,
    ) errors.Error!std.json.Parsed(gen.ListFilesResponse) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        var writer = fbs.writer();
        writer.writeAll("/files") catch {
            return errors.Error.SerializeError;
        };

        var first = true;
        if (params.purpose) |purpose| {
            try common.appendQueryParam(writer, &first, "purpose", purpose);
        }
        if (params.limit) |limit| {
            var value_buf: [32]u8 = undefined;
            const value = std.fmt.bufPrint(&value_buf, "{d}", .{limit}) catch {
                return errors.Error.SerializeError;
            };
            try common.appendQueryParam(writer, &first, "limit", value);
        }
        if (params.order) |order| {
            try common.appendQueryParam(writer, &first, "order", order);
        }
        if (params.after) |after| {
            try common.appendQueryParam(writer, &first, "after", after);
        }
        const path = fbs.getWritten();
        return common.sendNoBodyTyped(self.transport, allocator, .GET, path, gen.ListFilesResponse);
    }

    pub fn list_files_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListFilesParams,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListFilesResponse) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        var writer = fbs.writer();
        writer.writeAll("/files") catch {
            return errors.Error.SerializeError;
        };

        var first = true;
        if (params.purpose) |purpose| {
            try common.appendQueryParam(writer, &first, "purpose", purpose);
        }
        if (params.limit) |limit| {
            var value_buf: [32]u8 = undefined;
            const value = std.fmt.bufPrint(&value_buf, "{d}", .{limit}) catch {
                return errors.Error.SerializeError;
            };
            try common.appendQueryParam(writer, &first, "limit", value);
        }
        if (params.order) |order| {
            try common.appendQueryParam(writer, &first, "order", order);
        }
        if (params.after) |after| {
            try common.appendQueryParam(writer, &first, "after", after);
        }
        const path = fbs.getWritten();

        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            .GET,
            path,
            gen.ListFilesResponse,
            request_opts,
        );
    }

    /// GET /files
    pub fn list(self: *const Resource, allocator: std.mem.Allocator, params: ListFilesParams) errors.Error!std.json.Parsed(gen.ListFilesResponse) {
        return self.list_files(allocator, params);
    }

    pub fn list_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListFilesParams,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListFilesResponse) {
        return self.list_files_with_options(allocator, params, request_opts);
    }

    /// POST /files (multipart)
    pub fn create_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.OpenAIFile) {
        return self.create_file_with_options(allocator, payload, null);
    }

    pub fn create_file_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.OpenAIFile) {
        const resp = try self.transport.requestWithOptions(
            .POST,
            "/files",
            &.{
                .{ .name = "Accept", .value = "application/json" },
                .{ .name = "Content-Type", .value = payload.content_type },
            },
            payload.body,
            request_opts,
        );
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.OpenAIFile, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /files (multipart)
    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.OpenAIFile) {
        return self.create_file(allocator, payload);
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.OpenAIFile) {
        return self.create_file_with_options(allocator, payload, request_opts);
    }

    /// DELETE /files/{file_id}
    pub fn delete_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteFileResponse) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/files/{s}", .{file_id}) catch {
            return errors.Error.SerializeError;
        };
        return common.sendNoBodyTyped(self.transport, allocator, .DELETE, path, gen.DeleteFileResponse);
    }

    pub fn delete_file_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        file_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeleteFileResponse) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/files/{s}", .{file_id}) catch {
            return errors.Error.SerializeError;
        };
        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            .DELETE,
            path,
            gen.DeleteFileResponse,
            request_opts,
        );
    }

    /// DELETE /files/{file_id}
    pub fn delete(self: *const Resource, allocator: std.mem.Allocator, file_id: []const u8) errors.Error!std.json.Parsed(gen.DeleteFileResponse) {
        return self.delete_file(allocator, file_id);
    }

    pub fn delete_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        file_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeleteFileResponse) {
        return self.delete_file_with_options(allocator, file_id, request_opts);
    }

    /// GET /files/{file_id}
    pub fn retrieve_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.OpenAIFile) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/files/{s}", .{file_id}) catch {
            return errors.Error.SerializeError;
        };
        return common.sendNoBodyTyped(self.transport, allocator, .GET, path, gen.OpenAIFile);
    }

    pub fn retrieve_file_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        file_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.OpenAIFile) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/files/{s}", .{file_id}) catch {
            return errors.Error.SerializeError;
        };
        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            .GET,
            path,
            gen.OpenAIFile,
            request_opts,
        );
    }

    /// GET /files/{file_id}
    pub fn retrieve(self: *const Resource, allocator: std.mem.Allocator, file_id: []const u8) errors.Error!std.json.Parsed(gen.OpenAIFile) {
        return self.retrieve_file(allocator, file_id);
    }

    pub fn retrieve_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        file_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.OpenAIFile) {
        return self.retrieve_file_with_options(allocator, file_id, request_opts);
    }

    /// GET /files/{file_id}/content -> binary body.
    pub fn download_file(
        self: *const Resource,
        file_id: []const u8,
    ) errors.Error!BinaryResponse {
        return self.download_file_with_options(file_id, null);
    }

    pub fn download_file_with_options(
        self: *const Resource,
        file_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!BinaryResponse {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/files/{s}/content", .{file_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.requestWithOptions(.GET, path, &.{}, null, request_opts);
        return BinaryResponse{
            .allocator = self.transport.allocator,
            .data = resp.body,
        };
    }

    /// GET /files/{file_id}/content -> binary body.
    pub fn download(self: *const Resource, file_id: []const u8) errors.Error!BinaryResponse {
        return self.download_file(file_id);
    }

    pub fn download_with_options(
        self: *const Resource,
        file_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!BinaryResponse {
        return self.download_file_with_options(file_id, request_opts);
    }
};
