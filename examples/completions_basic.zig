const std = @import("std");
const sdk = @import("openai_zig");
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
        .timeout_ms = conf.timeout_ms,
        .organization = conf.organization,
        .project = conf.project,
        .max_retries = conf.max_retries,
        .retry_base_delay_ms = conf.retry_base_delay_ms,
    });
    defer client.deinit();

    const model_json = try std.fmt.allocPrint(gpa, "\"{s}\"", .{conf.model});
    defer gpa.free(model_json);
    var model = try std.json.parseFromSlice(std.json.Value, gpa, model_json, .{});
    defer model.deinit();

    var prompt = try std.json.parseFromSlice(std.json.Value, gpa, "\"Write a complete 4-line poem about a river. Output only the poem, no explanation. Do not add labels.\"", .{});
    defer prompt.deinit();

    const response = client.completions().create_completion_with_options(
        gpa,
        .{
            .model = model.value,
            .prompt = prompt.value,
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
    const text = response.value.choices[0].text;
    std.debug.print("Completion:\n{s}\n", .{text});
}
