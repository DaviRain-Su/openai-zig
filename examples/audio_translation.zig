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

    const audio_file_path = std.process.getEnvVarOwned(gpa, "OPENAI_AUDIO_FILE") catch null;
    if (audio_file_path == null or audio_file_path.?.len == 0) {
        std.debug.print("Set OPENAI_AUDIO_FILE to run this example (path to local audio file).\n", .{});
        return;
    }
    defer gpa.free(audio_file_path.?);

    std.fs.cwd().access(audio_file_path.?, .{}) catch {
        std.debug.print("Audio file not found: {s}\n", .{audio_file_path.?});
        return;
    };

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

    if (compat.skipIfDeepSeek(conf.base_url, "translations")) return;

    const response = client.audio().create_translation_from_path(gpa, .{
        .file_path = audio_file_path.?,
        .model = "whisper-1",
        .prompt = null,
        .response_format = "json",
        .temperature = null,
        .filename = null,
        .file_content_type = null,
    }) catch |err| {
        switch (err) {
            errors.Error.NotFoundError => {
                std.debug.print("translations endpoint unavailable on this provider (HTTP 404).\n", .{});
                return;
            },
            errors.Error.HttpError => {
                std.debug.print("HTTP transport error (likely invalid key/model).\n", .{});
                return;
            },
            else => return err,
        }
    };
    defer response.deinit();

    std.debug.print("Translation:\n{s}\n", .{response.value.text});
}
