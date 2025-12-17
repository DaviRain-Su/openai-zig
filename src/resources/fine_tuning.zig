const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

pub const ListParams = struct {
    after: ?[]const u8 = null,
    limit: ?u32 = null,
    metadata: ?std.json.Value = null,
};

pub const ListCheckpointsParams = struct {
    after: ?[]const u8 = null,
    limit: ?u32 = null,
};

pub const ListEventsParams = struct {
    after: ?[]const u8 = null,
    limit: ?u32 = null,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn appendListParams(writer: anytype, params: ListParams, sep_start: []const u8) !void {
        var sep = sep_start;
        if (params.after) |after| {
            try writer.print("{s}after={s}", .{ sep, after });
            sep = "&";
        }
        if (params.limit) |limit| {
            try writer.print("{s}limit={d}", .{ sep, limit });
            sep = "&";
        }
        if (params.metadata) |meta| {
            // Metadata filter is freeform: delegate to caller to build query if needed.
            _ = meta;
        }
    }

    fn appendBasicList(writer: anytype, after: ?[]const u8, limit: ?u32, sep_start: []const u8) !void {
        var sep = sep_start;
        if (after) |a| {
            try writer.print("{s}after={s}", .{ sep, a });
            sep = "&";
        }
        if (limit) |l| {
            try writer.print("{s}limit={d}", .{ sep, l });
        }
    }

    fn sendJson(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(value) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        const resp = try self.transport.request(method, path, &.{
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

    fn sendNoBody(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        const resp = try self.transport.request(method, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /fine_tuning/alpha/graders/run
    pub fn run_grader(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJson(allocator, .POST, "/fine_tuning/alpha/graders/run", body);
    }

    /// POST /fine_tuning/alpha/graders/validate
    pub fn validate_grader(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJson(allocator, .POST, "/fine_tuning/alpha/graders/validate", body);
    }

    /// POST /fine_tuning/checkpoints/{fine_tuned_model_checkpoint}/permissions
    pub fn create_checkpoint_permission(
        self: *const Resource,
        allocator: std.mem.Allocator,
        checkpoint_id: []const u8,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/fine_tuning/checkpoints/{s}/permissions", .{checkpoint_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, body);
    }

    /// DELETE /fine_tuning/checkpoints/{fine_tuned_model_checkpoint}/permissions/{permission_id}
    pub fn delete_checkpoint_permission(
        self: *const Resource,
        allocator: std.mem.Allocator,
        checkpoint_id: []const u8,
        permission_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/fine_tuning/checkpoints/{s}/permissions/{s}", .{ checkpoint_id, permission_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .DELETE, path);
    }

    /// GET /fine_tuning/checkpoints/{fine_tuned_model_checkpoint}/permissions
    pub fn list_checkpoint_permissions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        checkpoint_id: []const u8,
        params: ListCheckpointsParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [320]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/fine_tuning/checkpoints/{s}/permissions", .{checkpoint_id});
        try appendBasicList(w, params.after, params.limit, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }

    /// POST /fine_tuning/jobs
    pub fn create_job(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJson(allocator, .POST, "/fine_tuning/jobs", body);
    }

    /// GET /fine_tuning/jobs
    pub fn list_jobs(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [320]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/fine_tuning/jobs");
        try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }

    /// GET /fine_tuning/jobs/{fine_tuning_job_id}
    pub fn retrieve_job(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/fine_tuning/jobs/{s}", .{job_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .GET, path);
    }

    /// POST /fine_tuning/jobs/{fine_tuning_job_id}/cancel
    pub fn cancel_job(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/fine_tuning/jobs/{s}/cancel", .{job_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .POST, path);
    }

    /// POST /fine_tuning/jobs/{fine_tuning_job_id}/pause
    pub fn pause_job(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/fine_tuning/jobs/{s}/pause", .{job_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .POST, path);
    }

    /// POST /fine_tuning/jobs/{fine_tuning_job_id}/resume
    pub fn resume_job(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/fine_tuning/jobs/{s}/resume", .{job_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .POST, path);
    }

    /// GET /fine_tuning/jobs/{fine_tuning_job_id}/checkpoints
    pub fn list_job_checkpoints(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        params: ListCheckpointsParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [320]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/fine_tuning/jobs/{s}/checkpoints", .{job_id});
        try appendBasicList(w, params.after, params.limit, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }

    /// GET /fine_tuning/jobs/{fine_tuning_job_id}/events
    pub fn list_job_events(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        params: ListEventsParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [320]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/fine_tuning/jobs/{s}/events", .{job_id});
        try appendBasicList(w, params.after, params.limit, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }
};
