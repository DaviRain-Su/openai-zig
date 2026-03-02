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

pub const ListVideosParams = struct {
    limit: ?u32 = null,
    order: ?[]const u8 = null,
    after: ?[]const u8 = null,
};

pub const CreateVideoRequest = gen.CreateVideoBody;

pub const CreateVideoRemixRequest = gen.CreateVideoRemixBody;

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn appendListParams(writer: anytype, params: ListVideosParams, first: *bool) !void {
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, first, "limit", @as(u64, limit));
        }
        try common.appendOptionalQueryParam(writer, first, "order", params.order);
        try common.appendOptionalQueryParam(writer, first, "after", params.after);
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

    fn sendMultipartWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        payload: MultipartRequest,
        comptime T: type,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendMultipartTypedWithOptions(
            self.transport,
            allocator,
            method,
            path,
            payload,
            T,
            request_opts,
        );
    }

    fn sendBinary(
        self: *const Resource,
        method: std.http.Method,
        path: []const u8,
    ) errors.Error!BinaryResponse {
        return self.sendBinaryWithOptions(method, path, null);
    }

    fn sendBinaryWithOptions(
        self: *const Resource,
        method: std.http.Method,
        path: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!BinaryResponse {
        const response_body = try common.sendBinaryWithOptions(
            self.transport,
            method,
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

    /// GET /videos
    pub fn list_videos(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListVideosParams,
    ) errors.Error!std.json.Parsed(gen.VideoListResource) {
        return self.list_videos_with_options(allocator, params, null);
    }

    pub fn list_videos_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListVideosParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VideoListResource) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/videos");
        var first = true;
        try appendListParams(w, params, &first);
        const path = fbs.getWritten();

        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.VideoListResource,
            request_opts,
        );
    }

    /// GET /videos
    pub fn list(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListVideosParams,
    ) errors.Error!std.json.Parsed(gen.VideoListResource) {
        return self.list_videos(allocator, params);
    }

    pub fn list_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListVideosParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VideoListResource) {
        return self.list_videos_with_options(allocator, params, request_opts);
    }

    /// POST /videos (JSON)
    pub fn create_video_json(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateVideoRequest,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.create_video_json_with_options(allocator, req, null);
    }

    pub fn create_video_json_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateVideoRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            "/videos",
            req,
            gen.VideoResource,
            request_opts,
        );
    }

    /// POST /videos (JSON)
    pub fn create_video(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateVideoRequest,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.create_video_json(allocator, req);
    }

    pub fn create_video_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateVideoRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.create_video_json_with_options(allocator, req, request_opts);
    }

    /// POST /videos (multipart body)
    pub fn create_video_with_payload(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.create_video_multipart(allocator, payload);
    }

    /// POST /videos (multipart)
    pub fn create_video_multipart(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.create_video_multipart_with_options(allocator, payload, null);
    }

    pub fn create_video_with_payload_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.create_video_multipart_with_options(allocator, payload, request_opts);
    }

    pub fn create_video_multipart_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.sendMultipartWithOptions(
            allocator,
            .POST,
            "/videos",
            payload,
            gen.VideoResource,
            request_opts,
        );
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateVideoRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.create_video_json_with_options(allocator, req, request_opts);
    }

    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateVideoRequest,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.create_video(allocator, req);
    }

    pub fn create_multipart(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.create_video_with_payload(allocator, payload);
    }

    pub fn create_multipart_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.create_video_multipart_with_options(allocator, payload, request_opts);
    }

    /// GET /videos/{video_id}
    pub fn get_video(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.get_video_with_options(allocator, video_id, null);
    }

    pub fn get_video_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/videos/{s}", .{video_id}) catch {
            return errors.Error.SerializeError;
        };

        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.VideoResource,
            request_opts,
        );
    }

    /// DELETE /videos/{video_id}
    pub fn delete_video(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeletedVideoResource) {
        return self.delete_video_with_options(allocator, video_id, null);
    }

    pub fn delete_video_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeletedVideoResource) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/videos/{s}", .{video_id}) catch {
            return errors.Error.SerializeError;
        };

        return self.sendNoBodyTypedWithOptions(
            allocator,
            .DELETE,
            path,
            gen.DeletedVideoResource,
            request_opts,
        );
    }

    /// GET /videos/{video_id}/content -> binary video content
    pub fn retrieve_video_content(
        self: *const Resource,
        video_id: []const u8,
    ) errors.Error!BinaryResponse {
        return self.retrieve_video_content_with_options(video_id, null);
    }

    pub fn retrieve_video_content_with_options(
        self: *const Resource,
        video_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!BinaryResponse {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/videos/{s}/content", .{video_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendBinaryWithOptions(.GET, path, request_opts);
    }

    pub fn content(
        self: *const Resource,
        video_id: []const u8,
    ) errors.Error!BinaryResponse {
        return self.retrieve_video_content(video_id);
    }

    pub fn content_with_options(
        self: *const Resource,
        video_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!BinaryResponse {
        return self.retrieve_video_content_with_options(video_id, request_opts);
    }

    /// POST /videos/{video_id}/remix (JSON)
    pub fn create_video_remix(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
        req: CreateVideoRemixRequest,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.create_video_remix_with_options(allocator, video_id, req, null);
    }

    pub fn create_video_remix_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
        req: CreateVideoRemixRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/videos/{s}/remix", .{video_id}) catch {
            return errors.Error.SerializeError;
        };

        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            req,
            gen.VideoResource,
            request_opts,
        );
    }

    /// POST /videos/{video_id}/remix (multipart)
    pub fn create_video_remix_multipart(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.create_video_remix_multipart_with_options(allocator, video_id, payload, null);
    }

    pub fn create_video_remix_multipart_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
        payload: MultipartRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/videos/{s}/remix", .{video_id}) catch {
            return errors.Error.SerializeError;
        };

        return self.sendMultipartWithOptions(
            allocator,
            .POST,
            path,
            payload,
            gen.VideoResource,
            request_opts,
        );
    }

    pub fn get(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.get_video(allocator, video_id);
    }

    pub fn get_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.get_video_with_options(allocator, video_id, request_opts);
    }

    pub fn delete(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeletedVideoResource) {
        return self.delete_video(allocator, video_id);
    }

    pub fn delete_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeletedVideoResource) {
        return self.delete_video_with_options(allocator, video_id, request_opts);
    }

    pub fn remix(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
        req: CreateVideoRemixRequest,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.create_video_remix(allocator, video_id, req);
    }

    pub fn remix_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
        req: CreateVideoRemixRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.create_video_remix_with_options(allocator, video_id, req, request_opts);
    }

    pub fn remix_multipart(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.create_video_remix_multipart(allocator, video_id, payload);
    }

    pub fn remix_multipart_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        video_id: []const u8,
        payload: MultipartRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VideoResource) {
        return self.create_video_remix_multipart_with_options(allocator, video_id, payload, request_opts);
    }
};
