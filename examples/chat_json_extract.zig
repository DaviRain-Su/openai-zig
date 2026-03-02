const std = @import("std");
const sdk = @import("openai_zig");
const errors = sdk.errors;
const config = @import("config");

const ExampleError = error{BadResponse};

fn firstContentString(val: sdk.generated.CreateChatCompletionResponse) ExampleError![]const u8 {
    const choices = val.choices;
    if (choices.len == 0) return ExampleError.BadResponse;
    const msg = choices[0].message orelse return ExampleError.BadResponse;
    return msg.content orelse return ExampleError.BadResponse;
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

    const system_prompt =
        \\The user will provide some exam text. Please parse the "question" and "answer" and output them in JSON format.
        \\EXAMPLE INPUT:
        \\Which is the highest mountain in the world? Mount Everest.
        \\EXAMPLE JSON OUTPUT:
        \\{
        \\  "question": "Which is the highest mountain in the world?",
        \\  "answer": "Mount Everest"
        \\}
    ;

    const user_prompt = "Which is the longest river in the world? The Nile River.";

    const messages = [_]sdk.resources.chat.ChatMessage{
        .{ .role = "system", .content = system_prompt },
        .{ .role = "user", .content = user_prompt },
    };

    var resp = client.chat().create_chat_completion(gpa, .{
        .model = conf.model,
        .messages = &messages,
        .response_format = .json_object,
        .max_tokens = 256,
    }) catch |err| {
        std.debug.print("Request failed: {s}\n", .{@errorName(err)});
        return;
    };
    defer resp.deinit();

    const content_str = firstContentString(resp.value) catch |e| {
        std.debug.print("Unexpected response shape: {s}\n", .{@errorName(e)});
        return;
    };

    const parsed = std.json.parseFromSlice(std.json.Value, gpa, content_str, .{}) catch {
        std.debug.print("Content is not valid JSON\n", .{});
        return;
    };
    defer parsed.deinit();

    var out = std.io.Writer.Allocating.init(gpa);
    defer out.deinit();
    var stream: std.json.Stringify = .{ .writer = &out.writer, .options = .{} };
    try stream.write(parsed.value);

    std.debug.print("Parsed JSON content:\n{s}\n", .{out.written()});
}
