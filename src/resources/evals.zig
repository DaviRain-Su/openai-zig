const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");

pub const ListParams = struct {
    limit: ?u32 = null,
    order: ?[]const u8 = null,
    after: ?[]const u8 = null,
    before: ?[]const u8 = null,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn appendListParams(writer: anytype, params: ListParams, sep_start: []const u8) !void {
        var sep = sep_start;
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
            sep = "&";
        }
        if (params.before) |before| {
            try writer.print("{s}before={s}", .{ sep, before });
        }
    }

    fn sendJsonTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
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

        const parsed = std.json.parseFromSlice(T, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    fn sendNoBodyTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        const resp = try self.transport.request(method, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(T, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// Evals
    pub fn list_evals(self: *const Resource, allocator: std.mem.Allocator, params: ListParams) errors.Error!std.json.Parsed(gen.EvalList) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/evals");
        try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.EvalList);
    }

    pub fn create_eval(self: *const Resource, allocator: std.mem.Allocator, body: gen.CreateEvalRequest) errors.Error!std.json.Parsed(gen.EvalObject) {
        return self.sendJsonTyped(allocator, .POST, "/evals", body, gen.EvalObject);
    }

    pub fn get_eval(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.EvalObject) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/evals/{s}", .{eval_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .GET, path, gen.EvalObject);
    }

    pub fn update_eval(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
        body: gen.CreateEvalRequest,
    ) errors.Error!std.json.Parsed(gen.EvalObject) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/evals/{s}", .{eval_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.EvalObject);
    }

    pub fn delete_eval(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.EvalObject) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/evals/{s}", .{eval_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .DELETE, path, gen.EvalObject);
    }

    /// Runs
    pub fn get_eval_runs(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.EvalRunList) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/evals/{s}/runs", .{eval_id});
        try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.EvalRunList);
    }

    pub fn create_eval_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
        body: gen.CreateEvalRunRequest,
    ) errors.Error!std.json.Parsed(gen.EvalRun) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/evals/{s}/runs", .{eval_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.EvalRun);
    }

    pub fn get_eval_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
        run_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.EvalRun) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/evals/{s}/runs/{s}", .{ eval_id, run_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .GET, path, gen.EvalRun);
    }

    pub fn cancel_eval_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
        run_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.EvalRun) {
        var buf: [260]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/evals/{s}/runs/{s}", .{ eval_id, run_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .POST, path, gen.EvalRun);
    }

    pub fn delete_eval_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
        run_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.EvalRun) {
        var buf: [260]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/evals/{s}/runs/{s}", .{ eval_id, run_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .DELETE, path, gen.EvalRun);
    }

    /// Output items
    pub fn get_eval_run_output_items(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
        run_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.EvalRunOutputItemList) {
        var buf: [280]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/evals/{s}/runs/{s}/output_items", .{ eval_id, run_id });
        try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.EvalRunOutputItemList);
    }

    pub fn get_eval_run_output_item(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
        run_id: []const u8,
        output_item_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.EvalRunOutputItem) {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/evals/{s}/runs/{s}/output_items/{s}", .{ eval_id, run_id, output_item_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .GET, path, gen.EvalRunOutputItem);
    }
};
