const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");

pub const CreateImageRequest = gen.CreateImageRequest;
pub const ImagesResponse = gen.ImagesResponse;

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
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
        const resp = try self.transport.request(.POST, "/images/edits", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = content_type },
        }, body);
        const resp_body = resp.body;
        defer self.transport.allocator.free(resp_body);

        const parsed = std.json.parseFromSlice(ImagesResponse, allocator, resp_body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
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

    /// POST /images/variations (multipart, caller builds payload)
    pub fn create_image_variation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        content_type: []const u8,
        body: []const u8,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        const resp = try self.transport.request(.POST, "/images/variations", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = content_type },
        }, body);
        const resp_body = resp.body;
        defer self.transport.allocator.free(resp_body);

        const parsed = std.json.parseFromSlice(ImagesResponse, allocator, resp_body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
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

    /// POST /images/generations
    pub fn generate(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateImageRequest,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        return self.create_image_generation(allocator, req);
    }

    /// POST /images/generations
    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateImageRequest,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        return self.create_image(allocator, req);
    }

    /// POST /images/generations
    pub fn create_image_generation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateImageRequest,
    ) errors.Error!std.json.Parsed(ImagesResponse) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        const resp = try self.transport.request(.POST, "/images/generations", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = "application/json" },
        }, payload);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(ImagesResponse, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }
};
