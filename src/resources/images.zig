const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

pub const CreateImageRequest = struct {
    model: []const u8,
    prompt: []const u8,
    size: ?[]const u8 = null,
    n: ?u32 = null,
    response_format: ?[]const u8 = null,
    user: ?[]const u8 = null,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    /// POST /images -> dynamic JSON
    pub fn create_image(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateImageRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
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

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
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
    ) errors.Error!std.json.Parsed(std.json.Value) {
        const resp = try self.transport.request(.POST, "/images/edits", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = content_type },
        }, body);
        const resp_body = resp.body;
        defer self.transport.allocator.free(resp_body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, resp_body, .{}) catch {
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
    ) errors.Error!std.json.Parsed(std.json.Value) {
        const resp = try self.transport.request(.POST, "/images/variations", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = content_type },
        }, body);
        const resp_body = resp.body;
        defer self.transport.allocator.free(resp_body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, resp_body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }
};
