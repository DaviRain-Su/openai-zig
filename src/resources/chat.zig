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

pub const CreateChatCompletionStreamResponse = gen.CreateChatCompletionStreamResponse;
pub const StreamEventHandler = *const fn (
    user_ctx: ?*anyopaque,
    event: std.json.Parsed(CreateChatCompletionStreamResponse),
) errors.Error!void;

const StreamChunkParser = struct {
    allocator: std.mem.Allocator,
    handler: StreamEventHandler,
    user_ctx: ?*anyopaque,
    line_buf: std.ArrayList(u8),

    fn init(
        allocator: std.mem.Allocator,
        handler: StreamEventHandler,
        user_ctx: ?*anyopaque,
    ) StreamChunkParser {
        return StreamChunkParser{
            .allocator = allocator,
            .handler = handler,
            .user_ctx = user_ctx,
            .line_buf = std.ArrayList(u8).init(allocator),
        };
    }

    fn deinit(self: *StreamChunkParser) void {
        self.line_buf.deinit();
    }

    fn onTransportChunk(context: ?*anyopaque, chunk: []const u8) errors.Error!void {
        const parser: *StreamChunkParser = @ptrCast(@alignCast(context.?));
        return parser.onChunk(chunk);
    }

    fn onChunk(self: *StreamChunkParser, chunk: []const u8) errors.Error!void {
        for (chunk) |byte| {
            if (byte == '\n') {
                const line = self.trimLine(self.line_buf.items);
                if (line.len > 0) {
                    try self.consumeLine(line);
                }
                self.line_buf.clearRetainingCapacity();
                continue;
            }

            if (byte == '\r') continue;
            try self.line_buf.append(byte);
        }
    }

    fn flush(self: *StreamChunkParser) errors.Error!void {
        if (self.line_buf.items.len > 0) {
            const line = self.trimLine(self.line_buf.items);
            if (line.len > 0) {
                try self.consumeLine(line);
            }
            self.line_buf.clearRetainingCapacity();
        }
    }

    fn trimLine(self: *StreamChunkParser, line: []const u8) []const u8 {
        _ = self;
        var start: usize = 0;
        while (start < line.len and (line[start] == ' ' or line[start] == '\t')) {
            start += 1;
        }

        var end: usize = line.len;
        while (end > start and (line[end - 1] == ' ' or line[end - 1] == '\t')) {
            end -= 1;
        }

        return line[start..end];
    }

    fn consumeLine(self: *StreamChunkParser, line: []const u8) errors.Error!void {
        if (!std.mem.startsWith(u8, line, "data:")) return;

        const raw_payload = line[5..];
        const payload = std.mem.trimLeft(u8, raw_payload, " \t");
        if (payload.len == 0 or std.mem.eql(u8, payload, "[DONE]")) return;

        const parsed = std.json.parseFromSlice(
            CreateChatCompletionStreamResponse,
            self.allocator,
            payload,
            .{ .ignore_unknown_fields = true },
        ) catch {
            return errors.Error.DeserializeError;
        };
        defer parsed.deinit();

        try self.handler(self.user_ctx, parsed);
    }
};

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

    /// POST /chat/completions -> dynamic JSON.
    pub fn create_chat_completion(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRequest,
    ) errors.Error!std.json.Parsed(gen.CreateChatCompletionResponse) {
        return common.sendJsonTyped(self.transport, allocator, .POST, "/chat/completions", req, gen.CreateChatCompletionResponse);
    }

    /// POST /chat/completions -> dynamic JSON.
    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRequest,
    ) errors.Error!std.json.Parsed(gen.CreateChatCompletionResponse) {
        return self.create_chat_completion(allocator, req);
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
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/chat/completions/{s}", .{completion_id}) catch {
            return errors.Error.SerializeError;
        };
        const resp = try self.transport.request(.POST, path, &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = "application/json" },
        }, payload);
        const body = resp.body;
        defer self.transport.allocator.free(body);
        const parsed = std.json.parseFromSlice(gen.CreateChatCompletionResponse, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
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
        var stream_req = req;
        stream_req.stream = true;

        var body_writer = std.io.Writer.Allocating.init(allocator);
        defer body_writer.deinit();

        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(stream_req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        var parser = StreamChunkParser.init(allocator, on_event, user_ctx);
        defer parser.deinit();

        try self.transport.requestStream(
            .POST,
            "/chat/completions",
            &.{
                .{ .name = "Accept", .value = "text/event-stream" },
                .{ .name = "Content-Type", .value = "application/json" },
            },
            payload,
            StreamChunkParser.onTransportChunk,
            &parser,
        );
        try parser.flush();
    }
};
