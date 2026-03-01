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
    return sendJsonTypedWithOptions(transport, allocator, method, path, value, T, null);
}

pub inline fn sendJsonTypedWithOptions(
    transport: *transport_mod.Transport,
    allocator: std.mem.Allocator,
    method: std.http.Method,
    path: []const u8,
    value: anytype,
    comptime T: type,
    req_opts: ?transport_mod.Transport.RequestOptions,
) errors.Error!std.json.Parsed(T) {
    var body_writer: std.io.Writer.Allocating = .init(allocator);
    defer body_writer.deinit();
    var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
    json_stream.write(value) catch {
        return errors.Error.SerializeError;
    };
    const payload = body_writer.written();

    const resp = try transport.requestWithOptions(method, path, &.{
        .{ .name = "Accept", .value = "application/json" },
        .{ .name = "Content-Type", .value = "application/json" },
    }, payload, req_opts);
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
    return sendNoBodyTypedWithOptions(transport, allocator, method, path, T, null);
}

pub inline fn sendNoBodyTypedWithOptions(
    transport: *transport_mod.Transport,
    allocator: std.mem.Allocator,
    method: std.http.Method,
    path: []const u8,
    comptime T: type,
    req_opts: ?transport_mod.Transport.RequestOptions,
) errors.Error!std.json.Parsed(T) {
    const resp = try transport.requestWithOptions(method, path, &.{
        .{ .name = "Accept", .value = "application/json" },
    }, null, req_opts);
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
    if (first.*) {
        writer.writeAll("?") catch {
            return errors.Error.SerializeError;
        };
        first.* = false;
    } else {
        writer.writeAll("&") catch {
            return errors.Error.SerializeError;
        };
    }
    try writeQueryComponent(writer, key);
    writer.writeAll("=") catch {
        return errors.Error.SerializeError;
    };
    try writeQueryComponent(writer, value);
}

fn writeQueryComponent(
    writer: anytype,
    component: []const u8,
) errors.Error!void {
    const hexdigits = "0123456789ABCDEF";
    for (component) |byte| {
        if (isQueryUnreserved(byte)) {
            writer.writeByte(byte) catch {
                return errors.Error.SerializeError;
            };
            continue;
        }

        const encoded = [_]u8{
            '%',
            hexdigits[(byte >> 4) & 0x0f],
            hexdigits[byte & 0x0f],
        };
        writer.writeAll(&encoded) catch {
            return errors.Error.SerializeError;
        };
    }
}

fn isQueryUnreserved(byte: u8) bool {
    return (byte >= 'a' and byte <= 'z') or
        (byte >= 'A' and byte <= 'Z') or
        (byte >= '0' and byte <= '9') or
        byte == '-' or
        byte == '.' or
        byte == '_' or
        byte == '~';
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
