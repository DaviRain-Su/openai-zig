const std = @import("std");
const transport_mod = @import("../transport/http.zig");
const errors = @import("../errors.zig");

/// Send a JSON request and parse into the provided type.
pub inline fn sendJsonTyped(
    transport: *transport_mod.Transport,
    allocator: std.mem.Allocator,
    method: std.http.Method,
    path: []const u8,
    value: anytype,
    comptime T: type,
) errors.Error!std.json.Parsed(T) {
    var body_writer: std.io.Writer.Allocating = .init(allocator);
    defer body_writer.deinit();
    var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
    json_stream.write(value) catch {
        return errors.Error.SerializeError;
    };
    const payload = body_writer.written();

    const resp = try transport.request(method, path, &.{
        .{ .name = "Accept", .value = "application/json" },
        .{ .name = "Content-Type", .value = "application/json" },
    }, payload);
    const body = resp.body;
    defer transport.allocator.free(body);

    const parsed = std.json.parseFromSlice(T, allocator, body, .{
        .ignore_unknown_fields = true,
    }) catch {
        return errors.Error.DeserializeError;
    };
    return parsed;
}

/// Send a request without a body and parse into the provided type.
pub inline fn sendNoBodyTyped(
    transport: *transport_mod.Transport,
    allocator: std.mem.Allocator,
    method: std.http.Method,
    path: []const u8,
    comptime T: type,
) errors.Error!std.json.Parsed(T) {
    const resp = try transport.request(method, path, &.{
        .{ .name = "Accept", .value = "application/json" },
    }, null);
    const body = resp.body;
    defer transport.allocator.free(body);

    const parsed = std.json.parseFromSlice(T, allocator, body, .{
        .ignore_unknown_fields = true,
    }) catch {
        return errors.Error.DeserializeError;
    };
    return parsed;
}

pub fn appendQueryParam(
    writer: anytype,
    first: *bool,
    key: []const u8,
    value: []const u8,
) errors.Error!void {
    var mutable_writer = writer;
    if (first.*) {
        mutable_writer.writeAll("?") catch {
            return errors.Error.SerializeError;
        };
        first.* = false;
    } else {
        mutable_writer.writeAll("&") catch {
            return errors.Error.SerializeError;
        };
    }
    mutable_writer.writeAll(key) catch {
        return errors.Error.SerializeError;
    };
    mutable_writer.writeAll("=") catch {
        return errors.Error.SerializeError;
    };
    mutable_writer.writeAll(value) catch {
        return errors.Error.SerializeError;
    };
}

pub fn appendOptionalQueryParam(
    writer: anytype,
    first: *bool,
    key: []const u8,
    value: ?[]const u8,
) errors.Error!void {
    if (value) |v| {
        try appendQueryParam(writer, first, key, v);
    }
}

pub fn appendOptionalQueryParamU64(
    writer: anytype,
    first: *bool,
    key: []const u8,
    value: ?u64,
) errors.Error!void {
    if (value) |v| {
        var buf: [32]u8 = undefined;
        const token = try std.fmt.bufPrint(&buf, "{d}", .{v});
        try appendQueryParam(writer, first, key, token);
    }
}

pub fn appendOptionalQueryParamBool(
    writer: anytype,
    first: *bool,
    key: []const u8,
    value: ?bool,
) errors.Error!void {
    if (value) |v| {
        if (v) {
            try appendQueryParam(writer, first, key, "true");
        } else {
            try appendQueryParam(writer, first, key, "false");
        }
    }
}

pub fn appendOptionalQueryParamList(
    writer: anytype,
    first: *bool,
    key: []const u8,
    values: ?[]const []const u8,
) errors.Error!void {
    if (values) |vals| {
        for (vals) |v| {
            try appendQueryParam(writer, first, key, v);
        }
    }
}
