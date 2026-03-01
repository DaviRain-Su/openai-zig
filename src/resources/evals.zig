const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const ListParams = struct {
    limit: ?u32 = null,
    order: ?[]const u8 = null,
    after: ?[]const u8 = null,
    before: ?[]const u8 = null,
    pub fn list(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.EvalList) {
        return self.list_evals(allocator, params);
    }

    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateEvalRequest,
    ) errors.Error!std.json.Parsed(gen.EvalObject) {
        return self.create_eval(allocator, body);
    }

    pub fn get(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.EvalObject) {
        return self.get_eval(allocator, eval_id);
    }

    pub fn update(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
        body: gen.CreateEvalRequest,
    ) errors.Error!std.json.Parsed(gen.EvalObject) {
        return self.update_eval(allocator, eval_id, body);
    }

    pub fn delete(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.EvalObject) {
        return self.delete_eval(allocator, eval_id);
    }

    pub fn list_runs(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.EvalRunList) {
        return self.get_eval_runs(allocator, eval_id, params);
    }

    pub fn create_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
        body: gen.CreateEvalRunRequest,
    ) errors.Error!std.json.Parsed(gen.EvalRun) {
        return self.create_eval_run(allocator, eval_id, body);
    }

    pub fn get_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
        run_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.EvalRun) {
        return self.get_eval_run(allocator, eval_id, run_id);
    }

    pub fn cancel_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
        run_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.EvalRun) {
        return self.cancel_eval_run(allocator, eval_id, run_id);
    }

    pub fn delete_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
        run_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.EvalRun) {
        return self.delete_eval_run(allocator, eval_id, run_id);
    }

    pub fn list_run_output_items(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
        run_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.EvalRunOutputItemList) {
        return self.get_eval_run_output_items(allocator, eval_id, run_id, params);
    }

    pub fn get_run_output_item(
        self: *const Resource,
        allocator: std.mem.Allocator,
        eval_id: []const u8,
        run_id: []const u8,
        output_item_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.EvalRunOutputItem) {
        return self.get_eval_run_output_item(allocator, eval_id, run_id, output_item_id);
    }
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn appendListParams(writer: anytype, params: ListParams, first: *bool) !void {
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, first, "limit", @as(u64, limit));
        }
        try common.appendOptionalQueryParam(writer, first, "order", params.order);
        try common.appendOptionalQueryParam(writer, first, "after", params.after);
        try common.appendOptionalQueryParam(writer, first, "before", params.before);
    }

    fn sendJsonTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendJsonTyped(self.transport, allocator, method, path, value, T);
    }

    fn sendNoBodyTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendNoBodyTyped(self.transport, allocator, method, path, T);
    }

    /// Evals
    pub fn list_evals(self: *const Resource, allocator: std.mem.Allocator, params: ListParams) errors.Error!std.json.Parsed(gen.EvalList) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/evals");
        var first = true;
        try appendListParams(w, params, &first);
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
        var first = true;
        try appendListParams(w, params, &first);
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
        var first = true;
        try appendListParams(w, params, &first);
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
