const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const CreateImageRequest = gen.CreateImageRequest;
pub const ImagesResponse = gen.ImagesResponse;

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn sendMultipartWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        content_type: []const u8,
        body: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        const payload = struct {
            content_type: []const u8,
            body: []const u8,
        }{ .content_type = content_type, .body = body };
        return common.sendMultipartTypedWithOptions(
            self.transport,
            allocator,
            method,
            path,
            payload,
            ImagesResponse,
            request_opts,
        );
    }

    /// POST /images/generations
    pub fn create_image(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateImageRequest,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        return self.create_image_generation(allocator, req);
    }

    /// POST /images/edits (multipart, caller builds payload)
    pub fn create_image_edit(
        self: *const Resource,
        allocator: std.mem.Allocator,
        content_type: []const u8,
        body: []const u8,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        return self.create_image_edit_with_options(allocator, content_type, body, null);
    }

    pub fn create_image_edit_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        content_type: []const u8,
        body: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        return self.sendMultipartWithOptions(
            allocator,
            .POST,
            "/images/edits",
            content_type,
            body,
            request_opts,
        );
    }

    /// POST /images/edits (multipart, caller builds payload)
    pub fn edit(
        self: *const Resource,
        allocator: std.mem.Allocator,
        content_type: []const u8,
        body: []const u8,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        return self.create_image_edit(allocator, content_type, body);
    }

    pub fn edit_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        content_type: []const u8,
        body: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        return self.create_image_edit_with_options(allocator, content_type, body, request_opts);
    }

    /// POST /images/variations (multipart, caller builds payload)
    pub fn create_image_variation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        content_type: []const u8,
        body: []const u8,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        return self.create_image_variation_with_options(allocator, content_type, body, null);
    }

    pub fn create_image_variation_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        content_type: []const u8,
        body: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        return self.sendMultipartWithOptions(
            allocator,
            .POST,
            "/images/variations",
            content_type,
            body,
            request_opts,
        );
    }

    /// POST /images/variations (multipart, caller builds payload)
    pub fn create_variation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        content_type: []const u8,
        body: []const u8,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        return self.create_image_variation(allocator, content_type, body);
    }

    pub fn variation_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        content_type: []const u8,
        body: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        return self.create_image_variation_with_options(allocator, content_type, body, request_opts);
    }

    /// POST /images/generations
    pub fn generate(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateImageRequest,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        return self.create_image_generation(allocator, req);
    }

    pub fn generate_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateImageRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        return self.create_image_generation_with_options(allocator, req, request_opts);
    }

    /// POST /images/generations
    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateImageRequest,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        return self.create_image(allocator, req);
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateImageRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        return self.create_image_generation_with_options(allocator, req, request_opts);
    }

    /// POST /images/generations
    pub fn create_image_generation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateImageRequest,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        return common.sendJsonTyped(
            self.transport,
            allocator,
            .POST,
            "/images/generations",
            req,
            ImagesResponse,
        );
    }

    pub fn create_image_generation_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateImageRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            "/images/generations",
            req,
            ImagesResponse,
            request_opts,
        );
    }
};
