const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");

pub const CreateBatchRequest = struct {
    input_file_id: []const u8,
    endpoint: []const u8,
    completion_window: []const u8 = "24h",
    metadata: ?std.json.Value = null,
    output_expires_after: ?std.json.Value = null,
};

pub const ListBatchesParams = struct {
    after: ?[]const u8 = null,
    limit: ?u32 = null,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    /// POST /batches
    pub fn create_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateBatchRequest,
    ) errors.Error!std.json.Parsed(gen.Batch) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        const resp = try self.transport.request(.POST, "/batches", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = "application/json" },
        }, payload);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.Batch, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// GET /batches
    pub fn list_batches(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListBatchesParams,
    ) errors.Error!std.json.Parsed(gen.ListBatchesResponse) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const writer = fbs.writer();
        try writer.writeAll("/batches");

        var sep: []const u8 = "?";
        if (params.after) |after| {
            try writer.print("{s}after={s}", .{ sep, after });
            sep = "&";
        }
        if (params.limit) |limit| {
            try writer.print("{s}limit={d}", .{ sep, limit });
        }
        const path = fbs.getWritten();

        const resp = try self.transport.request(.GET, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.ListBatchesResponse, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// GET /batches/{batch_id}
    pub fn retrieve_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        batch_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Batch) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/batches/{s}", .{batch_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.GET, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.Batch, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /batches/{batch_id}/cancel
    pub fn cancel_batch(
        self: *const Resource,
        allocator: std.mem.Allocator,
        batch_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Batch) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/batches/{s}/cancel", .{batch_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.POST, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.Batch, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }
};
