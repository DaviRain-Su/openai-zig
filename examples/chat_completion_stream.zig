const std = @import("std");
const sdk = @import("openai_zig");
const errors = sdk.errors;
const config = @import("config");
const compat = @import("provider_compat");
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
            try dumpTextValue(content, state, choice_index, false);
        }
        if (choice.delta.reasoning_content) |reasoning| {
            try dumpTextValue(reasoning, state, choice_index, true);
        }
        if (choice.delta.refusal) |refusal| {
            try dumpTextValue(refusal, state, choice_index, false);
        }
        if (choice.finish_reason) |finish| {
            state.saw_finish_reason = true;
            state.stream_done = finish.len > 0;
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
            if (std.mem.eql(u8, last[last.len - overlap ..], chunk[0..overlap])) {
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

fn emitIncrementalReasoning(
    self: *StreamState,
    choice_index: usize,
    chunk: []const u8,
) errors.Error!void {
    if (chunk.len == 0) return;

    while (self.reasoning_choice_last_texts.items.len <= choice_index) {
        self.reasoning_choice_last_texts.append(self.allocator, null) catch {
            return errors.Error.HttpError;
        };
    }

    const tail = if (self.reasoning_choice_last_texts.items[choice_index]) |last| blk: {
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
            if (std.mem.eql(u8, last[last.len - overlap ..], chunk[0..overlap])) {
                break :blk chunk[overlap..];
            }
        }

        break :blk chunk;
    } else chunk;

    if (tail.len == 0) return;

    self.reasoning_output.appendSlice(self.allocator, tail) catch {
        return errors.Error.HttpError;
    };

    if (self.reasoning_choice_last_texts.items[choice_index]) |last| {
        self.allocator.free(last);
    }
    const dup = self.allocator.dupe(u8, chunk) catch {
        return errors.Error.HttpError;
    };
    self.reasoning_choice_last_texts.items[choice_index] = dup;
}

fn dumpTextValue(
    text: []const u8,
    state: *StreamState,
    choice_index: usize,
    is_reasoning: bool,
) errors.Error!void {
    if (text.len == 0) return;

    if (is_reasoning) {
        try emitIncrementalReasoning(state, choice_index, text);
    } else {
        try emitIncrementalText(state, choice_index, text);
    }
}

fn firstChoiceText(response: gen.CreateChatCompletionResponse) ?[]const u8 {
    if (response.choices.len == 0) return null;
    const message = response.choices[0].message orelse return null;
    const content = message.content orelse return null;
    return content;
}

fn firstChoiceReasoning(response: gen.CreateChatCompletionResponse) ?[]const u8 {
    if (response.choices.len == 0) return null;
    const message = response.choices[0].message orelse return null;
    const reasoning = message.reasoning_content orelse return null;
    return reasoning;
}

const StreamState = struct {
    allocator: std.mem.Allocator,
    choice_last_texts: std.ArrayListUnmanaged(?[]const u8),
    reasoning_choice_last_texts: std.ArrayListUnmanaged(?[]const u8),
    output: std.ArrayListUnmanaged(u8),
    reasoning_output: std.ArrayListUnmanaged(u8),
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
        for (self.reasoning_choice_last_texts.items) |entry| {
            if (entry) |text| {
                self.allocator.free(text);
            }
        }
        self.choice_last_texts.deinit(self.allocator);
        self.reasoning_choice_last_texts.deinit(self.allocator);
        self.output.deinit(self.allocator);
        self.reasoning_output.deinit(self.allocator);
    }

    fn looksIncomplete(self: *StreamState) bool {
        if (self.output.items.len == 0) return true;

        const trimmed = std.mem.trimRight(u8, self.output.items, " \t\r\n");
        if (trimmed.len == 0) return true;
        const normalized = trimCompletionTrailingNoise(trimmed);
        if (normalized.len == 0) return true;

        return !hasCompleteEnding(normalized);
    }
};

fn hasCompleteEnding(text: []const u8) bool {
    if (text.len == 0) return false;

    const normalized = trimCompletionTrailingNoise(text);
    if (normalized.len == 0) return false;

    const last = normalized[normalized.len - 1];
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

fn trimCompletionTrailingNoise(text: []const u8) []const u8 {
    const trailing_noise = [_][]const u8{
        "✨",
        "😊",
        "🙂",
        "🎉",
        "🌟",
        "🚀",
        "🙏",
        "🫶",
        "🔥",
        "💡",
    };

    var trimmed = std.mem.trimRight(u8, text, " \t\r\n");
    var did_trim = true;
    while (did_trim) {
        did_trim = false;

        for (trailing_noise) |noise| {
            if (trimmed.len >= noise.len and
                std.mem.eql(u8, trimmed[trimmed.len - noise.len ..], noise))
            {
                trimmed = trimmed[0 .. trimmed.len - noise.len];
                did_trim = true;
                break;
            }
        }
        if (!did_trim) break;
        trimmed = std.mem.trimRight(u8, trimmed, " \t\r\n");
    }
    return trimmed;
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
        .stream = true,
    };

    std.debug.print("Assistant stream:\n", .{});
    if (compat.isDeepSeek(conf.base_url)) {
        const fallback_request = compat.withoutStream(@TypeOf(request), request);
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
        if (firstChoiceReasoning(response.value)) |reasoning| {
            std.debug.print("Reasoning:\n{s}\n", .{reasoning});
        }
        std.debug.print("\n", .{});
        return;
    }

    var stream_state = StreamState{
        .allocator = gpa,
        .choice_last_texts = .{},
        .output = .{},
        .reasoning_choice_last_texts = .{},
        .reasoning_output = .{},
    };
    defer stream_state.deinit();

    client.chat().create_chat_completion_stream_with_options_and_done(
        gpa,
        request,
        onChunk,
        &stream_state,
        null,
        onDone,
        &stream_state,
    ) catch |err| {
        std.debug.print("Chat stream request failed: {s}\n", .{@errorName(err)});
        std.debug.print("Falling back to non-stream chat completion...\n", .{});
        const fallback_request = compat.withoutStream(@TypeOf(request), request);
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
        if (firstChoiceReasoning(response.value)) |reasoning| {
            std.debug.print("Reasoning:\n{s}\n", .{reasoning});
        }
        std.debug.print("\n", .{});
        return;
    };

    const stream_unfinished = !stream_state.stream_done or !stream_state.saw_finish_reason;
    const fallback_needed = stream_state.output.items.len == 0 or
        (stream_state.event_count > 0 and stream_unfinished and stream_state.looksIncomplete());

    if (fallback_needed) {
        std.debug.print("\n", .{});
        if (stream_state.output.items.len > 0 and stream_state.looksIncomplete()) {
            std.debug.print("Stream response appears incomplete, fallback to non-stream call:\n", .{});
        } else {
            std.debug.print("Stream response incomplete, fallback to non-stream call:\n", .{});
        }
        const fallback_request = compat.withoutStream(@TypeOf(request), request);
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
        if (firstChoiceReasoning(response.value)) |reasoning| {
            std.debug.print("Reasoning:\n{s}\n", .{reasoning});
        }
        std.debug.print("\n", .{});
        return;
    }

    if (stream_state.output.items.len > 0) {
        std.debug.print("{s}\n", .{stream_state.output.items});
    } else {
        std.debug.print("Stream response returned no textual output.\n", .{});
    }
    if (stream_state.reasoning_output.items.len > 0) {
        std.debug.print("Reasoning:\n{s}\n", .{stream_state.reasoning_output.items});
    }

    std.debug.print("\n", .{});
}
