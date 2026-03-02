const std = @import("std");
const gen = @import("generated/types.zig");

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

test "create chat completion response ignores unknown fields" {
    const payload =
        \\{"id":"chatcmpl-test","object":"chat.completion","created":1700000000,"model":"deepseek-chat","service_tier":{"foo":"bar"},"system_fingerprint":"fp_x","choices":[{"index":0,"message":{"role":"assistant","content":"ok","refusal":null,"annotations":[],"tool_calls":null},"finish_reason":"stop","logprobs":null}],"usage":{"prompt_tokens":10,"completion_tokens":20,"total_tokens":30},"extra_root":"ignored"}
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
}
