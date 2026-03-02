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
    try std.testing.expect(reasoning == .string);
    try std.testing.expectEqualStrings("think through details", reasoning.string);
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
