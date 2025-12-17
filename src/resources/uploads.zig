const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

pub const CreateUploadRequest = struct {
    filename: []const u8,
    purpose: []const u8,
    bytes: u64,
    mime_type: []const u8,
    expires_after: ?ExpiresAfter = null,
};

pub const ExpiresAfter = struct {
    anchor: []const u8,
    seconds: u32,
};

pub const CompleteUploadRequest = struct {
    part_ids: []const []const u8,
};

pub const MultipartPart = struct {
    content_type: []const u8,
    body: []const u8,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    /// POST /uploads
    pub fn create_upload(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateUploadRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        const resp = try self.transport.request(.POST, "/uploads", &.{
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

    /// POST /uploads/{upload_id}/cancel
    pub fn cancel_upload(
        self: *const Resource,
        allocator: std.mem.Allocator,
        upload_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/uploads/{s}/cancel", .{upload_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.POST, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /uploads/{upload_id}/complete
    pub fn complete_upload(
        self: *const Resource,
        allocator: std.mem.Allocator,
        upload_id: []const u8,
        req: CompleteUploadRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/uploads/{s}/complete", .{upload_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.POST, path, &.{
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

    /// POST /uploads/{upload_id}/parts (multipart)
    pub fn add_upload_part(
        self: *const Resource,
        allocator: std.mem.Allocator,
        upload_id: []const u8,
        part: MultipartPart,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/uploads/{s}/parts", .{upload_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.POST, path, &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = part.content_type },
        }, part.body);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }
};
