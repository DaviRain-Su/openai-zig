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

const ApiErrorEnvelope = struct {
    message: ?[]const u8 = null,
    type: ?[]const u8 = null,
    param: ?[]const u8 = null,
    code: ?[]const u8 = null,
};

const ApiErrorResponse = struct {
    error: ?ApiErrorEnvelope = null,
    detail: ?[]const u8 = null,
};

/// Response wrapper that keeps both status and body text for diagnostics.
pub const HttpErrorDetail = struct {
    status: u16,
    body: []const u8,
};

pub fn unexpectedStatus(detail: HttpErrorDetail) Error {
    if (detail.body.len > 0 and logDecodedApiError(detail.status, detail.body)) {
        return Error.HttpError;
    }
    const max_preview = 2048;
    const preview = if (detail.body.len > max_preview)
        detail.body[0..max_preview]
    else
        detail.body;
    if (detail.body.len > max_preview) {
        std.debug.print("http status {d}, body (truncated): {s}...\n", .{ detail.status, preview });
    } else {
        std.debug.print("http status {d}, body: {s}\n", .{ detail.status, detail.body });
    }
    return Error.HttpError;
}

pub fn unimplemented(comptime feature: []const u8) Error {
    std.debug.print("feature not implemented: {s}\n", .{feature});
    return Error.Unimplemented;
}

fn logDecodedApiError(status: u16, body: []const u8) bool {
    const parsed = std.json.parseFromSlice(
        ApiErrorResponse,
        std.heap.page_allocator,
        body,
        .{ .ignore_unknown_fields = true },
    ) catch {
        return false;
    };
    defer parsed.deinit();

    const root = parsed.value;
    if (root.error) |api_err| {
        const message = api_err.message orelse "request failed";
        const typ = api_err.type orelse "unknown";
        std.debug.print(
            "http status {d}, type={s}, message={s}, code={s}, param={s}\n",
            .{
                status,
                typ,
                message,
                api_err.code orelse "n/a",
                api_err.param orelse "n/a",
            },
        );
        return true;
    }
    if (root.detail) |detail| {
        std.debug.print("http status {d}, detail={s}\n", .{ status, detail });
        return true;
    }
    return false;
}
