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

    const parsed = std.json.parseFromSlice(T, allocator, body, .{}) catch {
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

    const parsed = std.json.parseFromSlice(T, allocator, body, .{}) catch {
        return errors.Error.DeserializeError;
    };
    return parsed;
}
