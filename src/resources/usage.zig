const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

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

    fn getUsage(self: *const Resource, allocator: std.mem.Allocator, path: []const u8, params: UsageParams) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [256]u8 = undefined;
        const full_path = buildPath(&buf, path, params) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.GET, full_path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    pub fn costs(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(std.json.Value) {
        return self.getUsage(allocator, "/organization/costs", params);
    }

    pub fn audio_speeches(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(std.json.Value) {
        return self.getUsage(allocator, "/organization/usage/audio_speeches", params);
    }

    pub fn audio_transcriptions(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(std.json.Value) {
        return self.getUsage(allocator, "/organization/usage/audio_transcriptions", params);
    }

    pub fn code_interpreter_sessions(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(std.json.Value) {
        return self.getUsage(allocator, "/organization/usage/code_interpreter_sessions", params);
    }

    pub fn completions(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(std.json.Value) {
        return self.getUsage(allocator, "/organization/usage/completions", params);
    }

    pub fn embeddings(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(std.json.Value) {
        return self.getUsage(allocator, "/organization/usage/embeddings", params);
    }

    pub fn images(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(std.json.Value) {
        return self.getUsage(allocator, "/organization/usage/images", params);
    }

    pub fn moderations(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(std.json.Value) {
        return self.getUsage(allocator, "/organization/usage/moderations", params);
    }

    pub fn vector_stores(self: *const Resource, allocator: std.mem.Allocator, params: UsageParams) errors.Error!std.json.Parsed(std.json.Value) {
        return self.getUsage(allocator, "/organization/usage/vector_stores", params);
    }
};
