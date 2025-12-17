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
};

pub const ListMessagesParams = struct {
    base: ListParams = .{},
    run_id: ?[]const u8 = null,
};

pub const ListRunStepsParams = struct {
    base: ListParams = .{},
    include: ?[]const []const u8 = null,
};

pub const CreateRunQuery = struct {
    include: ?[]const []const u8 = null,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn appendListParams(writer: anytype, params: ListParams, sep_start: []const u8) ![]const u8 {
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
            sep = "&";
        }
        return sep;
    }

    fn sendJson(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJsonTyped(allocator, method, path, value, std.json.Value);
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

    fn sendNoBody(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendNoBodyTyped(allocator, method, path, std.json.Value);
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

    /// GET /assistants
    pub fn list_assistants(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ListAssistantsResponse) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/assistants");
        _ = try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ListAssistantsResponse);
    }

    /// POST /assistants
    pub fn create_assistant(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateAssistantRequest,
    ) errors.Error!std.json.Parsed(gen.AssistantObject) {
        return self.sendJsonTyped(allocator, .POST, "/assistants", body, gen.AssistantObject);
    }

    /// GET /assistants/{assistant_id}
    pub fn get_assistant(
        self: *const Resource,
        allocator: std.mem.Allocator,
        assistant_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.AssistantObject) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/assistants/{s}", .{assistant_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .GET, path, gen.AssistantObject);
    }

    /// POST /assistants/{assistant_id}
    pub fn modify_assistant(
        self: *const Resource,
        allocator: std.mem.Allocator,
        assistant_id: []const u8,
        body: gen.ModifyAssistantRequest,
    ) errors.Error!std.json.Parsed(gen.AssistantObject) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/assistants/{s}", .{assistant_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.AssistantObject);
    }

    /// DELETE /assistants/{assistant_id}
    pub fn delete_assistant(
        self: *const Resource,
        allocator: std.mem.Allocator,
        assistant_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteAssistantResponse) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/assistants/{s}", .{assistant_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .DELETE, path, gen.DeleteAssistantResponse);
    }

    /// POST /threads
    pub fn create_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateThreadRequest,
    ) errors.Error!std.json.Parsed(gen.ThreadObject) {
        return self.sendJsonTyped(allocator, .POST, "/threads", body, gen.ThreadObject);
    }

    /// POST /threads/runs
    pub fn create_thread_and_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateThreadAndRunRequest,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        return self.sendJsonTyped(allocator, .POST, "/threads/runs", body, gen.RunObject);
    }

    /// GET /threads/{thread_id}
    pub fn get_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ThreadObject) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}", .{thread_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ThreadObject);
    }

    /// POST /threads/{thread_id}
    pub fn modify_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        body: gen.ModifyThreadRequest,
    ) errors.Error!std.json.Parsed(gen.ThreadObject) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}", .{thread_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.ThreadObject);
    }

    /// DELETE /threads/{thread_id}
    pub fn delete_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteThreadResponse) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}", .{thread_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .DELETE, path, gen.DeleteThreadResponse);
    }

    /// GET /threads/{thread_id}/messages
    pub fn list_messages(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        params: ListMessagesParams,
    ) errors.Error!std.json.Parsed(gen.ListMessagesResponse) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/threads/{s}/messages", .{thread_id});
        const sep = try appendListParams(w, params.base, "?");
        if (params.run_id) |run_id| {
            try w.print("{s}run_id={s}", .{ sep, run_id });
        }
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ListMessagesResponse);
    }

    /// POST /threads/{thread_id}/messages
    pub fn create_message(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        body: gen.CreateMessageRequest,
    ) errors.Error!std.json.Parsed(gen.MessageObject) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/messages", .{thread_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.MessageObject);
    }

    /// GET /threads/{thread_id}/messages/{message_id}
    pub fn get_message(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        message_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.MessageObject) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/messages/{s}", .{ thread_id, message_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .GET, path, gen.MessageObject);
    }

    /// POST /threads/{thread_id}/messages/{message_id}
    pub fn modify_message(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        message_id: []const u8,
        body: gen.ModifyMessageRequest,
    ) errors.Error!std.json.Parsed(gen.MessageObject) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/messages/{s}", .{ thread_id, message_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.MessageObject);
    }

    /// DELETE /threads/{thread_id}/messages/{message_id}
    pub fn delete_message(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        message_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteMessageResponse) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/messages/{s}", .{ thread_id, message_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .DELETE, path, gen.DeleteMessageResponse);
    }

    /// GET /threads/{thread_id}/runs
    pub fn list_runs(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ListRunsResponse) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/threads/{s}/runs", .{thread_id});
        _ = try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ListRunsResponse);
    }

    /// POST /threads/{thread_id}/runs
    pub fn create_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        query: CreateRunQuery,
        body: gen.CreateRunRequest,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/threads/{s}/runs", .{thread_id});
        var sep: []const u8 = "?";
        if (query.include) |incs| {
            for (incs) |inc| {
                try w.print("{s}include[]={s}", .{ sep, inc });
                sep = "&";
            }
        }
        const path = fbs.getWritten();
        return self.sendJsonTyped(allocator, .POST, path, body, gen.RunObject);
    }

    /// GET /threads/{thread_id}/runs/{run_id}
    pub fn get_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/runs/{s}", .{ thread_id, run_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .GET, path, gen.RunObject);
    }

    /// POST /threads/{thread_id}/runs/{run_id}
    pub fn modify_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        body: gen.ModifyRunRequest,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/runs/{s}", .{ thread_id, run_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.RunObject);
    }

    /// POST /threads/{thread_id}/runs/{run_id}/cancel
    pub fn cancel_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/runs/{s}/cancel", .{ thread_id, run_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTyped(allocator, .POST, path, gen.RunObject);
    }

    /// GET /threads/{thread_id}/runs/{run_id}/steps
    pub fn list_run_steps(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        params: ListRunStepsParams,
    ) errors.Error!std.json.Parsed(gen.ListRunStepsResponse) {
        var buf: [320]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/threads/{s}/runs/{s}/steps", .{ thread_id, run_id });
        var sep = try appendListParams(w, params.base, "?");
        if (params.include) |incs| {
            for (incs) |inc| {
                try w.print("{s}include[]={s}", .{ sep, inc });
                sep = "&";
            }
        }
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.ListRunStepsResponse);
    }

    /// GET /threads/{thread_id}/runs/{run_id}/steps/{step_id}
    pub fn get_run_step(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        step_id: []const u8,
        include: ?[]const []const u8,
    ) errors.Error!std.json.Parsed(gen.RunStepObject) {
        var buf: [360]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/threads/{s}/runs/{s}/steps/{s}", .{ thread_id, run_id, step_id });
        var sep: []const u8 = "?";
        if (include) |incs| {
            for (incs) |inc| {
                try w.print("{s}include[]={s}", .{ sep, inc });
                sep = "&";
            }
        }
        const path = fbs.getWritten();
        return self.sendNoBodyTyped(allocator, .GET, path, gen.RunStepObject);
    }

    /// POST /threads/{thread_id}/runs/{run_id}/submit_tool_outputs
    pub fn submit_tool_outputs_to_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        body: gen.SubmitToolOutputsRequest,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        var buf: [360]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/runs/{s}/submit_tool_outputs", .{ thread_id, run_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, .POST, path, body, gen.RunObject);
    }
};
