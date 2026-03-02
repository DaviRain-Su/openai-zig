const std = @import("std");
const sdk = @import("openai_zig");
const config = @import("config");

fn printToolCalls(allocator: std.mem.Allocator, tool_calls: []const sdk.generated.ChatCompletionMessageToolCall) !void {
    if (tool_calls.len == 0) {
        std.debug.print("No tool calls returned.\n", .{});
        return;
    }

    std.debug.print("Tool calls:\n", .{});
    for (tool_calls, 0..) |tool_call, index| {
        std.debug.print("  [{d}] id={s} type={s} function={s}\n", .{
            index,
            tool_call.id,
            tool_call.type,
            tool_call.function.name,
        });

        const arguments_text = tool_call.function.arguments;
        if (arguments_text.len > 0) {
            std.debug.print("             arguments={s}\n", .{arguments_text});
            if (std.json.parseFromSlice(
                std.json.Value,
                allocator,
                arguments_text,
                .{},
            )) |parsed| {
                defer parsed.deinit();

                var writer = std.io.Writer.Allocating.init(allocator);
                defer writer.deinit();
                var json_out: std.json.Stringify = .{
                    .writer = &writer.writer,
                    .options = .{},
                };
                try json_out.write(parsed.value);
                std.debug.print("             parsed arguments={s}\n", .{writer.written()});
            } else |_| {
                // Keep raw string output if parsing fails.
            }
        } else {
            std.debug.print("             arguments=<empty>\n", .{});
        }
    }
}

fn printTextMessage(message: sdk.generated.ChatCompletionResponseMessage) void {
    const content = message.content orelse return;
    std.debug.print("assistant content: {s}\n", .{content});
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
        .{ .role = "user", .content = "Need weather for Shanghai and Beijing." },
    };

    const weather_parameters = try std.json.parseFromSlice(
        std.json.Value,
        gpa,
        "{\"type\":\"object\",\"properties\":{\"city\":{\"type\":\"string\"},\"unit\":{\"type\":\"string\",\"enum\":[\"celsius\",\"fahrenheit\"]}},\"required\":[\"city\"]}",
        .{},
    );
    defer weather_parameters.deinit();

    const tools = [_]sdk.resources.chat.ChatTool{
        sdk.resources.chat.ChatToolsBuilder.function(
            "get_weather",
            "Get weather for a city",
            weather_parameters.value,
        ),
    };

    const request = sdk.resources.chat.CreateChatCompletionRequest{
        .model = conf.model,
        .messages = &messages,
        .tools = &tools,
        .tool_choice = sdk.resources.chat.ChatToolChoice.forFunction("get_weather"),
        .max_tokens = 128,
        .stream = null,
    };

    const response = client.chat().create_chat_completion(gpa, request) catch |err| {
        std.debug.print("chat completion with tools failed: {s}\n", .{@errorName(err)});
        return;
    };
    defer response.deinit();

    if (response.value.choices.len == 0) {
        std.debug.print("No choices returned.\n", .{});
        return;
    }

    const first = response.value.choices[0];
    const message = first.message orelse {
        std.debug.print("First choice has no message object.\n", .{});
        return;
    };

    if (message.content) |_| {
        printTextMessage(message);
    }

    if (message.tool_calls) |tool_calls| {
        try printToolCalls(gpa, tool_calls);
    } else {
        std.debug.print("No tool_calls field in the first choice message.\n", .{});
    }
}
