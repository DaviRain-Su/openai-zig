const std = @import("std");
const sdk = @import("openai_zig");
const errors = sdk.errors;
const config = @import("config");

fn onChunk(
    _: ?*anyopaque,
    event: std.json.Parsed(std.json.Value),
) errors.Error!void {
    const root = switch (event.value) {
        .object => |obj| obj,
        else => return,
    };

    const choices = root.get("choices") orelse return;
    switch (choices) {
        .array => |items| {
            for (items.items) |choice| {
                const choice_obj = switch (choice) {
                    .object => |obj| obj,
                    else => continue,
                };
                const text = choice_obj.get("text") orelse continue;
                if (text == .string) {
                    std.debug.print("{s}", .{text.string});
                }
            }
        },
        else => return,
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

    var model = try std.json.parseFromSlice(std.json.Value, gpa, "\"deepseek-chat\"", .{});
    defer model.deinit();

    var prompt = try std.json.parseFromSlice(std.json.Value, gpa, "\"write a short poem about a river\"", .{});
    defer prompt.deinit();

    std.debug.print("Completion stream:\n", .{});
    client.completions().create_completion_stream(
        gpa,
        .{
            .model = model.value,
            .prompt = prompt.value,
            .best_of = null,
            .echo = null,
            .frequency_penalty = null,
            .logit_bias = null,
            .logprobs = null,
            .max_tokens = 24,
            .n = null,
            .presence_penalty = null,
            .seed = null,
            .stop = null,
            .stream_options = null,
            .suffix = null,
            .temperature = null,
            .top_p = null,
            .user = null,
            .stream = true,
        },
        onChunk,
        null,
    ) catch |err| {
        std.debug.print("Completion stream request failed: {s}\n", .{@errorName(err)});
    };
    std.debug.print("\n", .{});
}
