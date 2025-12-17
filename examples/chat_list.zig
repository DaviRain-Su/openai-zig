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

    var chats = client.chat().list_chat_completions(gpa) catch |err| {
        if (err == errors.Error.HttpError) {
            std.debug.print("HTTP error (likely invalid key)\n", .{});
            return;
        }
        return err;
    };
    defer chats.deinit();

    var out: std.io.Writer.Allocating = .init(gpa);
    defer out.deinit();
    var stream: std.json.Stringify = .{ .writer = &out.writer, .options = .{} };
    try stream.write(chats.value);

    std.debug.print("Chat completions list:\n{s}\n", .{out.written()});
}
