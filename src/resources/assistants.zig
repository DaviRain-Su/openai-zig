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

    fn appendListParams(writer: anytype, params: ListParams, first: *bool) !void {
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, first, "limit", @as(u64, limit));
        }
        try common.appendOptionalQueryParam(writer, first, "order", params.order);
        try common.appendOptionalQueryParam(writer, first, "after", params.after);
        try common.appendOptionalQueryParam(writer, first, "before", params.before);
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

    fn sendJsonTypedWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
        comptime T: type,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            method,
            path,
            value,
            T,
            request_opts,
        );
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

    fn sendNoBodyTypedWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            method,
            path,
            T,
            request_opts,
        );
    }

    /// GET /assistants
    pub fn list_assistants(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ListAssistantsResponse) {
        return self.list_assistants_with_options(allocator, params, null);
    }

    pub fn list_assistants_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListAssistantsResponse) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        w.writeAll("/assistants") catch {
            return errors.Error.SerializeError;
        };
        var first = true;
        try appendListParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ListAssistantsResponse,
            request_opts,
        );
    }

    /// POST /assistants
    pub fn create_assistant(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateAssistantRequest,
    ) errors.Error!std.json.Parsed(gen.AssistantObject) {
        return self.create_assistant_with_options(allocator, body, null);
    }

    pub fn create_assistant_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateAssistantRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.AssistantObject) {
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            "/assistants",
            body,
            gen.AssistantObject,
            request_opts,
        );
    }

    /// GET /assistants/{assistant_id}
    pub fn get_assistant(
        self: *const Resource,
        allocator: std.mem.Allocator,
        assistant_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.AssistantObject) {
        return self.get_assistant_with_options(allocator, assistant_id, null);
    }

    pub fn get_assistant_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        assistant_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.AssistantObject) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/assistants/{s}", .{assistant_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.AssistantObject,
            request_opts,
        );
    }

    /// POST /assistants/{assistant_id}
    pub fn modify_assistant(
        self: *const Resource,
        allocator: std.mem.Allocator,
        assistant_id: []const u8,
        body: gen.ModifyAssistantRequest,
    ) errors.Error!std.json.Parsed(gen.AssistantObject) {
        return self.modify_assistant_with_options(allocator, assistant_id, body, null);
    }

    pub fn modify_assistant_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        assistant_id: []const u8,
        body: gen.ModifyAssistantRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.AssistantObject) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/assistants/{s}", .{assistant_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.AssistantObject,
            request_opts,
        );
    }

    /// DELETE /assistants/{assistant_id}
    pub fn delete_assistant(
        self: *const Resource,
        allocator: std.mem.Allocator,
        assistant_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteAssistantResponse) {
        return self.delete_assistant_with_options(allocator, assistant_id, null);
    }

    pub fn delete_assistant_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        assistant_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeleteAssistantResponse) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/assistants/{s}", .{assistant_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .DELETE,
            path,
            gen.DeleteAssistantResponse,
            request_opts,
        );
    }

    /// POST /threads
    pub fn create_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateThreadRequest,
    ) errors.Error!std.json.Parsed(gen.ThreadObject) {
        return self.create_thread_with_options(allocator, body, null);
    }

    pub fn create_thread_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateThreadRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ThreadObject) {
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            "/threads",
            body,
            gen.ThreadObject,
            request_opts,
        );
    }

    /// POST /threads/runs
    pub fn create_thread_and_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateThreadAndRunRequest,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        return self.create_thread_and_run_with_options(allocator, body, null);
    }

    pub fn create_thread_and_run_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateThreadAndRunRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            "/threads/runs",
            body,
            gen.RunObject,
            request_opts,
        );
    }

    /// GET /threads/{thread_id}
    pub fn get_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ThreadObject) {
        return self.get_thread_with_options(allocator, thread_id, null);
    }

    pub fn get_thread_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ThreadObject) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}", .{thread_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ThreadObject,
            request_opts,
        );
    }

    /// POST /threads/{thread_id}
    pub fn modify_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        body: gen.ModifyThreadRequest,
    ) errors.Error!std.json.Parsed(gen.ThreadObject) {
        return self.modify_thread_with_options(allocator, thread_id, body, null);
    }

    pub fn modify_thread_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        body: gen.ModifyThreadRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ThreadObject) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}", .{thread_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.ThreadObject,
            request_opts,
        );
    }

    /// DELETE /threads/{thread_id}
    pub fn delete_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteThreadResponse) {
        return self.delete_thread_with_options(allocator, thread_id, null);
    }

    pub fn delete_thread_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeleteThreadResponse) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}", .{thread_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .DELETE,
            path,
            gen.DeleteThreadResponse,
            request_opts,
        );
    }

    /// GET /threads/{thread_id}/messages
    pub fn list_messages(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        params: ListMessagesParams,
    ) errors.Error!std.json.Parsed(gen.ListMessagesResponse) {
        return self.list_messages_with_options(allocator, thread_id, params, null);
    }

    pub fn list_messages_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        params: ListMessagesParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListMessagesResponse) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/threads/{s}/messages", .{thread_id});
        var first = true;
        try appendListParams(w, params.base, &first);
        if (params.run_id) |run_id| {
            try common.appendQueryParam(w, &first, "run_id", run_id);
        }
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ListMessagesResponse,
            request_opts,
        );
    }

    /// POST /threads/{thread_id}/messages
    pub fn create_message(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        body: gen.CreateMessageRequest,
    ) errors.Error!std.json.Parsed(gen.MessageObject) {
        return self.create_message_with_options(allocator, thread_id, body, null);
    }

    pub fn create_message_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        body: gen.CreateMessageRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.MessageObject) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/messages", .{thread_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.MessageObject,
            request_opts,
        );
    }

    /// GET /threads/{thread_id}/messages/{message_id}
    pub fn get_message(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        message_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.MessageObject) {
        return self.get_message_with_options(allocator, thread_id, message_id, null);
    }

    pub fn get_message_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        message_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.MessageObject) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/messages/{s}", .{ thread_id, message_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.MessageObject,
            request_opts,
        );
    }

    /// POST /threads/{thread_id}/messages/{message_id}
    pub fn modify_message(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        message_id: []const u8,
        body: gen.ModifyMessageRequest,
    ) errors.Error!std.json.Parsed(gen.MessageObject) {
        return self.modify_message_with_options(allocator, thread_id, message_id, body, null);
    }

    pub fn modify_message_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        message_id: []const u8,
        body: gen.ModifyMessageRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.MessageObject) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/messages/{s}", .{ thread_id, message_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.MessageObject,
            request_opts,
        );
    }

    /// DELETE /threads/{thread_id}/messages/{message_id}
    pub fn delete_message(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        message_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteMessageResponse) {
        return self.delete_message_with_options(allocator, thread_id, message_id, null);
    }

    pub fn delete_message_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        message_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeleteMessageResponse) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/messages/{s}", .{ thread_id, message_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .DELETE,
            path,
            gen.DeleteMessageResponse,
            request_opts,
        );
    }

    /// GET /threads/{thread_id}/runs
    pub fn list_runs(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ListRunsResponse) {
        return self.list_runs_with_options(allocator, thread_id, params, null);
    }

    pub fn list_runs_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        params: ListParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListRunsResponse) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/threads/{s}/runs", .{thread_id});
        var first = true;
        try appendListParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ListRunsResponse,
            request_opts,
        );
    }

    /// POST /threads/{thread_id}/runs
    pub fn create_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        query: CreateRunQuery,
        body: gen.CreateRunRequest,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        return self.create_run_with_options(allocator, thread_id, query, body, null);
    }

    pub fn create_run_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        query: CreateRunQuery,
        body: gen.CreateRunRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/threads/{s}/runs", .{thread_id});
        var first = true;
        if (query.include) |incs| {
            try common.appendOptionalQueryParamList(w, &first, "include[]", incs);
        }
        const path = fbs.getWritten();
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.RunObject,
            request_opts,
        );
    }

    /// GET /threads/{thread_id}/runs/{run_id}
    pub fn get_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        return self.get_run_with_options(allocator, thread_id, run_id, null);
    }

    pub fn get_run_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/runs/{s}", .{ thread_id, run_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.RunObject,
            request_opts,
        );
    }

    /// POST /threads/{thread_id}/runs/{run_id}
    pub fn modify_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        body: gen.ModifyRunRequest,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        return self.modify_run_with_options(allocator, thread_id, run_id, body, null);
    }

    pub fn modify_run_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        body: gen.ModifyRunRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/runs/{s}", .{ thread_id, run_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.RunObject,
            request_opts,
        );
    }

    /// POST /threads/{thread_id}/runs/{run_id}/cancel
    pub fn cancel_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        return self.cancel_run_with_options(allocator, thread_id, run_id, null);
    }

    pub fn cancel_run_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        var buf: [320]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/runs/{s}/cancel", .{ thread_id, run_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .POST,
            path,
            gen.RunObject,
            request_opts,
        );
    }

    /// GET /threads/{thread_id}/runs/{run_id}/steps
    pub fn list_run_steps(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        params: ListRunStepsParams,
    ) errors.Error!std.json.Parsed(gen.ListRunStepsResponse) {
        return self.list_run_steps_with_options(allocator, thread_id, run_id, params, null);
    }

    pub fn list_run_steps_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        params: ListRunStepsParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListRunStepsResponse) {
        var buf: [320]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/threads/{s}/runs/{s}/steps", .{ thread_id, run_id });
        var first = true;
        try appendListParams(w, params.base, &first);
        if (params.include) |incs| {
            try common.appendOptionalQueryParamList(w, &first, "include[]", incs);
        }
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ListRunStepsResponse,
            request_opts,
        );
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
        return self.get_run_step_with_options(allocator, thread_id, run_id, step_id, include, null);
    }

    pub fn get_run_step_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        step_id: []const u8,
        include: ?[]const []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.RunStepObject) {
        var buf: [360]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/threads/{s}/runs/{s}/steps/{s}", .{ thread_id, run_id, step_id });
        var first = true;
        try common.appendOptionalQueryParamList(w, &first, "include[]", include);
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.RunStepObject,
            request_opts,
        );
    }

    /// POST /threads/{thread_id}/runs/{run_id}/submit_tool_outputs
    pub fn submit_tool_outputs_to_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        body: gen.SubmitToolOutputsRequest,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        return self.submit_tool_outputs_to_run_with_options(allocator, thread_id, run_id, body, null);
    }

    pub fn submit_tool_outputs_to_run_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        body: gen.SubmitToolOutputsRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        var buf: [360]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/threads/{s}/runs/{s}/submit_tool_outputs", .{ thread_id, run_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.RunObject,
            request_opts,
        );
    }

    pub fn submit_tool_ouputs_to_run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        run_id: []const u8,
        body: gen.SubmitToolOutputsRequest,
    ) errors.Error!std.json.Parsed(gen.RunObject) {
        return self.submit_tool_outputs_to_run_with_options(allocator, thread_id, run_id, body, null);
    }

    /// GET /assistants
    pub fn list(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ListAssistantsResponse) {
        return self.list_assistants(allocator, params);
    }

    /// POST /assistants
    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateAssistantRequest,
    ) errors.Error!std.json.Parsed(gen.AssistantObject) {
        return self.create_assistant(allocator, body);
    }

    /// GET /assistants/{assistant_id}
    pub fn get(
        self: *const Resource,
        allocator: std.mem.Allocator,
        assistant_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.AssistantObject) {
        return self.get_assistant(allocator, assistant_id);
    }

    /// GET /assistants/{assistant_id}
    pub fn retrieve(
        self: *const Resource,
        allocator: std.mem.Allocator,
        assistant_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.AssistantObject) {
        return self.get_assistant(allocator, assistant_id);
    }

    /// POST /assistants/{assistant_id}
    pub fn update(
        self: *const Resource,
        allocator: std.mem.Allocator,
        assistant_id: []const u8,
        body: gen.ModifyAssistantRequest,
    ) errors.Error!std.json.Parsed(gen.AssistantObject) {
        return self.modify_assistant(allocator, assistant_id, body);
    }

    /// DELETE /assistants/{assistant_id}
    pub fn delete(
        self: *const Resource,
        allocator: std.mem.Allocator,
        assistant_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteAssistantResponse) {
        return self.delete_assistant(allocator, assistant_id);
    }

    /// POST /threads
    pub fn create_thread_alias(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateThreadRequest,
    ) errors.Error!std.json.Parsed(gen.ThreadObject) {
        return self.create_thread(allocator, body);
    }

    /// GET /threads/{thread_id}
    pub fn retrieve_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ThreadObject) {
        return self.get_thread(allocator, thread_id);
    }

    /// GET /threads/{thread_id}
    pub fn get_thread_alias(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ThreadObject) {
        return self.get_thread(allocator, thread_id);
    }
};
