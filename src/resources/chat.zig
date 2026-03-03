const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const ChatTool = gen.ChatCompletionTool;
pub const ChatFunction = gen.FunctionObject;
pub const ChatNamedToolChoice = gen.ChatCompletionNamedToolChoice;

pub const ChatLogitBiasEntry = struct {
    token: []const u8,
    bias: i64,
};

pub const ChatLogitBias = union(enum) {
    entries: []const ChatLogitBiasEntry,
    raw: std.json.Value,

    pub fn forEntries(entries: []const ChatLogitBiasEntry) ChatLogitBias {
        return .{ .entries = entries };
    }

    pub fn forRaw(value: std.json.Value) ChatLogitBias {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ChatLogitBias, writer: anytype) !void {
        switch (self) {
            .entries => |value| {
                try writer.beginObject();
                for (value) |entry| {
                    try writer.objectField(entry.token);
                    try writer.write(entry.bias);
                }
                try writer.endObject();
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }
};

pub const ChatFunctionCall = union(enum) {
    none: void,
    auto: void,
    named: []const u8,
    raw: std.json.Value,

    pub fn forNone() ChatFunctionCall {
        return .none;
    }

    pub fn forAuto() ChatFunctionCall {
        return .auto;
    }

    pub fn forName(name: []const u8) ChatFunctionCall {
        return .{ .named = name };
    }

    pub fn forRaw(value: std.json.Value) ChatFunctionCall {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ChatFunctionCall, writer: anytype) !void {
        switch (self) {
            .none => {
                try writer.write("none");
            },
            .auto => {
                try writer.write("auto");
            },
            .named => |value| {
                try writer.beginObject();
                try writer.objectField("type");
                try writer.write("function");
                try writer.objectField("function");
                try writer.beginObject();
                try writer.objectField("name");
                try writer.write(value);
                try writer.endObject();
                try writer.endObject();
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }
};

pub const ChatToolChoice = union(enum) {
    none: void,
    auto: void,
    required: void,
    named: ChatNamedToolChoice,
    raw: std.json.Value,

    pub fn forNone() ChatToolChoice {
        return .none;
    }

    pub fn forAuto() ChatToolChoice {
        return .auto;
    }

    pub fn forRequired() ChatToolChoice {
        return .required;
    }

    pub fn forFunction(name: []const u8) ChatToolChoice {
        return .{
            .named = .{
                .type = "function",
                .function = .{
                    .name = name,
                },
            },
        };
    }

    pub fn forRaw(value: std.json.Value) ChatToolChoice {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ChatToolChoice, writer: anytype) !void {
        switch (self) {
            .none => {
                try writer.write("none");
            },
            .auto => {
                try writer.write("auto");
            },
            .required => {
                try writer.write("required");
            },
            .named => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }
};

pub const ChatTools = []const ChatTool;

pub const ChatToolsBuilder = struct {
    pub fn function(
        name: []const u8,
        description: ?[]const u8,
        parameters: std.json.Value,
    ) ChatTool {
        return .{
            .type = "function",
            .function = .{
                .name = name,
                .description = description,
                .parameters = .forSchema(parameters),
                .strict = null,
            },
        };
    }

    pub fn functionStrict(
        name: []const u8,
        description: ?[]const u8,
        parameters: std.json.Value,
        strict: bool,
    ) ChatTool {
        return .{
            .type = "function",
            .function = .{
                .name = name,
                .description = description,
                .parameters = .forSchema(parameters),
                .strict = .{ .bool = strict },
            },
        };
    }
};

pub const ChatResponseFormatSchema = struct {
    name: ?[]const u8 = null,
    description: ?[]const u8 = null,
    schema: std.json.Value,
    strict: ?bool = null,
};

pub const ResponseFormat = union(enum) {
    text: void,
    json_object: void,
    json_schema: ChatResponseFormatSchema,
    raw: std.json.Value,

    pub fn forText() ResponseFormat {
        return .text;
    }

    pub fn forJsonObject() ResponseFormat {
        return .json_object;
    }

    pub fn forJsonSchema(schema: std.json.Value, options: ChatResponseFormatSchema) ResponseFormat {
        var payload = options;
        payload.schema = schema;
        return .{ .json_schema = payload };
    }

    pub fn forRaw(value: std.json.Value) ResponseFormat {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ResponseFormat, writer: anytype) !void {
        switch (self) {
            .text => {
                try writer.beginObject();
                try writer.objectField("type");
                try writer.write("text");
                try writer.endObject();
            },
            .json_object => {
                try writer.beginObject();
                try writer.objectField("type");
                try writer.write("json_object");
                try writer.endObject();
            },
            .json_schema => |value| {
                try writer.beginObject();
                try writer.objectField("type");
                try writer.write("json_schema");

                try writer.objectField("json_schema");
                try writer.beginObject();
                if (value.name) |name| {
                    try writer.objectField("name");
                    try writer.write(name);
                }
                if (value.description) |description| {
                    try writer.objectField("description");
                    try writer.write(description);
                }
                try writer.objectField("schema");
                try writer.write(value.schema);
                if (value.strict) |strict| {
                    try writer.objectField("strict");
                    try writer.write(strict);
                }
                try writer.endObject();
                try writer.endObject();
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }
};

/// Flexible request shape for POST /chat/completions.
pub const ChatMessage = struct {
    role: []const u8,
    content: ?[]const u8 = null,
    content_json: ?std.json.Value = null,
    name: ?[]const u8 = null,
    reasoning_content: ?[]const u8 = null,
    function_call: ?gen.ChatCompletionRequestFunctionCall = null,
    tool_calls: ?gen.ChatCompletionMessageToolCalls = null,
    tool_call_id: ?[]const u8 = null,
    audio: ?gen.ChatCompletionRequestAssistantMessageAudio = null,
    prefix: ?bool = null,

    pub fn jsonStringify(self: ChatMessage, writer: anytype) !void {
        try writer.beginObject();
        try writer.objectField("role");
        try writer.write(self.role);

        if (self.content) |content| {
            try writer.objectField("content");
            try writer.write(content);
        } else if (self.content_json) |content_json| {
            try writer.objectField("content");
            try writer.write(content_json);
        }

        if (self.name) |value| {
            try writer.objectField("name");
            try writer.write(value);
        }
        if (self.reasoning_content) |value| {
            try writer.objectField("reasoning_content");
            try writer.write(value);
        }
        if (self.function_call) |value| {
            try writer.objectField("function_call");
            try writer.write(value);
        }
        if (self.tool_calls) |value| {
            try writer.objectField("tool_calls");
            try writer.write(value);
        }
        if (self.tool_call_id) |value| {
            try writer.objectField("tool_call_id");
            try writer.write(value);
        }
        if (self.audio) |value| {
            try writer.objectField("audio");
            try writer.write(value);
        }
        if (self.prefix) |value| {
            try writer.objectField("prefix");
            try writer.write(value);
        }
        try writer.endObject();
    }

    pub fn withContent(role: []const u8, content: []const u8) ChatMessage {
        return .{
            .role = role,
            .content = content,
        };
    }

    pub fn withContentValue(role: []const u8, content_json: std.json.Value) ChatMessage {
        return .{
            .role = role,
            .content_json = content_json,
        };
    }
};

pub const CreateChatCompletionRequest = struct {
    model: []const u8,
    messages: []const ChatMessage,
    max_tokens: ?u32 = null,
    seed: ?u64 = null,
    max_completion_tokens: ?u32 = null,
    n: ?u32 = null,
    logit_bias: ?ChatLogitBias = null,
    functions: ?[]const gen.ChatCompletionFunctions = null,
    function_call: ?ChatFunctionCall = null,
    top_p: ?f64 = null,
    temperature: ?f64 = null,
    stop: ?gen.StopConfiguration = null,
    presence_penalty: ?f64 = null,
    frequency_penalty: ?f64 = null,
    user: ?[]const u8 = null,
    stream_options: ?gen.ChatCompletionStreamOptions = null,
    tools: ?ChatTools = null,
    tool_choice: ?ChatToolChoice = null,
    parallel_tool_calls: ?bool = null,
    reasoning_effort: ?gen.ReasoningEffort = null,
    service_tier: ?[]const u8 = null,
    metadata: ?std.json.Value = null,
    logprobs: ?bool = null,
    top_logprobs: ?u32 = null,
    thinking: ?std.json.Value = null,
    modalities: ?gen.ChatCompletionModalities = null,
    audio: ?std.json.Value = null,
    store: ?bool = null,
    prediction: ?std.json.Value = null,
    stream: ?bool = null,
    response_format: ?ResponseFormat = null,
    extra_body: ?std.json.Value = null,

    pub fn jsonStringify(self: CreateChatCompletionRequest, writer: anytype) !void {
        try writer.beginObject();
        try writer.objectField("model");
        try writer.write(self.model);
        try writer.objectField("messages");
        try writer.write(self.messages);

        if (self.max_tokens) |value| {
            try writer.objectField("max_tokens");
            try writer.write(value);
        }
        if (self.seed) |value| {
            try writer.objectField("seed");
            try writer.write(value);
        }
        if (self.max_completion_tokens) |value| {
            try writer.objectField("max_completion_tokens");
            try writer.write(value);
        }
        if (self.n) |value| {
            try writer.objectField("n");
            try writer.write(value);
        }
        if (self.logit_bias) |value| {
            try writer.objectField("logit_bias");
            try writer.write(value);
        }
        if (self.functions) |value| {
            try writer.objectField("functions");
            try writer.write(value);
        }
        if (self.function_call) |value| {
            try writer.objectField("function_call");
            try writer.write(value);
        }
        if (self.top_p) |value| {
            try writer.objectField("top_p");
            try writer.write(value);
        }
        if (self.temperature) |value| {
            try writer.objectField("temperature");
            try writer.write(value);
        }
        if (self.stop) |value| {
            try writer.objectField("stop");
            try writer.write(value);
        }
        if (self.presence_penalty) |value| {
            try writer.objectField("presence_penalty");
            try writer.write(value);
        }
        if (self.frequency_penalty) |value| {
            try writer.objectField("frequency_penalty");
            try writer.write(value);
        }
        if (self.user) |value| {
            try writer.objectField("user");
            try writer.write(value);
        }
        if (self.stream_options) |value| {
            try writer.objectField("stream_options");
            try writer.write(value);
        }
        if (self.tools) |value| {
            try writer.objectField("tools");
            try writer.write(value);
        }
        if (self.tool_choice) |value| {
            try writer.objectField("tool_choice");
            try writer.write(value);
        }
        if (self.parallel_tool_calls) |value| {
            try writer.objectField("parallel_tool_calls");
            try writer.write(value);
        }
        if (self.reasoning_effort) |value| {
            try writer.objectField("reasoning_effort");
            try writer.write(value);
        }
        if (self.service_tier) |value| {
            try writer.objectField("service_tier");
            try writer.write(value);
        }
        if (self.metadata) |value| {
            try writer.objectField("metadata");
            try writer.write(value);
        }
        if (self.logprobs) |value| {
            try writer.objectField("logprobs");
            try writer.write(value);
        }
        if (self.top_logprobs) |value| {
            try writer.objectField("top_logprobs");
            try writer.write(value);
        }
        if (self.thinking) |value| {
            try writer.objectField("thinking");
            try writer.write(value);
        }
        if (self.modalities) |value| {
            try writer.objectField("modalities");
            try writer.write(value);
        }
        if (self.audio) |value| {
            try writer.objectField("audio");
            try writer.write(value);
        }
        if (self.store) |value| {
            try writer.objectField("store");
            try writer.write(value);
        }
        if (self.prediction) |value| {
            try writer.objectField("prediction");
            try writer.write(value);
        }
        if (self.stream) |value| {
            try writer.objectField("stream");
            try writer.write(value);
        }
        if (self.response_format) |value| {
            try writer.objectField("response_format");
            try writer.write(value);
        }
        if (self.extra_body) |value| {
            switch (value) {
                .object => |extra| {
                    var entries = extra.iterator();
                    while (entries.next()) |entry| {
                        try writer.objectField(entry.key_ptr.*);
                        try writer.write(entry.value_ptr.*);
                    }
                },
                else => {
                    try writer.objectField("extra_body");
                    try writer.write(value);
                },
            }
        }

        try writer.endObject();
    }
};

pub const CreateChatCompletionRawRequest = std.json.Value;

const StreamResponseDelta = struct {
    content: ?[]const u8 = null,
    reasoning_content: ?[]const u8 = null,
    function_call: ?gen.ChatCompletionRequestFunctionCall = null,
    tool_calls: ?[]const gen.ChatCompletionMessageToolCallChunk = null,
    role: ?[]const u8 = null,
    refusal: ?[]const u8 = null,
    audio: ?gen.ChatCompletionResponseMessageAudio = null,
};

const StreamResponseLogprobs = struct {
    content: ?[]const gen.ChatCompletionTokenLogprob = null,
    refusal: ?[]const gen.ChatCompletionTokenLogprob = null,
};

const StreamResponseChoice = struct {
    delta: StreamResponseDelta = .{},
    finish_reason: ?[]const u8 = null,
    index: i64 = 0,
    logprobs: ?StreamResponseLogprobs = null,
};

pub const CreateChatCompletionStreamResponse = struct {
    id: ?[]const u8 = null,
    choices: []const StreamResponseChoice = &.{},
    created: ?i64 = null,
    model: ?[]const u8 = null,
    service_tier: ?gen.ServiceTier = null,
    system_fingerprint: ?[]const u8 = null,
    object: ?[]const u8 = null,
    usage: ?gen.CompletionUsage = null,
};

pub const StreamEventHandler = *const fn (
    user_ctx: ?*anyopaque,
    event: std.json.Parsed(CreateChatCompletionStreamResponse),
) errors.Error!void;
pub const StreamDoneHandler = *const fn (user_ctx: ?*anyopaque) errors.Error!void;

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

    /// POST /chat/completions -> raw JSON payload.
    pub fn create_chat_completion_raw(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRawRequest,
    ) errors.Error!std.json.Parsed(gen.CreateChatCompletionResponse) {
        return common.sendJsonTyped(self.transport, allocator, .POST, "/chat/completions", req, gen.CreateChatCompletionResponse);
    }

    /// POST /chat/completions -> raw JSON payload with request options.
    pub fn create_chat_completion_raw_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRawRequest,
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

    /// POST /chat/completions -> dynamic JSON value payload.
    pub fn create_chat_completion_value(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return common.sendJsonTyped(self.transport, allocator, .POST, "/chat/completions", req, std.json.Value);
    }

    pub fn create_chat_completion_value_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            "/chat/completions",
            req,
            std.json.Value,
            request_opts,
        );
    }

    /// POST /chat/completions -> raw JSON payload returning raw JSON value.
    pub fn create_chat_completion_raw_value(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRawRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return common.sendJsonTyped(self.transport, allocator, .POST, "/chat/completions", req, std.json.Value);
    }

    /// POST /chat/completions -> raw JSON payload with request options returning raw JSON value.
    pub fn create_chat_completion_raw_value_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRawRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            "/chat/completions",
            req,
            std.json.Value,
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

    /// POST /chat/completions -> raw JSON payload.
    pub fn create_raw(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRawRequest,
    ) errors.Error!std.json.Parsed(gen.CreateChatCompletionResponse) {
        return self.create_chat_completion_raw(allocator, req);
    }

    /// POST /chat/completions -> raw JSON payload with request options.
    pub fn create_raw_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRawRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CreateChatCompletionResponse) {
        return self.create_chat_completion_raw_with_options(allocator, req, request_opts);
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
        return self.create_chat_completion_stream_with_done(
            allocator,
            req,
            on_event,
            user_ctx,
            null,
            null,
        );
    }

    pub fn create_chat_completion_stream_with_done(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRequest,
        on_event: StreamEventHandler,
        user_ctx: ?*anyopaque,
        on_done: ?StreamDoneHandler,
        done_ctx: ?*anyopaque,
    ) errors.Error!void {
        return self.create_chat_completion_stream_with_options_and_done(
            allocator,
            req,
            on_event,
            user_ctx,
            null,
            on_done,
            done_ctx,
        );
    }

    pub fn create_chat_completion_stream_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRequest,
        on_event: StreamEventHandler,
        user_ctx: ?*anyopaque,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!void {
        return self.create_chat_completion_stream_with_options_and_done(
            allocator,
            req,
            on_event,
            user_ctx,
            request_opts,
            null,
            null,
        );
    }

    pub fn create_chat_completion_stream_with_options_and_done(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRequest,
        on_event: StreamEventHandler,
        user_ctx: ?*anyopaque,
        request_opts: ?transport_mod.Transport.RequestOptions,
        on_done: ?StreamDoneHandler,
        done_ctx: ?*anyopaque,
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

        try common.sendStreamTypedWithDoneWithOptions(
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
            on_done,
            done_ctx,
            request_opts,
        );
    }

    pub fn create_chat_completion_stream_raw(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRawRequest,
        on_event: StreamEventHandler,
        user_ctx: ?*anyopaque,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!void {
        return self.create_chat_completion_stream_raw_with_done_and_options(
            allocator,
            req,
            on_event,
            user_ctx,
            request_opts,
            null,
            null,
        );
    }

    pub fn create_chat_completion_stream_raw_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRawRequest,
        on_event: StreamEventHandler,
        user_ctx: ?*anyopaque,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!void {
        return self.create_chat_completion_stream_raw_with_done_and_options(
            allocator,
            req,
            on_event,
            user_ctx,
            request_opts,
            null,
            null,
        );
    }

    pub fn create_chat_completion_stream_raw_with_done(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRawRequest,
        on_event: StreamEventHandler,
        user_ctx: ?*anyopaque,
        on_done: ?StreamDoneHandler,
        done_ctx: ?*anyopaque,
    ) errors.Error!void {
        return self.create_chat_completion_stream_raw_with_done_and_options(
            allocator,
            req,
            on_event,
            user_ctx,
            null,
            on_done,
            done_ctx,
        );
    }

    pub fn create_chat_completion_stream_raw_with_done_and_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRawRequest,
        on_event: StreamEventHandler,
        user_ctx: ?*anyopaque,
        request_opts: ?transport_mod.Transport.RequestOptions,
        on_done: ?StreamDoneHandler,
        done_ctx: ?*anyopaque,
    ) errors.Error!void {
        var body_writer = std.io.Writer.Allocating.init(allocator);
        defer body_writer.deinit();

        var json_stream: std.json.Stringify = .{
            .writer = &body_writer.writer,
            .options = .{ .emit_null_optional_fields = false },
        };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        try common.sendStreamTypedWithDoneWithOptions(
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
            on_done,
            done_ctx,
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

    pub fn create_raw_with_options_stream(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRawRequest,
        on_event: StreamEventHandler,
        user_ctx: ?*anyopaque,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!void {
        return self.create_chat_completion_stream_raw(
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

test "create chat request supports prefix continuation flag" {
    const req = CreateChatCompletionRequest{
        .model = "test-model",
        .messages = &[_]ChatMessage{
            .{
                .role = "assistant",
                .content = "Before text.",
                .prefix = true,
            },
        },
        .stream = null,
    };

    var writer = std.io.Writer.Allocating.init(std.testing.allocator);
    defer writer.deinit();
    var json_stream: std.json.Stringify = .{
        .writer = &writer.writer,
        .options = .{ .emit_null_optional_fields = false },
    };
    try json_stream.write(req);

    const body = writer.written();
    const parsed = try std.json.parseFromSlice(std.json.Value, std.testing.allocator, body, .{});
    defer parsed.deinit();

    const expected = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"model\":\"test-model\",\"messages\":[{\"role\":\"assistant\",\"content\":\"Before text.\",\"prefix\":true}]}",
        .{},
    );
    defer expected.deinit();

    try std.testing.expect(std.json.eql(parsed.value, expected.value));
}

test "create chat request supports tool declarations and tool_choice" {
    const tool_schema = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"type\":\"object\",\"properties\":{\"city\":{\"type\":\"string\"}},\"required\":[\"city\"]}",
        .{},
    );
    defer tool_schema.deinit();

    const tools = [_]ChatTool{
        .{
            .type = "function",
            .function = .{
                .name = "get_weather",
                .description = "Get weather by city",
                .parameters = .forSchema(tool_schema.value),
                .strict = null,
            },
        },
    };

    const req = CreateChatCompletionRequest{
        .model = "test-model",
        .messages = &[_]ChatMessage{
            .{ .role = "user", .content = "What's the weather in Beijing?" },
        },
        .stream = null,
        .tools = &tools,
        .tool_choice = .forFunction("get_weather"),
    };

    var writer = std.io.Writer.Allocating.init(std.testing.allocator);
    defer writer.deinit();
    var json_stream: std.json.Stringify = .{
        .writer = &writer.writer,
        .options = .{ .emit_null_optional_fields = false },
    };
    try json_stream.write(req);

    const body = writer.written();
    const parsed = try std.json.parseFromSlice(std.json.Value, std.testing.allocator, body, .{});
    defer parsed.deinit();

    const expected = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"model\":\"test-model\",\"messages\":[{\"role\":\"user\",\"content\":\"What's the weather in Beijing?\"}],\"tools\":[{\"type\":\"function\",\"function\":{\"name\":\"get_weather\",\"description\":\"Get weather by city\",\"parameters\":{\"type\":\"object\",\"properties\":{\"city\":{\"type\":\"string\"}},\"required\":[\"city\"]}}}],\"tool_choice\":{\"type\":\"function\",\"function\":{\"name\":\"get_weather\"}}}",
        .{},
    );
    defer expected.deinit();

    try std.testing.expect(std.json.eql(parsed.value, expected.value));
}

test "create chat request supports strict tool definition and tool choice modes" {
    const tool_schema = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"type\":\"object\",\"properties\":{\"city\":{\"type\":\"string\"}},\"required\":[\"city\"]}",
        .{},
    );
    defer tool_schema.deinit();

    const tools = [_]ChatTool{
        ChatToolsBuilder.functionStrict(
            "get_weather_strict",
            "Get weather and require strict output",
            tool_schema.value,
            true,
        ),
    };

    const request_none = CreateChatCompletionRequest{
        .model = "test-model",
        .messages = &[_]ChatMessage{
            .{ .role = "user", .content = "Weather?" },
        },
        .tools = &tools,
        .tool_choice = .forRequired(),
    };

    var writer = std.io.Writer.Allocating.init(std.testing.allocator);
    defer writer.deinit();
    var json_stream: std.json.Stringify = .{
        .writer = &writer.writer,
        .options = .{ .emit_null_optional_fields = false },
    };
    try json_stream.write(request_none);

    const body = writer.written();
    const parsed = try std.json.parseFromSlice(std.json.Value, std.testing.allocator, body, .{});
    defer parsed.deinit();

    const expected = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"model\":\"test-model\",\"messages\":[{\"role\":\"user\",\"content\":\"Weather?\"}],\"tools\":[{\"type\":\"function\",\"function\":{\"name\":\"get_weather_strict\",\"description\":\"Get weather and require strict output\",\"parameters\":{\"type\":\"object\",\"properties\":{\"city\":{\"type\":\"string\"}},\"required\":[\"city\"]},\"strict\":true}}],\"tool_choice\":\"required\"}",
        .{},
    );
    defer expected.deinit();

    try std.testing.expect(std.json.eql(parsed.value, expected.value));
}

test "create chat request supports json_object response_format" {
    const req = CreateChatCompletionRequest{
        .model = "test-model",
        .messages = &[_]ChatMessage{
            .{ .role = "user", .content = "hi" },
        },
        .stream = null,
        .response_format = .json_object,
    };

    var writer = std.io.Writer.Allocating.init(std.testing.allocator);
    defer writer.deinit();
    var json_stream: std.json.Stringify = .{
        .writer = &writer.writer,
        .options = .{ .emit_null_optional_fields = false },
    };
    try json_stream.write(req);

    const body = writer.written();
    const parsed = try std.json.parseFromSlice(std.json.Value, std.testing.allocator, body, .{});
    defer parsed.deinit();

    const expected = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"model\":\"test-model\",\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}],\"response_format\":{\"type\":\"json_object\"}}",
        .{},
    );
    defer expected.deinit();

    try std.testing.expect(std.json.eql(parsed.value, expected.value));
}

test "create chat request supports json_schema response_format" {
    const schema = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"type\":\"object\",\"properties\":{\"question\":{\"type\":\"string\"},\"answer\":{\"type\":\"string\"}},\"required\":[\"question\",\"answer\"]}",
        .{},
    );
    defer schema.deinit();

    const req = CreateChatCompletionRequest{
        .model = "test-model",
        .messages = &[_]ChatMessage{
            .{ .role = "user", .content = "hi" },
        },
        .stream = null,
        .response_format = ResponseFormat{
            .json_schema = .{
                .name = "qa",
                .description = "question/answer pair",
                .schema = schema.value,
                .strict = true,
            },
        },
    };

    var writer = std.io.Writer.Allocating.init(std.testing.allocator);
    defer writer.deinit();
    var json_stream: std.json.Stringify = .{
        .writer = &writer.writer,
        .options = .{ .emit_null_optional_fields = false },
    };
    try json_stream.write(req);

    const body = writer.written();
    const parsed = try std.json.parseFromSlice(std.json.Value, std.testing.allocator, body, .{});
    defer parsed.deinit();

    const expected = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"model\":\"test-model\",\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}],\"response_format\":{\"type\":\"json_schema\",\"json_schema\":{\"name\":\"qa\",\"description\":\"question/answer pair\",\"schema\":{\"type\":\"object\",\"properties\":{\"question\":{\"type\":\"string\"},\"answer\":{\"type\":\"string\"}},\"required\":[\"question\",\"answer\"]},\"strict\":true}}}",
        .{},
    );
    defer expected.deinit();

    try std.testing.expect(std.json.eql(parsed.value, expected.value));
}

test "create chat request supports complex message content via content_json" {
    const raw_content = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "[{\"type\":\"text\",\"text\":\"hello\"}]",
        .{},
    );
    defer raw_content.deinit();

    const req = CreateChatCompletionRequest{
        .model = "test-model",
        .messages = &[_]ChatMessage{
            .{
                .role = "user",
                .content_json = raw_content.value,
            },
        },
        .stream = null,
    };

    var writer = std.io.Writer.Allocating.init(std.testing.allocator);
    defer writer.deinit();
    var json_stream: std.json.Stringify = .{
        .writer = &writer.writer,
        .options = .{ .emit_null_optional_fields = false },
    };
    try json_stream.write(req);

    const body = writer.written();
    const parsed = try std.json.parseFromSlice(std.json.Value, std.testing.allocator, body, .{});
    defer parsed.deinit();

    const expected = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"model\":\"test-model\",\"messages\":[{\"role\":\"user\",\"content\":[{\"type\":\"text\",\"text\":\"hello\"}]}]}",
        .{},
    );
    defer expected.deinit();

    try std.testing.expect(std.json.eql(parsed.value, expected.value));
}

test "create chat raw request keeps custom fields" {
    const req = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"model\":\"test-model\",\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}],\"temperature\":0.7,\"extra_field\":\"custom\"}",
        .{},
    );
    defer req.deinit();

    var writer = std.io.Writer.Allocating.init(std.testing.allocator);
    defer writer.deinit();
    var json_stream: std.json.Stringify = .{
        .writer = &writer.writer,
        .options = .{ .emit_null_optional_fields = false },
    };
    try json_stream.write(req.value);

    const body = writer.written();
    const parsed = try std.json.parseFromSlice(std.json.Value, std.testing.allocator, body, .{});
    defer parsed.deinit();

    const expected = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"model\":\"test-model\",\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}],\"temperature\":0.7,\"extra_field\":\"custom\"}",
        .{},
    );
    defer expected.deinit();

    try std.testing.expect(std.json.eql(parsed.value, expected.value));
}

test "create chat request supports compatibility extensions (function calling + store/modalities/audio)" {
    const function_parameters = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"type\":\"object\",\"properties\":{\"city\":{\"type\":\"string\"}}}",
        .{},
    );
    defer function_parameters.deinit();

    const function_call = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"type\":\"function\",\"function\":{\"name\":\"get_weather\"}}",
        .{},
    );
    defer function_call.deinit();

    const logit_bias = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"token\":-1}",
        .{},
    );
    defer logit_bias.deinit();

    const request = CreateChatCompletionRequest{
        .model = "test-model",
        .messages = &[_]ChatMessage{
            .{ .role = "user", .content = "Hello" },
        },
        .functions = &[_]gen.ChatCompletionFunctions{
            .{
                .name = "get_weather",
                .description = "Get weather",
                .parameters = .forSchema(function_parameters.value),
            },
        },
        .function_call = .{ .raw = function_call.value },
        .logit_bias = .{ .raw = logit_bias.value },
        .modalities = &.{"text"},
        .audio = .{ .null = {} },
        .store = true,
        .prediction = .{ .null = {} },
    };

    var writer = std.io.Writer.Allocating.init(std.testing.allocator);
    defer writer.deinit();
    var json_stream: std.json.Stringify = .{
        .writer = &writer.writer,
        .options = .{ .emit_null_optional_fields = false },
    };
    try json_stream.write(request);

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
        "{\"model\":\"test-model\",\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}],\"functions\":[{\"name\":\"get_weather\",\"description\":\"Get weather\",\"parameters\":{\"type\":\"object\",\"properties\":{\"city\":{\"type\":\"string\"}}}}],\"function_call\":{\"type\":\"function\",\"function\":{\"name\":\"get_weather\"}},\"logit_bias\":{\"token\":-1},\"modalities\":[\"text\"],\"audio\":null,\"store\":true,\"prediction\":null}",
        .{},
    );
    defer expected.deinit();

    try std.testing.expect(std.json.eql(parsed.value, expected.value));
}

test "create chat request supports typed function_call and logit_bias" {
    const request = CreateChatCompletionRequest{
        .model = "test-model",
        .messages = &[_]ChatMessage{
            .{ .role = "user", .content = "Hello" },
        },
        .function_call = .forName("get_weather"),
        .logit_bias = .forEntries(&[_]ChatLogitBiasEntry{
            .{ .token = "123", .bias = -1 },
            .{ .token = "456", .bias = 2 },
        }),
    };

    var writer = std.io.Writer.Allocating.init(std.testing.allocator);
    defer writer.deinit();
    var json_stream: std.json.Stringify = .{
        .writer = &writer.writer,
        .options = .{ .emit_null_optional_fields = false },
    };
    try json_stream.write(request);

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
        "{\"model\":\"test-model\",\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}],\"function_call\":{\"type\":\"function\",\"function\":{\"name\":\"get_weather\"}},\"logit_bias\":{\"123\":-1,\"456\":2}}",
        .{},
    );
    defer expected.deinit();

    try std.testing.expect(std.json.eql(parsed.value, expected.value));
}

test "create chat request supports structured stop field" {
    const request_single = CreateChatCompletionRequest{
        .model = "test-model",
        .messages = &[_]ChatMessage{
            .{ .role = "user", .content = "Hello" },
        },
        .stop = .{ .single = "done" },
        .stream = null,
    };

    var writer_single = std.io.Writer.Allocating.init(std.testing.allocator);
    defer writer_single.deinit();
    var stream_single: std.json.Stringify = .{
        .writer = &writer_single.writer,
        .options = .{ .emit_null_optional_fields = false },
    };
    try stream_single.write(request_single);
    const body_single = writer_single.written();
    const parsed_single = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        body_single,
        .{},
    );
    defer parsed_single.deinit();

    const expected_single = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"model\":\"test-model\",\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}],\"stop\":\"done\"}",
        .{},
    );
    defer expected_single.deinit();
    try std.testing.expect(std.json.eql(parsed_single.value, expected_single.value));

    const request_multi = CreateChatCompletionRequest{
        .model = "test-model",
        .messages = &[_]ChatMessage{
            .{ .role = "user", .content = "Hello" },
        },
        .stop = .{ .multiple = &.{ "done", "exit" } },
        .stream = null,
    };

    var writer_multi = std.io.Writer.Allocating.init(std.testing.allocator);
    defer writer_multi.deinit();
    var stream_multi: std.json.Stringify = .{
        .writer = &writer_multi.writer,
        .options = .{ .emit_null_optional_fields = false },
    };
    try stream_multi.write(request_multi);
    const body_multi = writer_multi.written();
    const parsed_multi = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        body_multi,
        .{},
    );
    defer parsed_multi.deinit();

    const expected_multi = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"model\":\"test-model\",\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}],\"stop\":[\"done\",\"exit\"]}",
        .{},
    );
    defer expected_multi.deinit();
    try std.testing.expect(std.json.eql(parsed_multi.value, expected_multi.value));
}

test "create chat request flattens extra_body object fields" {
    const extra_body = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"thinking\":{\"type\":\"enabled\"},\"foo\":7}",
        .{},
    );
    defer extra_body.deinit();

    const request = CreateChatCompletionRequest{
        .model = "test-model",
        .messages = &[_]ChatMessage{
            .{ .role = "user", .content = "Hello" },
        },
        .extra_body = extra_body.value,
    };

    var writer = std.io.Writer.Allocating.init(std.testing.allocator);
    defer writer.deinit();
    var json_stream: std.json.Stringify = .{
        .writer = &writer.writer,
        .options = .{ .emit_null_optional_fields = false },
    };
    try json_stream.write(request);

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
        "{\"model\":\"test-model\",\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}],\"thinking\":{\"type\":\"enabled\"},\"foo\":7}",
        .{},
    );
    defer expected.deinit();

    try std.testing.expect(std.json.eql(parsed.value, expected.value));
}
