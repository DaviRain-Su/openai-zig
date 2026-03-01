const std = @import("std");
const sdk = @import("openai_zig");
const errors = sdk.errors;
const config = @import("config");

fn onChunk(
    _: ?*anyopaque,
    event: std.json.Parsed(sdk.resources.chat.CreateChatCompletionStreamResponse),
) errors.Error!void {
    for (event.value.choices) |choice| {
        if (choice.delta.content) |content| {
            switch (content) {
                .string => |text| {
                    std.debug.print("{s}", .{text});
                },
                else => {},
            }
        }
    }
}

pub fn main() !void {
    var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa_impl.deinit();
    const gpa = gpa_impl.allocator();

    var conf = try config.load(gpa, "config/config.toml");
    defer conf.deinit(gpa);

    if (conf.api_key.len == 0) {
        std.debug.print("API key missing; set config/config.toml\n", .{});
        return;
    }

    var client = try sdk.initClient(gpa, .{
        .base_url = conf.base_url,
        .api_key = conf.api_key,
        .timeout_ms = conf.timeout_ms,
        .organization = conf.organization,
        .project = conf.project,
        .max_retries = conf.max_retries,
        .retry_base_delay_ms = conf.retry_base_delay_ms,
    });
    defer client.deinit();

    const messages = [_]sdk.resources.chat.ChatMessage{
        .{ .role = "user", .content = "用中文说你是谁" },
    };

    std.debug.print("Assistant stream:\n", .{});
    try client.chat().create_chat_completion_stream(
        gpa,
        .{
            .model = conf.model,
            .messages = &messages,
            .stream = true,
        },
        onChunk,
        null,
    );

    std.debug.print("\n", .{});
}
