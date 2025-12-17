const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");

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

        const parsed = std.json.parseFromSlice(gen.CreateTranscriptionResponseJson, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
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

        const parsed = std.json.parseFromSlice(gen.CreateTranslationResponseJson, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
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

        const parsed = std.json.parseFromSlice(gen.VoiceConsentResource, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
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

        var sep: []const u8 = "?";
        if (params.after) |after| {
            try writer.print("{s}after={s}", .{ sep, after });
            sep = "&";
        }
        if (params.limit) |limit| {
            try writer.print("{s}limit={d}", .{ sep, limit });
        }
        const path = fbs.getWritten();

        const resp = try self.transport.request(.GET, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.VoiceConsentListResource, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
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

        const parsed = std.json.parseFromSlice(gen.VoiceConsentResource, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
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

        const parsed = std.json.parseFromSlice(gen.VoiceConsentResource, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
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

        const parsed = std.json.parseFromSlice(gen.VoiceConsentDeletedResource, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
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

        const parsed = std.json.parseFromSlice(gen.VoiceResource, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }
};
