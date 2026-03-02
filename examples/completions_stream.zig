const std = @import("std");
const sdk = @import("openai_zig");
const errors = sdk.errors;
const config = @import("config");
const compat = @import("provider_compat");

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

    fn emitOverlap(self: *StreamState, prev: []const u8, chunk: []const u8) []const u8 {
        _ = self;
        if (prev.len == 0) return chunk;

        const max_len = @min(prev.len, chunk.len);
        var overlap = max_len;
        while (overlap > 0) : (overlap -= 1) {
            if (std.mem.eql(u8, prev[prev.len - overlap..], chunk[0..overlap])) {
                return chunk[overlap..];
            }
        }

        return chunk;
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

            break :blk self.emitOverlap(last, chunk);
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

            break :blk self.emitOverlap(last, chunk);
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

    fn looksIncomplete(self: *StreamState) bool {
        if (self.output.items.len == 0) return true;
        if (self.char_count < 64) return false;

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

fn choiceIndex(choice_obj: std.json.ObjectMap) usize {
    if (choice_obj.get("index")) |idx| {
        return switch (idx) {
            .integer => |value| if (value > 0) @intCast(value) else 0,
            .float => |value| if (value > 0) @intCast(@as(i64, @intFromFloat(value))) else 0,
            .string => |text| std.fmt.parseInt(usize, text, 10) catch 0,
            else => 0,
        };
    }
    return 0;
}

fn onChunk(
    user_ctx: ?*anyopaque,
    event: std.json.Parsed(std.json.Value),
) errors.Error!void {
    const state: *StreamState = if (user_ctx) |ctx| @ptrCast(@alignCast(ctx)) else return;
    state.event_count += 1;

    const root = switch (event.value) {
        .object => |obj| obj,
        else => return,
    };

    const choices = root.get("choices") orelse return;

    switch (choices) {
        .array => |items| {
            for (items.items) |choice| {
                if (choice != .object) continue;
                const choice_obj = choice.object;
                const choice_index = choiceIndex(choice_obj);

                const text_payload = choice_obj.get("text");
                if (text_payload) |text| {
                    try dumpTextValue(text, state, choice_index, false);
                }

                if (choice_obj.get("reasoning")) |reasoning| {
                    try dumpTextValue(reasoning, state, choice_index, true);
                }
                if (choice_obj.get("reasoning_content")) |reasoning_content| {
                    try dumpTextValue(reasoning_content, state, choice_index, true);
                }

                if (choice_obj.get("finish_reason")) |finish_reason| {
                    state.saw_finish_reason = true;
                    switch (finish_reason) {
                        .string => |reason| {
                            if (reason.len > 0) state.stream_done = true;
                        },
                        else => {},
                    }
                }

                if (choice_obj.get("delta")) |delta| {
                    try dumpTextValue(delta, state, choice_index, false);
                }
            }
        },
        else => return,
    }
}

fn onDone(user_ctx: ?*anyopaque) errors.Error!void {
    const state: *StreamState = if (user_ctx) |ctx| @ptrCast(@alignCast(ctx)) else return;
    state.stream_done = true;
}

fn dumpTextValue(
    value: std.json.Value,
    state: *StreamState,
    choice_index: usize,
    is_reasoning: bool,
) errors.Error!void {
    if (value == .null) return;

    switch (value) {
        .string => |text| {
            if (is_reasoning) {
                try state.emitIncrementalReasoning(choice_index, text);
            } else {
                try state.emitIncrementalText(choice_index, text);
            }
        },
        .array => |items| {
            for (items.items) |item| {
                if (item == .object) {
                    const item_object = item.object;
                    if (item_object.get("type")) |kind| {
                        if (kind == .string and std.mem.eql(u8, kind.string, "text")) {
                            if (item_object.get("text")) |text| {
                                try dumpTextValue(text, state, choice_index, is_reasoning);
                                continue;
                            }
                            if (item_object.get("input_text")) |input| {
                                try dumpTextValue(input, state, choice_index, is_reasoning);
                                continue;
                            }
                        }
                        if (kind == .string and std.mem.eql(u8, kind.string, "reasoning")) {
                            if (item_object.get("text")) |text| {
                                try dumpTextValue(text, state, choice_index, true);
                                continue;
                            }
                            if (item_object.get("reasoning")) |reasoning| {
                                try dumpTextValue(reasoning, state, choice_index, true);
                                continue;
                            }
                        }
                    }
                }

                try dumpTextValue(item, state, choice_index, is_reasoning);
            }
        },
        .object => |object| {
            if (object.get("text")) |text| {
                try dumpTextValue(text, state, choice_index, is_reasoning);
            } else if (object.get("input_text")) |input| {
                try dumpTextValue(input, state, choice_index, is_reasoning);
            } else if (object.get("content")) |content| {
                try dumpTextValue(content, state, choice_index, is_reasoning);
            } else if (object.get("reasoning")) |reasoning| {
                try dumpTextValue(reasoning, state, choice_index, true);
            } else if (object.get("reasoning_content")) |reasoning_content| {
                try dumpTextValue(reasoning_content, state, choice_index, true);
            } else if (object.get("delta")) |delta| {
                if (delta == .object) {
                    const delta_object = delta.object;
                    if (delta_object.get("reasoning")) |reasoning| {
                        try dumpTextValue(reasoning, state, choice_index, true);
                    }
                    if (delta_object.get("reasoning_content")) |reasoning_content| {
                        try dumpTextValue(reasoning_content, state, choice_index, true);
                    }
                }
                try dumpTextValue(delta, state, choice_index, is_reasoning);
            }
        },
        else => {},
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

    const model_json = try std.fmt.allocPrint(gpa, "\"{s}\"", .{conf.model});
    defer gpa.free(model_json);
    var model = try std.json.parseFromSlice(std.json.Value, gpa, model_json, .{});
    defer model.deinit();

    var prompt = try std.json.parseFromSlice(std.json.Value, gpa, "\"Write a short poem about a river\"", .{});
    defer prompt.deinit();

    const completion_request = sdk.resources.completions.CreateCompletionRequest{
        .model = model.value,
        .prompt = prompt.value,
        .best_of = null,
        .echo = false,
        .frequency_penalty = null,
        .logit_bias = null,
        .logprobs = null,
        .max_tokens = 768,
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
    };

    std.debug.print("Completion stream:\n", .{});
    var stream_state = StreamState{
        .allocator = gpa,
        .choice_last_texts = .{},
        .reasoning_choice_last_texts = .{},
        .output = .{},
        .reasoning_output = .{},
    };
    defer stream_state.deinit();

    client.completions().create_completion_stream_with_options_and_done(
        gpa,
        completion_request,
        onChunk,
        &stream_state,
        null,
        onDone,
        &stream_state,
    ) catch |err| {
        std.debug.print("Completion stream request failed: {s}\n", .{@errorName(err)});
        return;
    };

    const is_deepseek = compat.isDeepSeek(conf.base_url);
    const fallback_needed = stream_state.output.items.len == 0 or
        (stream_state.event_count > 0 and
            (if (is_deepseek)
                (!stream_state.stream_done or !stream_state.saw_finish_reason or stream_state.looksIncomplete())
            else
                (!stream_state.stream_done or !stream_state.saw_finish_reason)));
    const should_fallback = fallback_needed;

    if (should_fallback) {
        std.debug.print("\n", .{});
        if (fallback_needed and is_deepseek and stream_state.looksIncomplete())
        {
            std.debug.print("Completion stream output appears truncated, fallback to non-stream request.\n", .{});
        } else {
            std.debug.print("Completion stream incomplete, fallback to non-stream request.\n", .{});
        }
        var non_stream = completion_request;
        non_stream.stream = null;
        const response = client.completions().create_completion_with_options(
            gpa,
            non_stream,
            null,
        ) catch |err| {
            std.debug.print("Completion fallback request failed: {s}\n", .{@errorName(err)});
            std.debug.print("\n", .{});
            return;
        };
        defer response.deinit();

        if (response.value.choices.len == 0) {
            std.debug.print("Completion stream fallback response has no choices.\n", .{});
            return;
        }
        const text = response.value.choices[0].text;
        if (text.len == 0) {
            std.debug.print("Completion stream fallback returned empty text.\n", .{});
            return;
        }
        std.debug.print("{s}\n", .{text});
        if (stream_state.reasoning_output.items.len > 0) {
            std.debug.print("Reasoning:\n{s}\n", .{stream_state.reasoning_output.items});
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
