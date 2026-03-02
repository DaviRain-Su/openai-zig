const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const CreateUploadRequest = gen.CreateUploadRequest;
pub const ExpiresAfter = gen.ExpiresAfterParam;
pub const CompleteUploadRequest = gen.CompleteUploadRequest;

pub const MultipartPart = struct {
    content_type: []const u8,
    body: []const u8,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
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

    fn sendMultipart(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        part: MultipartPart,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        return self.sendMultipartWithOptions(allocator, method, path, part, T, null);
    }

    fn sendMultipartWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        part: MultipartPart,
        comptime T: type,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendMultipartTypedWithOptions(
            self.transport,
            allocator,
            method,
            path,
            part,
            T,
            request_opts,
        );
    }

    /// POST /uploads
    pub fn create_upload(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateUploadRequest,
    ) errors.Error!std.json.Parsed(gen.Upload) {
        return self.create_upload_with_options(allocator, req, null);
    }

    pub fn create_upload_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateUploadRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Upload) {
        return self.sendJsonTypedWithOptions(allocator, .POST, "/uploads", req, gen.Upload, request_opts);
    }

    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateUploadRequest,
    ) errors.Error!std.json.Parsed(gen.Upload) {
        return self.create_upload(allocator, req);
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateUploadRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Upload) {
        return self.create_upload_with_options(allocator, req, request_opts);
    }

    /// POST /uploads/{upload_id}/cancel
    pub fn cancel_upload(
        self: *const Resource,
        allocator: std.mem.Allocator,
        upload_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Upload) {
        return self.cancel_upload_with_options(allocator, upload_id, null);
    }

    pub fn cancel_upload_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        upload_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Upload) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/uploads/{s}/cancel", .{upload_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .POST, path, gen.Upload, request_opts);
    }

    pub fn cancel(
        self: *const Resource,
        allocator: std.mem.Allocator,
        upload_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Upload) {
        return self.cancel_upload(allocator, upload_id);
    }

    pub fn cancel_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        upload_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Upload) {
        return self.cancel_upload_with_options(allocator, upload_id, request_opts);
    }

    /// POST /uploads/{upload_id}/complete
    pub fn complete_upload(
        self: *const Resource,
        allocator: std.mem.Allocator,
        upload_id: []const u8,
        req: CompleteUploadRequest,
    ) errors.Error!std.json.Parsed(gen.Upload) {
        return self.complete_upload_with_options(allocator, upload_id, req, null);
    }

    pub fn complete_upload_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        upload_id: []const u8,
        req: CompleteUploadRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Upload) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/uploads/{s}/complete", .{upload_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(allocator, .POST, path, req, gen.Upload, request_opts);
    }

    pub fn complete(
        self: *const Resource,
        allocator: std.mem.Allocator,
        upload_id: []const u8,
        req: CompleteUploadRequest,
    ) errors.Error!std.json.Parsed(gen.Upload) {
        return self.complete_upload(allocator, upload_id, req);
    }

    pub fn complete_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        upload_id: []const u8,
        req: CompleteUploadRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Upload) {
        return self.complete_upload_with_options(allocator, upload_id, req, request_opts);
    }

    /// POST /uploads/{upload_id}/parts (multipart)
    pub fn add_upload_part(
        self: *const Resource,
        allocator: std.mem.Allocator,
        upload_id: []const u8,
        part: MultipartPart,
    ) errors.Error!std.json.Parsed(gen.UploadPart) {
        return self.add_upload_part_with_options(allocator, upload_id, part, null);
    }

    pub fn add_upload_part_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        upload_id: []const u8,
        part: MultipartPart,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UploadPart) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/uploads/{s}/parts", .{upload_id}) catch {
            return errors.Error.SerializeError;
        };

        return self.sendMultipartWithOptions(allocator, .POST, path, part, gen.UploadPart, request_opts);
    }

    pub fn add_part(
        self: *const Resource,
        allocator: std.mem.Allocator,
        upload_id: []const u8,
        part: MultipartPart,
    ) errors.Error!std.json.Parsed(gen.UploadPart) {
        return self.add_upload_part(allocator, upload_id, part);
    }

    pub fn add_part_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        upload_id: []const u8,
        part: MultipartPart,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UploadPart) {
        return self.add_upload_part_with_options(allocator, upload_id, part, request_opts);
    }
};
