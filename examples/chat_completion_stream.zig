const std = @import("std");
const sdk = @import("openai_zig");
const errors = sdk.errors;
const config = @import("config");
const gen = sdk.generated;

fn onChunk(
    user_ctx: ?*anyopaque,
    event: std.json.Parsed(sdk.resources.chat.CreateChatCompletionStreamResponse),
) errors.Error!void {
    const state: *StreamState = if (user_ctx) |ctx| @ptrCast(@alignCast(ctx)) else return;
    state.event_count += 1;

    for (event.value.choices) |choice| {
        const choice_index: usize = if (choice.index > 0) @intCast(choice.index) else 0;

        if (choice.delta.content) |content| {
            try dumpTextValue(content, state, choice_index);
        }
        if (choice.delta.reasoning_content) |reasoning| {
            try dumpTextValue(reasoning, state, choice_index);
        }
        if (choice.delta.refusal) |refusal| {
            try dumpTextValue(refusal, state, choice_index);
        }
        if (choice.finish_reason) |finish| {
            state.saw_finish_reason = true;
            if (finish != .null) state.stream_done = true;
        }
    }
}

fn onDone(user_ctx: ?*anyopaque) errors.Error!void {
    const state: *StreamState = if (user_ctx) |ctx| @ptrCast(@alignCast(ctx)) else return;
    state.stream_done = true;
}

fn emitIncrementalText(
    self: *StreamState,
    choice_index: usize,
    chunk: []const u8,
) errors.Error!void {
    if (chunk.len == 0) return;

    while (self.choice_last_texts.items.len <= choice_index) {
        self.choice_last_texts.append(self.allocator, null) catch {
            return errors.Error.HttpError;
        };
    }

    const tail = if (self.choice_last_texts.items[choice_index]) |last| blk: {
        if (last.len == chunk.len and std.mem.eql(u8, last, chunk)) return;

        if (chunk.len >= last.len and std.mem.startsWith(u8, chunk, last)) {
            const suffix = chunk[last.len..];
            if (suffix.len == 0) return;
            break :blk suffix;
        }

        if (chunk.len <= last.len and std.mem.startsWith(u8, last, chunk)) return;

        const max_len = @min(last.len, chunk.len);
        var overlap: usize = max_len;
        while (overlap > 0) : (overlap -= 1) {
            if (std.mem.eql(u8, last[last.len - overlap..], chunk[0..overlap])) {
                break :blk chunk[overlap..];
            }
        }

        break :blk chunk;
    } else chunk;

    if (tail.len == 0) return;

    self.output.appendSlice(self.allocator, tail) catch {
        return errors.Error.HttpError;
    };
    self.char_count += tail.len;
    self.printed_any = true;

    if (self.choice_last_texts.items[choice_index]) |last| {
        self.allocator.free(last);
    }
    const dup = self.allocator.dupe(u8, chunk) catch {
        return errors.Error.HttpError;
    };
    self.choice_last_texts.items[choice_index] = dup;
}

fn dumpTextValue(
    value: std.json.Value,
    state: *StreamState,
    choice_index: usize,
) errors.Error!void {
    if (value == .null) return;

    switch (value) {
        .string => |text| {
            try emitIncrementalText(state, choice_index, text);
        },
        .object => |object| {
            if (object.get("text")) |text| {
                try dumpTextValue(text, state, choice_index);
            } else if (object.get("input_text")) |input| {
                try dumpTextValue(input, state, choice_index);
            } else if (object.get("content")) |content| {
                try dumpTextValue(content, state, choice_index);
            } else if (object.get("delta")) |delta| {
                try dumpTextValue(delta, state, choice_index);
            }
        },
        .array => |items| {
            for (items.items) |item| {
                try dumpTextValue(item, state, choice_index);
            }
        },
        else => {},
    }
}

fn firstChoiceText(response: gen.CreateChatCompletionResponse) ?[]const u8 {
    if (response.choices.len == 0) return null;
    const message = response.choices[0].message orelse return null;
    const content = message.content orelse return null;

    return switch (content) {
        .string => |text| text,
        else => null,
    };
}

const StreamState = struct {
    allocator: std.mem.Allocator,
    choice_last_texts: std.ArrayListUnmanaged(?[]const u8),
    output: std.ArrayListUnmanaged(u8),
    event_count: usize = 0,
    saw_finish_reason: bool = false,
    printed_any: bool = false,
    char_count: usize = 0,
    stream_done: bool = false,

    fn deinit(self: *StreamState) void {
        for (self.choice_last_texts.items) |entry| {
            if (entry) |text| {
                self.allocator.free(text);
            }
        }
        self.choice_last_texts.deinit(self.allocator);
        self.output.deinit(self.allocator);
    }

    fn looksIncomplete(self: *StreamState) bool {
        if (self.output.items.len == 0) return true;
        if (self.output.items.len < 64) return false;

        const trimmed = std.mem.trimRight(u8, self.output.items, " \t\r\n");
        if (trimmed.len == 0) return true;

        return !hasCompleteEnding(trimmed);
    }
};

fn hasCompleteEnding(text: []const u8) bool {
    if (text.len == 0) return false;

    const last = text[text.len - 1];
    if (last == '.' or
        last == '!' or
        last == '?' or
        last == ';' or
        last == ':' or
        last == ')' or
        last == ']' or
        last == '}' or
        last == '"' or
        last == '\'' or
        last == '-' or
        last == '+' or
        last == '_')
    {
        return true;
    }

    if (std.mem.endsWith(u8, text, "。")) return true;
    if (std.mem.endsWith(u8, text, "？")) return true;
    if (std.mem.endsWith(u8, text, "！")) return true;
    if (std.mem.endsWith(u8, text, "；")) return true;
    if (std.mem.endsWith(u8, text, "：")) return true;
    if (std.mem.endsWith(u8, text, "）")) return true;
    if (std.mem.endsWith(u8, text, "】")) return true;
    if (std.mem.endsWith(u8, text, "》")) return true;
    if (std.mem.endsWith(u8, text, "“")) return true;
    if (std.mem.endsWith(u8, text, "”")) return true;
    if (std.mem.endsWith(u8, text, "‘")) return true;
    if (std.mem.endsWith(u8, text, "’")) return true;

    return false;
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
        .{ .role = "user", .content = "用中文说你是谁" },
    };
    const request = sdk.resources.chat.CreateChatCompletionRequest{
        .model = conf.model,
        .messages = &messages,
        .max_tokens = 256,
    };

    std.debug.print("Assistant stream:\n", .{});
    var stream_state = StreamState{
        .allocator = gpa,
        .choice_last_texts = .{},
        .output = .{},
    };
    defer stream_state.deinit();

    try client.chat().create_chat_completion_stream_with_options_and_done(
        gpa,
        request,
        onChunk,
        &stream_state,
        null,
        onDone,
        &stream_state,
    );

    const is_deepseek = std.mem.indexOf(u8, conf.base_url, "api.deepseek.com") != null;
    const fallback_needed = stream_state.output.items.len == 0 or
        (if (is_deepseek)
            stream_state.looksIncomplete()
        else
            (stream_state.event_count > 0 and
                (!stream_state.stream_done or !stream_state.saw_finish_reason)));

    if (fallback_needed) {
        std.debug.print("\n", .{});
        if (stream_state.output.items.len > 0 and stream_state.looksIncomplete()) {
            std.debug.print("Stream response appears incomplete, fallback to non-stream call:\n", .{});
        } else {
            std.debug.print("Stream response incomplete, fallback to non-stream call:\n", .{});
        }
        const fallback_request = sdk.resources.chat.CreateChatCompletionRequest{
            .model = request.model,
            .messages = request.messages,
            .max_tokens = request.max_tokens,
            .temperature = null,
            .max_completion_tokens = null,
            .n = null,
            .top_p = null,
            .stop = null,
            .presence_penalty = null,
            .frequency_penalty = null,
            .user = null,
            .stream_options = null,
            .tools = null,
            .tool_choice = null,
            .parallel_tool_calls = null,
            .reasoning_effort = null,
            .service_tier = null,
            .metadata = null,
            .logprobs = null,
            .top_logprobs = null,
            .thinking = null,
            .response_format = null,
            .stream = null,
            .seed = null,
        };
        const response = client.chat().create_chat_completion(gpa, fallback_request) catch {
            std.debug.print("Fallback chat completion failed.\n", .{});
            std.debug.print("\n", .{});
            return;
        };
        defer response.deinit();
        if (firstChoiceText(response.value)) |content| {
            std.debug.print("{s}\n", .{content});
        } else {
            std.debug.print("Fallback chat completion returned non-text content.\n", .{});
        }
        std.debug.print("\n", .{});
        return;
    }

    if (stream_state.output.items.len > 0) {
        std.debug.print("{s}\n", .{stream_state.output.items});
    } else {
        std.debug.print("Stream response returned no textual output.\n", .{});
    }

    std.debug.print("\n", .{});
}
