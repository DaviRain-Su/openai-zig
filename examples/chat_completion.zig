const std = @import("std");
const sdk = @import("openai_zig");
const config = @import("config");
const gen = sdk.generated;

fn firstContentString(val: gen.CreateChatCompletionResponse) ?[]const u8 {
    if (val.choices.len == 0) return null;
    const msg = val.choices[0].message orelse return null;
    return switch (msg.content orelse return null) {
        .string => |text| text,
        else => null,
    };
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

    var chat = try client.chat().create_chat_completion(gpa, .{
        .model = conf.model,
        .messages = &messages,
        .max_tokens = 512,
    });
    defer chat.deinit();

    const content = firstContentString(chat.value) orelse {
        std.debug.print("Unexpected response shape.\n", .{});
        return;
    };
    std.debug.print("Chat completion:\n{s}\n", .{content});
}
