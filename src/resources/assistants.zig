const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

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

/// Minimal typed request bodies (keep complex nested fields as generic JSON for flexibility).
pub const CreateAssistantRequest = struct {
    model: []const u8,
    name: ?[]const u8 = null,
    description: ?[]const u8 = null,
    instructions: ?[]const u8 = null,
    tools: ?std.json.Value = null,
    metadata: ?std.json.Value = null,
    temperature: ?f64 = null,
    top_p: ?f64 = null,
    response_format: ?std.json.Value = null,
    tool_resources: ?std.json.Value = null,
};

pub const ModifyAssistantRequest = struct {
    name: ?[]const u8 = null,
    description: ?[]const u8 = null,
    instructions: ?[]const u8 = null,
    tools: ?std.json.Value = null,
    metadata: ?std.json.Value = null,
    temperature: ?f64 = null,
    top_p: ?f64 = null,
    response_format: ?std.json.Value = null,
    tool_resources: ?std.json.Value = null,
    model: ?[]const u8 = null,
};

pub const ThreadMessage = struct {
    role: []const u8,
    content: std.json.Value,
    attachments: ?std.json.Value = null,
    metadata: ?std.json.Value = null,
};

pub const CreateThreadRequest = struct {
    messages: ?[]const ThreadMessage = null,
    metadata: ?std.json.Value = null,
    tool_resources: ?std.json.Value = null,
};

pub const CreateMessageRequest = struct {
    role: []const u8,
    content: std.json.Value,
    attachments: ?std.json.Value = null,
    metadata: ?std.json.Value = null,
};

pub const CreateRunRequest = struct {
    assistant_id: []const u8,
    instructions: ?[]const u8 = null,
    model: ?[]const u8 = null,
    metadata: ?std.json.Value = null,
    tools: ?std.json.Value = null,
    parallel_tool_calls: ?bool = null,
    tool_choice: ?std.json.Value = null,
    response_format: ?std.json.Value = null,
    truncation_strategy: ?std.json.Value = null,
    temperature: ?f64 = null,
    top_p: ?f64 = null,
    max_prompt_tokens: ?u32 = null,
    max_completion_tokens: ?u32 = null,
    stream: ?bool = null,
    additional_instructions: ?[]const u8 = null,
    additional_messages: ?std.json.Value = null,
    tool_resources: ?std.json.Value = null,
};

pub const ModifyRunRequest = struct {
    metadata: ?std.json.Value = null,
    instructions: ?[]const u8 = null,
    tool_choice: ?std.json.Value = null,
    parallel_tool_calls: ?bool = null,
    temperature: ?f64 = null,
    max_prompt_tokens: ?u32 = null,
    max_completion_tokens: ?u32 = null,
};

pub const SubmitToolOutputsRequest = struct {
    tool_outputs: std.json.Value,
    stream: ?bool = null,
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

    /// GET /assistants
    pub fn list_assistants(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/assistants");
        _ = try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }

    /// POST /assistants
    pub fn create_assistant(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: CreateAssistantRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJson(allocator, .POST, "/assistants", body);
    }

    /// GET /assistants/{assistant_id}
    pub fn get_assistant(
        self: *const Resource,
        allocator: std.mem.Allocator,
        assistant_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/assistants/{s}", .{assistant_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .GET, path);
    }

    /// POST /assistants/{assistant_id}
    pub fn modify_assistant(
        self: *const Resource,
        allocator: std.mem.Allocator,
        assistant_id: []const u8,
        body: ModifyAssistantRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/assistants/{s}", .{assistant_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, body);
    }

    /// DELETE /assistants/{assistant_id}
    pub fn delete_assistant(
        self: *const Resource,
        allocator: std.mem.Allocator,
        assistant_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/assistants/{s}", .{assistant_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .DELETE, path);
    }

    /// POST /threads
    pub fn create_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: CreateThreadRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJson(allocator, .POST, "/threads", body);
    }

    /// POST /threads/runs
    pub fn create_thread_and_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJson(allocator, .POST, "/threads/runs", body);
    }

    /// GET /threads/{thread_id}
    pub fn get_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}", .{thread_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .GET, path);
    }

    /// POST /threads/{thread_id}
    pub fn modify_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}", .{thread_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, body);
    }

    /// DELETE /threads/{thread_id}
    pub fn delete_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}", .{thread_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .DELETE, path);
    }

    /// GET /threads/{thread_id}/messages
    pub fn list_messages(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        params: ListMessagesParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/threads/{s}/messages", .{thread_id});
        const sep = try appendListParams(w, params.base, "?");
        if (params.run_id) |run_id| {
            try w.print("{s}run_id={s}", .{ sep, run_id });
        }
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }

    /// POST /threads/{thread_id}/messages
    pub fn create_message(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        body: CreateMessageRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/messages", .{thread_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, body);
    }

    /// GET /threads/{thread_id}/messages/{message_id}
    pub fn get_message(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        message_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/messages/{s}", .{ thread_id, message_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .GET, path);
    }

    /// POST /threads/{thread_id}/messages/{message_id}
    pub fn modify_message(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        message_id: []const u8,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/messages/{s}", .{ thread_id, message_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, body);
    }

    /// DELETE /threads/{thread_id}/messages/{message_id}
    pub fn delete_message(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        message_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/messages/{s}", .{ thread_id, message_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .DELETE, path);
    }

    /// GET /threads/{thread_id}/runs
    pub fn list_runs(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/threads/{s}/runs", .{thread_id});
        _ = try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }

    /// POST /threads/{thread_id}/runs
    pub fn create_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        query: CreateRunQuery,
        body: CreateRunRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
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
        return self.sendJson(allocator, .POST, path, body);
    }

    /// GET /threads/{thread_id}/runs/{run_id}
    pub fn get_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/runs/{s}", .{ thread_id, run_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .GET, path);
    }

    /// POST /threads/{thread_id}/runs/{run_id}
    pub fn modify_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        body: ModifyRunRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/runs/{s}", .{ thread_id, run_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, body);
    }

    /// POST /threads/{thread_id}/runs/{run_id}/cancel
    pub fn cancel_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/runs/{s}/cancel", .{ thread_id, run_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .POST, path);
    }

    /// GET /threads/{thread_id}/runs/{run_id}/steps
    pub fn list_run_steps(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        params: ListRunStepsParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
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
        return self.sendNoBody(allocator, .GET, path);
    }

    /// GET /threads/{thread_id}/runs/{run_id}/steps/{step_id}
    pub fn get_run_step(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        step_id: []const u8,
        include: ?[]const []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
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
        return self.sendNoBody(allocator, .GET, path);
    }

    /// POST /threads/{thread_id}/runs/{run_id}/submit_tool_outputs
    pub fn submit_tool_outputs_to_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        body: SubmitToolOutputsRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [360]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/runs/{s}/submit_tool_outputs", .{ thread_id, run_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, body);
    }
};
