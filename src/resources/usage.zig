const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");

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

        var sep: []const u8 = "?";
        if (params.start_time) |start_time| {
            try writer.print("{s}start_time={d}", .{ sep, start_time });
            sep = "&";
        }
        if (params.end_time) |end_time| {
            try writer.print("{s}end_time={d}", .{ sep, end_time });
            sep = "&";
        }
        if (params.limit) |limit| {
            try writer.print("{s}limit={d}", .{ sep, limit });
        }
        return fbs.getWritten();
    }

    fn getUsage(self: *const Resource, allocator: std.mem.Allocator, path: []const u8, params: UsageParams, comptime T: type) errors.Error!std.json.Parsed(T) {
        var buf: [256]u8 = undefined;
        const full_path = buildPath(&buf, path, params) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.GET, full_path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(T, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    pub fn costs(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.CostsResult) {
        return self.getUsage(allocator, "/organization/costs", params, gen.CostsResult);
    }

    pub fn audio_speeches(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageAudioSpeechesResult) {
        return self.getUsage(allocator, "/organization/usage/audio_speeches", params, gen.UsageAudioSpeechesResult);
    }

    pub fn audio_transcriptions(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageAudioTranscriptionsResult) {
        return self.getUsage(allocator, "/organization/usage/audio_transcriptions", params, gen.UsageAudioTranscriptionsResult);
    }

    pub fn code_interpreter_sessions(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageCodeInterpreterSessionsResult) {
        return self.getUsage(allocator, "/organization/usage/code_interpreter_sessions", params, gen.UsageCodeInterpreterSessionsResult);
    }

    pub fn completions(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageCompletionsResult) {
        return self.getUsage(allocator, "/organization/usage/completions", params, gen.UsageCompletionsResult);
    }

    pub fn embeddings(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageEmbeddingsResult) {
        return self.getUsage(allocator, "/organization/usage/embeddings", params, gen.UsageEmbeddingsResult);
    }

    pub fn images(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageImagesResult) {
        return self.getUsage(allocator, "/organization/usage/images", params, gen.UsageImagesResult);
    }

    pub fn moderations(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageModerationsResult) {
        return self.getUsage(allocator, "/organization/usage/moderations", params, gen.UsageModerationsResult);
    }

    pub fn vector_stores(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(gen.UsageVectorStoresResult) {
        return self.getUsage(allocator, "/organization/usage/vector_stores", params, gen.UsageVectorStoresResult);
    }
};
