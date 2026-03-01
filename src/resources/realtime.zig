const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn sendJsonTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        path: []const u8,
        body: anytype,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendJsonTyped(self.transport, allocator, .POST, path, body, T);
    }

    fn sendJsonValue(
        self: *const Resource,
        allocator: std.mem.Allocator,
        path: []const u8,
        body: anytype,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(body) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        const resp = try self.transport.request(.POST, path, &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = "application/json" },
        }, payload);
        const response_body = resp.body;
        defer self.transport.allocator.free(response_body);

        const body_to_parse = if (response_body.len == 0) "null" else response_body;
        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body_to_parse, .{
            .ignore_unknown_fields = true,
        }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    fn sendNoBodyValueOrNull(
        self: *const Resource,
        allocator: std.mem.Allocator,
        path: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        const resp = try self.transport.request(.POST, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const response_body = resp.body;
        defer self.transport.allocator.free(response_body);

        const body_to_parse = if (response_body.len == 0) "null" else response_body;
        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body_to_parse, .{
            .ignore_unknown_fields = true,
        }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    fn createCallPayload(
        _: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.RealtimeCallCreateRequest,
    ) errors.Error![]u8 {
        var multipart = std.ArrayList(u8).init(allocator);
        defer multipart.deinit();
        const writer = multipart.writer();
        const boundary = "realtime-call-boundary-0f9e";

        try writer.writeAll("--");
        try writer.writeAll(boundary);
        try writer.writeAll("\r\n");
        try writer.writeAll("Content-Disposition: form-data; name=\"sdp\"\r\n");
        try writer.writeAll("Content-Type: application/sdp\r\n");
        try writer.writeAll("\r\n");
        try writer.writeAll(body.sdp);
        try writer.writeAll("\r\n");

        if (body.session) |session| {
            try writer.writeAll("--");
            try writer.writeAll(boundary);
            try writer.writeAll("\r\n");
            try writer.writeAll("Content-Disposition: form-data; name=\"session\"\r\n");
            try writer.writeAll("Content-Type: application/json\r\n");
            try writer.writeAll("\r\n");
            var session_stream: std.json.Stringify = .{ .writer = writer, .options = .{} };
            session_stream.write(session) catch {
                return errors.Error.SerializeError;
            };
            try writer.writeAll("\r\n");
        }

        try writer.writeAll("--");
        try writer.writeAll(boundary);
        try writer.writeAll("--\r\n");

        return try multipart.toOwnedSlice();
    }

    pub fn create_realtime_call(self: *const Resource, allocator: std.mem.Allocator, body: gen.RealtimeCallCreateRequest) errors.Error![]u8 {
        if (body.session == null) {
            const headers = [_]std.http.Header{
                .{ .name = "Accept", .value = "application/sdp" },
                .{ .name = "Content-Type", .value = "application/sdp" },
            };

            const resp = try self.transport.request(.POST, "/realtime/calls", &headers, body.sdp);
            return resp.body;
        }

        const headers = [_]std.http.Header{
            .{ .name = "Accept", .value = "application/sdp" },
            .{ .name = "Content-Type", .value = "multipart/form-data; boundary=realtime-call-boundary-0f9e" },
        };
        const payload = try self.createCallPayload(allocator, body);
        defer allocator.free(payload);
        const resp = try self.transport.request(.POST, "/realtime/calls", &headers, payload);
        return resp.body;
    }

    /// POST /realtime/calls
    pub fn create_call(self: *const Resource, allocator: std.mem.Allocator, body: gen.RealtimeCallCreateRequest) errors.Error![]u8 {
        return self.create_realtime_call(allocator, body);
    }

    pub fn accept_realtime_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: gen.RealtimeSessionCreateRequestGA,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/realtime/calls/{s}/accept", .{call_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonValue(allocator, path, body);
    }

    /// POST /realtime/calls/{call_id}/accept
    pub fn accept_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: gen.RealtimeSessionCreateRequestGA,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.accept_realtime_call(allocator, call_id, body);
    }

    pub fn hangup_realtime_call(self: *const Resource, allocator: std.mem.Allocator, call_id: []const u8) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/realtime/calls/{s}/hangup", .{call_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyValueOrNull(allocator, path);
    }

    /// POST /realtime/calls/{call_id}/hangup
    pub fn hangup_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.hangup_realtime_call(allocator, call_id);
    }

    pub fn refer_realtime_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: gen.RealtimeCallReferRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/realtime/calls/{s}/refer", .{call_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonValue(allocator, path, body);
    }

    /// POST /realtime/calls/{call_id}/refer
    pub fn refer_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: gen.RealtimeCallReferRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.refer_realtime_call(allocator, call_id, body);
    }

    pub fn reject_realtime_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: ?gen.RealtimeCallRejectRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/realtime/calls/{s}/reject", .{call_id}) catch {
            return errors.Error.SerializeError;
        };
        if (body) |payload| {
            return self.sendJsonValue(allocator, path, payload);
        }
        return self.sendNoBodyValueOrNull(allocator, path);
    }

    /// POST /realtime/calls/{call_id}/reject
    pub fn reject_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: ?gen.RealtimeCallRejectRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.reject_realtime_call(allocator, call_id, body);
    }

    pub fn create_realtime_client_secret(self: *const Resource, allocator: std.mem.Allocator, body: gen.RealtimeCreateClientSecretRequest) errors.Error!std.json.Parsed(gen.RealtimeCreateClientSecretResponse) {
        return self.sendJsonTyped(allocator, "/realtime/client_secrets", body, gen.RealtimeCreateClientSecretResponse);
    }

    /// POST /realtime/client_secrets
    pub fn create_client_secret(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.RealtimeCreateClientSecretRequest,
    ) errors.Error!std.json.Parsed(gen.RealtimeCreateClientSecretResponse) {
        return self.create_realtime_client_secret(allocator, body);
    }

    pub fn create_realtime_session(self: *const Resource, allocator: std.mem.Allocator, body: gen.RealtimeSessionCreateRequest) errors.Error!std.json.Parsed(gen.RealtimeSessionCreateResponse) {
        return self.sendJsonTyped(allocator, "/realtime/sessions", body, gen.RealtimeSessionCreateResponse);
    }

    /// POST /realtime/sessions
    pub fn create_session(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.RealtimeSessionCreateRequest,
    ) errors.Error!std.json.Parsed(gen.RealtimeSessionCreateResponse) {
        return self.create_realtime_session(allocator, body);
    }

    pub fn create_realtime_transcription_session(self: *const Resource, allocator: std.mem.Allocator, body: gen.RealtimeTranscriptionSessionCreateRequest) errors.Error!std.json.Parsed(gen.RealtimeTranscriptionSessionCreateResponse) {
        return self.sendJsonTyped(allocator, "/realtime/transcription_sessions", body, gen.RealtimeTranscriptionSessionCreateResponse);
    }

    /// POST /realtime/transcription_sessions
    pub fn create_transcription_session(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.RealtimeTranscriptionSessionCreateRequest,
    ) errors.Error!std.json.Parsed(gen.RealtimeTranscriptionSessionCreateResponse) {
        return self.create_realtime_transcription_session(allocator, body);
    }
};
