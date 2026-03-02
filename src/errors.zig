const std = @import("std");

/// Shared error set for client operations.
pub const Error = error{
    HttpError,
    BadRequestError,
    AuthenticationError,
    PermissionDeniedError,
    NotFoundError,
    ConflictError,
    UnprocessableEntityError,
    RateLimitError,
    TimeoutError,
    InternalServerError,
    DeserializeError,
    SerializeError,
    Timeout,
    Unimplemented,
};

/// HTTP-level error payload, if the API returns a JSON error object.
pub const ApiError = struct {
    message: ?[]const u8 = null,
    type: ?[]const u8 = null,
    param: ?[]const u8 = null,
    code: ?[]const u8 = null,
};

pub const ParsedApiError = struct {
    message: ?[]const u8 = null,
    type: ?[]const u8 = null,
    param: ?[]const u8 = null,
    code: ?[]const u8 = null,
    detail: ?[]const u8 = null,
};

const ApiErrorEnvelope = struct {
    message: ?[]const u8 = null,
    type: ?[]const u8 = null,
    param: ?[]const u8 = null,
    code: ?[]const u8 = null,
};

const ApiErrorResponse = struct {
    @"error": ?ApiErrorEnvelope = null,
    detail: ?[]const u8 = null,
};

/// Response wrapper that keeps both status and body text for diagnostics.
pub const HttpErrorDetail = struct {
    status: u16,
    body: []const u8,
    request_id: ?[]const u8 = null,
    message: ?[]const u8 = null,
    type: ?[]const u8 = null,
    param: ?[]const u8 = null,
    code: ?[]const u8 = null,
    detail: ?[]const u8 = null,
};

pub fn unexpectedStatus(detail: HttpErrorDetail) Error {
    const parsed = if (detail.body.len > 0 and detail.message == null and detail.type == null and
        detail.param == null and detail.code == null and detail.detail == null)
    parseApiError(detail.body)
    else
        null;

    const message = detail.message orelse if (parsed) |value| value.message else null;
    const typ = detail.type orelse if (parsed) |value| value.type else null;
    const param = detail.param orelse if (parsed) |value| value.param else null;
    const code = detail.code orelse if (parsed) |value| value.code else null;
    const detail_text = detail.detail orelse if (parsed) |value| value.detail else null;

    if (detail.request_id) |request_id| {
        std.debug.print("request_id={s}\n", .{request_id});
    }
    if (message != null or typ != null or param != null or code != null or detail_text != null) {
        std.debug.print(
            "http status {d}, type={s}, message={s}, code={s}, param={s}\n",
            .{
                detail.status,
                typ orelse "n/a",
                message orelse "request failed",
                code orelse "n/a",
                param orelse "n/a",
            },
        );
        if (detail_text) |value| {
            std.debug.print("detail={s}\n", .{value});
        }
        return classifyStatus(detail.status);
    }

    if (detail.body.len > 0) {
        if (logDecodedApiError(detail.status, detail.body)) {
            return classifyStatus(detail.status);
        }
    }

    const max_preview = 2048;
    const preview = if (detail.body.len > max_preview)
        detail.body[0..max_preview]
    else
        detail.body;
    if (detail.request_id) |request_id| {
        std.debug.print("request_id={s}\n", .{request_id});
    }
    printBodySafely(detail.status, preview, detail.body.len > max_preview);
    return classifyStatus(detail.status);
}

pub fn unimplemented(comptime feature: []const u8) Error {
    std.debug.print("feature not implemented: {s}\n", .{feature});
    return Error.Unimplemented;
}

fn classifyStatus(status: u16) Error {
    return switch (status) {
        400 => Error.BadRequestError,
        401 => Error.AuthenticationError,
        403 => Error.PermissionDeniedError,
        404 => Error.NotFoundError,
        409 => Error.ConflictError,
        422 => Error.UnprocessableEntityError,
        429 => Error.RateLimitError,
        408 => Error.TimeoutError,
        500...599 => Error.InternalServerError,
        else => Error.HttpError,
    };
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
    if (root.@"error") |api_err| {
        const message = api_err.message orelse "request failed";
        std.debug.print(
            "http status {d}, type={s}, code={s}, param={s}\n",
            .{
                status,
                api_err.type orelse "unknown",
                api_err.code orelse "n/a",
                api_err.param orelse "n/a",
            },
        );
        printStringSafely("message", message);
        return true;
    }
    if (root.detail) |detail| {
        std.debug.print("http status {d}, detail=", .{status});
        printStringSafely("detail", detail);
        return true;
    }
    return false;
}

fn printBodySafely(status: u16, body: []const u8, truncated: bool) void {
    if (body.len == 0) {
        std.debug.print("http status {d}, body: <empty>\n", .{status});
        return;
    }

    if (std.unicode.utf8ValidateSlice(body)) {
        if (truncated) {
            std.debug.print("http status {d}, body (truncated): {s}...\n", .{ status, body });
        } else {
            std.debug.print("http status {d}, body: {s}\n", .{ status, body });
        }
        return;
    }

    std.debug.print("http status {d}, body ({} bytes, non-utf8): ", .{ status, body.len });
    const display_len = @min(body.len, 64);
    for (body[0..display_len], 0..) |byte, idx| {
        std.debug.print("{x:0>2}", .{byte});
        if (idx + 1 < display_len) {
            std.debug.print(" ", .{});
        }
    }
    if (body.len > display_len) {
        std.debug.print(" ...", .{});
    }
    std.debug.print("\n", .{});
}

fn printStringSafely(_: []const u8, value: []const u8) void {
    if (std.unicode.utf8ValidateSlice(value)) {
        std.debug.print("{s}\n", .{value});
        return;
    }

    std.debug.print("(non-utf8 {d} bytes): ", .{value.len});
    for (value) |byte| {
        std.debug.print("{x:0>2}", .{byte});
    }
    std.debug.print("\n", .{});
}

pub fn parseApiError(body: []const u8) ?ParsedApiError {
    const parsed = std.json.parseFromSlice(
        ApiErrorResponse,
        std.heap.page_allocator,
        body,
        .{ .ignore_unknown_fields = true },
    ) catch {
        return null;
    };
    const detail = parsed.value;
    const clone = std.heap.page_allocator;

    const cloneSlice = struct {
        fn run(src: []const u8) ?[]const u8 {
            const out = clone.alloc(u8, src.len) catch null;
            if (out) |buf| {
                std.mem.copyForwards(u8, buf, src);
            }
            return out;
        }
    }.run;

    if (detail.@"error") |api_err| {
        const message = if (api_err.message) |value| cloneSlice(value) else null;
        const typ = if (api_err.type) |value| cloneSlice(value) else null;
        const param = if (api_err.param) |value| cloneSlice(value) else null;
        const code = if (api_err.code) |value| cloneSlice(value) else null;
        parsed.deinit();
        return ParsedApiError{
            .message = message,
            .type = typ,
            .param = param,
            .code = code,
            .detail = null,
        };
    }
    if (detail.detail) |msg| {
        const detail_text = cloneSlice(msg);
        parsed.deinit();
        return ParsedApiError{ .detail = detail_text };
    }
    parsed.deinit();
    return null;
}

test "unexpectedStatus maps http status to specific errors" {
    const cases = [_]struct {
        status: u16,
        expect: Error,
    }{
        .{ .status = 400, .expect = Error.BadRequestError },
        .{ .status = 401, .expect = Error.AuthenticationError },
        .{ .status = 403, .expect = Error.PermissionDeniedError },
        .{ .status = 404, .expect = Error.NotFoundError },
        .{ .status = 409, .expect = Error.ConflictError },
        .{ .status = 422, .expect = Error.UnprocessableEntityError },
        .{ .status = 429, .expect = Error.RateLimitError },
        .{ .status = 408, .expect = Error.TimeoutError },
        .{ .status = 500, .expect = Error.InternalServerError },
        .{ .status = 502, .expect = Error.InternalServerError },
        .{ .status = 999, .expect = Error.HttpError },
    };

    inline for (cases) |case| {
        const got = try unexpectedStatus(.{ .status = case.status, .body = "{}" });
        try std.testing.expectEqual(case.expect, got);
    }
}
