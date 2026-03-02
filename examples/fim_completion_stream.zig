const std = @import("std");
const sdk = @import("openai_zig");
const errors = sdk.errors;
const config = @import("config");
const compat = @import("provider_compat");

const StreamState = struct {
    allocator: std.mem.Allocator,
    output: std.ArrayListUnmanaged(u8),
    output_reasoning: std.ArrayListUnmanaged(u8),
    event_count: usize = 0,
    saw_finish_reason: bool = false,
    stream_done: bool = false,
    char_count: usize = 0,

    fn deinit(self: *StreamState) void {
        self.output.deinit(self.allocator);
        self.output_reasoning.deinit(self.allocator);
    }

    fn emitIncremental(self: *StreamState, dst: *std.ArrayListUnmanaged(u8), text: []const u8) errors.Error!void {
        self.char_count += text.len;
        dst.appendSlice(self.allocator, text) catch return errors.Error.HttpError;
    }

    fn looksIncomplete(self: *StreamState) bool {
        if (self.output.items.len == 0) return true;
        if (self.char_count < 64) return false;

        const trimmed = std.mem.trimRight(u8, self.output.items, " \t\r\n");
        if (trimmed.len == 0) return true;

        const normalized = trimCompletionTrailingNoise(trimmed);
        if (normalized.len == 0) return true;

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
            return false;
        }

        if (std.mem.endsWith(u8, normalized, "。") or
            std.mem.endsWith(u8, normalized, "？") or
            std.mem.endsWith(u8, normalized, "！") or
            std.mem.endsWith(u8, normalized, "；") or
            std.mem.endsWith(u8, normalized, "：") or
            std.mem.endsWith(u8, normalized, "）") or
            std.mem.endsWith(u8, normalized, "】") or
            std.mem.endsWith(u8, normalized, "》") or
            std.mem.endsWith(u8, normalized, "“") or
            std.mem.endsWith(u8, normalized, "”") or
            std.mem.endsWith(u8, normalized, "‘") or
            std.mem.endsWith(u8, normalized, "’"))
        {
            return false;
        }

        return true;
    }
};

fn onDone(user_ctx: ?*anyopaque) errors.Error!void {
    const state: *StreamState = if (user_ctx) |ctx| @ptrCast(@alignCast(ctx)) else return;
    state.stream_done = true;
}

fn dumpTextValue(
    value: std.json.Value,
    state: *StreamState,
    use_reasoning: bool,
) errors.Error!void {
    if (value == .null) return;

    switch (value) {
        .string => |text| {
            if (use_reasoning) {
                try state.emitIncremental(&state.output_reasoning, text);
            } else {
                try state.emitIncremental(&state.output, text);
            }
        },
        .array => |items| {
            for (items.items) |item| {
                if (item == .object) {
                    const item_obj = item.object;
                    if (item_obj.get("type")) |kind| {
                        if (kind == .string and std.mem.eql(u8, kind.string, "text")) {
                            if (item_obj.get("text")) |text| {
                                try dumpTextValue(text, state, use_reasoning);
                            }
                            continue;
                        }
                    }
                    if (item_obj.get("text")) |text| {
                        try dumpTextValue(text, state, use_reasoning);
                    } else if (item_obj.get("input_text")) |input_text| {
                        try dumpTextValue(input_text, state, use_reasoning);
                    }
                } else if (item != .null) {
                    try dumpTextValue(item, state, use_reasoning);
                }
            }
        },
        .object => |obj| {
            if (obj.get("text")) |text| {
                try dumpTextValue(text, state, use_reasoning);
            }
            if (obj.get("reasoning")) |reasoning| {
                try dumpTextValue(reasoning, state, true);
            }
            if (obj.get("reasoning_content")) |reasoning_content| {
                try dumpTextValue(reasoning_content, state, true);
            }
        },
        else => {},
    }
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
    if (choices != .array) return;

    for (choices.array.items) |choice| {
        if (choice != .object) continue;
        const choice_obj = choice.object;

        if (choice_obj.get("text")) |text| {
            try dumpTextValue(text, state, false);
        } else if (choice_obj.get("delta")) |delta| {
            try dumpTextValue(delta, state, false);
        }

        if (choice_obj.get("reasoning")) |reasoning| {
            try dumpTextValue(reasoning, state, true);
        }
        if (choice_obj.get("reasoning_content")) |reasoning_content| {
            try dumpTextValue(reasoning_content, state, true);
        }

        if (choice_obj.get("finish_reason")) |finish_reason| {
            state.saw_finish_reason = true;
            if (finish_reason == .string) state.stream_done = true;
        }
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

    const prompt = "def fib(a):";

    var state = StreamState{
        .allocator = gpa,
        .output = .{},
        .output_reasoning = .{},
    };
    defer state.deinit();

    const request = sdk.resources.completions.CreateCompletionRequest{
        .model = conf.model,
        .prompt = prompt,
        .suffix = "    return fib(a - 1) + fib(a - 2)",
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
        .stream = true,
        .stream_options = null,
        .temperature = null,
        .top_p = null,
        .user = null,
    };

    std.debug.print("FIM completion stream:\n", .{});
    if (compat.isDeepSeek(conf.base_url)) {
        const non_stream = compat.withoutStream(@TypeOf(request), request);
        const response = client.completions().create_completion_with_options(gpa, non_stream, null) catch |err| {
            std.debug.print("FIM request failed on DeepSeek fallback path: {s}\n", .{@errorName(err)});
            std.debug.print("\n", .{});
            return;
        };
        defer response.deinit();

        if (response.value.choices.len == 0) {
            std.debug.print("FIM request returned no choices.\n", .{});
            return;
        }
        if (response.value.choices[0].text.len == 0) {
            std.debug.print("FIM request returned empty text.\n", .{});
            return;
        }
        std.debug.print("{s}\n\n", .{response.value.choices[0].text});
        return;
    }

    client.completions().create_completion_stream_with_options_and_done(
        gpa,
        request,
        onChunk,
        &state,
        null,
        onDone,
        &state,
    ) catch |err| {
        std.debug.print("FIM stream request failed: {s}\n", .{@errorName(err)});
        return;
    };

    const stream_unfinished = !state.stream_done or !state.saw_finish_reason;
    const fallback_needed = state.output.items.len == 0 or
        (state.event_count > 0 and stream_unfinished and state.looksIncomplete());

    if (fallback_needed) {
        if (state.output.items.len > 0 and state.looksIncomplete()) {
            std.debug.print("Stream response appears incomplete; fallback to non-stream.\n", .{});
        } else if (state.output.items.len == 0) {
            std.debug.print("Stream returned no text payload, fallback to non-stream.\n", .{});
        } else {
            std.debug.print("Stream fallback path.\n", .{});
        }

        const non_stream = compat.withoutStream(@TypeOf(request), request);
        const fallback = client.completions().create_completion_with_options(gpa, non_stream, null) catch |err| {
            std.debug.print("FIM stream fallback request failed: {s}\n", .{@errorName(err)});
            std.debug.print("\n", .{});
            return;
        };
        defer fallback.deinit();

        if (fallback.value.choices.len == 0) {
            std.debug.print("Fallback result has no choices.\n", .{});
            return;
        }
        if (fallback.value.choices[0].text.len == 0) {
            std.debug.print("Fallback result has empty text.\n", .{});
            return;
        }
        std.debug.print("Fallback text:\n{s}\n", .{fallback.value.choices[0].text});
    } else {
        if (state.output.items.len > 0) {
            std.debug.print("Stream text:\n{s}\n", .{state.output.items});
        } else {
            std.debug.print("Stream response returned no textual output.\n", .{});
        }
    }

    if (state.output_reasoning.items.len > 0) {
        std.debug.print("Reasoning:\n{s}\n", .{state.output_reasoning.items});
    }
    std.debug.print("\n", .{});
}
