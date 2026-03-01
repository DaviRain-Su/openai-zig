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

    /// POST /audio/speech -> binary audio payload.
    pub fn create_speech(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateSpeechRequest,
    ) errors.Error!BinaryResponse {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        const resp = try self.transport.request(.POST, "/audio/speech", &.{
            .{ .name = "Content-Type", .value = "application/json" },
        }, payload);

        // Transfer ownership of the response bytes to the caller for writing to disk.
        return BinaryResponse{
            .allocator = self.transport.allocator,
            .data = resp.body,
        };
    }

    /// POST /audio/speech -> binary audio payload.
    pub fn speech(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateSpeechRequest,
    ) errors.Error!BinaryResponse {
        return self.create_speech(allocator, req);
    }

    /// POST /audio/transcriptions (multipart form-data, caller builds payload).
    pub fn create_transcription(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.CreateTranscriptionResponseJson) {
        const resp = try self.transport.request(.POST, "/audio/transcriptions", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = payload.content_type },
        }, payload.body);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.CreateTranscriptionResponseJson, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /audio/transcriptions (multipart form-data, caller builds payload).
    pub fn transcriptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.CreateTranscriptionResponseJson) {
        return self.create_transcription(allocator, payload);
    }

    /// POST /audio/translations (multipart form-data, caller builds payload).
    pub fn create_translation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.CreateTranslationResponseJson) {
        const resp = try self.transport.request(.POST, "/audio/translations", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = payload.content_type },
        }, payload.body);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.CreateTranslationResponseJson, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /audio/translations (multipart form-data, caller builds payload).
    pub fn translations(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.CreateTranslationResponseJson) {
        return self.create_translation(allocator, payload);
    }

    /// POST /audio/voice_consents (multipart form-data).
    pub fn create_voice_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        const resp = try self.transport.request(.POST, "/audio/voice_consents", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = payload.content_type },
        }, payload.body);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.VoiceConsentResource, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /audio/voice_consents (multipart form-data).
    pub fn create_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.create_voice_consent(allocator, payload);
    }

    /// GET /audio/voice_consents
    pub fn list_voice_consents(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListVoiceConsentsParams,
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

        const resp = try self.transport.request(.GET, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.VoiceConsentListResource, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// GET /audio/voice_consents
    pub fn list_consents(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListVoiceConsentsParams,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentListResource) {
        return self.list_voice_consents(allocator, params);
    }

    /// GET /audio/voice_consents/{consent_id}
    pub fn get_voice_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/audio/voice_consents/{s}", .{consent_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.GET, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.VoiceConsentResource, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// GET /audio/voice_consents/{consent_id}
    pub fn get_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.get_voice_consent(allocator, consent_id);
    }

    /// GET /audio/voice_consents/{consent_id}
    pub fn retrieve_voice_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.get_voice_consent(allocator, consent_id);
    }

    /// POST /audio/voice_consents/{consent_id}
    pub fn update_voice_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
        req: UpdateVoiceConsentRequest,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/audio/voice_consents/{s}", .{consent_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.POST, path, &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = "application/json" },
        }, payload);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.VoiceConsentResource, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
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

    /// POST /audio/voice_consents/{consent_id}
    pub fn modify_voice_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
        req: UpdateVoiceConsentRequest,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentResource) {
        return self.update_voice_consent(allocator, consent_id, req);
    }

    /// DELETE /audio/voice_consents/{consent_id}
    pub fn delete_voice_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentDeletedResource) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/audio/voice_consents/{s}", .{consent_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.DELETE, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.VoiceConsentDeletedResource, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// DELETE /audio/voice_consents/{consent_id}
    pub fn delete_consent(
        self: *const Resource,
        allocator: std.mem.Allocator,
        consent_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.VoiceConsentDeletedResource) {
        return self.delete_voice_consent(allocator, consent_id);
    }

    /// POST /audio/voices (multipart form-data).
    pub fn create_voice(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.VoiceResource) {
        const resp = try self.transport.request(.POST, "/audio/voices", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = payload.content_type },
        }, payload.body);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.VoiceResource, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /audio/voices (multipart form-data).
    pub fn create_voices(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.VoiceResource) {
        return self.create_voice(allocator, payload);
    }
};
