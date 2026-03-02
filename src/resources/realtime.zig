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
        return self.sendJsonTypedWithOptions(allocator, path, body, T, null);
    }

    fn sendJsonTypedWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        path: []const u8,
        body: anytype,
        comptime T: type,
        req_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendJsonTypedWithOptions(self.transport, allocator, .POST, path, body, T, req_opts);
    }

    fn sendNoBodyValueOrNull(
        self: *const Resource,
        allocator: std.mem.Allocator,
        path: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendNoBodyValueOrNullWithOptions(allocator, path, null);
    }

    fn sendNoBodyValueOrNullWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        path: []const u8,
        req_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return common.sendValueOrNullWithOptions(
            self.transport,
            allocator,
            .POST,
            path,
            &.{
                .{ .name = "Accept", .value = "application/json" },
            },
            null,
            req_opts,
        );
    }

    fn createCallPayload(
        _: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.RealtimeCallCreateRequest,
    ) errors.Error![]u8 {
        var multipart = std.ArrayList(u8).initCapacity(allocator, 0) catch {
            return errors.Error.SerializeError;
        };
        defer multipart.deinit(allocator);
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
            var session_stream: std.json.Stringify = .{
                .writer = writer,
                .options = .{ .emit_null_optional_fields = false },
            };
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

    pub fn create_realtime_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.RealtimeCallCreateRequest,
    ) errors.Error![]u8 {
        return self.create_realtime_call_with_options(allocator, body, null);
    }

    pub fn create_realtime_call_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.RealtimeCallCreateRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error![]u8 {
        if (body.session == null) {
            const headers = [_]std.http.Header{
                .{ .name = "Accept", .value = "application/sdp" },
                .{ .name = "Content-Type", .value = "application/sdp" },
            };

            return try common.sendBinaryWithOptions(
                self.transport,
                .POST,
                "/realtime/calls",
                &headers,
                body.sdp,
                request_opts,
            );
        }

        const headers = [_]std.http.Header{
            .{ .name = "Accept", .value = "application/sdp" },
            .{ .name = "Content-Type", .value = "multipart/form-data; boundary=realtime-call-boundary-0f9e" },
        };
        const payload = try self.createCallPayload(allocator, body);
        defer allocator.free(payload);
        return try common.sendBinaryWithOptions(
            self.transport,
            .POST,
            "/realtime/calls",
            &headers,
            payload,
            request_opts,
        );
    }

    /// POST /realtime/calls
    pub fn create_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.RealtimeCallCreateRequest,
    ) errors.Error![]u8 {
        return self.create_realtime_call(allocator, body);
    }

    pub fn create_call_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.RealtimeCallCreateRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error![]u8 {
        return self.create_realtime_call_with_options(allocator, body, request_opts);
    }

    pub fn create_realtime_session(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.RealtimeSessionCreateRequest,
    ) errors.Error!std.json.Parsed(gen.RealtimeSessionCreateResponse) {
        return self.create_realtime_session_with_options(allocator, body, null);
    }

    pub fn create_realtime_session_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.RealtimeSessionCreateRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.RealtimeSessionCreateResponse) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            "/realtime/sessions",
            body,
            gen.RealtimeSessionCreateResponse,
            request_opts,
        );
    }

    pub fn create_realtime_transcription_session(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.RealtimeTranscriptionSessionCreateRequest,
    ) errors.Error!std.json.Parsed(gen.RealtimeTranscriptionSessionCreateResponse) {
        return self.create_realtime_transcription_session_with_options(allocator, body, null);
    }

    pub fn create_realtime_transcription_session_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.RealtimeTranscriptionSessionCreateRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.RealtimeTranscriptionSessionCreateResponse) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            "/realtime/transcription_sessions",
            body,
            gen.RealtimeTranscriptionSessionCreateResponse,
            request_opts,
        );
    }

    pub fn accept_realtime_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: gen.RealtimeSessionCreateRequestGA,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.accept_realtime_call_with_options(allocator, call_id, body, null);
    }

    pub fn accept_realtime_call_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: gen.RealtimeSessionCreateRequestGA,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/realtime/calls/{s}/accept", .{call_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(allocator, path, body, std.json.Value, request_opts);
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

    pub fn accept_call_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: gen.RealtimeSessionCreateRequestGA,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.accept_realtime_call_with_options(allocator, call_id, body, request_opts);
    }

    pub fn hangup_realtime_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.hangup_realtime_call_with_options(allocator, call_id, null);
    }

    pub fn hangup_realtime_call_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/realtime/calls/{s}/hangup", .{call_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyValueOrNullWithOptions(allocator, path, request_opts);
    }

    /// POST /realtime/calls/{call_id}/hangup
    pub fn hangup_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.hangup_realtime_call(allocator, call_id);
    }

    pub fn hangup_call_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.hangup_realtime_call_with_options(allocator, call_id, request_opts);
    }

    pub fn refer_realtime_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: gen.RealtimeCallReferRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.refer_realtime_call_with_options(allocator, call_id, body, null);
    }

    pub fn refer_realtime_call_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: gen.RealtimeCallReferRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/realtime/calls/{s}/refer", .{call_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(allocator, path, body, std.json.Value, request_opts);
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

    pub fn refer_call_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: gen.RealtimeCallReferRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.refer_realtime_call_with_options(allocator, call_id, body, request_opts);
    }

    pub fn reject_realtime_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: ?gen.RealtimeCallRejectRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.reject_realtime_call_with_options(allocator, call_id, body, null);
    }

    pub fn reject_realtime_call_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: ?gen.RealtimeCallRejectRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/realtime/calls/{s}/reject", .{call_id}) catch {
            return errors.Error.SerializeError;
        };
        if (body) |payload| {
            return self.sendJsonTypedWithOptions(allocator, path, payload, std.json.Value, request_opts);
        }
        return self.sendNoBodyValueOrNullWithOptions(allocator, path, request_opts);
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

    pub fn reject_call_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: ?gen.RealtimeCallRejectRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        return self.reject_realtime_call_with_options(allocator, call_id, body, request_opts);
    }

    pub fn create_realtime_client_secret(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.RealtimeCreateClientSecretRequest,
    ) errors.Error!std.json.Parsed(gen.RealtimeCreateClientSecretResponse) {
        return self.create_realtime_client_secret_with_options(allocator, body, null);
    }

    pub fn create_realtime_client_secret_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.RealtimeCreateClientSecretRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.RealtimeCreateClientSecretResponse) {
        return self.sendJsonTypedWithOptions(allocator, "/realtime/client_secrets", body, gen.RealtimeCreateClientSecretResponse, request_opts);
    }

    /// POST /realtime/client_secrets
    pub fn create_client_secret(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.RealtimeCreateClientSecretRequest,
    ) errors.Error!std.json.Parsed(gen.RealtimeCreateClientSecretResponse) {
        return self.create_realtime_client_secret(allocator, body);
    }

    pub fn create_client_secret_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.RealtimeCreateClientSecretRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.RealtimeCreateClientSecretResponse) {
        return self.create_realtime_client_secret_with_options(allocator, body, request_opts);
    }
};
