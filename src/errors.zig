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
    if (detail.body.len > max_preview) {
        std.debug.print("http status {d}, body (truncated): {s}...\n", .{ detail.status, preview });
    } else {
        std.debug.print("http status {d}, body: {s}\n", .{ detail.status, detail.body });
    }
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

pub fn parseApiError(body: []const u8) ?ParsedApiError {
    const parsed = std.json.parseFromSlice(
        ApiErrorResponse,
        std.heap.page_allocator,
        body,
        .{ .ignore_unknown_fields = true },
    ) catch {
        return null;
    };
    defer parsed.deinit();

    const root = parsed.value;
    if (root.@"error") |api_err| {
        return ParsedApiError{
            .message = api_err.message,
            .type = api_err.type,
            .param = api_err.param,
            .code = api_err.code,
            .detail = null,
        };
    }
    if (root.detail) |detail| {
        return ParsedApiError{ .detail = detail };
    }
    return null;
}
