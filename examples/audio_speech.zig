const std = @import("std");
const sdk = @import("openai_zig");
const errors = sdk.errors;
const config = @import("config");
const compat = @import("provider_compat.zig");

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

    if (compat.skipIfDeepSeek(conf.base_url, "speech")) return;

    var resp = client.audio().create_speech(gpa, .{
        .model = .{ .string = "tts-1" }, // change to a valid TTS model you have access to
        .input = "Hello from Zig",
        .instructions = null,
        .speed = 1.0,
        .voice = .{ .string = "alloy" },
        .response_format = "mp3",
        .stream_format = null,
    }) catch |err| {
        switch (err) {
            errors.Error.NotFoundError => {
                std.debug.print("speech endpoint unavailable on this provider (HTTP 404).\n", .{});
                return;
            },
            errors.Error.HttpError => {
                std.debug.print("HTTP transport error (likely invalid key/model)\n", .{});
                return;
            },
            else => return err,
        }
    };
    defer resp.deinit();

    try std.fs.cwd().writeFile(.{ .sub_path = "speech.mp3", .data = resp.data });
    std.debug.print("Wrote speech.mp3 ({d} bytes)\n", .{resp.data.len});
}
