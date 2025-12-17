const std = @import("std");
const sdk = @import("openai_zig");
const errors = sdk.errors;
const config = @import("config.zig");

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

    var models = client.models().list_models(gpa) catch |err| {
        if (err == errors.Error.HttpError) {
            std.debug.print("HTTP error (check API key/base URL)\n", .{});
            return;
        }
        return err;
    };
    defer models.deinit();

    var out: std.io.Writer.Allocating = .init(gpa);
    defer out.deinit();
    var stream: std.json.Stringify = .{ .writer = &out.writer, .options = .{} };
    try stream.write(models.value);
    const rendered = out.written();

    std.debug.print("Models list JSON:\n{s}\n", .{rendered});

    // Simple chat completion call.
    const messages = [_]sdk.resources.chat.ChatMessage{
        .{ .role = "user", .content = "who are you?" },
    };
    var chat = client.chat().create_chat_completion(gpa, .{
        .model = "gpt-oss-20b",
        .messages = &messages,
    }) catch |err| {
        if (err == errors.Error.HttpError) {
            std.debug.print("Chat call failed (HTTP error)\n", .{});
            return;
        }
        return err;
    };
    defer chat.deinit();

    var chat_out: std.io.Writer.Allocating = .init(gpa);
    defer chat_out.deinit();
    var chat_stream: std.json.Stringify = .{ .writer = &chat_out.writer, .options = .{} };
    try chat_stream.write(chat.value);
    std.debug.print("Chat completion JSON:\n{s}\n", .{chat_out.written()});
}

test "client init/deinit" {
    const gpa = std.heap.page_allocator;
    var client = try sdk.initClient(gpa, .{
        .base_url = "https://api.openai.com/v1",
        .api_key = null,
    });
    defer client.deinit();
}
