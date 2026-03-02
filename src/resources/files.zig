const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const MultipartRequest = struct {
    content_type: []const u8,
    body: []const u8,
};

pub const CreateFileUploadRequest = struct {
    file_path: []const u8,
    purpose: []const u8,
    filename: ?[]const u8 = null,
    file_content_type: ?[]const u8 = null,
    expires_after: ?gen.FileExpirationAfter = null,
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
        request_opts: ?transport_mod.Transport.RequestOptions,
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
        request_opts: ?transport_mod.Transport.RequestOptions,
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
        return common.sendMultipartTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            "/files",
            payload,
            gen.OpenAIFile,
            request_opts,
        );
    }

    /// POST /files (multipart with path + purpose helper)
    pub fn create_file_from_path(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: CreateFileUploadRequest,
    ) errors.Error!std.json.Parsed(gen.OpenAIFile) {
        return self.create_file_from_path_with_options(allocator, payload, null);
    }

    pub fn create_file_from_path_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: CreateFileUploadRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.OpenAIFile) {
        const multipart = try buildCreateFileMultipartPayload(allocator, payload);
        defer allocator.free(multipart.body);
        return self.create_file_with_options(allocator, multipart, request_opts);
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
        request_opts: ?transport_mod.Transport.RequestOptions,
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
        request_opts: ?transport_mod.Transport.RequestOptions,
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
        request_opts: ?transport_mod.Transport.RequestOptions,
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
        request_opts: ?transport_mod.Transport.RequestOptions,
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
        request_opts: ?transport_mod.Transport.RequestOptions,
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
        const response_body = try common.sendBinaryWithOptions(
            self.transport,
            .GET,
            path,
            &.{},
            null,
            request_opts,
        );
        return .{
            .allocator = self.transport.allocator,
            .data = response_body,
        };
    }

    /// GET /files/{file_id}/content -> binary body.
    pub fn download(self: *const Resource, file_id: []const u8) errors.Error!BinaryResponse {
        return self.download_file(file_id);
    }

    pub fn download_with_options(
        self: *const Resource,
        file_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!BinaryResponse {
        return self.download_file_with_options(file_id, request_opts);
    }
};

const file_upload_boundary = "----openai-zig-file-upload-0f9e";

fn buildCreateFileMultipartPayload(
    allocator: std.mem.Allocator,
    req: CreateFileUploadRequest,
) errors.Error!MultipartRequest {
    var multipart = try common.MultipartBuilder.init(allocator, file_upload_boundary);
    errdefer multipart.deinit();

    try multipart.appendTextField("purpose", req.purpose);

    if (req.expires_after) |expiration| {
        try multipart.appendTextField("expires_after[anchor]", expiration.anchor);
        var seconds_buf: [32]u8 = undefined;
        const seconds = std.fmt.bufPrint(&seconds_buf, "{d}", .{expiration.seconds}) catch {
            return errors.Error.SerializeError;
        };
        try multipart.appendTextField("expires_after[seconds]", seconds);
    }

    const file = std.fs.cwd().openFile(req.file_path, .{}) catch {
        return errors.Error.SerializeError;
    };
    defer file.close();

    const file_size = try file.stat();
    const file_len = std.math.cast(usize, file_size.size) orelse return errors.Error.SerializeError;
    const file_data = file.readToEndAlloc(allocator, file_len) catch {
        return errors.Error.SerializeError;
    };
    defer allocator.free(file_data);

    const filename = req.filename orelse std.fs.path.basename(req.file_path);
    const content_type = req.file_content_type orelse "application/octet-stream";
    try multipart.appendFileField("file", filename, content_type, file_data);
    try multipart.appendFooter();

    return MultipartRequest{
        .content_type = "multipart/form-data; boundary=" ++ file_upload_boundary,
        .body = try multipart.toOwnedSlice(),
    };
}
