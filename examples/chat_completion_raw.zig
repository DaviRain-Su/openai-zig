const std = @import("std");
const sdk = @import("openai_zig");
const config = @import("config");

fn firstText(value: std.json.Value) ?[]const u8 {
    return if (value != .string) null else value.string;
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

    const request_json = try std.fmt.allocPrint(
        gpa,
        "{{\"model\":\"{s}\",\"messages\":[{{\"role\":\"user\",\"content\":\"请用中文回答：你支持哪些能力？\"}}],\"max_tokens\":256,\"temperature\":0.7,\"top_p\":0.9,\"frequency_penalty\":0.0,\"presence_penalty\":0.0,\"stream\":false,\"extra_field\":\"compat\"}}",
        .{conf.model},
    );
    defer gpa.free(request_json);

    var payload = try std.json.parseFromSlice(std.json.Value, gpa, request_json, .{});
    defer payload.deinit();

    const response = client.chat().create_chat_completion_raw(gpa, payload.value) catch |err| {
        std.debug.print("chat completion raw failed: {s}\n", .{@errorName(err)});
        return;
    };
    defer response.deinit();

    for (response.value.choices) |choice| {
        if (choice.message) |message| {
            const content = firstText(message.content orelse {
                std.debug.print("Response message has no string content.\n", .{});
                return;
            });
            if (content) |text| {
                std.debug.print("Chat completion raw:\n{s}\n", .{text});
            } else {
                std.debug.print("Response message content is non-string JSON.\n", .{});
            }
        }
    }
}
