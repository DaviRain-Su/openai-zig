const std = @import("std");
const sdk = @import("openai_zig");
const config = @import("config");

fn stripInstructionPrefix(text: []const u8) []const u8 {
    var trimmed = std.mem.trimLeft(u8, text, " \t\r\n");
    if (trimmed.len == 0) return "";

    if (trimmed.len > 0 and trimmed[0] == '.') {
        trimmed = std.mem.trimLeft(u8, trimmed[1..], " \t\r\n");
    }
    if (std.mem.startsWith(u8, trimmed, "The poem should") or
        std.mem.startsWith(u8, trimmed, "The poem must") or
        std.mem.startsWith(u8, trimmed, "A poem should") or
        std.mem.startsWith(u8, trimmed, "A poem must") or
        std.mem.startsWith(u8, trimmed, "Write a"))
    {
        if (std.mem.indexOf(u8, trimmed, "\n")) |idx| {
            return std.mem.trimLeft(u8, trimmed[idx + 1 ..], " \t\r\n");
        }
        return "";
    }
    return trimmed;
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

    const prompt_json = "Write a complete 4-line poem about a river. Output only the poem, no explanation, and do not output any instructions.";

    const response = client.completions().create_completion_with_options(
        gpa,
        .{
            .model = conf.model,
            .prompt = prompt_json,
            .best_of = null,
            .echo = false,
            .frequency_penalty = null,
            .logit_bias = null,
            .logprobs = null,
            .max_tokens = 512,
            .n = null,
            .presence_penalty = null,
            .seed = null,
            .stop = null,
            .stream = null,
            .stream_options = null,
            .suffix = null,
            .temperature = null,
            .top_p = null,
            .user = null,
        },
        null,
    ) catch |err| {
        std.debug.print("Completions request failed: {s}\n", .{@errorName(err)});
        return;
    };
    defer response.deinit();

    if (response.value.choices.len == 0) {
        std.debug.print("Completion response has no choices.\n", .{});
        return;
    }
    const text = stripInstructionPrefix(response.value.choices[0].text);
    std.debug.print("Completion:\n{s}\n", .{text});
}
