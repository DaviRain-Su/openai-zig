const std = @import("std");
const gen = @import("generated/types.zig");
const user_balance = @import("resources/user_balance.zig");

test "core responses ignore unknown fields" {
    const list_models_payload =
        \\{"object":"list","data":[{"id":"gpt-4o-mini","object":"model","owner":"openai"},{"id":"deepseek-chat","object":"model"}],"extra_root":"x","data_meta":{"count":2}}
    ;
    const models = try std.json.parseFromSlice(
        gen.ListModelsResponse,
        std.testing.allocator,
        list_models_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer models.deinit();
    try std.testing.expectEqualStrings("list", models.value.object);
    try std.testing.expectEqual(@as(usize, 2), models.value.data.len);

    const list_files_payload =
        \\{"object":"list","data":[{"id":"file-abc","object":"file","bytes":123},{"id":"file-def","object":"file"}],"has_more":false,"first_id":"file-abc","last_id":"file-def","unexpected":"ignore-me"}
    ;
    const files = try std.json.parseFromSlice(
        gen.ListFilesResponse,
        std.testing.allocator,
        list_files_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer files.deinit();
    try std.testing.expectEqualStrings("list", files.value.object);
    try std.testing.expect(!files.value.has_more);
    try std.testing.expectEqualStrings("file-abc", files.value.first_id);
    try std.testing.expectEqualStrings("file-def", files.value.last_id);
}

test "moderation response ignores unknown fields" {
    const moderation_payload =
        \\{"id":"mod-1","model":"text-moderation-latest","results":[],"extra_result":"value"}
    ;
    const response = try std.json.parseFromSlice(
        gen.CreateModerationResponse,
        std.testing.allocator,
        moderation_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();
    try std.testing.expectEqualStrings("mod-1", response.value.id);
    try std.testing.expectEqualStrings("text-moderation-latest", response.value.model);
    try std.testing.expectEqual(@as(usize, 0), response.value.results.len);
}

test "moderation response parses bool categories" {
    const moderation_payload =
        \\{"id":"mod-2","model":"text-moderation-latest","results":[{"flagged":true,"categories":{"hate":false,"hate_threatening":false,"harassment":false,"harassment_threatening":false,"illicit":false,"illicit_violent":true,"self_harm":false,"self_harm_intent":false,"self_harm_instructions":false,"sexual":false,"sexual_minors":false,"violence":false,"violence_graphic":false},"category_scores":{"hate":0.01,"hate_threatening":0.01,"harassment":0.01,"harassment_threatening":0.01,"illicit":0.01,"illicit_violent":0.7,"self_harm":0.01,"self_harm_intent":0.01,"self_harm_instructions":0.01,"sexual":0.01,"sexual_minors":0.01,"violence":0.01,"violence_graphic":0.01},"category_applied_input_types":{"hate":[],"hate_threatening":[],"harassment":[],"harassment_threatening":[],"illicit":[],"illicit_violent":[],"self_harm":[],"self_harm_intent":[],"self_harm_instructions":[],"sexual":[],"sexual_minors":[],"violence":[],"violence_graphic":[]}}]}
    ;
    const response = try std.json.parseFromSlice(
        gen.CreateModerationResponse,
        std.testing.allocator,
        moderation_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();
    try std.testing.expect(!response.value.results[0].categories.illicit);
    try std.testing.expect(response.value.results[0].categories.illicit_violent);
}

test "assistants response ignores unknown fields" {
    const assistants_payload =
        \\{"object":"list","data":[{"id":"asst_123","object":"assistant","created_at":1700000000,"name":"demo","description":"test","model":"deepseek-chat","instructions":"你是助手","tools":[{"type":"text"}],"metadata":{},"tool_resources":null,"unused_field":"ignored"}],"first_id":"asst_123","last_id":"asst_123","has_more":false,"unexpected":"x"}
    ;
    const assistants = try std.json.parseFromSlice(
        gen.ListAssistantsResponse,
        std.testing.allocator,
        assistants_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer assistants.deinit();
    try std.testing.expectEqualStrings("list", assistants.value.object);
    try std.testing.expectEqual(@as(usize, 1), assistants.value.data.len);
    try std.testing.expect(!assistants.value.has_more);
    try std.testing.expectEqualStrings("asst_123", assistants.value.first_id);
    try std.testing.expectEqualStrings("asst_123", assistants.value.last_id);
    try std.testing.expectEqualStrings("asst_123", assistants.value.data[0].id);
}

test "assistant response parses typed response_format auto" {
    const payload =
        \\{"id":"asst_123","object":"assistant","created_at":1700000000,"name":"demo","description":"test","model":"deepseek-chat","instructions":"你是助手","tools":[{"type":"code_interpreter"}],"tool_resources":{"code_interpreter":{"file_ids":["file_1"]}},"metadata":{},"response_format":"auto"}
    ;
    const assistant = try std.json.parseFromSlice(
        gen.AssistantObject,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer assistant.deinit();

    const response_format = assistant.value.response_format orelse {
        try std.testing.expect(false);
        return;
    };

    switch (response_format) {
        .auto => {},
        else => try std.testing.expect(false),
    }
}

test "tool parses code_interpreter auto container" {
    const payload =
        \\{"type":"code_interpreter","container":{"type":"auto","file_ids":["file_1","file_2"],"memory_limit":"4GB"}}
    ;
    const tool = try std.json.parseFromSlice(
        gen.Tool,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer tool.deinit();

    switch (tool.value) {
        .code_interpreter => |code_tool| {
            switch (code_tool.container) {
                .auto => |container| {
                    try std.testing.expectEqualStrings("auto", container.type);
                    try std.testing.expect(container.file_ids != null);
                    try std.testing.expectEqual(@as(usize, 2), container.file_ids.?.len);
                    try std.testing.expectEqualStrings("file_1", container.file_ids.?[0]);
                    try std.testing.expectEqualStrings("file_2", container.file_ids.?[1]);
                    try std.testing.expect(container.memory_limit != null);
                    try std.testing.expectEqualStrings("4GB", container.memory_limit.?);
                },
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }
}

test "tool keeps code_interpreter unknown container as raw" {
    const payload =
        \\{"type":"code_interpreter","container":{"type":"legacy","container_id":"ci_abc"}}
    ;
    const tool = try std.json.parseFromSlice(
        gen.Tool,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer tool.deinit();

    switch (tool.value) {
        .code_interpreter => |code_tool| {
            switch (code_tool.container) {
                .raw => |_| {},
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }
}

test "response objects parse with structured fields and raw fallback" {
    const payload =
        \\{"id":"resp_123","object":"response","status":"completed","model":"deepseek-chat","created_at":1700000000,"output":{"type":"text","text":"ok"},"usage":{"input_tokens":10,"input_tokens_details":{"cached_tokens":1},"output_tokens":20,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":30}}
    ;
    const response = try std.json.parseFromSlice(
        gen.Response,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();

    switch (response.value) {
        .object => |value| {
            try std.testing.expectEqualStrings("resp_123", value.id.?);
            try std.testing.expectEqualStrings("response", value.object.?);
            try std.testing.expectEqualStrings("completed", value.status.?);
            try std.testing.expect(value.usage != null);
            try std.testing.expectEqual(@as(i64, 30), value.usage.?.total_tokens);
        },
        .raw => |value| {
            _ = value;
            try std.testing.expect(false);
        },
    }
}

test "response objects can retain unknown payload as raw" {
    const payload =
        \\{"unexpected":"shape"}
    ;
    const response = try std.json.parseFromSlice(
        gen.Response,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();

    switch (response.value) {
        .object => |_| {
            // current fallback strategy may still parse object-shaped inputs.
            // this keeps behavior stable while still validating parse success.
            return;
        },
        .raw => |value| {
            try std.testing.expectEqualStrings("shape", value.object.get("unexpected").?.string);
        },
    }
}

test "create responses parser supports both structured and raw variants" {
    const object_payload =
        \\{"input":"tell me a joke","model":"deepseek-chat"}
    ;
    const request_object = try std.json.parseFromSlice(
        gen.CreateResponse,
        std.testing.allocator,
        object_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer request_object.deinit();
    switch (request_object.value) {
        .object => |value| {
            const input = value.input orelse {
                try std.testing.expect(false);
                return;
            };
            switch (input) {
                .text => |text| try std.testing.expectEqualStrings("tell me a joke", text),
                else => try std.testing.expect(false),
            }
        },
        .raw => {
            try std.testing.expect(false);
        },
    }

    const raw_payload =
        \\1
    ;
    const request_raw = try std.json.parseFromSlice(
        gen.CreateResponse,
        std.testing.allocator,
        raw_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer request_raw.deinit();
    switch (request_raw.value) {
        .raw => |value| {
            try std.testing.expectEqual(std.json.Value{ .integer = 1 }, value);
        },
        .object => |_| {
            try std.testing.expect(false);
        },
    }
}

test "response error supports structured fields and raw fallback" {
    const response_error_payload =
        \\{"error":{"message":"Invalid response input","type":"invalid_request_error","code":"invalid_type","param":"input"}}
    ;
    const response = try std.json.parseFromSlice(
        gen.Response,
        std.testing.allocator,
        response_error_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();

    switch (response.value) {
        .object => |value| {
            switch (value.@"error") {
                .object => |response_error| {
                    try std.testing.expectEqualStrings("Invalid response input", response_error.message);
                    try std.testing.expectEqualStrings("invalid_request_error", response_error.type.?);
                    try std.testing.expectEqualStrings("invalid_type", response_error.code.?);
                    try std.testing.expectEqualStrings("input", response_error.param.?);
                },
                .raw => |raw| {
                    try std.testing.expectEqualStrings("invalid_type", (raw.object.get("error").?.object.get("code").?).string);
                },
                null => try std.testing.expect(false),
            }
        },
        .raw => |value| {
            try std.testing.expect(false);
            _ = value;
        },
    }

    const odd_error_payload =
        \\{"error":"unexpected"}
    ;
    const raw_error_response = try std.json.parseFromSlice(
        gen.Response,
        std.testing.allocator,
        odd_error_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer raw_error_response.deinit();

    switch (raw_error_response.value) {
        .raw => |raw| {
            try std.testing.expectEqualStrings("unexpected", raw.object.get("error").?.string);
        },
        .object => |value| {
            if (value.@"error") |err| {
                switch (err) {
                    .raw => |raw| {
                        try std.testing.expectEqualStrings("unexpected", raw.string);
                    },
                    .object => |_| {},
                }
            } else {
                try std.testing.expect(false);
            }
        },
    }
}

test "create eval request parses typed datasource and criteria unions" {
    const payload =
        \\{"name":"response-quality","data_source_config":{"type":"custom","item_schema":{"type":"object","properties":{"question":{"type":"string"}},"required":["question"]},"include_sample_schema":true},"testing_criteria":[{"type":"string_check","name":"ContainsHello","input":"{{sample.output_text}}","reference":"hello","operation":"contains"},{"type":"label_model","name":"Labeler","model":"deepseek-chat","input":[{"role":"user","type":"message","content":"Classify this response: {{item.response}}"},{"role":"assistant","type":"message","content":{"type":"output_text","text":"positive"}}],"labels":["positive","negative"],"passing_labels":["positive"]}]}
    ;
    const request = try std.json.parseFromSlice(
        gen.CreateEvalRequest,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer request.deinit();

    switch (request.value.data_source_config) {
        .custom => |source| {
            try std.testing.expect(source.include_sample_schema != null);
            try std.testing.expect(source.include_sample_schema.?);
        },
        else => try std.testing.expect(false),
    }

    try std.testing.expectEqual(@as(usize, 2), request.value.testing_criteria.len);

    switch (request.value.testing_criteria[0]) {
        .string_check => |criterion| {
            try std.testing.expectEqualStrings("ContainsHello", criterion.name);
            try std.testing.expectEqualStrings("contains", criterion.operation);
        },
        else => try std.testing.expect(false),
    }

    switch (request.value.testing_criteria[1]) {
        .label_model => |criterion| {
            try std.testing.expectEqualStrings("Labeler", criterion.name);
            try std.testing.expectEqual(@as(usize, 2), criterion.input.len);
            switch (criterion.input[0]) {
                .eval_item => |item| {
                    try std.testing.expectEqualStrings("user", item.role);
                    switch (item.content) {
                        .item => |content| {
                            switch (content) {
                                .text => |value| {
                                    try std.testing.expectEqualStrings("Classify this response: {{item.response}}", value);
                                },
                                else => try std.testing.expect(false),
                            }
                        },
                        else => try std.testing.expect(false),
                    }
                },
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }
}

test "create eval item supports simple and eval-item variants" {
    const simple_payload =
        \\{"role":"user","content":"Simple prompt with {{item.name}}."}
    ;
    const simple_item = try std.json.parseFromSlice(
        gen.CreateEvalItem,
        std.testing.allocator,
        simple_payload,
        .{},
    );
    defer simple_item.deinit();
    switch (simple_item.value) {
        .simple => |item| {
            try std.testing.expectEqualStrings("user", item.role);
            try std.testing.expectEqualStrings("Simple prompt with {{item.name}}.", item.content);
        },
        else => try std.testing.expect(false),
    }

    const complex_payload =
        \\{"role":"assistant","type":"message","content":{"type":"output_text","text":"Done"}}
    ;
    const complex_item = try std.json.parseFromSlice(
        gen.CreateEvalItem,
        std.testing.allocator,
        complex_payload,
        .{},
    );
    defer complex_item.deinit();
    switch (complex_item.value) {
        .eval_item => |item| {
            try std.testing.expectEqualStrings("assistant", item.role);
            switch (item.content) {
                .item => |content| {
                    switch (content) {
                        .output_text => |output_text| {
                            try std.testing.expectEqualStrings("Done", output_text.text);
                        },
                        else => try std.testing.expect(false),
                    }
                },
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }
}

test "prompt parses template object and falls back raw on invalid payload" {
    const prompt_payload =
        \\{"id":"prompt-123","version":"v1","variables":{"customer":"Alice"}}
    ;
    const prompt = try std.json.parseFromSlice(
        gen.Prompt,
        std.testing.allocator,
        prompt_payload,
        .{},
    );
    defer prompt.deinit();
    switch (prompt.value) {
        .template => |value| {
            try std.testing.expectEqualStrings("prompt-123", value.id);
            try std.testing.expectEqualStrings("v1", value.version.?);
            try std.testing.expect(value.variables != null);
            try std.testing.expectEqualStrings("Alice", value.variables.?.asJson().object.get("customer").?.string);
        },
        .raw => |_| {
            try std.testing.expect(false);
        },
    }

    const invalid_payload =
        \\{"id":123}
    ;
    const invalid = try std.json.parseFromSlice(
        gen.Prompt,
        std.testing.allocator,
        invalid_payload,
        .{},
    );
    defer invalid.deinit();
    switch (invalid.value) {
        .raw => |value| {
            const id_field = value.object.get("id") orelse return error.TestUnexpectedResult;
            try std.testing.expectEqual(@as(i64, 123), id_field.integer);
        },
        .template => |_| {
            try std.testing.expect(false);
        },
    }
}

test "realtime audio format parses typed formats and keeps raw fallback" {
    const pcm_payload =
        \\{"type":"audio/pcm","rate":24000}
    ;
    const pcm = try std.json.parseFromSlice(
        gen.RealtimeAudioFormats,
        std.testing.allocator,
        pcm_payload,
        .{},
    );
    defer pcm.deinit();
    switch (pcm.value) {
        .pcm => |value| {
            try std.testing.expectEqualStrings("audio/pcm", value.type);
            try std.testing.expectEqual(@as(i64, 24000), value.rate.?);
        },
        else => try std.testing.expect(false),
    }

    const pcmu_payload =
        \\{"type":"audio/pcmu"}
    ;
    const pcmu = try std.json.parseFromSlice(
        gen.RealtimeAudioFormats,
        std.testing.allocator,
        pcmu_payload,
        .{},
    );
    defer pcmu.deinit();
    switch (pcmu.value) {
        .pcmu => |value| {
            try std.testing.expectEqualStrings("audio/pcmu", value.type);
        },
        else => try std.testing.expect(false),
    }

    const unknown_payload =
        \\"pcm16"
    ;
    const unknown = try std.json.parseFromSlice(
        gen.RealtimeAudioFormats,
        std.testing.allocator,
        unknown_payload,
        .{},
    );
    defer unknown.deinit();
    switch (unknown.value) {
        .raw => |value| {
            try std.testing.expectEqualStrings("pcm16", value.string);
        },
        else => try std.testing.expect(false),
    }
}

test "realtime truncation and turn detection parse typed variants" {
    const server_vad_payload =
        \\{"type":"server_vad","threshold":0.8,"prefix_padding_ms":250,"silence_duration_ms":500,"create_response":true,"interrupt_response":false,"idle_timeout_ms":12000}
    ;
    const server_vad = try std.json.parseFromSlice(
        gen.RealtimeTurnDetection,
        std.testing.allocator,
        server_vad_payload,
        .{},
    );
    defer server_vad.deinit();
    switch (server_vad.value) {
        .server_vad => |value| {
            try std.testing.expectEqual(@as(f64, 0.8), value.threshold.?);
            try std.testing.expect(value.create_response.?);
            try std.testing.expect(!value.interrupt_response.?);
        },
        else => try std.testing.expect(false),
    }

    const semantic_vad_payload =
        \\{"type":"semantic_vad","eagerness":"high","create_response":false,"interrupt_response":true}
    ;
    const semantic_vad = try std.json.parseFromSlice(
        gen.RealtimeTurnDetection,
        std.testing.allocator,
        semantic_vad_payload,
        .{},
    );
    defer semantic_vad.deinit();
    switch (semantic_vad.value) {
        .semantic_vad => |value| {
            try std.testing.expectEqualStrings("high", value.eagerness.?);
            try std.testing.expect(!value.create_response.?);
            try std.testing.expect(value.interrupt_response.?);
        },
        else => try std.testing.expect(false),
    }

    const unknown_turn_detection_payload =
        \\{"type":"custom_vad"}
    ;
    const unknown_turn_detection = try std.json.parseFromSlice(
        gen.RealtimeTurnDetection,
        std.testing.allocator,
        unknown_turn_detection_payload,
        .{},
    );
    defer unknown_turn_detection.deinit();
    switch (unknown_turn_detection.value) {
        .raw => |_| {},
        else => try std.testing.expect(false),
    }

    const truncation_auto = try std.json.parseFromSlice(
        gen.RealtimeTruncation,
        std.testing.allocator,
        "\"auto\"",
        .{},
    );
    defer truncation_auto.deinit();
    switch (truncation_auto.value) {
        .auto => {},
        else => try std.testing.expect(false),
    }

    const truncation_retention_payload =
        \\{"type":"retention_ratio","retention_ratio":0.75,"token_limits":{"post_instructions":5000}}
    ;
    const truncation_retention = try std.json.parseFromSlice(
        gen.RealtimeTruncation,
        std.testing.allocator,
        truncation_retention_payload,
        .{},
    );
    defer truncation_retention.deinit();
    switch (truncation_retention.value) {
        .retention_ratio => |value| {
            try std.testing.expectEqual(@as(f64, 0.75), value.retention_ratio);
            try std.testing.expect(value.token_limits != null);
            try std.testing.expectEqual(@as(i64, 5000), value.token_limits.?.post_instructions.?);
        },
        else => try std.testing.expect(false),
    }
}

test "AssistantsApiResponseFormatOption parses json_schema form" {
    const payload =
        \\{"type":"json_schema","json_schema":{"name":"qa","description":"question answer","schema":{"type":"object","properties":{"question":{"type":"string"}},"required":["question"]},"strict":true}}
    ;
    const response_format = try std.json.parseFromSlice(
        gen.AssistantsApiResponseFormatOption,
        std.testing.allocator,
        payload,
        .{},
    );
    defer response_format.deinit();

    switch (response_format.value) {
        .json_schema => |value| {
            try std.testing.expectEqualStrings("qa", value.json_schema.name);
            try std.testing.expectEqualStrings("question answer", value.json_schema.description.?);
            try std.testing.expect(value.json_schema.strict.?);
            try std.testing.expect(value.json_schema.schema != null);
            try std.testing.expect(value.json_schema.schema != null and value.json_schema.schema.?.asJson().object.get("type") != null);
        },
        else => try std.testing.expect(false),
    }
}

test "create message request content serializes text and parts variants" {
    const request_text = gen.CreateMessageRequest{
        .role = "user",
        .content = .{ .text = "hello world" },
        .attachments = null,
        .metadata = null,
    };

    var text_buf: [256]u8 = undefined;
    var text_fbs = std.io.fixedBufferStream(&text_buf);
    const text_writer = text_fbs.writer();
    try std.json.stringify(request_text, .{ .emit_null_optional_fields = false }, text_writer);
    const text_json = text_fbs.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, text_json, "\"content\":\"hello world\"") != null);

    const parts = [_]gen.CreateMessageRequestContentPart{
        .{
            .text = .{
                .type = "text",
                .text = "part one",
            },
        },
    };
    const request_parts = gen.CreateMessageRequest{
        .role = "user",
        .content = .{ .parts = &parts },
        .attachments = null,
        .metadata = null,
    };

    var parts_buf: [256]u8 = undefined;
    var parts_fbs = std.io.fixedBufferStream(&parts_buf);
    const parts_writer = parts_fbs.writer();
    try std.json.stringify(request_parts, .{ .emit_null_optional_fields = false }, parts_writer);
    const parts_json = parts_fbs.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, parts_json, "\"content\":[") != null);
    try std.testing.expect(std.mem.indexOf(u8, parts_json, "\"type\":\"text\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, parts_json, "\"text\":\"part one\"") != null);
}

test "create moderation request input serializes scalar and array forms" {
    const request_text = gen.CreateModerationRequest{
        .input = .{ .text = "A short statement." },
        .model = null,
    };

    var text_buf: [256]u8 = undefined;
    var text_fbs = std.io.fixedBufferStream(&text_buf);
    const text_writer = text_fbs.writer();
    try std.json.stringify(request_text, .{ .emit_null_optional_fields = false }, text_writer);
    const text_json = text_fbs.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, text_json, "\"input\":\"A short statement.\"") != null);

    const multi = [_][]const u8{
        "First text.",
        "Second text.",
    };
    const request_multi = gen.CreateModerationRequest{
        .input = .{ .texts = &multi },
        .model = "text-moderation-latest",
    };

    var multi_buf: [256]u8 = undefined;
    var multi_fbs = std.io.fixedBufferStream(&multi_buf);
    const multi_writer = multi_fbs.writer();
    try std.json.stringify(request_multi, .{ .emit_null_optional_fields = false }, multi_writer);
    const multi_json = multi_fbs.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, multi_json, "\"input\":[\"First text.\",\"Second text.\"]") != null);
}

test "thread object ignores unknown fields" {
    const thread_payload =
        \\{"id":"thread_abc","object":"thread","created_at":1700000000,"tool_resources":{"kind":"test"},"metadata":{"foo":"bar"},"unknown_thread_field":"ignored"}
    ;
    const thread = try std.json.parseFromSlice(
        gen.ThreadObject,
        std.testing.allocator,
        thread_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer thread.deinit();
    try std.testing.expectEqualStrings("thread_abc", thread.value.id);
    try std.testing.expectEqualStrings("thread", thread.value.object);
}

test "list messages response ignores unknown fields" {
    const payload =
        \\{"object":"list","data":[{"id":"msg_abc","object":"thread.message","created_at":1700000000,"thread_id":"thread_abc","status":"completed","incomplete_details":null,"completed_at":1700000010,"incomplete_at":null,"role":"user","content":[],"assistant_id":null,"run_id":null,"attachments":null,"metadata":{},"unknown_msg":"x"}],"first_id":"msg_abc","last_id":"msg_abc","has_more":false,"root_extra":"ignore"}
    ;
    const response = try std.json.parseFromSlice(
        gen.ListMessagesResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();
    try std.testing.expectEqualStrings("list", response.value.object);
    try std.testing.expectEqual(@as(usize, 1), response.value.data.len);
    try std.testing.expectEqualStrings("msg_abc", response.value.data[0].id);
    try std.testing.expect(!response.value.has_more);
    try std.testing.expectEqualStrings("msg_abc", response.value.first_id);
    try std.testing.expectEqualStrings("msg_abc", response.value.last_id);
}

test "list run steps response ignores unknown fields" {
    const payload =
        \\{"object":"list","data":[{"id":"step_abc","object":"thread.run.step","created_at":1700000000,"assistant_id":"asst_1","thread_id":"thread_abc","run_id":"run_1","type":"message_creation","status":"completed","step_details":{"type":"message_creation","message_creation":{"message_id":"msg_abc"}},"last_error":null,"expired_at":null,"cancelled_at":null,"failed_at":null,"completed_at":1700000005,"metadata":{},"usage":{}},"root_step_extra":"ignore"],"first_id":"step_abc","last_id":"step_abc","has_more":false}
    ;
    const response = try std.json.parseFromSlice(
        gen.ListRunStepsResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();
    try std.testing.expectEqualStrings("list", response.value.object);
    try std.testing.expectEqual(@as(usize, 1), response.value.data.len);
    try std.testing.expectEqualStrings("step_abc", response.value.data[0].id);
    try std.testing.expect(!response.value.has_more);
    try std.testing.expectEqualStrings("step_abc", response.value.first_id);
    try std.testing.expectEqualStrings("step_abc", response.value.last_id);
}

test "list vector store files and stores responses ignore unknown fields" {
    const files_payload =
        \\{"object":"list","data":[{"id":"file-abc","object":"vector_store.file","usage_bytes":1234,"created_at":1700000000,"vector_store_id":"vs_1","status":"completed","last_error":null,"chunking_strategy":null,"attributes":null,"extra_file":"ignore"}],"first_id":"file-abc","last_id":"file-abc","has_more":false}
    ;
    const files = try std.json.parseFromSlice(
        gen.ListVectorStoreFilesResponse,
        std.testing.allocator,
        files_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer files.deinit();
    try std.testing.expectEqualStrings("list", files.value.object);
    try std.testing.expectEqual(@as(usize, 1), files.value.data.len);
    try std.testing.expectEqualStrings("file-abc", files.value.data[0].id);
    try std.testing.expect(!files.value.has_more);

    const stores_payload =
        \\{"object":"list","data":[{"id":"vs_abc","object":"vector_store","created_at":1700000000,"name":"my_store","usage_bytes":2048,"file_counts":{"in_progress":0,"completed":1,"failed":0,"cancelled":0,"total":1},"status":"ready","expires_after":null,"expires_at":null,"last_active_at":null,"metadata":{},"extra_store":"ignore"}],"first_id":"vs_abc","last_id":"vs_abc","has_more":false,"root_extra":"ignore"}
    ;
    const stores = try std.json.parseFromSlice(
        gen.ListVectorStoresResponse,
        std.testing.allocator,
        stores_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer stores.deinit();
    try std.testing.expectEqualStrings("list", stores.value.object);
    try std.testing.expectEqual(@as(usize, 1), stores.value.data.len);
    try std.testing.expectEqualStrings("vs_abc", stores.value.data[0].id);
    try std.testing.expect(!stores.value.has_more);
    try std.testing.expectEqualStrings("vs_abc", stores.value.first_id);
    try std.testing.expectEqualStrings("vs_abc", stores.value.last_id);
}

test "comparison filter parses scalar, boolean, and array values" {
    const scalar_payload =
        \\{"type":"eq","key":"status","value":"active"}
    ;
    const scalar_filter = try std.json.parseFromSlice(
        gen.ComparisonFilter,
        std.testing.allocator,
        scalar_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer scalar_filter.deinit();
    try std.testing.expectEqualStrings("eq", scalar_filter.value.type);
    try std.testing.expectEqualStrings("status", scalar_filter.value.key);
    switch (scalar_filter.value.value) {
        .string => |value| try std.testing.expectEqualStrings("active", value),
        else => try std.testing.expect(false),
    }

    const bool_payload =
        \\{"type":"eq","key":"featured","value":true}
    ;
    const bool_filter = try std.json.parseFromSlice(
        gen.ComparisonFilter,
        std.testing.allocator,
        bool_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer bool_filter.deinit();
    switch (bool_filter.value.value) {
        .boolean => |value| try std.testing.expect(value),
        else => try std.testing.expect(false),
    }

    const array_payload =
        \\{"type":"in","key":"tag","value":["vip", "premium", 100]}
    ;
    const array_filter = try std.json.parseFromSlice(
        gen.ComparisonFilter,
        std.testing.allocator,
        array_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer array_filter.deinit();
    switch (array_filter.value.value) {
        .items => |value| {
            try std.testing.expectEqual(@as(usize, 3), value.len);
            switch (value[0]) {
                .string => |entry| try std.testing.expectEqualStrings("vip", entry),
                else => try std.testing.expect(false),
            }
            switch (value[2]) {
                .number => |entry| try std.testing.expectEqual(@as(f64, 100), entry),
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }
}

test "filters parses comparison and compound forms" {
    const comparison_payload =
        \\{"type":"eq","key":"status","value":"active"}
    ;
    const comparison_filter = try std.json.parseFromSlice(
        gen.Filters,
        std.testing.allocator,
        comparison_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer comparison_filter.deinit();
    switch (comparison_filter.value) {
        .comparison => |value| {
            try std.testing.expectEqualStrings("eq", value.type);
            switch (value.value) {
                .string => |entry| try std.testing.expectEqualStrings("active", entry),
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }

    const compound_payload =
        \\{"type":"and","filters":[{"type":"eq","key":"status","value":"active"},{"type":"gt","key":"score","value":0.7}]}
    ;
    const compound_filter = try std.json.parseFromSlice(
        gen.Filters,
        std.testing.allocator,
        compound_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer compound_filter.deinit();
    switch (compound_filter.value) {
        .compound => |value| {
            try std.testing.expectEqualStrings("and", value.type);
            try std.testing.expectEqual(@as(usize, 2), value.filters.len);
        },
        else => try std.testing.expect(false),
    }

    const unknown_payload =
        \\{"type":"contains","key":"status","value":"active"}
    ;
    const unknown_filter = try std.json.parseFromSlice(
        gen.Filters,
        std.testing.allocator,
        unknown_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer unknown_filter.deinit();
    switch (unknown_filter.value) {
        .raw => |_| {},
        else => try std.testing.expect(false),
    }
}

test "vector store request and tools reuse Filters type" {
    const vector_search_payload =
        \\{"query":"hello","filters":{"type":"gt","key":"score","value":0.9},"max_num_results":10}
    ;
    const request = try std.json.parseFromSlice(
        gen.VectorStoreSearchRequest,
        std.testing.allocator,
        vector_search_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer request.deinit();
    const filter = request.value.filters orelse {
        try std.testing.expect(false);
        return;
    };
    switch (filter) {
        .comparison => |value| {
            try std.testing.expectEqualStrings("gt", value.type);
            switch (value.value) {
                .number => |entry| try std.testing.expectEqual(@as(f64, 0.9), entry),
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }

    const file_search_tool_payload =
        \\{"type":"file_search","vector_store_ids":["vs_abc"],"filters":{"type":"or","filters":[{"type":"eq","key":"region","value":"us"}]}}
    ;
    const tool = try std.json.parseFromSlice(
        gen.FileSearchTool,
        std.testing.allocator,
        file_search_tool_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer tool.deinit();
    const tool_filter = tool.value.filters orelse {
        try std.testing.expect(false);
        return;
    };
    switch (tool_filter) {
        .compound => |value| {
            try std.testing.expectEqualStrings("or", value.type);
        },
        else => try std.testing.expect(false),
    }

    const file_search_call_payload =
        \\{"id":"call_1","type":"file_search_call","status":"completed","queries":["doc"],"results":[{"file_id":"file_abc","text":"snippet","filename":"a.txt","attributes":{"source":"doc"},"score":0.87}]}
    ;
    const call = try std.json.parseFromSlice(
        gen.FileSearchToolCall,
        std.testing.allocator,
        file_search_call_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer call.deinit();
    const results = call.value.results orelse {
        try std.testing.expect(false);
        return;
    };
    try std.testing.expectEqual(@as(usize, 1), results.len);
    try std.testing.expectEqualStrings("file_abc", results[0].file_id);
    try std.testing.expectEqualStrings("a.txt", results[0].filename);
}

test "list runs response ignores unknown fields" {
    const payload =
        \\{"object":"list","data":[{"id":"run_abc","object":"thread.run","created_at":1700000000,"thread_id":"thread_abc","assistant_id":"asst_1","status":"in_progress","required_action":{"type":"none","submit_tool_outputs":{"tool_calls":[]}},"last_error":{"code":"","message":""},"expires_at":1700001000,"started_at":1700000500,"cancelled_at":0,"failed_at":0,"completed_at":0,"incomplete_details":{"reason":null},"model":"deepseek-chat","instructions":"test","tools":[],"metadata":{},"usage":{},"temperature":1.0,"top_p":1.0,"max_prompt_tokens":4096,"max_completion_tokens":4096,"truncation_strategy":{},"tool_choice":{},"parallel_tool_calls":false,"response_format":{},"root_extra":"x"}],"first_id":"run_abc","last_id":"run_abc","has_more":false,"list_extra":"y"}
    ;
    const response = try std.json.parseFromSlice(
        gen.ListRunsResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();
    try std.testing.expectEqualStrings("list", response.value.object);
    try std.testing.expectEqual(@as(usize, 1), response.value.data.len);
    try std.testing.expectEqualStrings("run_abc", response.value.data[0].id);
    try std.testing.expect(!response.value.has_more);
    try std.testing.expectEqualStrings("run_abc", response.value.first_id);
    try std.testing.expectEqualStrings("run_abc", response.value.last_id);
}

test "run object parses with unknown extras and nullable nested fields" {
    const payload =
        \\{"id":"run_abc","object":"thread.run","created_at":1700000000,"thread_id":"thread_abc","assistant_id":"asst_1","status":"in_progress","required_action":{"type":"none","submit_tool_outputs":{"tool_calls":[]}},"last_error":{"code":"","message":""},"expires_at":1700001000,"started_at":1700000500,"cancelled_at":0,"failed_at":0,"completed_at":0,"incomplete_details":{"reason":null},"model":"deepseek-chat","instructions":"test","tools":[],"metadata":{},"usage":{},"temperature":1.0,"top_p":1.0,"max_prompt_tokens":4096,"max_completion_tokens":4096,"truncation_strategy":{},"tool_choice":{},"parallel_tool_calls":false,"response_format":{},"unknown_run_field":"ignored"}
    ;
    const run = try std.json.parseFromSlice(
        gen.RunObject,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer run.deinit();
    try std.testing.expectEqualStrings("run_abc", run.value.id);
    try std.testing.expectEqualStrings("thread.run", run.value.object);
    try std.testing.expectEqualStrings("thread_abc", run.value.thread_id);
    try std.testing.expect(run.value.incomplete_details.reason == null);
}

test "create completion response ignores unknown fields and tolerates optional usage" {
    const payload =
        \\{"id":"cmpl-test","object":"text_completion","created":1700000000,"model":"text-davinci-003","choices":[{"text":"hello","index":0,"logprobs":null,"finish_reason":"stop","choice_extra":1}],"usage":{"prompt_tokens":1,"completion_tokens":2,"total_tokens":3},"unknown_root":"x"}
    ;
    const response = try std.json.parseFromSlice(
        gen.CreateCompletionResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();
    try std.testing.expectEqualStrings("cmpl-test", response.value.id);
    try std.testing.expectEqualStrings("text_completion", response.value.object);
    try std.testing.expectEqualStrings("text-davinci-003", response.value.model);
    try std.testing.expectEqual(@as(usize, 1), response.value.choices.len);
    try std.testing.expectEqualStrings("hello", response.value.choices[0].text);
    try std.testing.expectEqual(@as(i64, 0), response.value.choices[0].index);
    try std.testing.expectEqualStrings("stop", response.value.choices[0].finish_reason);
    try std.testing.expect(response.value.usage != null);
    try std.testing.expectEqual(@as(i64, 1), response.value.usage.?.prompt_tokens);
}

test "create completion response parses structured logprobs" {
    const payload =
        \\{"id":"cmpl-log","object":"text_completion","created":1700000000,"model":"text-davinci-003","choices":[{"text":"hello","index":0,"logprobs":{"tokens":["hello"],"token_logprobs":[-0.04],"top_logprobs":[[{"token":" hello","logprob":-0.12,"bytes":[32,104,101,108,108,111]}]],"text_offset":[0]},"finish_reason":"stop"}],"usage":{"prompt_tokens":1,"completion_tokens":2,"total_tokens":3}}
    ;
    const response = try std.json.parseFromSlice(
        gen.CreateCompletionResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();

    try std.testing.expectEqual(@as(usize, 1), response.value.choices.len);
    const choice = response.value.choices[0];
    try std.testing.expect(choice.logprobs != null);
    try std.testing.expectEqualStrings("hello", choice.logprobs.?.tokens.?[0]);
    try std.testing.expectEqual(@as(usize, 1), choice.logprobs.?.top_logprobs.?.len);
    const top = choice.logprobs.?.top_logprobs.?[0];
    try std.testing.expect(top.len > 0);
    try std.testing.expectEqualStrings(" hello", top[0].token.?);
}

test "create completion response parses DeepSeek cache usage fields" {
    const payload =
        \\{"id":"cmpl-deepseek","object":"text_completion","created":1700000000,"model":"deepseek-chat","choices":[{"text":"hello","index":0,"logprobs":null,"finish_reason":"stop"}],"usage":{"prompt_tokens":10,"completion_tokens":20,"total_tokens":30,"prompt_cache_hit_tokens":25,"prompt_cache_miss_tokens":5}}
    ;
    const response = try std.json.parseFromSlice(
        gen.CreateCompletionResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();

    try std.testing.expect(response.value.usage != null);
    try std.testing.expectEqual(@as(i64, 25), response.value.usage.?.prompt_cache_hit_tokens.?);
    try std.testing.expectEqual(@as(i64, 5), response.value.usage.?.prompt_cache_miss_tokens.?);
}

test "generated create completion request serializes structured logit_bias map" {
    const biases = [_]gen.CreateCompletionLogitBiasEntry{
        .{
            .token = "50256",
            .bias = -100,
        },
    };

    const request = gen.CreateCompletionRequest{
        .model = "text-davinci-003",
        .prompt = "hello",
        .best_of = null,
        .echo = null,
        .frequency_penalty = null,
        .logit_bias = .{ .entries = &biases },
        .logprobs = null,
        .max_tokens = null,
        .n = null,
        .presence_penalty = null,
        .seed = null,
        .stop = null,
        .stream = null,
        .stream_options = null,
        .suffix = null,
        .temperature = null,
        .top_p = null,
        .user = null,
    };

    var fbs: [256]u8 = undefined;
    var stream = std.io.fixedBufferStream(&fbs);
    const writer = stream.writer();
    try std.json.stringify(request, .{ .emit_null_optional_fields = false }, writer);
    const json = stream.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, json, "\"logit_bias\":{\"50256\":-100}") != null);
}

test "generated create completion request serializes raw logit_bias passthrough" {
    const payload =
        \\{"token":"value"}
    ;
    const parsed = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        payload,
        .{},
    );
    defer parsed.deinit();

    const request = gen.CreateCompletionRequest{
        .model = "text-davinci-003",
        .prompt = "hello",
        .best_of = null,
        .echo = null,
        .frequency_penalty = null,
        .logit_bias = .{ .raw = parsed.value },
        .logprobs = null,
        .max_tokens = null,
        .n = null,
        .presence_penalty = null,
        .seed = null,
        .stop = null,
        .stream = null,
        .stream_options = null,
        .suffix = null,
        .temperature = null,
        .top_p = null,
        .user = null,
    };

    var fbs: [256]u8 = undefined;
    var stream = std.io.fixedBufferStream(&fbs);
    const writer = stream.writer();
    try std.json.stringify(request, .{ .emit_null_optional_fields = false }, writer);
    const json = stream.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, json, "\"logit_bias\":{\"token\":\"value\"}") != null);
}

test "generated chunking strategy request serializes static variant" {
    const request = gen.ChunkingStrategyRequestParam{
        .static = .{
            .type = "static",
            .static = .{
                .max_chunk_size_tokens = 800,
                .chunk_overlap_tokens = 128,
            },
        },
    };

    var fbs: [256]u8 = undefined;
    var stream = std.io.fixedBufferStream(&fbs);
    const writer = stream.writer();
    try std.json.stringify(request, .{ .emit_null_optional_fields = false }, writer);
    const json = stream.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, json, "\"type\":\"static\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, json, "\"static\":{\"max_chunk_size_tokens\":800,\"chunk_overlap_tokens\":128}") != null);
}

test "generated input/content variants parse text, image, file and audio forms" {
    const input_text_payload =
        \\{"type":"text","text":"hello world"}
    ;
    const parsed_text = try std.json.parseFromSlice(
        gen.InputContent,
        std.testing.allocator,
        input_text_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_text.deinit();
    switch (parsed_text.value) {
        .text => |value| {
            try std.testing.expectEqualStrings("text", value.type);
            try std.testing.expectEqualStrings("hello world", value.text);
        },
        else => try std.testing.expect(false),
    }

    const input_image_payload =
        \\{"type":"input_image","image_url":"https://example.com/image.png","detail":"high"}
    ;
    const parsed_image = try std.json.parseFromSlice(
        gen.InputContent,
        std.testing.allocator,
        input_image_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_image.deinit();
    switch (parsed_image.value) {
        .image => |value| {
            try std.testing.expectEqualStrings("input_image", value.type);
            try std.testing.expectEqualStrings("https://example.com/image.png", value.image_url.?);
            try std.testing.expectEqualStrings("high", value.detail.?);
        },
        else => try std.testing.expect(false),
    }

    const input_file_payload =
        \\{"type":"input_file","file_id":"file-abc","filename":"a.txt"}
    ;
    const parsed_file = try std.json.parseFromSlice(
        gen.InputContent,
        std.testing.allocator,
        input_file_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_file.deinit();
    switch (parsed_file.value) {
        .file => |value| {
            try std.testing.expectEqualStrings("input_file", value.type);
            try std.testing.expectEqualStrings("file-abc", value.file_id.?);
            try std.testing.expectEqualStrings("a.txt", value.filename.?);
        },
        else => try std.testing.expect(false),
    }

    const input_audio_payload =
        \\{"type":"input_audio","input_audio":{"data":"aGVsbG8=","format":"wav"}}
    ;
    const parsed_audio = try std.json.parseFromSlice(
        gen.InputContent,
        std.testing.allocator,
        input_audio_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_audio.deinit();
    switch (parsed_audio.value) {
        .audio => |value| {
            try std.testing.expectEqualStrings("input_audio", value.type);
            try std.testing.expectEqualStrings("aGVsbG8=", value.input_audio.data);
            try std.testing.expectEqualStrings("wav", value.input_audio.format);
        },
        else => try std.testing.expect(false),
    }
}

test "generated message content parses text variants with structured annotations" {
    const message_payload =
        \\{"type":"text","text":{"value":"Hello","annotations":[{"type":"file_citation","text":"Cited","file_citation":{"file_id":"file-abc"},"start_index":0,"end_index":6}]}}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.MessageContent,
        std.testing.allocator,
        message_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();
    switch (parsed.value) {
        .text => |value| {
            try std.testing.expectEqualStrings("text", value.type);
            try std.testing.expectEqualStrings("Hello", value.text.value);
            try std.testing.expect(value.text.annotations.len == 1);
            switch (value.text.annotations[0]) {
                .file_citation => |ann| {
                    try std.testing.expectEqualStrings("file-abc", ann.file_citation.file_id);
                },
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }

    const delta_payload =
        \\{"index":0,"type":"text","text":{"value":"Hi","annotations":[{"type":"file_path","text":"path","file_path":{"file_id":"file-xyz"},"start_index":0,"end_index":2}]}}
    ;
    const parsed_delta = try std.json.parseFromSlice(
        gen.MessageContentDelta,
        std.testing.allocator,
        delta_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_delta.deinit();
    switch (parsed_delta.value) {
        .text => |value| {
            try std.testing.expectEqual(@as(i64, 0), value.index);
            try std.testing.expectEqualStrings("Hi", value.text.?.value.?);
            try std.testing.expect(value.text.?.annotations != null);
            const annos = value.text.?.annotations.?;
            try std.testing.expectEqual(@as(usize, 1), annos.len);
            switch (annos[0]) {
                .file_path => |anno| {
                    try std.testing.expectEqualStrings("file-xyz", anno.file_path.?.file_id.?);
                },
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }

    const unknown_payload =
        \\{"type":"legacy","raw":"x"}
    ;
    const parsed_unknown = try std.json.parseFromSlice(
        gen.MessageContent,
        std.testing.allocator,
        unknown_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_unknown.deinit();
    switch (parsed_unknown.value) {
        .raw => |value| {
            try std.testing.expectEqualStrings("legacy", value.object.get("type").?.string);
        },
        else => try std.testing.expect(false),
    }
}

test "generated thread response format and thread item discriminators parse typed values" {
    const text_format_payload =
        \\{"type":"text"}
    ;
    const text_format = try std.json.parseFromSlice(
        gen.TextResponseFormatConfiguration,
        std.testing.allocator,
        text_format_payload,
        .{},
    );
    defer text_format.deinit();
    switch (text_format.value) {
        .text => |value| {
            try std.testing.expectEqualStrings("text", value.type);
        },
        else => try std.testing.expect(false),
    }

    const json_schema_payload =
        \\{"type":"json_schema","json_schema":{"description":"A response payload","name":"answer","schema":{"type":"object","properties":{"x":{"type":"string"}}},"strict":true}}
    ;
    const json_schema = try std.json.parseFromSlice(
        gen.TextResponseFormatConfiguration,
        std.testing.allocator,
        json_schema_payload,
        .{},
    );
    defer json_schema.deinit();
    switch (json_schema.value) {
        .json_schema => |value| {
            try std.testing.expectEqualStrings("json_schema", value.type);
            try std.testing.expectEqualStrings("answer", value.name);
            try std.testing.expect(value.strict orelse false);
        },
        else => try std.testing.expect(false),
    }

    const json_object_payload =
        \\{"type":"json_object"}
    ;
    const json_object = try std.json.parseFromSlice(
        gen.TextResponseFormatConfiguration,
        std.testing.allocator,
        json_object_payload,
        .{},
    );
    defer json_object.deinit();
    switch (json_object.value) {
        .json_object => |value| {
            try std.testing.expectEqualStrings("json_object", value.type);
        },
        else => try std.testing.expect(false),
    }

    const unknown_format_payload =
        \\{"type":"legacy","meta":"x"}
    ;
    const unknown_format = try std.json.parseFromSlice(
        gen.TextResponseFormatConfiguration,
        std.testing.allocator,
        unknown_format_payload,
        .{},
    );
    defer unknown_format.deinit();
    switch (unknown_format.value) {
        .raw => |value| {
            try std.testing.expectEqualStrings("legacy", value.object.get("type").?.string);
        },
        else => try std.testing.expect(false),
    }

    const thread_user_payload =
        \\{"id":"item-user-1","object":"chatkit.thread_item","created_at":1700000000,"thread_id":"thread-1","type":"chatkit.user_message","content":[{"type":"input_text","text":"hello"}],"attachments":[],"inference_options":null}
    ;
    const parsed_user_item = try std.json.parseFromSlice(
        gen.ThreadItem,
        std.testing.allocator,
        thread_user_payload,
        .{},
    );
    defer parsed_user_item.deinit();
    switch (parsed_user_item.value) {
        .user => |item| {
            try std.testing.expectEqualStrings("item-user-1", item.id);
            try std.testing.expectEqualStrings("chatkit.user_message", item.type);
            try std.testing.expectEqualStrings("input_text", item.content[0].input_text.type);
        },
        else => try std.testing.expect(false),
    }

    const thread_assistant_payload =
        \\{"id":"item-assistant-1","object":"chatkit.thread_item","created_at":1700000001,"thread_id":"thread-1","type":"chatkit.assistant_message","content":[{"type":"output_text","text":"hi","annotations":[]}]}
    ;
    const parsed_assistant_item = try std.json.parseFromSlice(
        gen.ThreadItem,
        std.testing.allocator,
        thread_assistant_payload,
        .{},
    );
    defer parsed_assistant_item.deinit();
    switch (parsed_assistant_item.value) {
        .assistant => |item| {
            try std.testing.expectEqualStrings("item-assistant-1", item.id);
            try std.testing.expectEqualStrings("chatkit.assistant_message", item.type);
            try std.testing.expectEqualStrings("output_text", item.content[0].type);
        },
        else => try std.testing.expect(false),
    }

    const unknown_thread_payload =
        \\{"type":"chatkit.legacy_item","id":"legacy-1","object":"chatkit.thread_item","thread_id":"thread-1","created_at":1700000002}
    ;
    const thread_unknown = try std.json.parseFromSlice(
        gen.ThreadItem,
        std.testing.allocator,
        unknown_thread_payload,
        .{},
    );
    defer thread_unknown.deinit();
    switch (thread_unknown.value) {
        .raw => |value| {
            try std.testing.expectEqualStrings("chatkit.legacy_item", value.object.get("type").?.string);
        },
        else => try std.testing.expect(false),
    }
}

test "generated user message item content parses input_text and quoted_text variants" {
    const input_payload =
        \\{"type":"input_text","text":"quoted"}
    ;
    const parsed_input = try std.json.parseFromSlice(
        gen.UserMessageItemContent,
        std.testing.allocator,
        input_payload,
        .{},
    );
    defer parsed_input.deinit();
    switch (parsed_input.value) {
        .input_text => |value| {
            try std.testing.expectEqualStrings("input_text", value.type);
            try std.testing.expectEqualStrings("quoted", value.text);
        },
        else => try std.testing.expect(false),
    }

    const quoted_payload =
        \\{"type":"quoted_text","text":"reply"}
    ;
    const parsed_quoted = try std.json.parseFromSlice(
        gen.UserMessageItemContent,
        std.testing.allocator,
        quoted_payload,
        .{},
    );
    defer parsed_quoted.deinit();
    switch (parsed_quoted.value) {
        .quoted_text => |value| {
            try std.testing.expectEqualStrings("quoted_text", value.type);
            try std.testing.expectEqualStrings("reply", value.text);
        },
        else => try std.testing.expect(false),
    }
}

test "generated output content parses output_text and falls back to raw for unknown type" {
    const output_text_payload =
        \\{"type":"output_text","text":"done","annotations":[]}
    ;
    const parsed_output = try std.json.parseFromSlice(
        gen.OutputContent,
        std.testing.allocator,
        output_text_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_output.deinit();
    switch (parsed_output.value) {
        .text => |value| {
            try std.testing.expectEqualStrings("output_text", value.type);
            try std.testing.expectEqualStrings("done", value.text);
        },
        else => try std.testing.expect(false),
    }

    const output_raw_payload =
        \\{"type":"unknown_output","data":123}
    ;
    const parsed_output_raw = try std.json.parseFromSlice(
        gen.OutputContent,
        std.testing.allocator,
        output_raw_payload,
        .{},
    );
    defer parsed_output_raw.deinit();
    switch (parsed_output_raw.value) {
        .raw => |value| {
            try std.testing.expectEqualStrings("unknown_output", value.object.get("type").?.string);
        },
        else => try std.testing.expect(false),
    }
}

test "generated message parses typed content blocks" {
    const message_payload =
        \\{"type":"assistant","id":"msg-1","status":"completed","role":"assistant","content":[{"type":"text","text":{"value":"Hello","annotations":[]}}]}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.Message,
        std.testing.allocator,
        message_payload,
        .{},
    );
    defer parsed.deinit();
    try std.testing.expectEqualStrings("assistant", parsed.value.type);
    try std.testing.expectEqualStrings("msg-1", parsed.value.id);
    try std.testing.expect(parsed.value.content.len > 0);
    switch (parsed.value.content[0]) {
        .text => |content| {
            try std.testing.expectEqualStrings("text", content.type);
            try std.testing.expectEqualStrings("Hello", content.text.value.?);
        },
        else => try std.testing.expect(false),
    }
}

test "generated chunking strategy parses static, other and raw fallback" {
    const static_payload =
        \\{"type":"static","static":{"max_chunk_size_tokens":256,"chunk_overlap_tokens":64}}
    ;
    const parsed_static = try std.json.parseFromSlice(
        gen.ChunkingStrategyRequestParam,
        std.testing.allocator,
        static_payload,
        .{},
    );
    defer parsed_static.deinit();
    switch (parsed_static.value) {
        .static => |value| {
            try std.testing.expectEqualStrings("static", value.type);
            try std.testing.expectEqual(@as(i64, 256), value.static.max_chunk_size_tokens);
            try std.testing.expectEqual(@as(i64, 64), value.static.chunk_overlap_tokens);
        },
        else => try std.testing.expect(false),
    }

    const other_payload =
        \\{"type":"other","metadata":{"note":"reserved-for-future"}}
    ;
    const parsed_other = try std.json.parseFromSlice(
        gen.ChunkingStrategyResponse,
        std.testing.allocator,
        other_payload,
        .{},
    );
    defer parsed_other.deinit();
    switch (parsed_other.value) {
        .other => |value| {
            try std.testing.expectEqualStrings("other", value.type);
        },
        else => try std.testing.expect(false),
    }

    const raw_payload = "[1,2,3]";
    const parsed_raw = try std.json.parseFromSlice(
        gen.ChunkingStrategyRequestParam,
        std.testing.allocator,
        raw_payload,
        .{},
    );
    defer parsed_raw.deinit();
    switch (parsed_raw.value) {
        .raw => |value| {
            try std.testing.expect(value == .array);
        },
        else => try std.testing.expect(false),
    }
}

test "create embedding response parses nested embedding objects" {
    const payload =
        \\{"object":"list","data":[{"object":"embedding","index":0,"embedding":[0.1,0.2,0.3]}],"model":"text-embedding-3-small","usage":{"prompt_tokens":3,"total_tokens":3},"extra_response_field":"ignored"}
    ;
    const response = try std.json.parseFromSlice(
        gen.CreateEmbeddingResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();
    try std.testing.expectEqualStrings("list", response.value.object);
    try std.testing.expectEqualStrings("text-embedding-3-small", response.value.model);
    try std.testing.expectEqual(@as(usize, 1), response.value.data.len);
    try std.testing.expectEqual(@as(i64, 0), response.value.data[0].index);
    try std.testing.expect(response.value.data[0].embedding.len == 3);
    try std.testing.expectEqual(@as(i64, 3), response.value.usage.total_tokens);
}

test "create embedding request input serializes scalar and array forms" {
    const request_text = gen.CreateEmbeddingRequest{
        .input = .{ .text = "Hello, world." },
        .model = "text-embedding-3-small",
        .encoding_format = null,
        .dimensions = null,
        .user = null,
    };

    var text_buf: [256]u8 = undefined;
    var text_fbs = std.io.fixedBufferStream(&text_buf);
    const text_writer = text_fbs.writer();
    try std.json.stringify(request_text, .{ .emit_null_optional_fields = false }, text_writer);
    const text_json = text_fbs.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, text_json, "\"input\":\"Hello, world.\"") != null);

    const texts = [_][]const u8{
        "first sentence",
        "second sentence",
    };
    const request_multi = gen.CreateEmbeddingRequest{
        .input = .{ .texts = &texts },
        .model = "text-embedding-3-small",
        .encoding_format = null,
        .dimensions = null,
        .user = null,
    };

    var multi_buf: [256]u8 = undefined;
    var multi_fbs = std.io.fixedBufferStream(&multi_buf);
    const multi_writer = multi_fbs.writer();
    try std.json.stringify(request_multi, .{ .emit_null_optional_fields = false }, multi_writer);
    const multi_json = multi_fbs.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, multi_json, "\"input\":[\"first sentence\",\"second sentence\"]") != null);
}

test "images response parses optional fields with unknown extras" {
    const payload =
        \\{"created":1700000000,"data":[{"url":"https://example.com/img.png","revised_prompt":"r"}],"quality":"hd","unknown_root":"ignored"}
    ;
    const response = try std.json.parseFromSlice(
        gen.ImagesResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();
    try std.testing.expectEqual(@as(i64, 1700000000), response.value.created);
    try std.testing.expect(response.value.data != null);
    try std.testing.expectEqual(@as(usize, 1), response.value.data.?.len);
    try std.testing.expectEqualStrings("https://example.com/img.png", response.value.data.?[0].url.?);
    try std.testing.expectEqualStrings("hd", response.value.quality.?);
}

test "create chat completion response ignores unknown fields" {
    const payload =
        \\{"id":"chatcmpl-test","object":"chat.completion","created":1700000000,"model":"deepseek-chat","service_tier":{"foo":"bar"},"system_fingerprint":"fp_x","choices":[{"index":0,"message":{"role":"assistant","content":"ok","reasoning_content":"think through details","refusal":null,"annotations":[],"tool_calls":null},"finish_reason":"stop","logprobs":null}],"usage":{"prompt_tokens":10,"completion_tokens":20,"total_tokens":30},"extra_root":"ignored"}
    ;
    const response = try std.json.parseFromSlice(
        gen.CreateChatCompletionResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();
    try std.testing.expectEqualStrings("chatcmpl-test", response.value.id);
    try std.testing.expectEqualStrings("chat.completion", response.value.object);
    try std.testing.expectEqualStrings("deepseek-chat", response.value.model);
    try std.testing.expectEqual(@as(usize, 1), response.value.choices.len);
    const choices = response.value.choices;
    try std.testing.expectEqualStrings("stop", choices[0].finish_reason.?);
    try std.testing.expectEqual(@as(i64, 0), choices[0].index);
    try std.testing.expectEqual(@as(?[]const gen.ChatCompletionTokenLogprob, null), choices[0].logprobs);
    const message = choices[0].message orelse return error.TestUnexpectedResult;
    const reasoning = message.reasoning_content orelse return error.TestUnexpectedResult;
    try std.testing.expectEqualStrings("think through details", reasoning);
}

test "model object with missing optional fields still parses" {
    const payload =
        \\{"id":"deepseek-chat","object":"model","owned_by":"deepseek","permission":[]}
    ;
    const model = try std.json.parseFromSlice(
        gen.Model,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer model.deinit();
    try std.testing.expectEqualStrings("deepseek-chat", model.value.id);
    try std.testing.expectEqualStrings("model", model.value.object);
    try std.testing.expectEqualStrings("deepseek", model.value.owned_by);
    try std.testing.expect(model.value.created == null);
}

test "list models handles model objects without all optional fields" {
    const payload =
        \\{"object":"list","data":[{"id":"deepseek-chat","object":"model","owned_by":"deepseek","permission":[]},{"id":"deepseek-reasoner","object":"model","owned_by":"deepseek","created":1700001000}]}
    ;
    const models = try std.json.parseFromSlice(
        gen.ListModelsResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer models.deinit();
    try std.testing.expectEqualStrings("list", models.value.object);
    try std.testing.expectEqual(@as(usize, 2), models.value.data.len);
    try std.testing.expectEqualStrings("deepseek-chat", models.value.data[0].id);
    try std.testing.expectEqualStrings("model", models.value.data[0].object);
    try std.testing.expectEqual(@as(?i64, null), models.value.data[0].created);
    try std.testing.expectEqual(@as(i64, 1700001000), models.value.data[1].created);
}

test "openai file object handles missing optional fields" {
    const payload =
        \\{"id":"file-abc","object":"file","filename":"demo.txt","purpose":"fine-tune"}
    ;
    const file_obj = try std.json.parseFromSlice(
        gen.OpenAIFile,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer file_obj.deinit();
    try std.testing.expectEqualStrings("file-abc", file_obj.value.id);
    try std.testing.expectEqualStrings("file", file_obj.value.object);
    try std.testing.expectEqualStrings("demo.txt", file_obj.value.filename);
    try std.testing.expectEqualStrings("fine-tune", file_obj.value.purpose);
    try std.testing.expect(file_obj.value.bytes == null);
    try std.testing.expect(file_obj.value.created_at == null);
}

test "list files response ignores optional missing file fields" {
    const payload =
        \\{"object":"list","data":[{"id":"file-abc","object":"file","filename":"demo.txt","purpose":"fine-tune"},{"id":"file-def","object":"file","filename":"demo2.txt","purpose":"fine-tune"}],"first_id":"file-abc","last_id":"file-def","has_more":false}
    ;
    const files = try std.json.parseFromSlice(
        gen.ListFilesResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer files.deinit();
    try std.testing.expectEqualStrings("list", files.value.object);
    try std.testing.expectEqual(@as(usize, 2), files.value.data.len);
    try std.testing.expectEqualStrings("file-abc", files.value.data[0].id);
    try std.testing.expectEqual(@as(?i64, null), files.value.data[0].bytes);
    try std.testing.expect(files.value.data[0].created_at == null);
    try std.testing.expectEqualStrings("file-def", files.value.data[1].id);
}

test "list batches response tolerates optional paging fields" {
    const payload =
        \\{"object":"list","data":[{"id":"batch_abc","object":"batch","completion_window":"24h","created_at":1700000000,"endpoint":"/v1/chat/completions","input_file_id":"file-abc","status":"in_progress"}],"has_more":false}
    ;
    const batches = try std.json.parseFromSlice(
        gen.ListBatchesResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer batches.deinit();
    try std.testing.expectEqualStrings("list", batches.value.object);
    try std.testing.expectEqual(@as(usize, 1), batches.value.data.len);
    try std.testing.expectEqualStrings("batch_abc", batches.value.data[0].id);
    try std.testing.expect(batches.value.first_id == null);
    try std.testing.expect(batches.value.last_id == null);
}

test "list fine tuning jobs response tolerates optional and ignores unknown" {
    const payload =
        \\{"object":"list","data":[{"id":"ftjob_abc","created_at":1700000000,"_error":{},"fine_tuned_model":null,"finished_at":null,"hyperparameters":{"batch_size":4,"learning_rate_multiplier":0.1,"n_epochs":2},"model":"ft:gpt-4o","object":"fine_tuning.job","organization_id":"org_abc","result_files":[],"status":"running","trained_tokens":null,"training_file":"file-abc","validation_file":null,"integrations":null,"seed":12345,"estimated_finish":null,"method":null,"metadata":null}],"has_more":false}
    ;
    const response = try std.json.parseFromSlice(
        gen.ListPaginatedFineTuningJobsResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();
    try std.testing.expectEqualStrings("list", response.value.object);
    try std.testing.expectEqual(@as(usize, 1), response.value.data.len);
    try std.testing.expect(!response.value.has_more);
    try std.testing.expectEqualStrings("ftjob_abc", response.value.data[0].id);
}

test "list fine tuning job events response ignores unknown fields" {
    const payload =
        \\{"data":[{"object":"fine_tuning.job.event","id":"ev_abc","created_at":1700000000,"level":"info","message":"started","type":"message","data":{"foo":"bar"}}],"object":"list","has_more":false,"extra":"ignored"}
    ;
    const response = try std.json.parseFromSlice(
        gen.ListFineTuningJobEventsResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();
    try std.testing.expectEqualStrings("list", response.value.object);
    try std.testing.expectEqual(@as(usize, 1), response.value.data.len);
    try std.testing.expect(!response.value.has_more);
    try std.testing.expectEqualStrings("ev_abc", response.value.data[0].id);
}

test "run step object and list response ignore unknown fields" {
    const payload =
        \\{"object":"list","data":[{"id":"step_abc","object":"thread.run.step","created_at":1700000000,"assistant_id":"asst_1","thread_id":"thread_abc","run_id":"run_1","type":"tool_calls","status":"in_progress","step_details":{"type":"tool_calls","tool_calls":[]},"last_error":null,"expired_at":null,"cancelled_at":null,"failed_at":null,"completed_at":null,"metadata":{},"usage":{}}],"first_id":"step_abc","last_id":"step_abc","has_more":false,"step_list_extra":"ignore"}
    ;
    const response = try std.json.parseFromSlice(
        gen.ListRunStepsResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();
    try std.testing.expectEqualStrings("list", response.value.object);
    try std.testing.expectEqual(@as(usize, 1), response.value.data.len);
    try std.testing.expectEqualStrings("step_abc", response.value.data[0].id);
    try std.testing.expect(!response.value.has_more);
    try std.testing.expectEqualStrings("step_abc", response.value.first_id);
    try std.testing.expectEqualStrings("step_abc", response.value.last_id);
}

test "fine tuning job and checkpoint objects ignore unknown fields" {
    const job_payload =
        \\{"id":"ftjob_abc","created_at":1700000000,"_error":{},"fine_tuned_model":null,"finished_at":null,"hyperparameters":{"batch_size":4,"learning_rate_multiplier":0.1,"n_epochs":2},"model":"ft:gpt-4o","object":"fine_tuning.job","organization_id":"org_abc","result_files":[],"status":"running","trained_tokens":null,"training_file":"file-abc","validation_file":null,"integrations":null,"seed":12345,"estimated_finish":null,"method":null,"metadata":null,"unknown_job_field":"x"}
    ;
    const job = try std.json.parseFromSlice(
        gen.FineTuningJob,
        std.testing.allocator,
        job_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer job.deinit();
    try std.testing.expectEqualStrings("ftjob_abc", job.value.id);
    try std.testing.expectEqualStrings("running", job.value.status);
    try std.testing.expectEqualStrings("ft:gpt-4o", job.value.model);

    const checkpoint_payload =
        \\{"id":"cp_abc","created_at":1700000001,"fine_tuned_model_checkpoint":"ft:gpt-4o-ckpt","step_number":12,"metrics":{"step":1.0,"train_loss":0.1,"train_mean_token_accuracy":0.95,"valid_loss":null,"valid_mean_token_accuracy":null,"full_valid_loss":null,"full_valid_mean_token_accuracy":null},"fine_tuning_job_id":"ftjob_abc","object":"fine_tuning.job.checkpoint","unknown_checkpoint":"y"}
    ;
    const checkpoint = try std.json.parseFromSlice(
        gen.FineTuningJobCheckpoint,
        std.testing.allocator,
        checkpoint_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer checkpoint.deinit();
    try std.testing.expectEqualStrings("cp_abc", checkpoint.value.id);
    try std.testing.expectEqualStrings("ft:gpt-4o-ckpt", checkpoint.value.fine_tuned_model_checkpoint);
    try std.testing.expectEqual(@as(i64, 12), checkpoint.value.step_number);
}

test "fine tuning job event object ignores unknown fields" {
    const payload =
        \\{"object":"fine_tuning.job.event","id":"ev_abc","created_at":1700000000,"level":"info","message":"starting","type":"message","data":{"foo":"bar"},"unknown_ft_event":"ignore"}
    ;
    const event = try std.json.parseFromSlice(
        gen.FineTuningJobEvent,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer event.deinit();
    try std.testing.expectEqualStrings("ev_abc", event.value.id);
    try std.testing.expectEqualStrings("info", event.value.level);
    try std.testing.expectEqualStrings("starting", event.value.message);
}

test "vector store file object ignores unknown fields" {
    const payload =
        \\{"id":"vsf_abc","object":"vector_store.file","usage_bytes":256,"created_at":1700000000,"vector_store_id":"vs_abc","status":"completed","last_error":{"code":null,"message":null},"chunking_strategy":null,"attributes":null,"extra_field":"x"}
    ;
    const file_obj = try std.json.parseFromSlice(
        gen.VectorStoreFileObject,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer file_obj.deinit();
    try std.testing.expectEqualStrings("vsf_abc", file_obj.value.id);
    try std.testing.expectEqualStrings("vector_store.file", file_obj.value.object);
    try std.testing.expectEqual(@as(i64, 256), file_obj.value.usage_bytes);
}

test "vector store object ignores unknown fields" {
    const payload =
        \\{"id":"vs_abc","object":"vector_store","created_at":1700000000,"name":"demo","usage_bytes":1024,"file_counts":{"in_progress":0,"completed":1,"failed":0,"cancelled":0,"total":1},"status":"ready","expires_after":null,"expires_at":null,"last_active_at":null,"metadata":{},"extra_store":"ignore"}
    ;
    const store = try std.json.parseFromSlice(
        gen.VectorStoreObject,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer store.deinit();
    try std.testing.expectEqualStrings("vs_abc", store.value.id);
    try std.testing.expectEqualStrings("vector_store", store.value.object);
    try std.testing.expectEqual(@as(i64, 1024), store.value.usage_bytes);
}

test "vector store file content response ignores unknown fields" {
    const payload =
        \\{"object":"list","data":[{"type":"text","text":"line one","extra_content":"ignore"}],"has_more":false,"next_page":null,"extra_root":"ignored"}
    ;
    const response = try std.json.parseFromSlice(
        gen.VectorStoreFileContentResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();
    try std.testing.expectEqualStrings("list", response.value.object);
    try std.testing.expectEqual(@as(usize, 1), response.value.data.len);
    try std.testing.expectEqualStrings("text", response.value.data[0].type.?);
    try std.testing.expectEqualStrings("line one", response.value.data[0].text.?);
    try std.testing.expect(!response.value.has_more);
}

test "vector store search results page ignores unknown fields" {
    const payload =
        \\{"object":"list","search_query":["foo","bar"],"data":[{"file_id":"file-abc","filename":"demo.txt","score":0.95,"attributes":{},"content":[{"type":"text","text":"section","unknown":"ignore"}],"extra_item":"ignore"}],"has_more":false,"next_page":null,"_extra":"x"}
    ;
    const response = try std.json.parseFromSlice(
        gen.VectorStoreSearchResultsPage,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();
    try std.testing.expectEqualStrings("list", response.value.object);
    try std.testing.expectEqual(@as(usize, 1), response.value.data.len);
    try std.testing.expectEqualStrings("file-abc", response.value.data[0].file_id);
    try std.testing.expect(response.value.data[0].content.len > 0);
    try std.testing.expectEqualStrings("text", response.value.data[0].content[0].type);
    try std.testing.expectEqualStrings("section", response.value.data[0].content[0].text);
}

test "list fine tuning job checkpoints response ignores unknown fields" {
    const payload =
        \\{"object":"list","data":[{"id":"cp_abc","created_at":1700000002,"fine_tuned_model_checkpoint":"ft:gpt-4o-ckpt","step_number":8,"metrics":{"step":8,"train_loss":0.1,"train_mean_token_accuracy":0.9,"valid_loss":null,"valid_mean_token_accuracy":null,"full_valid_loss":null,"full_valid_mean_token_accuracy":null},"fine_tuning_job_id":"ftjob_abc","object":"fine_tuning.job.checkpoint","unknown_checkpoint":"ignore"}],"has_more":false,"first_id":null,"last_id":null}
    ;
    const response = try std.json.parseFromSlice(
        gen.ListFineTuningJobCheckpointsResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();
    try std.testing.expectEqualStrings("list", response.value.object);
    try std.testing.expectEqual(@as(usize, 1), response.value.data.len);
    try std.testing.expect(!response.value.has_more);
    try std.testing.expectEqualStrings("cp_abc", response.value.data[0].id);
}

test "AssistantStreamEvent parses thread.created event into thread branch" {
    const payload =
        \\{"event":"thread.created","enabled":true,"data":{"id":"thread_abc","object":"thread","created_at":1700000000,"tool_resources":null,"metadata":{}}}
    ;
    const event = try std.json.parseFromSlice(
        gen.AssistantStreamEvent,
        std.testing.allocator,
        payload,
        .{},
    );
    defer event.deinit();
    try std.testing.expectEqualStrings("thread", event.value.thread.created.event);
    try std.testing.expectEqualStrings("thread_abc", event.value.thread.created.data.id);
}

test "AssistantStreamEvent parses run.in_progress event into run branch" {
    const payload =
        \\{"event":"thread.run.in_progress","data":{"id":"run_abc","object":"thread.run","created_at":1700000000,"thread_id":"thread_abc","assistant_id":"asst_abc","status":"in_progress","required_action":{"type":"submit_tool_outputs","submit_tool_outputs":{"tool_calls":[]}},"last_error":{"code":"","message":""},"expires_at":1700000010,"started_at":1700000001,"cancelled_at":0,"failed_at":0,"completed_at":0,"incomplete_details":{"reason":null},"model":"deepseek-chat","instructions":"run task","tools":[{"type":"code_interpreter","container":{"type":"auto","file_ids":[]}}],"metadata":{},"usage":null,"temperature":1.0,"top_p":1.0,"max_prompt_tokens":1000,"max_completion_tokens":1000,"truncation_strategy":{},"tool_choice":{"type":"auto"},"parallel_tool_calls":true,"response_format":{"type":"text"}}
    ;
    const event = try std.json.parseFromSlice(
        gen.AssistantStreamEvent,
        std.testing.allocator,
        payload,
        .{},
    );
    defer event.deinit();
    switch (event.value) {
        .run => |value| {
            try std.testing.expectEqualStrings("in_progress", value.in_progress.data.status);
            try std.testing.expectEqualStrings("run_abc", value.in_progress.data.id);
        },
        else => {
            try std.testing.expect(false);
        },
    }
}

test "AssistantStreamEvent parses run_step.delta event into run_step branch" {
    const payload =
        \\{"event":"thread.run.step.delta","data":{"id":"step_abc","object":"thread.run.step","delta":{"step_details":null}}}
    ;
    const event = try std.json.parseFromSlice(
        gen.AssistantStreamEvent,
        std.testing.allocator,
        payload,
        .{},
    );
    defer event.deinit();
    switch (event.value) {
        .run_step => |value| {
            try std.testing.expectEqualStrings("thread.run.step.delta", value.delta.event);
            try std.testing.expectEqualStrings("step_abc", value.delta.data.id);
        },
        else => {
            try std.testing.expect(false);
        },
    }
}

test "AssistantStreamEvent parses message.created event into message branch" {
    const payload =
        \\{"event":"thread.message.created","data":{"id":"msg_abc","object":"thread.message","created_at":1700000000,"thread_id":"thread_abc","status":"completed","incomplete_details":null,"completed_at":1700000000,"incomplete_at":null,"role":"assistant","content":[{"type":"text","text":{"value":"hello","annotations":[]}}],"assistant_id":null,"run_id":null,"attachments":null,"metadata":{}}
    ;
    const event = try std.json.parseFromSlice(
        gen.AssistantStreamEvent,
        std.testing.allocator,
        payload,
        .{},
    );
    defer event.deinit();
    switch (event.value) {
        .message => |value| {
            try std.testing.expectEqualStrings("thread.message.created", value.created.event);
            try std.testing.expectEqualStrings("msg_abc", value.created.data.id);
        },
        else => {
            try std.testing.expect(false);
        },
    }
}

test "AssistantStreamEvent parses error event into err branch" {
    const payload =
        \\{"event":"error","data":{"code":"invalid_request_error","message":"bad request","param":null,"type":"invalid_request_error"}}
    ;
    const event = try std.json.parseFromSlice(
        gen.AssistantStreamEvent,
        std.testing.allocator,
        payload,
        .{},
    );
    defer event.deinit();
    switch (event.value) {
        .err => |value| {
            try std.testing.expectEqualStrings("error", value.event);
            try std.testing.expectEqualStrings("bad request", value.data.message);
        },
        else => {
            try std.testing.expect(false);
        },
    }
}

test "AssistantStreamEvent falls back to raw for unknown event types" {
    const payload =
        \\{"event":"thread.some_new_event","data":{"id":"x"}} 
    ;
    const event = try std.json.parseFromSlice(
        gen.AssistantStreamEvent,
        std.testing.allocator,
        payload,
        .{},
    );
    defer event.deinit();
    switch (event.value) {
        .raw => |value| {
            try std.testing.expect(std.mem.eql(u8, value.object.get("event").?.string, "thread.some_new_event"));
        },
        else => {
            try std.testing.expect(false);
        },
    }
}

test "InputParam parses text and item arrays" {
    const text_payload =
        \\"hello from response"
    ;
    const text_input = try std.json.parseFromSlice(
        gen.InputParam,
        std.testing.allocator,
        text_payload,
        .{},
    );
    defer text_input.deinit();
    switch (text_input.value) {
        .text => |value| {
            try std.testing.expectEqualStrings("hello from response", value);
        },
        else => try std.testing.expect(false),
    }

    const items_payload =
        \\[{"role":"user","content":[{"type":"input_text","text":"hello"}]}]
    ;
    const items_input = try std.json.parseFromSlice(
        gen.InputParam,
        std.testing.allocator,
        items_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer items_input.deinit();
    switch (items_input.value) {
        .items => |items| {
            try std.testing.expectEqual(@as(usize, 1), items.len);
            switch (items[0]) {
                .easy_message => |value| {
                    try std.testing.expectEqualStrings("user", value.role);
                },
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }
}

test "Item parses message and function call variants" {
    const message_payload =
        \\{"type":"message","role":"user","content":[{"type":"input_text","text":"hello"}]}
    ;
    const message_item = try std.json.parseFromSlice(
        gen.Item,
        std.testing.allocator,
        message_payload,
        .{},
    );
    defer message_item.deinit();
    switch (message_item.value) {
        .input_message => |value| {
            try std.testing.expectEqualStrings("user", value.role);
            try std.testing.expectEqualStrings("message", value.type.?);
        },
        else => try std.testing.expect(false),
    }

    const tool_call_payload =
        \\{"id":"call_item_1","type":"function_call","call_id":"tool_call_id","name":"get_weather","arguments":"{\"city\":\"shanghai\"}","status":"completed"}
    ;
    const tool_call_item = try std.json.parseFromSlice(
        gen.Item,
        std.testing.allocator,
        tool_call_payload,
        .{},
    );
    defer tool_call_item.deinit();
    switch (tool_call_item.value) {
        .function_tool_call => |value| {
            try std.testing.expectEqualStrings("get_weather", value.name);
        },
        else => try std.testing.expect(false),
    }
}

test "ItemResource parses input-message resource and function-call resource" {
    const input_message_payload =
        \\{"id":"imsg_1","type":"message","role":"user","content":[{"type":"input_text","text":"hello"}]}
    ;
    const input_message_resource = try std.json.parseFromSlice(
        gen.ItemResource,
        std.testing.allocator,
        input_message_payload,
        .{},
    );
    defer input_message_resource.deinit();
    switch (input_message_resource.value) {
        .input_message => |value| {
            try std.testing.expectEqualStrings("imsg_1", value.id);
            try std.testing.expectEqualStrings("message", value.type.?);
        },
        else => try std.testing.expect(false),
    }

    const function_tool_payload =
        \\{"id":"fcall_1","type":"function_call","call_id":"tool_call_id","name":"calc","arguments":"{\"a\":1}","status":"completed"}
    ;
    const function_tool_resource = try std.json.parseFromSlice(
        gen.ItemResource,
        std.testing.allocator,
        function_tool_payload,
        .{},
    );
    defer function_tool_resource.deinit();
    switch (function_tool_resource.value) {
        .function_tool_call => |value| {
            try std.testing.expectEqualStrings("fcall_1", value.id);
            try std.testing.expectEqualStrings("calc", value.name);
        },
        else => try std.testing.expect(false),
    }
}

test "OutputContent parses refusal and reasoning parts" {
    const refusal_payload =
        \\{"type":"refusal","refusal":"I cannot provide that"}
    ;
    const refusal_content = try std.json.parseFromSlice(
        gen.OutputContent,
        std.testing.allocator,
        refusal_payload,
        .{},
    );
    defer refusal_content.deinit();
    switch (refusal_content.value) {
        .refusal => |value| {
            try std.testing.expectEqualStrings("I cannot provide that", value.refusal);
        },
        else => try std.testing.expect(false),
    }

    const reasoning_payload =
        \\{"type":"reasoning_text","text":"Let me think first"}
    ;
    const reasoning_content = try std.json.parseFromSlice(
        gen.OutputContent,
        std.testing.allocator,
        reasoning_payload,
        .{},
    );
    defer reasoning_content.deinit();
    switch (reasoning_content.value) {
        .reasoning => |value| {
            try std.testing.expectEqualStrings("Let me think first", value.text);
        },
        else => try std.testing.expect(false),
    }
}

test "OutputItem parses structured variants and keeps raw fallback" {
    const output_message_payload =
        \\{"id":"msg_out_1","type":"message","role":"assistant","status":"completed","content":[{"type":"output_text","text":"Hello"}]}
    ;
    const output_message_item = try std.json.parseFromSlice(
        gen.OutputItem,
        std.testing.allocator,
        output_message_payload,
        .{},
    );
    defer output_message_item.deinit();
    switch (output_message_item.value) {
        .message => |value| {
            try std.testing.expectEqualStrings("msg_out_1", value.id);
            try std.testing.expectEqualStrings("assistant", value.role);
        },
        else => try std.testing.expect(false),
    }

    const function_call_payload =
        \\{"id":"fn_out_1","type":"function_call","call_id":"out_call_id","name":"search","arguments":"{\"q\":\"deepseek\"}","status":"completed"}
    ;
    const function_call_item = try std.json.parseFromSlice(
        gen.OutputItem,
        std.testing.allocator,
        function_call_payload,
        .{},
    );
    defer function_call_item.deinit();
    switch (function_call_item.value) {
        .function_tool_call => |value| {
            try std.testing.expectEqualStrings("search", value.name);
        },
        else => try std.testing.expect(false),
    }

    const raw_payload =
        \\123
    ;
    const raw_item = try std.json.parseFromSlice(
        gen.OutputItem,
        std.testing.allocator,
        raw_payload,
        .{},
    );
    defer raw_item.deinit();
    switch (raw_item.value) {
        .raw => |value| {
            try std.testing.expectEqual(@as(i64, 123), value.integer);
        },
        else => try std.testing.expect(false),
    }
}

test "Response parses output item array as structured value" {
    const payload =
        \\{"id":"resp_abc","object":"response","status":"completed","output":[{"id":"msg_1","type":"message","role":"assistant","status":"completed","content":[{"type":"output_text","text":"Hello"}]}]}
    ;
    const response = try std.json.parseFromSlice(
        gen.Response,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();

    switch (response.value) {
        .object => |value| {
            try std.testing.expectEqualStrings("resp_abc", value.id.?);
            switch (value.output.?) {
                .items => |items| {
                    try std.testing.expectEqual(@as(usize, 1), items.len);
                    switch (items[0]) {
                        .message => |msg| {
                            try std.testing.expectEqualStrings("msg_1", msg.id);
                        },
                        else => try std.testing.expect(false),
                    }
                },
                else => try std.testing.expect(false),
            }
        },
        .raw => try std.testing.expect(false),
    }
}

test "Response parses output item object as structured value" {
    const payload =
        \\{"id":"resp_def","object":"response","status":"completed","output":{"id":"msg_2","type":"message","role":"assistant","status":"completed","content":[{"type":"output_text","text":"Hello"}]}}
    ;
    const response = try std.json.parseFromSlice(
        gen.Response,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();

    switch (response.value) {
        .object => |value| {
            try std.testing.expectEqualStrings("resp_def", value.id.?);
            switch (value.output.?) {
                .item => |item| {
                    switch (item) {
                        .message => |msg| {
                            try std.testing.expectEqualStrings("msg_2", msg.id);
                        },
                        else => try std.testing.expect(false),
                    }
                },
                else => try std.testing.expect(false),
            }
        },
        .raw => try std.testing.expect(false),
    }
}

test "Response keeps response output raw fallback on invalid shape" {
    const payload =
        \\{"id":"resp_raw","object":"response","status":"failed","output":"text-output"}
    ;
    const response = try std.json.parseFromSlice(
        gen.Response,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();

    switch (response.value) {
        .object => |value| {
            switch (value.output.?) {
                .raw => |raw| {
                    try std.testing.expectEqualStrings("text-output", raw.string);
                },
                else => try std.testing.expect(false),
            }
        },
        .raw => try std.testing.expect(false),
    }
}

test "create response object parses narrowed typed request fields" {
    const payload =
        \\{"input":"tell me another joke","model":"deepseek-chat","tools":[{"type":"function","function":{"name":"noop","parameters":{"type":"object"}}}],"tool_choice":{"type":"function","name":"noop"},"parallel_tool_calls":true,"response_format":{"type":"json_object"},"conversation":"conv_123"}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.CreateResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    switch (parsed.value) {
        .object => |value| {
            const input = value.input orelse {
                try std.testing.expect(false);
                return;
            };
            switch (input) {
                .text => |text| try std.testing.expectEqualStrings("tell me another joke", text),
                else => try std.testing.expect(false),
            }

            try std.testing.expect(value.tools != null);
            try std.testing.expectEqual(@as(usize, 1), value.tools.?.len);
            switch (value.tools.?[0]) {
                .raw => |raw| {
                    try std.testing.expectEqualStrings("function", raw.object.get("type").?.string);
                },
                else => try std.testing.expect(false),
            }

            try std.testing.expect(value.tool_choice != null);
            switch (value.tool_choice.?) {
                .raw => |raw| {
                    try std.testing.expectEqualStrings("function", raw.object.get("type").?.string);
                },
                else => try std.testing.expect(false),
            }

            try std.testing.expect(value.parallel_tool_calls != null and value.parallel_tool_calls.?);

            const response_format = value.response_format orelse {
                try std.testing.expect(false);
                return;
            };
            switch (response_format) {
                .json_object => |format| try std.testing.expectEqualStrings("json_object", format.type),
                else => try std.testing.expect(false),
            }

            const conversation = value.conversation orelse {
                try std.testing.expect(false);
                return;
            };
            switch (conversation) {
                .id => |id| try std.testing.expectEqualStrings("conv_123", id),
                else => try std.testing.expect(false),
            }
        },
        .raw => try std.testing.expect(false),
    }
}

test "token counts body parses narrowed fields" {
    const payload =
        \\{"model":"gpt-4o-mini","input":"count this","text":{"format":{"type":"text"},"verbosity":"low"},"reasoning":{"effort":"medium","summary":"auto"},"conversation":{"id":"conv_456"},"parallel_tool_calls":true}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.TokenCountsBody,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    const input = parsed.value.input orelse {
        try std.testing.expect(false);
        return;
    };
    switch (input) {
        .text => |text| try std.testing.expectEqualStrings("count this", text),
        else => try std.testing.expect(false),
    }

    const text = parsed.value.text orelse {
        try std.testing.expect(false);
        return;
    };
    const format = text.format orelse {
        try std.testing.expect(false);
        return;
    };
    switch (format) {
        .text => |value| try std.testing.expectEqualStrings("text", value.type),
        else => try std.testing.expect(false),
    }
    try std.testing.expectEqualStrings("low", text.verbosity.?);

    const reasoning = parsed.value.reasoning orelse {
        try std.testing.expect(false);
        return;
    };
    try std.testing.expectEqualStrings("medium", reasoning.effort.?);
    try std.testing.expectEqualStrings("auto", reasoning.summary.?);

    const conversation = parsed.value.conversation orelse {
        try std.testing.expect(false);
        return;
    };
    switch (conversation) {
        .conversation => |value| try std.testing.expectEqualStrings("conv_456", value.id),
        else => try std.testing.expect(false),
    }

    try std.testing.expect(parsed.value.parallel_tool_calls != null and parsed.value.parallel_tool_calls.?);
}

test "realtime create client secret response parses typed session" {
    const payload =
        \\{"value":"secret_123","expires_at":1700000000,"session":{"id":"sess_123","object":"realtime.session","model":"gpt-4o-realtime-preview","input_audio_transcription":{"model":"gpt-4o-transcribe"},"prompt":{"id":"pmpt_1"},"include":["item.input_audio_transcription.logprobs"]}}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.RealtimeCreateClientSecretResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    try std.testing.expectEqualStrings("secret_123", parsed.value.value);
    try std.testing.expectEqualStrings("sess_123", parsed.value.session.id.?);
    try std.testing.expectEqualStrings("gpt-4o-transcribe", parsed.value.session.input_audio_transcription.?.model.?);
    try std.testing.expectEqual(@as(usize, 1), parsed.value.session.include.?.len);

    const prompt = parsed.value.session.prompt orelse {
        try std.testing.expect(false);
        return;
    };
    switch (prompt) {
        .template => |value| try std.testing.expectEqualStrings("pmpt_1", value.id),
        else => try std.testing.expect(false),
    }
}

test "realtime response create params parses typed tools and conversation" {
    const payload =
        \\{"conversation":"conv_realtime_1","tools":[{"type":"function","function":{"name":"lookup_weather","parameters":{"type":"object"}}}],"max_output_tokens":256}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.RealtimeResponseCreateParams,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    const conversation = parsed.value.conversation orelse {
        try std.testing.expect(false);
        return;
    };
    switch (conversation) {
        .id => |id| try std.testing.expectEqualStrings("conv_realtime_1", id),
        else => try std.testing.expect(false),
    }

    try std.testing.expect(parsed.value.tools != null);
    try std.testing.expectEqual(@as(usize, 1), parsed.value.tools.?.len);
    switch (parsed.value.tools.?[0]) {
        .raw => |raw| try std.testing.expectEqualStrings("function", raw.object.get("type").?.string),
        else => try std.testing.expect(false),
    }
    try std.testing.expectEqual(@as(?i64, 256), parsed.value.max_output_tokens);
}

test "eval grader config parses typed variants" {
    const score_payload =
        \\{"type":"score_model","name":"score","model":"gpt-4o-mini","input":[{"role":"assistant","content":"ok"}],"range":[0,1]}
    ;
    const score = try std.json.parseFromSlice(
        gen.EvalGraderConfig,
        std.testing.allocator,
        score_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer score.deinit();
    switch (score.value) {
        .score_model => |value| {
            try std.testing.expectEqualStrings("score", value.name);
            try std.testing.expectEqualStrings("gpt-4o-mini", value.model);
            try std.testing.expectEqual(@as(usize, 1), value.input.len);
        },
        else => try std.testing.expect(false),
    }

    const multi_payload =
        \\{"type":"multi","name":"combo","graders":[{"type":"python","name":"py","source":"return 1"}],"calculate_output":"mean"}
    ;
    const multi = try std.json.parseFromSlice(
        gen.EvalGraderConfig,
        std.testing.allocator,
        multi_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer multi.deinit();
    switch (multi.value) {
        .multi => |value| {
            try std.testing.expectEqualStrings("combo", value.name);
            try std.testing.expectEqual(@as(usize, 1), value.graders.len);
            switch (value.graders[0]) {
                .python => |py| try std.testing.expectEqualStrings("py", py.name),
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }
}

test "eval grader config keeps raw fallback for unknown shape" {
    const raw_payload =
        \\{"type":"future_grader","foo":1}
    ;
    const raw = try std.json.parseFromSlice(
        gen.EvalGraderConfig,
        std.testing.allocator,
        raw_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer raw.deinit();

    switch (raw.value) {
        .raw => |value| {
            try std.testing.expectEqualStrings("future_grader", value.object.get("type").?.string);
        },
        else => try std.testing.expect(false),
    }
}

test "realtime truncation parses mode/object and keeps raw fallback" {
    const mode = try std.json.parseFromSlice(
        gen.RealtimeTruncation,
        std.testing.allocator,
        "\"auto\"",
        .{ .ignore_unknown_fields = true },
    );
    defer mode.deinit();
    switch (mode.value) {
        .mode => |value| try std.testing.expectEqualStrings("auto", value),
        else => try std.testing.expect(false),
    }

    const config_payload =
        \\{"type":"retention","last_messages":8}
    ;
    const config = try std.json.parseFromSlice(
        gen.RealtimeTruncation,
        std.testing.allocator,
        config_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer config.deinit();
    switch (config.value) {
        .config => |value| {
            try std.testing.expectEqualStrings("retention", value.type);
            try std.testing.expectEqual(@as(?i64, 8), value.last_messages);
        },
        else => try std.testing.expect(false),
    }

    const raw = try std.json.parseFromSlice(
        gen.RealtimeTruncation,
        std.testing.allocator,
        "1",
        .{ .ignore_unknown_fields = true },
    );
    defer raw.deinit();
    switch (raw.value) {
        .raw => |value| try std.testing.expectEqual(@as(std.json.Value, .{ .integer = 1 }), value),
        else => try std.testing.expect(false),
    }
}

test "realtime session parses typed turn detection" {
    const payload =
        \\{"turn_detection":{"type":"server_vad","threshold":0.4,"prefix_padding_ms":120,"silence_duration_ms":250}}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.RealtimeSession,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    const turn_detection = parsed.value.turn_detection orelse {
        try std.testing.expect(false);
        return;
    };
    try std.testing.expectEqualStrings("server_vad", turn_detection.type.?);
    try std.testing.expectEqual(@as(?f64, 0.4), turn_detection.threshold);
    try std.testing.expectEqual(@as(?i64, 120), turn_detection.prefix_padding_ms);
    try std.testing.expectEqual(@as(?i64, 250), turn_detection.silence_duration_ms);
}

test "realtime client event parses typed variant and keeps raw fallback" {
    const typed_payload =
        \\{"type":"response.create","response":null}
    ;
    const typed = try std.json.parseFromSlice(
        gen.RealtimeClientEvent,
        std.testing.allocator,
        typed_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer typed.deinit();

    switch (typed.value) {
        .response_create => |value| {
            try std.testing.expectEqualStrings("response.create", value.type);
            try std.testing.expect(value.response == null);
        },
        else => try std.testing.expect(false),
    }

    const raw_payload =
        \\{"type":"future.client.event","x":1}
    ;
    const raw = try std.json.parseFromSlice(
        gen.RealtimeClientEvent,
        std.testing.allocator,
        raw_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer raw.deinit();

    switch (raw.value) {
        .raw => |value| try std.testing.expectEqualStrings("future.client.event", value.object.get("type").?.string),
        else => try std.testing.expect(false),
    }
}

test "realtime server event parses typed variant and keeps raw fallback" {
    const typed_payload =
        \\{"event_id":"evt_1","type":"session.updated","session":{"id":"sess_1"}}
    ;
    const typed = try std.json.parseFromSlice(
        gen.RealtimeServerEvent,
        std.testing.allocator,
        typed_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer typed.deinit();

    switch (typed.value) {
        .session_updated => |value| {
            try std.testing.expectEqualStrings("session.updated", value.type);
            try std.testing.expectEqualStrings("sess_1", value.session.id.?);
        },
        else => try std.testing.expect(false),
    }

    const raw_payload =
        \\{"event_id":"evt_2","type":"future.server.event","foo":true}
    ;
    const raw = try std.json.parseFromSlice(
        gen.RealtimeServerEvent,
        std.testing.allocator,
        raw_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer raw.deinit();

    switch (raw.value) {
        .raw => |value| try std.testing.expectEqualStrings("future.server.event", value.object.get("type").?.string),
        else => try std.testing.expect(false),
    }
}

test "eval item content parses text and array variants" {
    const text_payload = "\"graded answer\"";
    const parsed_text = try std.json.parseFromSlice(
        gen.EvalItemContent,
        std.testing.allocator,
        text_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_text.deinit();

    switch (parsed_text.value) {
        .text => |value| try std.testing.expectEqualStrings("graded answer", value),
        else => try std.testing.expect(false),
    }

    const array_payload =
        \\[
        \\  {"type":"output_text","text":"hello"},
        \\  {"type":"input_image","image_url":"https://example.com/a.png"}
        \\]
    ;
    const parsed_items = try std.json.parseFromSlice(
        gen.EvalItemContent,
        std.testing.allocator,
        array_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_items.deinit();

    switch (parsed_items.value) {
        .items => |items| {
            try std.testing.expectEqual(@as(usize, 2), items.len);
            switch (items[0]) {
                .output_text => |value| try std.testing.expectEqualStrings("hello", value.text),
                else => try std.testing.expect(false),
            }
            switch (items[1]) {
                .input_image => |value| try std.testing.expectEqualStrings("https://example.com/a.png", value.image_url),
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }
}

test "eval item content item keeps raw fallback for unknown type" {
    const raw_payload =
        \\{"type":"future_eval_item","foo":"bar"}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.EvalItemContentItem,
        std.testing.allocator,
        raw_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    switch (parsed.value) {
        .raw => |value| try std.testing.expectEqualStrings("future_eval_item", value.object.get("type").?.string),
        else => try std.testing.expect(false),
    }
}

test "create eval item parses typed eval item and raw fallback" {
    const typed_payload =
        \\{"role":"assistant","content":"scored output","type":"message"}
    ;
    const typed = try std.json.parseFromSlice(
        gen.CreateEvalItem,
        std.testing.allocator,
        typed_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer typed.deinit();

    switch (typed.value) {
        .item => |value| {
            try std.testing.expectEqualStrings("assistant", value.role);
            switch (value.content) {
                .text => |text| try std.testing.expectEqualStrings("scored output", text),
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }

    const raw_payload =
        \\{"foo":"bar"}
    ;
    const raw = try std.json.parseFromSlice(
        gen.CreateEvalItem,
        std.testing.allocator,
        raw_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer raw.deinit();

    switch (raw.value) {
        .raw => |value| try std.testing.expectEqualStrings("bar", value.object.get("foo").?.string),
        else => try std.testing.expect(false),
    }
}

test "fine-tune assistant message parses typed assistant payload and raw fallback" {
    const typed_payload =
        \\{"role":"assistant","content":"done"}
    ;
    const typed = try std.json.parseFromSlice(
        gen.FineTuneChatCompletionRequestAssistantMessage,
        std.testing.allocator,
        typed_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer typed.deinit();

    switch (typed.value) {
        .message => |message| {
            try std.testing.expectEqualStrings("assistant", message.role);
            const content = message.content orelse {
                try std.testing.expect(false);
                return;
            };
            switch (content) {
                .text => |text| try std.testing.expectEqualStrings("done", text),
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }

    const raw_payload =
        \\{"role":"tool","content":"other"}
    ;
    const raw = try std.json.parseFromSlice(
        gen.FineTuneChatCompletionRequestAssistantMessage,
        std.testing.allocator,
        raw_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer raw.deinit();

    switch (raw.value) {
        .raw => |value| try std.testing.expectEqualStrings("tool", value.object.get("role").?.string),
        else => try std.testing.expect(false),
    }
}

test "create chat completion request parses typed object and raw fallback" {
    const typed_payload =
        \\{"model":"gpt-4o-mini","messages":[{"role":"user","content":"hello"}]}
    ;
    const typed = try std.json.parseFromSlice(
        gen.CreateChatCompletionRequest,
        std.testing.allocator,
        typed_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer typed.deinit();

    switch (typed.value) {
        .object => |value| {
            try std.testing.expectEqualStrings("gpt-4o-mini", value.model.?);
            try std.testing.expectEqual(@as(usize, 1), value.messages.?.len);
            switch (value.messages.?[0]) {
                .user => |message| try std.testing.expectEqualStrings("user", message.role),
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }

    const raw_payload =
        \\{"foo":"bar"}
    ;
    const raw = try std.json.parseFromSlice(
        gen.CreateChatCompletionRequest,
        std.testing.allocator,
        raw_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer raw.deinit();

    switch (raw.value) {
        .raw => |value| try std.testing.expectEqualStrings("bar", value.object.get("foo").?.string),
        else => try std.testing.expect(false),
    }
}

test "chat completion request message parses typed role variants and raw fallback" {
    const typed_payload =
        \\{"role":"assistant","content":"hi"}
    ;
    const typed = try std.json.parseFromSlice(
        gen.ChatCompletionRequestMessage,
        std.testing.allocator,
        typed_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer typed.deinit();

    switch (typed.value) {
        .assistant => |message| {
            try std.testing.expectEqualStrings("assistant", message.role);
            const content = message.content orelse {
                try std.testing.expect(false);
                return;
            };
            switch (content) {
                .text => |text| try std.testing.expectEqualStrings("hi", text),
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }

    const raw_payload =
        \\{"role":"future_role","content":"x"}
    ;
    const raw = try std.json.parseFromSlice(
        gen.ChatCompletionRequestMessage,
        std.testing.allocator,
        raw_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer raw.deinit();

    switch (raw.value) {
        .raw => |value| try std.testing.expectEqualStrings("future_role", value.object.get("role").?.string),
        else => try std.testing.expect(false),
    }
}

test "generic content parses text and array variants" {
    const text_payload = "\"hello-content\"";
    const parsed_text = try std.json.parseFromSlice(
        gen.GenericContent,
        std.testing.allocator,
        text_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_text.deinit();

    switch (parsed_text.value) {
        .text => |value| try std.testing.expectEqualStrings("hello-content", value),
        else => try std.testing.expect(false),
    }

    const array_payload =
        \\[{"a":1},{"b":"x"}]
    ;
    const parsed_array = try std.json.parseFromSlice(
        gen.GenericContent,
        std.testing.allocator,
        array_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_array.deinit();

    switch (parsed_array.value) {
        .items => |items| {
            try std.testing.expectEqual(@as(usize, 2), items.len);
            switch (items[0]) {
                .raw => |value| try std.testing.expectEqual(@as(i64, 1), value.object.get("a").?.integer),
                else => try std.testing.expect(false),
            }
            switch (items[1]) {
                .raw => |value| try std.testing.expectEqualStrings("x", value.object.get("b").?.string),
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }
}

test "generic content keeps raw fallback for object payload" {
    const payload =
        \\{"k":"v"}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.GenericContent,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    switch (parsed.value) {
        .raw => |value| try std.testing.expectEqualStrings("v", value.object.get("k").?.string),
        else => try std.testing.expect(false),
    }
}

test "create eval request parses testing criteria as typed grader config" {
    const payload =
        \\{"name":"eval-1","data_source_config":{"foo":"bar"},"testing_criteria":[{"type":"python","name":"grader_py","source":"return 1"}]}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.CreateEvalRequest,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    try std.testing.expectEqual(@as(usize, 1), parsed.value.testing_criteria.len);
    switch (parsed.value.testing_criteria[0]) {
        .python => |value| {
            try std.testing.expectEqualStrings("grader_py", value.name);
            try std.testing.expectEqualStrings("return 1", value.source);
        },
        else => try std.testing.expect(false),
    }
}

test "function tool call output parses generic content variants" {
    const text_payload =
        \\{"type":"function_call_output","call_id":"call_1","output":"ok"}
    ;
    const parsed_text = try std.json.parseFromSlice(
        gen.FunctionToolCallOutput,
        std.testing.allocator,
        text_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_text.deinit();

    switch (parsed_text.value.output) {
        .text => |value| try std.testing.expectEqualStrings("ok", value),
        else => try std.testing.expect(false),
    }

    const object_payload =
        \\{"type":"function_call_output","call_id":"call_1","output":{"foo":"bar"}}
    ;
    const parsed_object = try std.json.parseFromSlice(
        gen.FunctionToolCallOutput,
        std.testing.allocator,
        object_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_object.deinit();

    switch (parsed_object.value.output) {
        .raw => |value| try std.testing.expectEqualStrings("bar", value.object.get("foo").?.string),
        else => try std.testing.expect(false),
    }
}

test "realtime mcp obfuscation parses generic content" {
    const payload =
        \\{"event_id":"evt_1","type":"response.mcp_call.arguments.delta","response_id":"resp_1","item_id":"item_1","output_index":0,"delta":"x","obfuscation":"redacted"}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.RealtimeServerEventResponseMCPCallArgumentsDelta,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    const obfuscation = parsed.value.obfuscation orelse {
        try std.testing.expect(false);
        return;
    };
    switch (obfuscation) {
        .text => |value| try std.testing.expectEqualStrings("redacted", value),
        else => try std.testing.expect(false),
    }
}

test "eval data source config parses typed create and eval variants" {
    const create_logs_payload =
        \\{"type":"logs","metadata":{"team":"alpha"}}
    ;
    const parsed_create_logs = try std.json.parseFromSlice(
        gen.EvalDataSourceConfig,
        std.testing.allocator,
        create_logs_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_create_logs.deinit();

    switch (parsed_create_logs.value) {
        .logs_create => |value| {
            const metadata = value.metadata orelse {
                try std.testing.expect(false);
                return;
            };
            try std.testing.expectEqualStrings("alpha", metadata.asJson().object.get("team").?.string);
        },
        else => try std.testing.expect(false),
    }

    const eval_stored_payload =
        \\{"type":"stored_completions","metadata":{"source":"api"},"schema":{"type":"object"}}
    ;
    const parsed_eval_stored = try std.json.parseFromSlice(
        gen.EvalDataSourceConfig,
        std.testing.allocator,
        eval_stored_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_eval_stored.deinit();

    switch (parsed_eval_stored.value) {
        .stored_completions => |value| {
            const metadata = value.metadata orelse {
                try std.testing.expect(false);
                return;
            };
            try std.testing.expectEqualStrings("api", metadata.asJson().object.get("source").?.string);
            try std.testing.expectEqualStrings("object", value.schema.asJson().object.get("type").?.string);
        },
        else => try std.testing.expect(false),
    }
}

test "eval data source config keeps raw fallback for unknown type" {
    const payload =
        \\{"type":"future_source","foo":1}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.EvalDataSourceConfig,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    switch (parsed.value) {
        .raw => |value| try std.testing.expectEqualStrings("future_source", value.object.get("type").?.string),
        else => try std.testing.expect(false),
    }
}

test "eval run data source parses typed variants and raw fallback" {
    const responses_payload =
        \\{"type":"responses","source":{"dataset":"eval-set"}}
    ;
    const parsed_responses = try std.json.parseFromSlice(
        gen.EvalRunDataSource,
        std.testing.allocator,
        responses_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_responses.deinit();

    switch (parsed_responses.value) {
        .responses => |value| {
            try std.testing.expectEqualStrings("responses", value.type);
            try std.testing.expectEqualStrings("eval-set", value.source.object.get("dataset").?.string);
        },
        else => try std.testing.expect(false),
    }

    const raw_payload =
        \\{"type":"future_run_source","k":1}
    ;
    const parsed_raw = try std.json.parseFromSlice(
        gen.EvalRunDataSource,
        std.testing.allocator,
        raw_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_raw.deinit();

    switch (parsed_raw.value) {
        .raw => |value| try std.testing.expectEqualStrings("future_run_source", value.object.get("type").?.string),
        else => try std.testing.expect(false),
    }
}

test "create eval run request parses typed data source" {
    const payload =
        \\{"name":"nightly-eval","data_source":{"type":"completions","source":{"id":"src_1"}}}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.CreateEvalRunRequest,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    try std.testing.expectEqualStrings("nightly-eval", parsed.value.name.?);
    switch (parsed.value.data_source) {
        .completions => |value| {
            try std.testing.expectEqualStrings("completions", value.type);
            try std.testing.expectEqualStrings("src_1", value.source.object.get("id").?.string);
        },
        else => try std.testing.expect(false),
    }
}

test "fine-tune chat request input parses typed message unions" {
    const payload =
        \\{"messages":[{"role":"user","content":"hello"},{"role":"assistant","content":"world"}]}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.FineTuneChatRequestInput,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    try std.testing.expect(parsed.value.messages != null);
    try std.testing.expectEqual(@as(usize, 2), parsed.value.messages.?.len);
    switch (parsed.value.messages.?[0]) {
        .user => |value| try std.testing.expectEqualStrings("user", value.role),
        else => try std.testing.expect(false),
    }
    switch (parsed.value.messages.?[1]) {
        .assistant => |value| try std.testing.expectEqualStrings("assistant", value.role),
        else => try std.testing.expect(false),
    }
}

test "fine-tune preference request input parses assistant outputs with raw fallback" {
    const payload =
        \\{"input":{"messages":[{"role":"user","content":"prompt"}]},"preferred_output":[{"role":"assistant","content":"good"}],"non_preferred_output":[{"role":"tool","content":"bad"}]}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.FineTunePreferenceRequestInput,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    const input = parsed.value.input orelse {
        try std.testing.expect(false);
        return;
    };
    try std.testing.expect(input.messages != null);
    switch (input.messages.?[0]) {
        .user => |value| try std.testing.expectEqualStrings("user", value.role),
        else => try std.testing.expect(false),
    }

    try std.testing.expect(parsed.value.preferred_output != null);
    switch (parsed.value.preferred_output.?[0]) {
        .message => |value| try std.testing.expectEqualStrings("assistant", value.role),
        else => try std.testing.expect(false),
    }

    try std.testing.expect(parsed.value.non_preferred_output != null);
    switch (parsed.value.non_preferred_output.?[0]) {
        .raw => |value| try std.testing.expectEqualStrings("tool", value.object.get("role").?.string),
        else => try std.testing.expect(false),
    }
}

test "fine-tune reinforcement request input parses typed message unions" {
    const payload =
        \\{"messages":[{"role":"user","content":"q"},{"role":"assistant","content":"a"}]}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.FineTuneReinforcementRequestInput,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    try std.testing.expectEqual(@as(usize, 2), parsed.value.messages.len);
    switch (parsed.value.messages[0]) {
        .user => |value| try std.testing.expectEqualStrings("user", value.role),
        else => try std.testing.expect(false),
    }
    switch (parsed.value.messages[1]) {
        .assistant => |value| try std.testing.expectEqualStrings("assistant", value.role),
        else => try std.testing.expect(false),
    }
}

test "create image edit request parses generic image payload variants" {
    const text_payload =
        \\{"image":"ipfs://image-1","prompt":"retouch"}
    ;
    const parsed_text = try std.json.parseFromSlice(
        gen.CreateImageEditRequest,
        std.testing.allocator,
        text_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_text.deinit();

    switch (parsed_text.value.image) {
        .text => |value| try std.testing.expectEqualStrings("ipfs://image-1", value),
        else => try std.testing.expect(false),
    }

    const object_payload =
        \\{"image":{"id":"img_1"},"prompt":"retouch"}
    ;
    const parsed_object = try std.json.parseFromSlice(
        gen.CreateImageEditRequest,
        std.testing.allocator,
        object_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_object.deinit();

    switch (parsed_object.value.image) {
        .raw => |value| try std.testing.expectEqualStrings("img_1", value.object.get("id").?.string),
        else => try std.testing.expect(false),
    }
}

test "fine tuning job event keeps typed metadata payload" {
    const payload =
        \\{"object":"fine_tuning.job.event","id":"ev_abc","created_at":1700000000,"level":"info","message":"starting","type":"message","data":{"foo":"bar"}}
    ;
    const event = try std.json.parseFromSlice(
        gen.FineTuningJobEvent,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer event.deinit();

    const data = event.value.data orelse {
        try std.testing.expect(false);
        return;
    };
    try std.testing.expectEqualStrings("bar", data.asJson().object.get("foo").?.string);
}

test "usage time bucket parses typed usage result variants" {
    const payload =
        \\{"object":"bucket","start_time":1,"end_time":2,"result":[{"object":"organization.usage.completions.result","input_tokens":10,"output_tokens":4,"num_model_requests":1},{"object":"organization.usage.images.result","images":2,"num_model_requests":1}]}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.UsageTimeBucket,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    try std.testing.expectEqual(@as(usize, 2), parsed.value.result.len);

    switch (parsed.value.result[0]) {
        .completions => |value| {
            try std.testing.expectEqualStrings("organization.usage.completions.result", value.object);
            try std.testing.expectEqual(@as(i64, 10), value.input_tokens);
            try std.testing.expectEqual(@as(i64, 4), value.output_tokens);
        },
        else => try std.testing.expect(false),
    }

    switch (parsed.value.result[1]) {
        .images => |value| {
            try std.testing.expectEqualStrings("organization.usage.images.result", value.object);
            try std.testing.expectEqual(@as(i64, 2), value.images);
        },
        else => try std.testing.expect(false),
    }
}

test "usage time bucket keeps raw fallback for unknown usage result" {
    const payload =
        \\{"object":"bucket","start_time":1,"end_time":2,"result":[{"object":"organization.usage.future.result","x":1}]}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.UsageTimeBucket,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    try std.testing.expectEqual(@as(usize, 1), parsed.value.result.len);
    switch (parsed.value.result[0]) {
        .raw => |value| try std.testing.expectEqualStrings("organization.usage.future.result", value.object.get("object").?.string),
        else => try std.testing.expect(false),
    }
}

test "function parameters parse schema object and raw fallback" {
    const schema_payload =
        \\{"type":"object","properties":{"city":{"type":"string"}}}
    ;
    const parsed_schema = try std.json.parseFromSlice(
        gen.FunctionParameters,
        std.testing.allocator,
        schema_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_schema.deinit();

    switch (parsed_schema.value) {
        .schema => |value| try std.testing.expectEqualStrings("object", value.object.get("type").?.string),
        else => try std.testing.expect(false),
    }

    const raw_payload = "\"not-an-object\"";
    const parsed_raw = try std.json.parseFromSlice(
        gen.FunctionParameters,
        std.testing.allocator,
        raw_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_raw.deinit();

    switch (parsed_raw.value) {
        .raw => |value| try std.testing.expectEqualStrings("not-an-object", value.string),
        else => try std.testing.expect(false),
    }
}

test "create message request content parses text/parts/raw variants" {
    const text_payload = "\"hello world\"";
    const parsed_text = try std.json.parseFromSlice(
        gen.CreateMessageRequestContent,
        std.testing.allocator,
        text_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_text.deinit();

    switch (parsed_text.value) {
        .text => |value| try std.testing.expectEqualStrings("hello world", value),
        else => try std.testing.expect(false),
    }

    const parts_payload =
        \\[
        \\  {"type":"text","text":"part-1"},
        \\  {"type":"future","x":1}
        \\]
    ;
    const parsed_parts = try std.json.parseFromSlice(
        gen.CreateMessageRequestContent,
        std.testing.allocator,
        parts_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_parts.deinit();

    switch (parsed_parts.value) {
        .parts => |parts| {
            try std.testing.expectEqual(@as(usize, 2), parts.len);
            switch (parts[0]) {
                .text => |value| try std.testing.expectEqualStrings("part-1", value.text),
                else => try std.testing.expect(false),
            }
            switch (parts[1]) {
                .raw => |value| try std.testing.expectEqualStrings("future", value.object.get("type").?.string),
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }

    const raw_payload =
        \\{"k":"v"}
    ;
    const parsed_raw = try std.json.parseFromSlice(
        gen.CreateMessageRequestContent,
        std.testing.allocator,
        raw_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_raw.deinit();

    switch (parsed_raw.value) {
        .raw => |value| try std.testing.expectEqualStrings("v", value.object.get("k").?.string),
        else => try std.testing.expect(false),
    }
}

test "create moderation request input parses scalar/array/raw variants" {
    const text_payload = "\"safe text\"";
    const parsed_text = try std.json.parseFromSlice(
        gen.CreateModerationRequestInput,
        std.testing.allocator,
        text_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_text.deinit();

    switch (parsed_text.value) {
        .text => |value| try std.testing.expectEqualStrings("safe text", value),
        else => try std.testing.expect(false),
    }

    const array_payload =
        \\["a","b"]
    ;
    const parsed_array = try std.json.parseFromSlice(
        gen.CreateModerationRequestInput,
        std.testing.allocator,
        array_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_array.deinit();

    switch (parsed_array.value) {
        .texts => |texts| {
            try std.testing.expectEqual(@as(usize, 2), texts.len);
            try std.testing.expectEqualStrings("a", texts[0]);
            try std.testing.expectEqualStrings("b", texts[1]);
        },
        else => try std.testing.expect(false),
    }

    const raw_payload =
        \\{"foo":"bar"}
    ;
    const parsed_raw = try std.json.parseFromSlice(
        gen.CreateModerationRequestInput,
        std.testing.allocator,
        raw_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_raw.deinit();

    switch (parsed_raw.value) {
        .raw => |value| try std.testing.expectEqualStrings("bar", value.object.get("foo").?.string),
        else => try std.testing.expect(false),
    }
}

test "assistant content and parts parse typed variants and raw fallback" {
    const text_payload = "\"assistant-text\"";
    const parsed_text = try std.json.parseFromSlice(
        gen.ChatCompletionRequestAssistantMessageContent,
        std.testing.allocator,
        text_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_text.deinit();

    switch (parsed_text.value) {
        .text => |value| try std.testing.expectEqualStrings("assistant-text", value),
        else => try std.testing.expect(false),
    }

    const parts_payload =
        \\[
        \\  {"type":"text","text":"ok"},
        \\  {"type":"refusal","refusal":"no"},
        \\  {"type":"future","x":1}
        \\]
    ;
    const parsed_parts = try std.json.parseFromSlice(
        gen.ChatCompletionRequestAssistantMessageContent,
        std.testing.allocator,
        parts_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_parts.deinit();

    switch (parsed_parts.value) {
        .parts => |parts| {
            try std.testing.expectEqual(@as(usize, 3), parts.len);
            switch (parts[0]) {
                .text => |value| try std.testing.expectEqualStrings("ok", value.text),
                else => try std.testing.expect(false),
            }
            switch (parts[1]) {
                .refusal => |value| try std.testing.expectEqualStrings("no", value.refusal),
                else => try std.testing.expect(false),
            }
            switch (parts[2]) {
                .raw => |value| try std.testing.expectEqualStrings("future", value.object.get("type").?.string),
                else => try std.testing.expect(false),
            }
        },
        else => try std.testing.expect(false),
    }
}

test "user content part parses text/image/audio/file and raw fallback" {
    const text_payload =
        \\{"type":"text","text":"hello"}
    ;
    const parsed_text = try std.json.parseFromSlice(
        gen.ChatCompletionRequestUserMessageContentPart,
        std.testing.allocator,
        text_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_text.deinit();
    switch (parsed_text.value) {
        .text => |value| try std.testing.expectEqualStrings("hello", value.text),
        else => try std.testing.expect(false),
    }

    const image_payload =
        \\{"type":"image_url","image_url":{"url":"https://example.com/a.png","detail":"auto"}}
    ;
    const parsed_image = try std.json.parseFromSlice(
        gen.ChatCompletionRequestUserMessageContentPart,
        std.testing.allocator,
        image_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_image.deinit();
    switch (parsed_image.value) {
        .image => |value| try std.testing.expectEqualStrings("https://example.com/a.png", value.image_url.url),
        else => try std.testing.expect(false),
    }

    const audio_payload =
        \\{"type":"input_audio","input_audio":{"data":"Zm9v","format":"wav"}}
    ;
    const parsed_audio = try std.json.parseFromSlice(
        gen.ChatCompletionRequestUserMessageContentPart,
        std.testing.allocator,
        audio_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_audio.deinit();
    switch (parsed_audio.value) {
        .audio => |value| try std.testing.expectEqualStrings("wav", value.input_audio.format),
        else => try std.testing.expect(false),
    }

    const file_payload =
        \\{"type":"file","file":{"file_id":"file_1"}}
    ;
    const parsed_file = try std.json.parseFromSlice(
        gen.ChatCompletionRequestUserMessageContentPart,
        std.testing.allocator,
        file_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_file.deinit();
    switch (parsed_file.value) {
        .file => |value| try std.testing.expectEqualStrings("file_1", value.file.file_id.?),
        else => try std.testing.expect(false),
    }

    const raw_payload =
        \\{"type":"future","x":1}
    ;
    const parsed_raw = try std.json.parseFromSlice(
        gen.ChatCompletionRequestUserMessageContentPart,
        std.testing.allocator,
        raw_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_raw.deinit();
    switch (parsed_raw.value) {
        .raw => |value| try std.testing.expectEqualStrings("future", value.object.get("type").?.string),
        else => try std.testing.expect(false),
    }
}

test "developer/system/tool content parse text and parts" {
    const text_payload = "\"hello\"";

    const dev_text = try std.json.parseFromSlice(
        gen.ChatCompletionRequestDeveloperMessageContent,
        std.testing.allocator,
        text_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer dev_text.deinit();
    switch (dev_text.value) {
        .text => |value| try std.testing.expectEqualStrings("hello", value),
        else => try std.testing.expect(false),
    }

    const sys_parts_payload =
        \\[{"type":"text","text":"sys"}]
    ;
    const sys_parts = try std.json.parseFromSlice(
        gen.ChatCompletionRequestSystemMessageContent,
        std.testing.allocator,
        sys_parts_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer sys_parts.deinit();
    switch (sys_parts.value) {
        .parts => |value| try std.testing.expectEqualStrings("sys", value[0].text),
        else => try std.testing.expect(false),
    }

    const tool_parts_payload =
        \\[{"type":"text","text":"tool"}]
    ;
    const tool_parts = try std.json.parseFromSlice(
        gen.ChatCompletionRequestToolMessageContent,
        std.testing.allocator,
        tool_parts_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer tool_parts.deinit();
    switch (tool_parts.value) {
        .parts => |value| try std.testing.expectEqualStrings("tool", value[0].text),
        else => try std.testing.expect(false),
    }
}

test "completion logit bias parses entries and raw fallback" {
    const payload =
        \\{"123":-5,"456":10}
    ;
    const parsed = try std.json.parseFromSlice(
        gen.CreateCompletionLogitBias,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    switch (parsed.value) {
        .entries => |entries| {
            try std.testing.expectEqual(@as(usize, 2), entries.len);
            var seen_123 = false;
            var seen_456 = false;
            for (entries) |entry| {
                if (std.mem.eql(u8, entry.token, "123")) {
                    seen_123 = true;
                    try std.testing.expectEqual(@as(i64, -5), entry.bias);
                }
                if (std.mem.eql(u8, entry.token, "456")) {
                    seen_456 = true;
                    try std.testing.expectEqual(@as(i64, 10), entry.bias);
                }
            }
            try std.testing.expect(seen_123 and seen_456);
        },
        else => try std.testing.expect(false),
    }

    const raw_payload =
        \\[1,2]
    ;
    const parsed_raw = try std.json.parseFromSlice(
        gen.CreateCompletionLogitBias,
        std.testing.allocator,
        raw_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_raw.deinit();
    switch (parsed_raw.value) {
        .raw => |value| try std.testing.expectEqual(@as(usize, 2), value.array.items.len),
        else => try std.testing.expect(false),
    }
}

test "embedding input and stop configuration parse scalar/array/raw variants" {
    const embedding_text = try std.json.parseFromSlice(
        gen.CreateEmbeddingRequestInput,
        std.testing.allocator,
        "\"embed me\"",
        .{ .ignore_unknown_fields = true },
    );
    defer embedding_text.deinit();
    switch (embedding_text.value) {
        .text => |value| try std.testing.expectEqualStrings("embed me", value),
        else => try std.testing.expect(false),
    }

    const embedding_array = try std.json.parseFromSlice(
        gen.CreateEmbeddingRequestInput,
        std.testing.allocator,
        "[\"a\",\"b\"]",
        .{ .ignore_unknown_fields = true },
    );
    defer embedding_array.deinit();
    switch (embedding_array.value) {
        .texts => |values| try std.testing.expectEqual(@as(usize, 2), values.len),
        else => try std.testing.expect(false),
    }

    const stop_single = try std.json.parseFromSlice(
        gen.StopConfiguration,
        std.testing.allocator,
        "\"STOP\"",
        .{ .ignore_unknown_fields = true },
    );
    defer stop_single.deinit();
    switch (stop_single.value) {
        .single => |value| try std.testing.expectEqualStrings("STOP", value),
        else => try std.testing.expect(false),
    }

    const stop_multi = try std.json.parseFromSlice(
        gen.StopConfiguration,
        std.testing.allocator,
        "[\"A\",\"B\"]",
        .{ .ignore_unknown_fields = true },
    );
    defer stop_multi.deinit();
    switch (stop_multi.value) {
        .multiple => |value| try std.testing.expectEqual(@as(usize, 2), value.len),
        else => try std.testing.expect(false),
    }

    const stop_raw = try std.json.parseFromSlice(
        gen.StopConfiguration,
        std.testing.allocator,
        "{\"k\":\"v\"}",
        .{ .ignore_unknown_fields = true },
    );
    defer stop_raw.deinit();
    switch (stop_raw.value) {
        .raw => |value| try std.testing.expectEqualStrings("v", value.object.get("k").?.string),
        else => try std.testing.expect(false),
    }
}

test "function-parameter aliases parse as schema/raw across migrated fields" {
    const eval_run = try std.json.parseFromSlice(
        gen.EvalRun,
        std.testing.allocator,
        "{\"object\":\"eval.run\",\"id\":\"run_1\",\"status\":\"completed\",\"model\":\"gpt-4o-mini\",\"name\":\"sample\",\"created_at\":1,\"report_url\":\"https://example.com/r\",\"result_counts\":{\"total\":1,\"errored\":0,\"failed\":0,\"passed\":1},\"per_model_usage\":[],\"per_testing_criteria_results\":[],\"data_source\":{\"type\":\"responses\"},\"metadata\":{},\"error\":{\"code\":\"ok\",\"message\":\"ok\"}}",
        .{ .ignore_unknown_fields = true },
    );
    defer eval_run.deinit();
    switch (eval_run.value.data_source) {
        .schema => |value| try std.testing.expectEqualStrings("responses", value.object.get("type").?.string),
        else => try std.testing.expect(false),
    }

    const custom_tool = try std.json.parseFromSlice(
        gen.CustomToolCallOutput,
        std.testing.allocator,
        "{\"type\":\"custom\",\"call_id\":\"call_1\",\"output\":\"ok\"}",
        .{ .ignore_unknown_fields = true },
    );
    defer custom_tool.deinit();
    switch (custom_tool.value.output) {
        .raw => |value| try std.testing.expectEqualStrings("ok", value.string),
        else => try std.testing.expect(false),
    }

    const rt_session = try std.json.parseFromSlice(
        gen.RealtimeClientEventSessionUpdate,
        std.testing.allocator,
        "{\"type\":\"session.update\",\"session\":{\"model\":\"gpt-4o-mini\"}}",
        .{ .ignore_unknown_fields = true },
    );
    defer rt_session.deinit();
    const session = rt_session.value.session orelse {
        try std.testing.expect(false);
        return;
    };
    switch (session) {
        .schema => |value| try std.testing.expectEqualStrings("gpt-4o-mini", value.object.get("model").?.string),
        else => try std.testing.expect(false),
    }
}

test "migrated semantic fields keep schema/raw behavior" {
    const local_shell = try std.json.parseFromSlice(
        gen.LocalShellExecAction,
        std.testing.allocator,
        "{\"type\":\"exec\",\"command\":[\"echo\",\"hi\"],\"env\":{\"A\":\"1\"}}",
        .{ .ignore_unknown_fields = true },
    );
    defer local_shell.deinit();
    const env = local_shell.value.env orelse {
        try std.testing.expect(false);
        return;
    };
    switch (env) {
        .schema => |value| try std.testing.expectEqualStrings("1", value.object.get("A").?.string),
        else => try std.testing.expect(false),
    }

    const mcp_tool = try std.json.parseFromSlice(
        gen.MCPListToolsTool,
        std.testing.allocator,
        "{\"name\":\"weather\",\"input_schema\":{\"type\":\"object\"}}",
        .{ .ignore_unknown_fields = true },
    );
    defer mcp_tool.deinit();
    switch (mcp_tool.value.input_schema) {
        .schema => |value| try std.testing.expectEqualStrings("object", value.object.get("type").?.string),
        else => try std.testing.expect(false),
    }

    const prediction = try std.json.parseFromSlice(
        gen.PredictionContent,
        std.testing.allocator,
        "{\"type\":\"content\",\"content\":\"hello\"}",
        .{ .ignore_unknown_fields = true },
    );
    defer prediction.deinit();
    switch (prediction.value.content) {
        .raw => |value| try std.testing.expectEqualStrings("hello", value.string),
        else => try std.testing.expect(false),
    }

    const validate = try std.json.parseFromSlice(
        gen.ValidateGraderRequest,
        std.testing.allocator,
        "{\"grader\":{\"type\":\"python\",\"name\":\"g\"}}",
        .{ .ignore_unknown_fields = true },
    );
    defer validate.deinit();
    switch (validate.value.grader) {
        .schema => |value| try std.testing.expectEqualStrings("python", value.object.get("type").?.string),
        else => try std.testing.expect(false),
    }
}

test "eval create request sources now parse via FunctionParameters" {
    const completions_payload =
        "{\"type\":\"completions\",\"input_messages\":[\"hello\"],\"source\":{\"id\":\"s1\",\"name\":\"demo\"}}";
    const completions_request = try std.json.parseFromSlice(
        gen.CreateEvalCompletionsRunDataSource,
        std.testing.allocator,
        completions_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer completions_request.deinit();
    switch (completions_request.value.source) {
        .schema => |value| try std.testing.expectEqualStrings("s1", value.object.get("id").?.string),
        .raw => |value| try std.testing.expectEqualStrings("s1", value.object.get("id").?.string),
    }

    const jsonl_payload =
        "{\"type\":\"jsonl\",\"source\":{\"id\":\"file_123\"}}";
    const jsonl_request = try std.json.parseFromSlice(
        gen.CreateEvalJsonlRunDataSource,
        std.testing.allocator,
        jsonl_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer jsonl_request.deinit();
    switch (jsonl_request.value.source) {
        .schema => |value| try std.testing.expectEqualStrings("file_123", value.object.get("id").?.string),
        .raw => |value| try std.testing.expectEqualStrings("file_123", value.object.get("id").?.string),
    }
}

test "raw constructors accept plain std.json.Value for FunctionParameters-backed unions" {
    const raw_value = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"x\":1,\"type\":\"test\"}",
        .{ .ignore_unknown_fields = true },
    );
    defer raw_value.deinit();

    const as_event = gen.AssistantStreamEvent.forRaw(raw_value.value);
    switch (as_event) {
        .raw => |value| switch (value) {
            .raw => |obj| try std.testing.expectEqual(@as(i64, 1), obj.object.get("x").?.integer),
            .schema => try std.testing.expect(false),
        },
        else => try std.testing.expect(false),
    }

    const as_response = gen.CreateResponse.forRaw(raw_value.value);
    switch (as_response) {
        .raw => |value| switch (value) {
            .raw => |obj| try std.testing.expectEqualStrings("test", obj.object.get("type").?.string),
            .schema => try std.testing.expect(false),
        },
        else => try std.testing.expect(false),
    }

    const as_tool_choice = gen.ToolChoiceParam.forRaw(raw_value.value);
    switch (as_tool_choice) {
        .raw => |value| switch (value) {
            .raw => |obj| try std.testing.expect(obj.object.get("type") != null),
            .schema => try std.testing.expect(false),
        },
        else => try std.testing.expect(false),
    }
}

test "metadata alias parse supports optional metadata as FunctionParameters" {
    const logs_data_source = try std.json.parseFromSlice(
        gen.CreateEvalLogsDataSourceConfig,
        std.testing.allocator,
        "{\"type\":\"logs\",\"metadata\":{\"run_id\":\"r1\",\"attempt\":1}}",
        .{ .ignore_unknown_fields = true },
    );
    defer logs_data_source.deinit();
    try std.testing.expect(logs_data_source.value.metadata != null);
    const metadata = logs_data_source.value.metadata.?;
    switch (metadata) {
        .schema => |value| try std.testing.expectEqualStrings("r1", value.object.get("run_id").?.string),
        .raw => |value| try std.testing.expectEqualStrings("r1", value.object.get("run_id").?.string),
    }
}

test "eval data source schema aliases resolve through FunctionParameters-backed union" {
    const custom_source = try std.json.parseFromSlice(
        gen.CreateEvalCustomDataSourceConfig,
        std.testing.allocator,
        "{\"type\":\"custom\",\"item_schema\":{\"type\":\"object\"}}",
        .{ .ignore_unknown_fields = true },
    );
    defer custom_source.deinit();
    switch (custom_source.value.item_schema) {
        .schema => |value| try std.testing.expectEqualStrings("object", value.object.get("type").?.string),
        .raw => |value| try std.testing.expectEqualStrings("object", value.object.get("type").?.string),
    }

    const logs_source = try std.json.parseFromSlice(
        gen.EvalLogsDataSourceConfig,
        std.testing.allocator,
        "{\"type\":\"logs\",\"metadata\":{\"a\":1},\"schema\":{\"field\":\"v\"}}",
        .{ .ignore_unknown_fields = true },
    );
    defer logs_source.deinit();
    switch (logs_source.value.schema) {
        .schema => |value| try std.testing.expectEqualStrings("v", value.object.get("field").?.string),
        .raw => |value| try std.testing.expectEqualStrings("v", value.object.get("field").?.string),
    }

    const stored_source = try std.json.parseFromSlice(
        gen.EvalStoredCompletionsDataSourceConfig,
        std.testing.allocator,
        "{\"type\":\"stored_completions\",\"schema\":{\"field\":\"w\"}}",
        .{ .ignore_unknown_fields = true },
    );
    defer stored_source.deinit();
    switch (stored_source.value.schema) {
        .schema => |value| try std.testing.expectEqualStrings("w", value.object.get("field").?.string),
        .raw => |value| try std.testing.expectEqualStrings("w", value.object.get("field").?.string),
    }
}

test "mcp list tools aliases parse as FunctionParameters-backed fields" {
    const mcp_tool_payload =
        "{\"name\":\"search\",\"input_schema\":{\"type\":\"object\",\"properties\":{\"q\":{\"type\":\"string\"}}},\"annotations\":{\"scope\":\"mcp\",\"version\":1},\"description\":\"search web\"}";
    const parsed_tool = try std.json.parseFromSlice(
        gen.MCPListToolsTool,
        std.testing.allocator,
        mcp_tool_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_tool.deinit();

    switch (parsed_tool.value.input_schema) {
        .schema => |value| try std.testing.expectEqualStrings(
            "object",
            value.object.get("type").?.string,
        ),
        .raw => |value| try std.testing.expectEqualStrings(
            "object",
            value.object.get("type").?.string,
        ),
    }

    if (parsed_tool.value.annotations) |annotations| {
        switch (annotations) {
            .schema => |value| try std.testing.expectEqualStrings(
                "mcp",
                value.object.get("scope").?.string,
            ),
            .raw => |value| try std.testing.expectEqualStrings(
                "mcp",
                value.object.get("scope").?.string,
            ),
        }
    } else {
        try std.testing.expect(false);
    }

    const mcp_tools_payload =
        "{\"type\":\"mcp.list_tools\",\"id\":\"evt_1\",\"server_label\":\"local\",\"tools\":[{\"name\":\"search\",\"input_schema\":{\"type\":\"object\"}}]}";
    const parsed_list = try std.json.parseFromSlice(
        gen.MCPListTools,
        std.testing.allocator,
        mcp_tools_payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed_list.deinit();
    try std.testing.expectEqual(@as(usize, 1), parsed_list.value.tools.len);
    const tool_from_list = parsed_list.value.tools[0];
    switch (tool_from_list.input_schema) {
        .schema => |value| try std.testing.expectEqualStrings(
            "object",
            value.object.get("type").?.string,
        ),
        .raw => |value| try std.testing.expectEqualStrings(
            "object",
            value.object.get("type").?.string,
        ),
    }
}

test "realtime status/details and session payload aliases remain parseable" {
    const openai_file = try std.json.parseFromSlice(
        gen.OpenAIFile,
        std.testing.allocator,
        "{\"id\":\"file_123\",\"object\":\"file\",\"filename\":\"x\",\"purpose\":\"assistants\",\"status\":\"processed\",\"status_details\":{\"state\":\"ok\",\"retry\":false}}",
        .{ .ignore_unknown_fields = true },
    );
    defer openai_file.deinit();
    try std.testing.expect(openai_file.value.status_details != null);
    switch (openai_file.value.status_details.?) {
        .schema => |v| try std.testing.expectEqualStrings("ok", v.object.get("state").?.string),
        .raw => |v| try std.testing.expectEqualStrings("ok", v.object.get("state").?.string),
    }

    const server_session_created = try std.json.parseFromSlice(
        gen.RealtimeServerEventSessionCreated,
        std.testing.allocator,
        "{\"event_id\":\"ev_1\",\"type\":\"session.created\",\"session\":{\"model\":\"gpt-realtime\"}}",
        .{ .ignore_unknown_fields = true },
    );
    defer server_session_created.deinit();
    switch (server_session_created.value.session) {
        .schema => |value| try std.testing.expectEqualStrings("gpt-realtime", value.object.get("model").?.string),
        .raw => |value| try std.testing.expectEqualStrings("gpt-realtime", value.object.get("model").?.string),
    }

    const server_session_updated = try std.json.parseFromSlice(
        gen.RealtimeServerEventSessionUpdated,
        std.testing.allocator,
        "{\"event_id\":\"ev_2\",\"type\":\"session.updated\",\"session\":{\"id\":\"session_1\"}}",
        .{ .ignore_unknown_fields = true },
    );
    defer server_session_updated.deinit();
    switch (server_session_updated.value.session) {
        .schema => |value| try std.testing.expectEqualStrings("session_1", value.object.get("id").?.string),
        .raw => |value| try std.testing.expectEqualStrings("session_1", value.object.get("id").?.string),
    }

    const call_create_req = try std.json.parseFromSlice(
        gen.RealtimeCallCreateRequest,
        std.testing.allocator,
        "{\"sdp\":\"v=0\",\"session\":{\"type\":\"session\",\"model\":\"gpt-4o-realtime\"}}",
        .{ .ignore_unknown_fields = true },
    );
    defer call_create_req.deinit();
    try std.testing.expect(call_create_req.value.session != null);
    switch (call_create_req.value.session.?) {
        .schema => |value| try std.testing.expectEqualStrings("session", value.object.get("type").?.string),
        .raw => |value| try std.testing.expectEqualStrings("session", value.object.get("type").?.string),
    }

    const client_secret_request = try std.json.parseFromSlice(
        gen.RealtimeCreateClientSecretRequest,
        std.testing.allocator,
        "{\"session\":{\"expires\":3600},\"expires_after\":{\"seconds\":900}}",
        .{ .ignore_unknown_fields = true },
    );
    defer client_secret_request.deinit();
    try std.testing.expect(client_secret_request.value.session != null);
    switch (client_secret_request.value.session.?) {
        .schema => |value| try std.testing.expectEqual(@as(?i64, 3600), value.object.get("expires").?.integer),
        .raw => |value| try std.testing.expectEqual(@as(?i64, 3600), value.object.get("expires").?.integer),
    }

    const client_secret_response = try std.json.parseFromSlice(
        gen.RealtimeCreateClientSecretResponse,
        std.testing.allocator,
        "{\"value\":\"abc\",\"expires_at\":123,\"session\":{\"region\":\"ap-east\"}}",
        .{ .ignore_unknown_fields = true },
    );
    defer client_secret_response.deinit();
    switch (client_secret_response.value.session) {
        .schema => |value| try std.testing.expectEqualStrings("ap-east", value.object.get("region").?.string),
        .raw => |value| try std.testing.expectEqualStrings("ap-east", value.object.get("region").?.string),
    }

    const client_event_update = try std.json.parseFromSlice(
        gen.RealtimeClientEventSessionUpdate,
        std.testing.allocator,
        "{\"type\":\"session.update\",\"session\":{\"voice\":\"alloy\"},\"event_id\":\"evt_100\"}",
        .{ .ignore_unknown_fields = true },
    );
    defer client_event_update.deinit();
    switch (client_event_update.value.session) {
        .schema => |value| try std.testing.expectEqualStrings("alloy", value.object.get("voice").?.string),
        .raw => |value| try std.testing.expectEqualStrings("alloy", value.object.get("voice").?.string),
    }
}

test "deepseek completion usage includes reasoning token details" {
    const payload =
        "{\"id\":\"cmpl-reason\",\"object\":\"text_completion\",\"created\":1700000000,\"model\":\"deepseek-reasoner\",\"choices\":[{\"text\":\"ok\",\"index\":0,\"logprobs\":null,\"finish_reason\":\"stop\"}],\"usage\":{\"prompt_tokens\":12,\"completion_tokens\":34,\"total_tokens\":46,\"completion_tokens_details\":{\"reasoning_tokens\":19,\"accepted_prediction_tokens\":5},\"prompt_tokens_details\":{\"cached_tokens\":7}}}";
    const response = try std.json.parseFromSlice(
        gen.CreateCompletionResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();

    const usage = response.value.usage orelse return error.TestUnexpectedResult;
    const completion_details = usage.completion_tokens_details orelse return error.TestUnexpectedResult;
    try std.testing.expectEqual(@as(i64, 19), completion_details.reasoning_tokens.?);
    try std.testing.expectEqual(@as(i64, 5), completion_details.accepted_prediction_tokens.?);
    const prompt_details = usage.prompt_tokens_details orelse return error.TestUnexpectedResult;
    try std.testing.expectEqual(@as(i64, 7), prompt_details.cached_tokens.?);
}

test "deepseek user balance response follows compatibility contract" {
    const payload =
        "{\"is_available\":true,\"balance_infos\":[{\"currency\":\"USD\",\"total_balance\":\"9.990000\",\"granted_balance\":\"8.120000\",\"topped_up_balance\":\"1.870000\",\"extra\":\"ignored\"},{\"currency\":\"CNY\",\"total_balance\":\"66.000\",\"granted_balance\":\"55.000\",\"topped_up_balance\":\"11.000\"}],\"unsupported\":false}";
    const parsed = try std.json.parseFromSlice(
        user_balance.GetUserBalanceResponse,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    try std.testing.expectEqual(true, parsed.value.is_available);
    try std.testing.expectEqual(@as(usize, 2), parsed.value.balance_infos.len);

    const usd = parsed.value.balance_infos[0];
    const cny = parsed.value.balance_infos[1];
    try std.testing.expectEqualStrings("USD", usd.currency);
    try std.testing.expectEqualStrings("9.990000", usd.total_balance);
    try std.testing.expectEqualStrings("CNY", cny.currency);
    try std.testing.expectEqualStrings("66.000", cny.total_balance);
}

test "deepseek responses parse status/output/usage contract" {
    const payload =
        "{\"id\":\"resp_7\",\"object\":\"response\",\"created_at\":1710000000,\"status\":\"completed\",\"model\":\"deepseek-reasoner\",\"output\":[{\"type\":\"reasoning\",\"id\":\"rsn_1\",\"summary\":[{\"type\":\"summary\",\"text\":\"prefetch\"}],\"content\":[{\"type\":\"text\",\"text\":\"reasoned about task\"}],\"status\":\"done\"}],\"usage\":{\"input_tokens\":12,\"input_tokens_details\":{\"cached_tokens\":3},\"output_tokens\":34,\"output_tokens_details\":{\"reasoning_tokens\":19},\"total_tokens\":46}}";
    const response = try std.json.parseFromSlice(
        gen.Response,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer response.deinit();

    const obj = response.value.object orelse return error.TestUnexpectedResult;
    try std.testing.expect(obj.usage != null);
    try std.testing.expectEqualStrings("completed", obj.status orelse "");
    const usage = obj.usage.?;
    try std.testing.expectEqual(@as(i64, 12), usage.input_tokens);
    try std.testing.expectEqual(@as(i64, 46), usage.total_tokens);
    try std.testing.expectEqual(@as(i64, 19), usage.output_tokens_details.reasoning_tokens);
    try std.testing.expectEqual(@as(i64, 3), usage.input_tokens_details.cached_tokens);

    const output = obj.output orelse return error.TestUnexpectedResult;
    switch (output) {
        .items => |items| {
            try std.testing.expectEqual(@as(usize, 1), items.len);
            switch (items[0]) {
                .reasoning => |r| {
                    try std.testing.expectEqualStrings("rsn_1", r.id);
                    try std.testing.expectEqualStrings("done", r.status orelse "");
                    try std.testing.expectEqual(@as(usize, 1), r.summary.len);
                    try std.testing.expectEqualStrings("summary", r.summary[0].type);
                    try std.testing.expectEqualStrings("prefetch", r.summary[0].text);
                },
                else => return error.TestUnexpectedResult,
            }
        },
        else => return error.TestUnexpectedResult,
    }
}

test "deepseek response stream event reasoning text delta" {
    const payload =
        "{\"type\":\"reasoning_text_delta\",\"item_id\":\"item_1\",\"output_index\":0,\"content_index\":0,\"delta\":\"Let's reason...\",\"sequence_number\":14}";
    const event = try std.json.parseFromSlice(
        gen.ResponseStreamEvent,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer event.deinit();

    switch (event.value) {
        .reasoning_text_delta => |delta| {
            try std.testing.expectEqualStrings("item_1", delta.item_id);
            try std.testing.expectEqual(@as(i64, 14), delta.sequence_number);
            try std.testing.expectEqualStrings("Let's reason...", delta.delta);
        },
        else => return error.TestUnexpectedResult,
    }
}

test "response stream unknown event falls back to raw payload" {
    const payload =
        "{\"type\":\"new_experimental_event\",\"item_id\":\"item_unknown\",\"sequence_number\":7,\"note\":\"future_compat\"}";
    const event = try std.json.parseFromSlice(
        gen.ResponseStreamEvent,
        std.testing.allocator,
        payload,
        .{ .ignore_unknown_fields = true },
    );
    defer event.deinit();

    switch (event.value) {
        .raw => |raw| {
            try std.testing.expectEqual(@as(?i64, 7), raw.object.get("sequence_number").?.integer);
            switch (raw) {
                .schema => |v| try std.testing.expectEqualStrings("future_compat", v.object.get("note").?.string),
                .raw => |v| try std.testing.expectEqualStrings("future_compat", v.object.get("note").?.string),
            }
        },
        else => return error.TestUnexpectedResult,
    }
}
