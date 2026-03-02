const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

/// Minimal request shape for POST /chat/completions (text content only).
pub const ChatMessage = struct {
    role: []const u8,
    content: []const u8,
};

pub const CreateChatCompletionRequest = struct {
    model: []const u8,
    messages: []const ChatMessage,
    max_tokens: ?u32 = null,
    temperature: ?f64 = null,
    stream: ?bool = null,
    response_format: ?std.json.Value = null,
};

const StreamResponseDelta = struct {
    content: ?std.json.Value = null,
    function_call: ?std.json.Value = null,
    tool_calls: ?std.json.Value = null,
    role: ?[]const u8 = null,
    refusal: ?std.json.Value = null,
};

const StreamResponseChoice = struct {
    delta: StreamResponseDelta = .{},
    finish_reason: ?std.json.Value = null,
    index: i64 = 0,
    logprobs: ?std.json.Value = null,
};

pub const CreateChatCompletionStreamResponse = struct {
    id: ?[]const u8 = null,
    choices: []const StreamResponseChoice = &.{},
    created: ?i64 = null,
    model: ?[]const u8 = null,
    service_tier: ?std.json.Value = null,
    system_fingerprint: ?[]const u8 = null,
    object: ?[]const u8 = null,
    usage: ?std.json.Value = null,
};

pub const StreamEventHandler = *const fn (
    user_ctx: ?*anyopaque,
    event: std.json.Parsed(CreateChatCompletionStreamResponse),
) errors.Error!void;

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    /// GET /chat/completions
    pub fn list_chat_completions(
        self: *const Resource,
        allocator: std.mem.Allocator,
    ) errors.Error!std.json.Parsed(gen.ChatCompletionList) {
        return common.sendNoBodyTyped(self.transport, allocator, .GET, "/chat/completions", gen.ChatCompletionList);
    }

    /// GET /chat/completions
    pub fn list(self: *const Resource, allocator: std.mem.Allocator) errors.Error!std.json.Parsed(gen.ChatCompletionList) {
        return self.list_chat_completions(allocator);
    }

    pub fn list_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ChatCompletionList) {
        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            .GET,
            "/chat/completions",
            gen.ChatCompletionList,
            request_opts,
        );
    }

    /// POST /chat/completions -> dynamic JSON.
    pub fn create_chat_completion(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRequest,
    ) errors.Error!std.json.Parsed(gen.CreateChatCompletionResponse) {
        return common.sendJsonTyped(self.transport, allocator, .POST, "/chat/completions", req, gen.CreateChatCompletionResponse);
    }

    pub fn create_chat_completion_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CreateChatCompletionResponse) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            "/chat/completions",
            req,
            gen.CreateChatCompletionResponse,
            request_opts,
        );
    }

    /// POST /chat/completions -> dynamic JSON.
    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRequest,
    ) errors.Error!std.json.Parsed(gen.CreateChatCompletionResponse) {
        return self.create_chat_completion(allocator, req);
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CreateChatCompletionResponse) {
        return self.create_chat_completion_with_options(allocator, req, request_opts);
    }

    /// GET /chat/completions/{completion_id}
    pub fn get_chat_completion(
        self: *const Resource,
        allocator: std.mem.Allocator,
        completion_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.CreateChatCompletionResponse) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/chat/completions/{s}", .{completion_id}) catch {
            return errors.Error.SerializeError;
        };
        return common.sendNoBodyTyped(self.transport, allocator, .GET, path, gen.CreateChatCompletionResponse);
    }

    /// GET /chat/completions/{completion_id}
    pub fn retrieve(
        self: *const Resource,
        allocator: std.mem.Allocator,
        completion_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.CreateChatCompletionResponse) {
        return self.get_chat_completion(allocator, completion_id);
    }

    /// POST /chat/completions/{completion_id} (generic JSON payload)
    pub fn update_chat_completion(
        self: *const Resource,
        allocator: std.mem.Allocator,
        completion_id: []const u8,
        payload: ?[]const u8,
    ) errors.Error!std.json.Parsed(gen.CreateChatCompletionResponse) {
        return self.update_chat_completion_with_options(allocator, completion_id, payload, null);
    }

    pub fn update_chat_completion_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        completion_id: []const u8,
        payload: ?[]const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CreateChatCompletionResponse) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/chat/completions/{s}", .{completion_id}) catch {
            return errors.Error.SerializeError;
        };
        return common.sendRawJsonTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            path,
            payload,
            gen.CreateChatCompletionResponse,
            request_opts,
        );
    }

    /// DELETE /chat/completions/{completion_id}
    pub fn delete_chat_completion(
        self: *const Resource,
        allocator: std.mem.Allocator,
        completion_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ChatCompletionDeleted) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/chat/completions/{s}", .{completion_id}) catch {
            return errors.Error.SerializeError;
        };
        return common.sendNoBodyTyped(self.transport, allocator, .DELETE, path, gen.ChatCompletionDeleted);
    }

    /// DELETE /chat/completions/{completion_id}
    pub fn delete(self: *const Resource, allocator: std.mem.Allocator, completion_id: []const u8) errors.Error!std.json.Parsed(gen.ChatCompletionDeleted) {
        return self.delete_chat_completion(allocator, completion_id);
    }

    /// GET /chat/completions/{completion_id}/messages
    pub fn get_chat_completion_messages(
        self: *const Resource,
        allocator: std.mem.Allocator,
        completion_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ChatCompletionMessageList) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/chat/completions/{s}/messages", .{completion_id}) catch {
            return errors.Error.SerializeError;
        };
        return common.sendNoBodyTyped(self.transport, allocator, .GET, path, gen.ChatCompletionMessageList);
    }

    /// POST /chat/completions (streaming)
    pub fn create_chat_completion_stream(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRequest,
        on_event: StreamEventHandler,
        user_ctx: ?*anyopaque,
    ) errors.Error!void {
        return self.create_chat_completion_stream_with_options(allocator, req, on_event, user_ctx, null);
    }

    pub fn create_chat_completion_stream_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRequest,
        on_event: StreamEventHandler,
        user_ctx: ?*anyopaque,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!void {
        var stream_req = req;
        stream_req.stream = true;

        var body_writer = std.io.Writer.Allocating.init(allocator);
        defer body_writer.deinit();

        var json_stream: std.json.Stringify = .{
            .writer = &body_writer.writer,
            .options = .{ .emit_null_optional_fields = false },
        };
        json_stream.write(stream_req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        try common.sendStreamTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            "/chat/completions",
            &.{
                .{ .name = "Accept", .value = "text/event-stream" },
                .{ .name = "Content-Type", .value = "application/json" },
            },
            payload,
            CreateChatCompletionStreamResponse,
            on_event,
            user_ctx,
            request_opts,
        );
    }

    pub fn create_with_options_stream(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRequest,
        on_event: StreamEventHandler,
        user_ctx: ?*anyopaque,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!void {
        return self.create_chat_completion_stream_with_options(
            allocator,
            req,
            on_event,
            user_ctx,
            request_opts,
        );
    }
};

test "create chat request omits null optional fields" {
    const req = CreateChatCompletionRequest{
        .model = "test-model",
        .messages = &[_]ChatMessage{
            .{ .role = "user", .content = "hi" },
        },
        .max_tokens = null,
        .temperature = null,
        .stream = null,
        .response_format = null,
    };

    var writer = std.io.Writer.Allocating.init(std.testing.allocator);
    defer writer.deinit();
    var json_stream: std.json.Stringify = .{
        .writer = &writer.writer,
        .options = .{ .emit_null_optional_fields = false },
    };
    try json_stream.write(req);

    const body = writer.written();
    const parsed = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        body,
        .{},
    );
    defer parsed.deinit();

    const expected = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"model\":\"test-model\",\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}]}",
        .{},
    );
    defer expected.deinit();

    try std.testing.expect(std.json.eql(parsed.value, expected.value));
}
