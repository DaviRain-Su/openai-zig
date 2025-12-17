const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

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
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    /// POST /chat/completions -> dynamic JSON.
    pub fn create_chat_completion(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        const resp = try self.transport.request(.POST, "/chat/completions", &.{
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
};
