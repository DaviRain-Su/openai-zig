const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

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

pub const ListVideosParams = struct {
    limit: ?u32 = null,
    order: ?[]const u8 = null,
    after: ?[]const u8 = null,
};

pub const CreateVideoRequest = struct {
    prompt: []const u8,
    model: ?[]const u8 = null,
    input_reference: ?[]const u8 = null, // for JSON requests; for binaries use multipart
    seconds: ?[]const u8 = null,
    size: ?[]const u8 = null,
};

pub const CreateVideoRemixRequest = struct {
    prompt: []const u8,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    /// GET /videos
    pub fn list_videos(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListVideosParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/videos");
        var sep: []const u8 = "?";
        if (params.limit) |limit| {
            try w.print("{s}limit={d}", .{ sep, limit });
            sep = "&";
        }
        if (params.order) |order| {
            try w.print("{s}order={s}", .{ sep, order });
            sep = "&";
        }
        if (params.after) |after| {
            try w.print("{s}after={s}", .{ sep, after });
        }
        const path = fbs.getWritten();

        const resp = try self.transport.request(.GET, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /videos (JSON)
    pub fn create_video_json(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateVideoRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        const resp = try self.transport.request(.POST, "/videos", &.{
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

    /// POST /videos (multipart)
    pub fn create_video_multipart(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        const resp = try self.transport.request(.POST, "/videos", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = payload.content_type },
        }, payload.body);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// GET /videos/{video_id}
    pub fn get_video(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/videos/{s}", .{video_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.GET, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// DELETE /videos/{video_id}
    pub fn delete_video(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/videos/{s}", .{video_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.DELETE, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// GET /videos/{video_id}/content -> binary video content
    pub fn retrieve_video_content(
        self: *const Resource,
        video_id: []const u8,
    ) errors.Error!BinaryResponse {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/videos/{s}/content", .{video_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.GET, path, &.{}, null);
        return BinaryResponse{
            .allocator = self.transport.allocator,
            .data = resp.body,
        };
    }

    /// POST /videos/{video_id}/remix (JSON)
    pub fn create_video_remix(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
        req: CreateVideoRemixRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/videos/{s}/remix", .{video_id}) catch {
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

    /// POST /videos/{video_id}/remix (multipart)
    pub fn create_video_remix_multipart(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/videos/{s}/remix", .{video_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.POST, path, &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = payload.content_type },
        }, payload.body);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }
};
