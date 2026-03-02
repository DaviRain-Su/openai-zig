const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

/// Request payload for POST /audio/speech (text-to-speech).
pub const CreateSpeechRequest = gen.CreateSpeechRequest;

/// Generic representation of a multipart/form-data payload. The caller is responsible
/// for constructing a valid body and boundary string.
pub const MultipartRequest = struct {
    content_type: []const u8,
    body: []const u8,
};

/// Binary audio response owner.
pub const BinaryResponse = struct {
    allocator: std.mem.Allocator,
    data: []u8,

    pub fn deinit(self: *BinaryResponse) void {
        self.allocator.free(self.data);
    }
};

/// Query params for listing voice consents.
pub const ListVoiceConsentsParams = struct {
    after: ?[]const u8 = null,
    limit: ?u32 = null,
};

/// Request body for updating an existing voice consent.
pub const UpdateVoiceConsentRequest = gen.UpdateVoiceConsentRequest;

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn sendJsonTypedWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
        comptime T: type,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendJsonTypedWithOptions(self.transport, allocator, method, path, value, T, request_opts);
    }

    fn sendNoBodyTypedWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendNoBodyTypedWithOptions(self.transport, allocator, method, path, T, request_opts);
    }

    fn sendMultipartWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        payload: MultipartRequest,
        comptime T: type,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendMultipartTypedWithOptions(
            self.transport,
            allocator,
            method,
            path,
            payload,
            T,
            request_opts,
        );
    }

    fn sendBinaryWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        body: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!BinaryResponse {
        _ = allocator;
        const response_body = try common.sendBinaryWithOptions(
            self.transport,
            method,
            path,
            &.{.{ .name = "Content-Type", .value = "application/json" }},
            body,
            request_opts,
        );
        return .{
            .allocator = self.transport.allocator,
            .data = response_body,
        };
    }

    /// POST /audio/speech -> binary audio payload.
    pub fn create_speech(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateSpeechRequest,
    ) errors.Error!BinaryResponse {
        return self.create_speech_with_options(allocator, req, null);
    }

    pub fn create_speech_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateSpeechRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!BinaryResponse {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{
            .writer = &body_writer.writer,
            .options = .{ .emit_null_optional_fields = false },
        };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();
        return self.sendBinaryWithOptions(allocator, .POST, "/audio/speech", payload, request_opts);
    }

    /// POST /audio/speech -> binary audio payload.
    pub fn speech(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateSpeechRequest,
    ) errors.Error!BinaryResponse {
        return self.create_speech(allocator, req);
    }

    pub fn speech_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateSpeechRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!BinaryResponse {
        return self.create_speech_with_options(allocator, req, request_opts);
    }

    /// POST /audio/transcriptions (multipart form-data, caller builds payload).
    pub fn create_transcription(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.CreateTranscriptionResponseJson) {
        return self.create_transcription_with_options(allocator, payload, null);
    }

    pub fn create_transcription_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CreateTranscriptionResponseJson) {
        return self.sendMultipartWithOptions(allocator, .POST, "/audio/transcriptions", payload, gen.CreateTranscriptionResponseJson, request_opts);
    }

    /// POST /audio/transcriptions (multipart form-data, caller builds payload).
    pub fn transcriptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.CreateTranscriptionResponseJson) {
        return self.create_transcription(allocator, payload);
    }

    pub fn transcriptions_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CreateTranscriptionResponseJson) {
        return self.create_transcription_with_options(allocator, payload, request_opts);
    }

    /// POST /audio/translations (multipart form-data, caller builds payload).
    pub fn create_translation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.CreateTranslationResponseJson) {
        return self.create_translation_with_options(allocator, payload, null);
    }

    pub fn create_translation_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CreateTranslationResponseJson) {
        return self.sendMultipartWithOptions(allocator, .POST, "/audio/translations", payload, gen.CreateTranslationResponseJson, request_opts);
    }

    /// POST /audio/translations (multipart form-data, caller builds payload).
    pub fn translations(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.CreateTranslationResponseJson) {
        return self.create_translation(allocator, payload);
    }

    pub fn translations_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CreateTranslationResponseJson) {
        return self.create_translation_with_options(allocator, payload, request_opts);
    }

    /// POST /audio/voice_consents (multipart form-data).
    pub fn create_voice_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.create_voice_consent_with_options(allocator, payload, null);
    }

    pub fn create_voice_consent_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.sendMultipartWithOptions(allocator, .POST, "/audio/voice_consents", payload, gen.VoiceConsentResource, request_opts);
    }

    /// POST /audio/voice_consents (multipart form-data).
    pub fn create_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.create_voice_consent(allocator, payload);
    }

    pub fn create_consent_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.create_voice_consent_with_options(allocator, payload, request_opts);
    }

    /// GET /audio/voice_consents
    pub fn list_voice_consents(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListVoiceConsentsParams,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentListResource) {
        return self.list_voice_consents_with_options(allocator, params, null);
    }

    pub fn list_voice_consents_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListVoiceConsentsParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentListResource) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const writer = fbs.writer();
        try writer.writeAll("/audio/voice_consents");

        var first = true;
        if (params.after) |after| {
            try common.appendQueryParam(writer, &first, "after", after);
        }
        if (params.limit) |limit| {
            var limit_buf: [32]u8 = undefined;
            const limit_value = try std.fmt.bufPrint(&limit_buf, "{d}", .{limit});
            try common.appendQueryParam(writer, &first, "limit", limit_value);
        }
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.VoiceConsentListResource, request_opts);
    }

    /// GET /audio/voice_consents
    pub fn list_consents(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListVoiceConsentsParams,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentListResource) {
        return self.list_voice_consents(allocator, params);
    }

    pub fn list_consents_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListVoiceConsentsParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentListResource) {
        return self.list_voice_consents_with_options(allocator, params, request_opts);
    }

    /// GET /audio/voice_consents/{consent_id}
    pub fn get_voice_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.get_voice_consent_with_options(allocator, consent_id, null);
    }

    pub fn get_voice_consent_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/audio/voice_consents/{s}", .{consent_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.VoiceConsentResource, request_opts);
    }

    /// GET /audio/voice_consents/{consent_id}
    pub fn get_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.get_voice_consent(allocator, consent_id);
    }

    pub fn get_consent_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.get_voice_consent_with_options(allocator, consent_id, request_opts);
    }

    /// GET /audio/voice_consents/{consent_id}
    pub fn retrieve_voice_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.get_voice_consent(allocator, consent_id);
    }

    pub fn retrieve_voice_consent_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.get_voice_consent_with_options(allocator, consent_id, request_opts);
    }

    /// POST /audio/voice_consents/{consent_id}
    pub fn update_voice_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
        req: UpdateVoiceConsentRequest,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.update_voice_consent_with_options(allocator, consent_id, req, null);
    }

    pub fn update_voice_consent_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
        req: UpdateVoiceConsentRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/audio/voice_consents/{s}", .{consent_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(allocator, .POST, path, req, gen.VoiceConsentResource, request_opts);
    }

    /// POST /audio/voice_consents/{consent_id}
    pub fn modify_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
        req: UpdateVoiceConsentRequest,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.update_voice_consent(allocator, consent_id, req);
    }

    pub fn modify_consent_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
        req: UpdateVoiceConsentRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.update_voice_consent_with_options(allocator, consent_id, req, request_opts);
    }

    /// POST /audio/voice_consents/{consent_id}
    pub fn modify_voice_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
        req: UpdateVoiceConsentRequest,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.update_voice_consent(allocator, consent_id, req);
    }

    pub fn modify_voice_consent_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
        req: UpdateVoiceConsentRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.update_voice_consent_with_options(allocator, consent_id, req, request_opts);
    }

    /// DELETE /audio/voice_consents/{consent_id}
    pub fn delete_voice_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentDeletedResource) {
        return self.delete_voice_consent_with_options(allocator, consent_id, null);
    }

    pub fn delete_voice_consent_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentDeletedResource) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/audio/voice_consents/{s}", .{consent_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .DELETE, path, gen.VoiceConsentDeletedResource, request_opts);
    }

    /// DELETE /audio/voice_consents/{consent_id}
    pub fn delete_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentDeletedResource) {
        return self.delete_voice_consent(allocator, consent_id);
    }

    pub fn delete_consent_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentDeletedResource) {
        return self.delete_voice_consent_with_options(allocator, consent_id, request_opts);
    }

    /// POST /audio/voices (multipart form-data).
    pub fn create_voice(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.VoiceResource) {
        return self.create_voice_with_options(allocator, payload, null);
    }

    pub fn create_voice_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VoiceResource) {
        return self.sendMultipartWithOptions(allocator, .POST, "/audio/voices", payload, gen.VoiceResource, request_opts);
    }

    /// POST /audio/voices (multipart form-data).
    pub fn create_voices(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.VoiceResource) {
        return self.create_voice(allocator, payload);
    }

    pub fn create_voices_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.VoiceResource) {
        return self.create_voice_with_options(allocator, payload, request_opts);
    }
};
