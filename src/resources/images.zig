const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    /// POST /images -> dynamic JSON
    pub fn create_image(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: gen.CreateImageRequest,
    ) errors.Error!std.json.Parsed(gen.CreateImageResponse) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        const resp = try self.transport.request(.POST, "/images", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = "application/json" },
        }, payload);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.CreateImageResponse, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /images/edits (multipart, caller builds payload)
    pub fn create_image_edit(
        self: *const Resource,
        allocator: std.mem.Allocator,
        content_type: []const u8,
        body: []const u8,
    ) errors.Error!std.json.Parsed(gen.CreateImageEditResponse) {
        const resp = try self.transport.request(.POST, "/images/edits", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = content_type },
        }, body);
        const resp_body = resp.body;
        defer self.transport.allocator.free(resp_body);

        const parsed = std.json.parseFromSlice(gen.CreateImageEditResponse, allocator, resp_body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /images/variations (multipart, caller builds payload)
    pub fn create_image_variation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        content_type: []const u8,
        body: []const u8,
    ) errors.Error!std.json.Parsed(gen.CreateImageVariationResponse) {
        const resp = try self.transport.request(.POST, "/images/variations", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = content_type },
        }, body);
        const resp_body = resp.body;
        defer self.transport.allocator.free(resp_body);

        const parsed = std.json.parseFromSlice(gen.CreateImageVariationResponse, allocator, resp_body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }
};
