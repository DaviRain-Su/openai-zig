const std = @import("std");
const sdk = @import("openai_zig");
const config = @import("config");

fn printContentMaybe(content: ?std.json.Value) void {
    if (content) |value| {
        switch (value) {
            .string => |text| {
                std.debug.print("{s}\n", .{text});
            },
            else => {
                std.debug.print("<non-text completion>\n", .{});
            },
        }
    } else {
        std.debug.print("<empty completion>\n", .{});
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

    const messages = [_]sdk.resources.chat.ChatMessage{
        .{ .role = "user", .content = "Continue the sentence naturally, only return the continuation text." },
        .{ .role = "assistant", .content = "The silver moonlight", .prefix = true },
    };

    const response = client.chat().create_chat_completion(
        gpa,
        .{
            .model = conf.model,
            .messages = &messages,
            .max_tokens = 64,
            .stream = null,
        },
    ) catch |err| {
        std.debug.print("Prefix completion request failed: {s}\n", .{@errorName(err)});
        return;
    };
    defer response.deinit();

    if (response.value.choices.len == 0) {
        std.debug.print("Prefix completion response had no choices.\n", .{});
        return;
    }

    const message = response.value.choices[0].message orelse {
        std.debug.print("Prefix completion first choice has no message.\n", .{});
        return;
    };

    std.debug.print("Prefix base:\n{s}\n", .{"The silver moonlight"});
    std.debug.print("Prefix continuation:\n", .{});
    printContentMaybe(message.content);
}
