const std = @import("std");
const sdk = @import("openai_zig");
const config = @import("config");
const compat = @import("provider_compat");

fn firstContentString(val: sdk.generated.CreateChatCompletionResponse) ?[]const u8 {
    if (val.choices.len == 0) return null;
    const msg = val.choices[0].message orelse return null;
    const content = msg.content orelse return null;
    return content;
}

fn unwrapMarkdownFence(input: []const u8) []const u8 {
    var text = std.mem.trim(u8, input, " \t\n\r");
    if (!std.mem.startsWith(u8, text, "```")) return text;

    // Trim the opening fence: ``` or ```json
    var body = text[3..];
    if (std.mem.startsWith(u8, body, "json")) {
        body = body[4..];
    }
    body = std.mem.trimLeft(u8, body, " \n\r\t");

    // Return content before closing fence if present.
    if (std.mem.lastIndexOf(u8, body, "```")) |end| {
        return std.mem.trim(u8, body[0..end], " \n\r\t");
    }
    return text;
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
        .{
            .role = "system",
            .content = "Return the output strictly as JSON only.",
        },
        .{
            .role = "user",
            .content = "Which is the longest river in the world? The Nile River.",
        },
    };

    const schema_payload = try std.json.parseFromSlice(
        std.json.Value,
        gpa,
        "{\"type\":\"object\",\"properties\":{\"question\":{\"type\":\"string\"},\"answer\":{\"type\":\"string\"},\"ranking\":{\"type\":\"integer\"}},\"required\":[\"question\",\"answer\"],\"additionalProperties\":false}",
        .{},
    );
    defer schema_payload.deinit();

    const response_format = if (compat.isDeepSeek(conf.base_url))
        sdk.resources.chat.ResponseFormat.forJsonObject()
    else
        sdk.resources.chat.ResponseFormat.forJsonSchema(
            schema_payload.value,
            .{
                .name = "qa",
                .description = "question and answer extraction",
                .schema = schema_payload.value,
                .strict = true,
            },
        );

    var response = client.chat().create_chat_completion(gpa, .{
        .model = conf.model,
        .messages = &messages,
        .max_tokens = 512,
        .response_format = response_format,
    }) catch |err| {
        std.debug.print("chat completion failed: {s}\n", .{@errorName(err)});
        return;
    };
    defer response.deinit();

    const content = firstContentString(response.value) orelse {
        std.debug.print("Unexpected response shape.\n", .{});
        return;
    };

    const normalized = unwrapMarkdownFence(content);
    const parsed = std.json.parseFromSlice(std.json.Value, gpa, normalized, .{}) catch {
        std.debug.print("Response was not valid JSON:\n{s}\n", .{normalized});
        return;
    };
    defer parsed.deinit();

    var out = std.io.Writer.Allocating.init(gpa);
    defer out.deinit();
    var json_out = std.json.Stringify{ .writer = &out.writer, .options = .{} };
    try json_out.write(parsed.value);
    std.debug.print("Parsed JSON content:\n{s}\n", .{out.written()});
}
