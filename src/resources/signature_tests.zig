const transport = @import("../transport/http.zig");
const chat = @import("chat.zig");
const completions = @import("completions.zig");
const models = @import("models.zig");
const files = @import("files.zig");
const audio = @import("audio.zig");
const embeddings = @import("embeddings.zig");
const moderations = @import("moderations.zig");
const batch = @import("batch.zig");
const responses = @import("responses.zig");
const images = @import("images.zig");

fn assertParamCount(comptime Func: type, comptime expected: comptime_int) void {
    const info = @typeInfo(Func).Fn;
    if (info.params.len != expected) {
        @compileError("function parameter count mismatch");
    }
}

fn assertLastParamIsOptionalRequestOptions(comptime Func: type) void {
    const params = @typeInfo(Func).Fn.params;
    if (params[params.len - 1].type != ?transport.RequestOptions) {
        @compileError("last param should be ?transport.RequestOptions");
    }
}

test "models resource signature keeps request_opts optional" {
    assertParamCount(models.Resource.list_models_with_options, 3);
    assertLastParamIsOptionalRequestOptions(models.Resource.list_models_with_options);

    assertParamCount(models.Resource.list_with_options, 3);
    assertLastParamIsOptionalRequestOptions(models.Resource.list_with_options);

    assertParamCount(models.Resource.retrieve_model_with_options, 4);
    assertLastParamIsOptionalRequestOptions(models.Resource.retrieve_model_with_options);

    assertParamCount(models.Resource.retrieve_with_options, 4);
    assertLastParamIsOptionalRequestOptions(models.Resource.retrieve_with_options);

    assertParamCount(models.Resource.delete_model_with_options, 4);
    assertLastParamIsOptionalRequestOptions(models.Resource.delete_model_with_options);

    assertParamCount(models.Resource.delete_with_options, 4);
    assertLastParamIsOptionalRequestOptions(models.Resource.delete_with_options);
}

test "chat completion signature keeps request options and optional payload fields" {
    assertParamCount(chat.Resource.create_chat_completion_with_options, 4);
    assertLastParamIsOptionalRequestOptions(chat.Resource.create_chat_completion_with_options);

    assertParamCount(chat.Resource.create_with_options, 4);
    assertLastParamIsOptionalRequestOptions(chat.Resource.create_with_options);

    assertParamCount(chat.Resource.create_chat_completion_stream_with_options, 6);
    assertLastParamIsOptionalRequestOptions(chat.Resource.create_chat_completion_stream_with_options);

    assertLastParamIsOptionalRequestOptions(chat.Resource.create_with_options_stream);

    assertParamCount(chat.Resource.list_with_options, 2);
}

test "completions resource signature keeps request options" {
    assertParamCount(completions.Resource.create_completion_with_options, 4);
    assertLastParamIsOptionalRequestOptions(completions.Resource.create_completion_with_options);

    assertParamCount(completions.Resource.create_with_options, 4);
    assertLastParamIsOptionalRequestOptions(completions.Resource.create_with_options);

    assertParamCount(completions.Resource.create_completion_stream_with_options, 6);
    assertLastParamIsOptionalRequestOptions(completions.Resource.create_completion_stream_with_options);

    assertParamCount(completions.Resource.create_with_options_stream, 6);
    assertLastParamIsOptionalRequestOptions(completions.Resource.create_with_options_stream);
}

test "files resource signature keeps request options" {
    assertParamCount(files.Resource.list_files_with_options, 4);
    assertLastParamIsOptionalRequestOptions(files.Resource.list_files_with_options);

    assertParamCount(files.Resource.create_file_with_options, 4);
    assertLastParamIsOptionalRequestOptions(files.Resource.create_file_with_options);

    assertParamCount(files.Resource.create_with_options, 4);
    assertLastParamIsOptionalRequestOptions(files.Resource.create_with_options);

    assertParamCount(files.Resource.create_file_from_path_with_options, 4);
    assertLastParamIsOptionalRequestOptions(files.Resource.create_file_from_path_with_options);

    assertParamCount(files.Resource.delete_file_with_options, 4);
    assertLastParamIsOptionalRequestOptions(files.Resource.delete_file_with_options);

    assertParamCount(files.Resource.delete_with_options, 4);
    assertLastParamIsOptionalRequestOptions(files.Resource.delete_with_options);

    assertParamCount(files.Resource.retrieve_file_with_options, 4);
    assertLastParamIsOptionalRequestOptions(files.Resource.retrieve_file_with_options);

    assertParamCount(files.Resource.retrieve_with_options, 4);
    assertLastParamIsOptionalRequestOptions(files.Resource.retrieve_with_options);
}

test "responses resource signature keeps request options" {
    assertParamCount(responses.Resource.create_response_with_options, 4);
    assertLastParamIsOptionalRequestOptions(responses.Resource.create_response_with_options);

    assertParamCount(responses.Resource.create_with_options, 4);
    assertLastParamIsOptionalRequestOptions(responses.Resource.create_with_options);

    assertParamCount(responses.Resource.create_response_stream_with_options, 6);
    assertLastParamIsOptionalRequestOptions(responses.Resource.create_response_stream_with_options);

    assertParamCount(responses.Resource.create_with_options_stream, 6);
    assertLastParamIsOptionalRequestOptions(responses.Resource.create_with_options_stream);

    assertParamCount(responses.Resource.get_response_with_options, 4);
    assertLastParamIsOptionalRequestOptions(responses.Resource.get_response_with_options);

    assertParamCount(responses.Resource.retrieve_with_options, 4);
    assertLastParamIsOptionalRequestOptions(responses.Resource.retrieve_with_options);
}

test "images resource signature keeps request options" {
    assertParamCount(images.Resource.create_image_edit_with_options, 5);
    assertLastParamIsOptionalRequestOptions(images.Resource.create_image_edit_with_options);

    assertParamCount(images.Resource.create_image_variation_with_options, 5);
    assertLastParamIsOptionalRequestOptions(images.Resource.create_image_variation_with_options);

    assertParamCount(images.Resource.variation_with_options, 5);
    assertLastParamIsOptionalRequestOptions(images.Resource.variation_with_options);

    assertParamCount(images.Resource.create_image_generation_with_options, 4);
    assertLastParamIsOptionalRequestOptions(images.Resource.create_image_generation_with_options);

    assertParamCount(images.Resource.create_with_options, 4);
    assertLastParamIsOptionalRequestOptions(images.Resource.create_with_options);
}

test "audio resource signature keeps request options" {
    assertParamCount(audio.Resource.create_speech_with_options, 4);
    assertLastParamIsOptionalRequestOptions(audio.Resource.create_speech_with_options);

    assertParamCount(audio.Resource.create_transcription_with_options, 4);
    assertLastParamIsOptionalRequestOptions(audio.Resource.create_transcription_with_options);

    assertParamCount(audio.Resource.create_voice_consent_with_options, 4);
    assertLastParamIsOptionalRequestOptions(audio.Resource.create_voice_consent_with_options);

    assertParamCount(audio.Resource.list_voice_consents_with_options, 4);
    assertLastParamIsOptionalRequestOptions(audio.Resource.list_voice_consents_with_options);

    assertParamCount(audio.Resource.get_voice_consent_with_options, 4);
    assertLastParamIsOptionalRequestOptions(audio.Resource.get_voice_consent_with_options);

    assertParamCount(audio.Resource.update_voice_consent_with_options, 5);
    assertLastParamIsOptionalRequestOptions(audio.Resource.update_voice_consent_with_options);
}

test "embeddings and moderations signatures keep request options" {
    assertParamCount(embeddings.Resource.create_embedding_with_options, 4);
    assertLastParamIsOptionalRequestOptions(embeddings.Resource.create_embedding_with_options);

    assertParamCount(embeddings.Resource.create_with_options, 4);
    assertLastParamIsOptionalRequestOptions(embeddings.Resource.create_with_options);

    assertParamCount(moderations.Resource.create_moderation_with_options, 4);
    assertLastParamIsOptionalRequestOptions(moderations.Resource.create_moderation_with_options);

    assertParamCount(moderations.Resource.create_with_options, 4);
    assertLastParamIsOptionalRequestOptions(moderations.Resource.create_with_options);
}

test "batch resource signature keeps request options" {
    assertParamCount(batch.Resource.create_batch_with_options, 4);
    assertLastParamIsOptionalRequestOptions(batch.Resource.create_batch_with_options);

    assertParamCount(batch.Resource.list_batches_with_options, 4);
    assertLastParamIsOptionalRequestOptions(batch.Resource.list_batches_with_options);

    assertParamCount(batch.Resource.retrieve_batch_with_options, 4);
    assertLastParamIsOptionalRequestOptions(batch.Resource.retrieve_batch_with_options);

    assertParamCount(batch.Resource.cancel_batch_with_options, 4);
    assertLastParamIsOptionalRequestOptions(batch.Resource.cancel_batch_with_options);

    assertParamCount(batch.Resource.create_with_options, 4);
    assertLastParamIsOptionalRequestOptions(batch.Resource.create_with_options);
}
