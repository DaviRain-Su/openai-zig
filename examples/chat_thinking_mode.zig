const std = @import("std");
const sdk = @import("openai_zig");
const config = @import("config");
const compat = @import("provider_compat");

fn objectFieldTextValue(value: std.json.Value, field: []const u8) ?[]const u8 {
    if (value != .object) return null;
    const field_value = value.object.get(field) orelse return null;
    return if (field_value == .string) field_value.string else null;
}

fn firstChoiceMessage(response: std.json.Value) ?std.json.Value {
    if (response != .object) return null;
    const choices = response.object.get("choices") orelse return null;
    if (choices != .array or choices.array.items.len == 0) return null;
    const first_choice = choices.array.items[0];
    if (first_choice != .object) return null;
    return first_choice.object.get("message");
}

fn firstContentAndReasoning(response: std.json.Value) struct { ?[]const u8, ?[]const u8 } {
    const message = firstChoiceMessage(response) orelse return .{ null, null };
    if (message != .object) return .{ null, null };
    return .{
        objectFieldTextValue(message, "content"),
        objectFieldTextValue(message, "reasoning_content"),
    };
}

fn printValueOrPlaceholder(label: []const u8, value: ?[]const u8) void {
    if (value) |text| {
        std.debug.print("{s}:{s}\n", .{ label, text });
    } else {
        std.debug.print("{s}:(none)\n", .{label});
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

    const extra_body_json = try std.json.parseFromSlice(
        std.json.Value,
        gpa,
        "{\"thinking\":{\"type\":\"enabled\"}}",
        .{},
    );
    defer extra_body_json.deinit();

    const is_deepseek = compat.isDeepSeek(conf.base_url);
    const model = if (is_deepseek and std.mem.indexOf(u8, conf.model, "reasoner") == null)
        "deepseek-reasoner"
    else
        conf.model;
    const extra_body = if (is_deepseek) extra_body_json.value else null;

    const messages = [_]sdk.resources.chat.ChatMessage{
        .{
            .role = "user",
            .content = "Write a 4-line poem about the ocean. Use vivid imagery.",
        },
    };

    std.debug.print("Thinking mode request:\n", .{});
    var response = client.chat().create_chat_completion_value(gpa, .{
        .model = model,
        .messages = &messages,
        .max_tokens = 256,
        .extra_body = extra_body,
    }) catch |err| {
        std.debug.print("create_chat_completion_value failed: {s}\n", .{@errorName(err)});
        return;
    };
    defer response.deinit();

    const first = firstContentAndReasoning(response.value);
    printValueOrPlaceholder("content", first[0]);
    printValueOrPlaceholder("reasoning", first[1]);

    const content_for_followup = first[0] orelse "I am a helpful assistant.";
    const follow_messages = [_]sdk.resources.chat.ChatMessage{
        .{ .role = "user", .content = "你是一位诗歌写作助手。", },
        .{
            .role = "assistant",
            .content = content_for_followup,
        },
        .{ .role = "user", .content = "请将上面的诗再改写成更简洁的 2 行版本。" },
    };

    std.debug.print("\nFollow-up without reasoning content:\n", .{});
    var followup = client.chat().create_chat_completion_value(gpa, .{
        .model = model,
        .messages = &follow_messages,
        .max_tokens = 256,
        .extra_body = extra_body,
    }) catch |err| {
        std.debug.print("create_chat_completion_value followup failed: {s}\n", .{@errorName(err)});
        return;
    };
    defer followup.deinit();

    const second = firstContentAndReasoning(followup.value);
    printValueOrPlaceholder("content", second[0]);
    printValueOrPlaceholder("reasoning", second[1]);
}
