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

    var resp = client.audio().create_speech(gpa, .{
        .model = "gpt-oss-20b", // change to a valid TTS model you have access to
        .input = "Hello from Zig",
        .voice = "alloy",
        .response_format = "mp3",
    }) catch |err| {
        if (err == errors.Error.HttpError) {
            std.debug.print("HTTP error (likely invalid key/model)\n", .{});
            return;
        }
        return err;
    };
    defer resp.deinit();

    try std.fs.cwd().writeFile(.{ .sub_path = "speech.mp3", .data = resp.data });
    std.debug.print("Wrote speech.mp3 ({d} bytes)\n", .{resp.data.len});
}
