const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");

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
        const writer = fbs.writer();
        try writer.writeAll("/files");

        var sep: []const u8 = "?";
        if (params.purpose) |purpose| {
            try writer.print("{s}purpose={s}", .{ sep, purpose });
            sep = "&";
        }
        if (params.limit) |limit| {
            try writer.print("{s}limit={d}", .{ sep, limit });
            sep = "&";
        }
        if (params.order) |order| {
            try writer.print("{s}order={s}", .{ sep, order });
            sep = "&";
        }
        if (params.after) |after| {
            try writer.print("{s}after={s}", .{ sep, after });
        }
        const path = fbs.getWritten();

        const resp = try self.transport.request(.GET, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.ListFilesResponse, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /files (multipart)
    pub fn create_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.OpenAIFile) {
        const resp = try self.transport.request(.POST, "/files", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = payload.content_type },
        }, payload.body);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.OpenAIFile, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
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

        const resp = try self.transport.request(.DELETE, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.DeleteFileResponse, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
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

        const resp = try self.transport.request(.GET, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.OpenAIFile, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// GET /files/{file_id}/content -> binary body.
    pub fn download_file(
        self: *const Resource,
        file_id: []const u8,
    ) errors.Error!BinaryResponse {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/files/{s}/content", .{file_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.GET, path, &.{}, null);
        return BinaryResponse{
            .allocator = self.transport.allocator,
            .data = resp.body,
        };
    }
};
