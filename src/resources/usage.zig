const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const UsageParams = struct {
    start_time: ?u64 = null,
    end_time: ?u64 = null,
    limit: ?u32 = null,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn buildPath(buf: []u8, path: []const u8, params: UsageParams) ![]const u8 {
        var fbs = std.io.fixedBufferStream(buf);
        const writer = fbs.writer();
        try writer.writeAll(path);

        var first = true;
        if (params.start_time) |start_time| {
            try common.appendOptionalQueryParamU64(writer, &first, "start_time", start_time);
        }
        if (params.end_time) |end_time| {
            try common.appendOptionalQueryParamU64(writer, &first, "end_time", end_time);
        }
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, &first, "limit", @as(u64, limit));
        }
        return fbs.getWritten();
    }

    fn getUsage(
        self: *const Resource,
        allocator: std.mem.Allocator,
        path: []const u8,
        params: UsageParams,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        return self.getUsageWithOptions(allocator, path, params, T, null);
    }

    fn getUsageWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        path: []const u8,
        params: UsageParams,
        comptime T: type,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        var buf: [256]u8 = undefined;
        const full_path = buildPath(&buf, path, params) catch {
            return errors.Error.SerializeError;
        };

        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            .GET,
            full_path,
            T,
            request_opts,
        );
    }

    pub fn costs(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.CostsResult) {
        return self.getUsage(allocator, "/organization/costs", params, gen.CostsResult);
    }

    pub fn costs_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CostsResult) {
        return self.getUsageWithOptions(allocator, "/organization/costs", params, gen.CostsResult, request_opts);
    }

    pub fn usage_costs(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.CostsResult) {
        return self.costs(allocator, params);
    }

    pub fn usage_costs_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CostsResult) {
        return self.costs_with_options(allocator, params, request_opts);
    }

    pub fn audio_speeches(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageAudioSpeechesResult) {
        return self.getUsage(allocator, "/organization/usage/audio_speeches", params, gen.UsageAudioSpeechesResult);
    }

    pub fn audio_speeches_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageAudioSpeechesResult) {
        return self.getUsageWithOptions(
            allocator,
            "/organization/usage/audio_speeches",
            params,
            gen.UsageAudioSpeechesResult,
            request_opts,
        );
    }

    pub fn usage_audio_speeches(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageAudioSpeechesResult) {
        return self.audio_speeches(allocator, params);
    }

    pub fn usage_audio_speeches_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageAudioSpeechesResult) {
        return self.audio_speeches_with_options(allocator, params, request_opts);
    }

    pub fn audio_transcriptions(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageAudioTranscriptionsResult) {
        return self.getUsage(allocator, "/organization/usage/audio_transcriptions", params, gen.UsageAudioTranscriptionsResult);
    }

    pub fn audio_transcriptions_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageAudioTranscriptionsResult) {
        return self.getUsageWithOptions(
            allocator,
            "/organization/usage/audio_transcriptions",
            params,
            gen.UsageAudioTranscriptionsResult,
            request_opts,
        );
    }

    pub fn usage_audio_transcriptions(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageAudioTranscriptionsResult) {
        return self.audio_transcriptions(allocator, params);
    }

    pub fn usage_audio_transcriptions_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageAudioTranscriptionsResult) {
        return self.audio_transcriptions_with_options(allocator, params, request_opts);
    }

    pub fn code_interpreter_sessions(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageCodeInterpreterSessionsResult) {
        return self.getUsage(allocator, "/organization/usage/code_interpreter_sessions", params, gen.UsageCodeInterpreterSessionsResult);
    }

    pub fn code_interpreter_sessions_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageCodeInterpreterSessionsResult) {
        return self.getUsageWithOptions(
            allocator,
            "/organization/usage/code_interpreter_sessions",
            params,
            gen.UsageCodeInterpreterSessionsResult,
            request_opts,
        );
    }

    pub fn usage_code_interpreter_sessions(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageCodeInterpreterSessionsResult) {
        return self.code_interpreter_sessions(allocator, params);
    }

    pub fn usage_code_interpreter_sessions_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageCodeInterpreterSessionsResult) {
        return self.code_interpreter_sessions_with_options(allocator, params, request_opts);
    }

    pub fn completions(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageCompletionsResult) {
        return self.getUsage(allocator, "/organization/usage/completions", params, gen.UsageCompletionsResult);
    }

    pub fn completions_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageCompletionsResult) {
        return self.getUsageWithOptions(
            allocator,
            "/organization/usage/completions",
            params,
            gen.UsageCompletionsResult,
            request_opts,
        );
    }

    pub fn usage_completions(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageCompletionsResult) {
        return self.completions(allocator, params);
    }

    pub fn usage_completions_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageCompletionsResult) {
        return self.completions_with_options(allocator, params, request_opts);
    }

    pub fn embeddings(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageEmbeddingsResult) {
        return self.getUsage(allocator, "/organization/usage/embeddings", params, gen.UsageEmbeddingsResult);
    }

    pub fn embeddings_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageEmbeddingsResult) {
        return self.getUsageWithOptions(
            allocator,
            "/organization/usage/embeddings",
            params,
            gen.UsageEmbeddingsResult,
            request_opts,
        );
    }

    pub fn usage_embeddings(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageEmbeddingsResult) {
        return self.embeddings(allocator, params);
    }

    pub fn usage_embeddings_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageEmbeddingsResult) {
        return self.embeddings_with_options(allocator, params, request_opts);
    }

    pub fn images(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageImagesResult) {
        return self.getUsage(allocator, "/organization/usage/images", params, gen.UsageImagesResult);
    }

    pub fn images_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageImagesResult) {
        return self.getUsageWithOptions(allocator, "/organization/usage/images", params, gen.UsageImagesResult, request_opts);
    }

    pub fn usage_images(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageImagesResult) {
        return self.images(allocator, params);
    }

    pub fn usage_images_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageImagesResult) {
        return self.images_with_options(allocator, params, request_opts);
    }

    pub fn moderations(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageModerationsResult) {
        return self.getUsage(allocator, "/organization/usage/moderations", params, gen.UsageModerationsResult);
    }

    pub fn moderations_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageModerationsResult) {
        return self.getUsageWithOptions(
            allocator,
            "/organization/usage/moderations",
            params,
            gen.UsageModerationsResult,
            request_opts,
        );
    }

    pub fn usage_moderations(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageModerationsResult) {
        return self.moderations(allocator, params);
    }

    pub fn usage_moderations_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageModerationsResult) {
        return self.moderations_with_options(allocator, params, request_opts);
    }

    pub fn vector_stores(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageVectorStoresResult) {
        return self.getUsage(allocator, "/organization/usage/vector_stores", params, gen.UsageVectorStoresResult);
    }

    pub fn vector_stores_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageVectorStoresResult) {
        return self.getUsageWithOptions(
            allocator,
            "/organization/usage/vector_stores",
            params,
            gen.UsageVectorStoresResult,
            request_opts,
        );
    }

    pub fn usage_vector_stores(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageVectorStoresResult) {
        return self.vector_stores(allocator, params);
    }

    pub fn usage_vector_stores_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageVectorStoresResult) {
        return self.vector_stores_with_options(allocator, params, request_opts);
    }

    pub fn list_costs(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
    ) errors.Error!std.json.Parsed(gen.CostsResult) {
        return self.costs(allocator, params);
    }

    pub fn list_costs_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CostsResult) {
        return self.costs_with_options(allocator, params, request_opts);
    }

    pub fn list_audio_speeches(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
    ) errors.Error!std.json.Parsed(gen.UsageAudioSpeechesResult) {
        return self.audio_speeches(allocator, params);
    }

    pub fn list_audio_speeches_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageAudioSpeechesResult) {
        return self.audio_speeches_with_options(allocator, params, request_opts);
    }

    pub fn list_audio_transcriptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
    ) errors.Error!std.json.Parsed(gen.UsageAudioTranscriptionsResult) {
        return self.audio_transcriptions(allocator, params);
    }

    pub fn list_audio_transcriptions_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageAudioTranscriptionsResult) {
        return self.audio_transcriptions_with_options(allocator, params, request_opts);
    }

    pub fn list_code_interpreter_sessions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
    ) errors.Error!std.json.Parsed(gen.UsageCodeInterpreterSessionsResult) {
        return self.code_interpreter_sessions(allocator, params);
    }

    pub fn list_code_interpreter_sessions_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageCodeInterpreterSessionsResult) {
        return self.code_interpreter_sessions_with_options(allocator, params, request_opts);
    }

    pub fn list_completions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
    ) errors.Error!std.json.Parsed(gen.UsageCompletionsResult) {
        return self.completions(allocator, params);
    }

    pub fn list_completions_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageCompletionsResult) {
        return self.completions_with_options(allocator, params, request_opts);
    }

    pub fn list_embeddings(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
    ) errors.Error!std.json.Parsed(gen.UsageEmbeddingsResult) {
        return self.embeddings(allocator, params);
    }

    pub fn list_embeddings_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageEmbeddingsResult) {
        return self.embeddings_with_options(allocator, params, request_opts);
    }

    pub fn list_images(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
    ) errors.Error!std.json.Parsed(gen.UsageImagesResult) {
        return self.images(allocator, params);
    }

    pub fn list_images_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageImagesResult) {
        return self.images_with_options(allocator, params, request_opts);
    }

    pub fn list_moderations(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
    ) errors.Error!std.json.Parsed(gen.UsageModerationsResult) {
        return self.moderations(allocator, params);
    }

    pub fn list_moderations_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageModerationsResult) {
        return self.moderations_with_options(allocator, params, request_opts);
    }

    pub fn list_vector_stores(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
    ) errors.Error!std.json.Parsed(gen.UsageVectorStoresResult) {
        return self.vector_stores(allocator, params);
    }

    pub fn list_vector_stores_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: UsageParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.UsageVectorStoresResult) {
        return self.vector_stores_with_options(allocator, params, request_opts);
    }

    test "usage buildPath encodes query params" {
        var buf: [256]u8 = undefined;
        const path = try buildPath(&buf, "/organization/costs", .{
            .start_time = 10,
            .end_time = 20,
            .limit = 7,
        });
        try std.testing.expectEqualStrings(
            "/organization/costs?start_time=10&end_time=20&limit=7",
            path,
        );
    }
};
