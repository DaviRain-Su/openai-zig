const std = @import("std");
const sdk = @import("openai_zig");
const errors = sdk.errors;
const config = @import("config");

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
    });
    defer client.deinit();

    // Simple multi-turn conversation.
    const messages = [_]sdk.resources.chat.ChatMessage{
        .{ .role = "system", .content = "You are a concise assistant that answers briefly." },
        .{ .role = "user", .content = "What's the capital of France?" },
        .{ .role = "assistant", .content = "Paris." },
        .{ .role = "user", .content = "And the population roughly?" },
    };

    var resp = client.chat().create_chat_completion(gpa, .{
        .model = "gpt-oss-20b",
        .messages = &messages,
        .max_tokens = 64,
    }) catch |err| {
        std.debug.print("Request failed (check API key or model): {s}\n", .{@errorName(err)});
        return;
    };
    defer resp.deinit();

    // Response is dynamic JSON (schema varies by model); just print the full payload.
    var out: std.io.Writer.Allocating = .init(gpa);
    defer out.deinit();
    var stream: std.json.Stringify = .{ .writer = &out.writer, .options = .{} };
    try stream.write(resp.value);

    std.debug.print("Response JSON:\n{s}\n", .{out.written()});
}
