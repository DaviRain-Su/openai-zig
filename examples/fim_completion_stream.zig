const std = @import("std");
const sdk = @import("openai_zig");
const errors = sdk.errors;
const config = @import("config");

const StreamState = struct {
    allocator: std.mem.Allocator,
    output: std.ArrayListUnmanaged(u8),
    output_reasoning: std.ArrayListUnmanaged(u8),
    event_count: usize = 0,
    saw_finish_reason: bool = false,
    stream_done: bool = false,

    fn deinit(self: *StreamState) void {
        self.output.deinit(self.allocator);
        self.output_reasoning.deinit(self.allocator);
    }

    fn emitIncremental(self: *StreamState, dst: *std.ArrayListUnmanaged(u8), text: []const u8) errors.Error!void {
        dst.appendSlice(self.allocator, text) catch return errors.Error.HttpError;
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

    const model_json = try std.fmt.allocPrint(gpa, "\"{s}\"", .{conf.model});
    defer gpa.free(model_json);
    var model = try std.json.parseFromSlice(std.json.Value, gpa, model_json, .{});
    defer model.deinit();

    var prompt = try std.json.parseFromSlice(std.json.Value, gpa, "\"def fib(a):\"", .{});
    defer prompt.deinit();

    var state = StreamState{
        .allocator = gpa,
        .output = .{},
        .output_reasoning = .{},
    };
    defer state.deinit();

    const request = sdk.resources.completions.CreateCompletionRequest{
        .model = model.value,
        .prompt = prompt.value,
        .suffix = "    return fib(a - 1) + fib(a - 2)",
        .best_of = null,
        .echo = false,
        .frequency_penalty = null,
        .logit_bias = null,
        .logprobs = null,
        .max_tokens = 128,
        .n = null,
        .presence_penalty = null,
        .seed = null,
        .stop = null,
        .stream = null,
        .stream_options = null,
        .temperature = null,
        .top_p = null,
        .user = null,
    };

    std.debug.print("FIM completion stream:\n", .{});
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

    if (state.stream_done or state.event_count > 0) {
        if (state.output.items.len > 0) {
            std.debug.print("Stream text:\n{s}\n", .{state.output.items});
        } else {
            std.debug.print("Stream returned no text payload, fallback to non-stream.\n", .{});
            const fallback = client.completions().create_completion_with_options(gpa, request, null) catch |err| {
                std.debug.print("FIM stream fallback request failed: {s}\n", .{@errorName(err)});
                std.debug.print("\n", .{});
                return;
            };
            defer fallback.deinit();
            if (fallback.value.choices.len > 0) {
                std.debug.print("Fallback text:\n{s}\n", .{fallback.value.choices[0].text});
            } else {
                std.debug.print("Fallback result has no choices.\n", .{});
            }
        }
        if (state.output_reasoning.items.len > 0) {
            std.debug.print("Reasoning:\n{s}\n", .{state.output_reasoning.items});
        }
        return;
    }

    std.debug.print("Stream response appears incomplete; fallback to non-stream.\n", .{});
    const fallback = client.completions().create_completion_with_options(gpa, request, null) catch |err| {
        std.debug.print("FIM stream fallback request failed: {s}\n", .{@errorName(err)});
        std.debug.print("\n", .{});
        return;
    };
    defer fallback.deinit();

    if (fallback.value.choices.len == 0) {
        std.debug.print("Fallback result has no choices.\n", .{});
        return;
    }

    std.debug.print("Fallback text:\n{s}\n", .{fallback.value.choices[0].text});
}
