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

    pub fn create_realtime_call(self: *const Resource, allocator: std.mem.Allocator, body: gen.RealtimeCallCreateRequest) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJsonTyped(allocator, "/realtime/calls", body, std.json.Value);
    }

    pub fn accept_realtime_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/realtime/calls/{s}/accept", .{call_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, path, body, std.json.Value);
    }

    pub fn hangup_realtime_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/realtime/calls/{s}/hangup", .{call_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, path, body, std.json.Value);
    }

    pub fn refer_realtime_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/realtime/calls/{s}/refer", .{call_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, path, body, std.json.Value);
    }

    pub fn reject_realtime_call(
        self: *const Resource,
        allocator: std.mem.Allocator,
        call_id: []const u8,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/realtime/calls/{s}/reject", .{call_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTyped(allocator, path, body, std.json.Value);
    }

    pub fn create_realtime_client_secret(self: *const Resource, allocator: std.mem.Allocator, body: gen.RealtimeCreateClientSecretRequest) errors.Error!std.json.Parsed(gen.RealtimeCreateClientSecretResponse) {
        return self.sendJsonTyped(allocator, "/realtime/client_secrets", body, gen.RealtimeCreateClientSecretResponse);
    }

    pub fn create_realtime_session(self: *const Resource, allocator: std.mem.Allocator, body: gen.RealtimeSessionCreateRequest) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJsonTyped(allocator, "/realtime/sessions", body, std.json.Value);
    }

    pub fn create_realtime_transcription_session(self: *const Resource, allocator: std.mem.Allocator, body: gen.RealtimeTranscriptionSessionCreateRequest) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendJsonTyped(allocator, "/realtime/transcription_sessions", body, std.json.Value);
    }
};
