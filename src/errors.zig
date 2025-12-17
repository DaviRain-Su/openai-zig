const std = @import("std");

/// Shared error set for client operations.
pub const Error = error{
    HttpError,
    DeserializeError,
    SerializeError,
    Timeout,
    Unimplemented,
};

/// HTTP-level error payload, if the API returns a JSON error object.
pub const ApiError = struct {
    message: []const u8,
    type: ?[]const u8 = null,
    param: ?[]const u8 = null,
    code: ?[]const u8 = null,
};

/// Response wrapper that keeps both status and body text for diagnostics.
pub const HttpErrorDetail = struct {
    status: u16,
    body: []const u8,
};

pub fn unexpectedStatus(detail: HttpErrorDetail) Error {
    std.debug.print("http status {d}, body: {s}\n", .{ detail.status, detail.body });
    return Error.HttpError;
}

pub fn unimplemented(comptime feature: []const u8) Error {
    std.debug.print("feature not implemented: {s}\n", .{feature});
    return Error.Unimplemented;
}
