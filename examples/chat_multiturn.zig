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
        .timeout_ms = conf.timeout_ms,
        .organization = conf.organization,
        .project = conf.project,
        .max_retries = conf.max_retries,
        .retry_base_delay_ms = conf.retry_base_delay_ms,
    });
    defer client.deinit();

    // Simple multi-turn conversation.
    const messages = [_]sdk.resources.chat.ChatMessage{
        .{ .role = "system", .content = "You are a concise assistant that answers briefly." },
        .{ .role = "user", .content = "What's the capital of France?" },
        .{ .role = "assistant", .content = "Paris." },
        .{ .role = "user", .content = "And the population roughly?" },
    };

    var resp = client.chat().create_chat_completion(gpa, .{
        .model = conf.model,
        .messages = &messages,
        .max_tokens = 64,
    }) catch |err| {
        std.debug.print("Request failed (check API key or model): {s}\n", .{@errorName(err)});
        return;
    };
    defer resp.deinit();

    if (resp.value.choices.len == 0) {
        std.debug.print("Response had no choices\n", .{});
        return;
    }
    const first_choice = resp.value.choices[0];
    const message = first_choice.message orelse {
        std.debug.print("Response first choice has no message\n", .{});
        return;
    };

    std.debug.print("Choice index: {d}\n", .{first_choice.index});

    if (message.content) |content| {
        switch (content) {
            .string => |text| std.debug.print("Content:\n{s}\n", .{text}),
            else => std.debug.print("Content: <non-text payload>\n", .{}),
        }
    } else {
        std.debug.print("Content: <null>\n", .{});
    }

    if (message.refusal) |refusal| {
        switch (refusal) {
            .string => |value| std.debug.print("Refusal:\n{s}\n", .{value}),
            else => std.debug.print("Refusal: <non-text payload>\n", .{}),
        }
    }

    const prefix_messages = [_]sdk.resources.chat.ChatMessage{
        .{ .role = "user", .content = "Write a short continuation." },
        .{ .role = "assistant", .content = "The river glides", .prefix = true },
    };

    std.debug.print("\nMulti-round continuation (prefix):\n", .{});
    var prefixed_resp = client.chat().create_chat_completion(gpa, .{
        .model = conf.model,
        .messages = &prefix_messages,
        .max_tokens = 64,
    }) catch |err| {
        std.debug.print("Prefix continuation request failed: {s}\n", .{@errorName(err)});
        return;
    };
    defer prefixed_resp.deinit();

    if (prefixed_resp.value.choices.len == 0) {
        std.debug.print("Prefix continuation response had no choices\n", .{});
        return;
    }
    const prefixed_choice = prefixed_resp.value.choices[0];
    const prefixed_message = prefixed_choice.message orelse {
        std.debug.print("Prefix continuation response first choice has no message\n", .{});
        return;
    };

    if (prefixed_message.content) |content| {
        switch (content) {
            .string => |text| std.debug.print("Content:\n{s}\n", .{text}),
            else => std.debug.print("Content: <non-text payload>\n", .{}),
        }
    } else {
        std.debug.print("Content: <null>\n", .{});
    }
}
