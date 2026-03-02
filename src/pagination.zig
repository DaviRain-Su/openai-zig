const std = @import("std");

pub const PaginationDirection = enum {
    after,
    before,
};

pub const AutoPaginationOptions = struct {
    max_pages: ?usize = null,
};

/// Automatically paginate using `after`.
pub fn auto_paginate_after(
    comptime Response: type,
    comptime Params: type,
    allocator: std.mem.Allocator,
    initial_params: Params,
    fetch_ctx: anytype,
    fetch_page: anytype,
    page_ctx: anytype,
    on_page: anytype,
    options: AutoPaginationOptions,
) !void {
    comptime if (!@hasField(Params, "after")) {
        @compileError("Params missing `after` field for auto paginate after");
    };
    return autoPaginateInternal(.after, Response, Params, allocator, initial_params, fetch_ctx, fetch_page, page_ctx, on_page, options);
}

/// Automatically paginate using `before`.
pub fn auto_paginate_before(
    comptime Response: type,
    comptime Params: type,
    allocator: std.mem.Allocator,
    initial_params: Params,
    fetch_ctx: anytype,
    fetch_page: anytype,
    page_ctx: anytype,
    on_page: anytype,
    options: AutoPaginationOptions,
) !void {
    comptime if (!@hasField(Params, "before")) {
        @compileError("Params missing `before` field for auto paginate before");
    };
    return autoPaginateInternal(.before, Response, Params, allocator, initial_params, fetch_ctx, fetch_page, page_ctx, on_page, options);
}

fn autoPaginateInternal(
    comptime direction: PaginationDirection,
    comptime Response: type,
    comptime Params: type,
    allocator: std.mem.Allocator,
    initial_params: Params,
    fetch_ctx: anytype,
    fetch_page: anytype,
    page_ctx: anytype,
    on_page: anytype,
    options: AutoPaginationOptions,
) !void {
    var params = initial_params;
    var page_index: usize = 0;
    var owned_cursor: ?[]const u8 = null;
    defer if (owned_cursor) |cursor| allocator.free(cursor);

    if (options.max_pages) |max_pages| {
        if (max_pages == 0) return;
    }

    while (true) : (page_index += 1) {
        var parsed: std.json.Parsed(Response) = try @call(.auto, fetch_page, .{ fetch_ctx, allocator, params });
        errdefer parsed.deinit();

        const should_continue = try @call(.auto, on_page, .{ page_ctx, parsed, page_index });
        const has_more = hasMoreFromListResponse(Response, &parsed.value);
        const next_cursor = if (has_more)
            if (direction == .after) nextAfterFromListResponse(Response, &parsed.value) else nextBeforeFromListResponse(Response, &parsed.value)
        else
            null;

        if (!has_more or !should_continue) {
            parsed.deinit();
            break;
        }
        if (options.max_pages) |max_pages| {
            if (page_index + 1 >= max_pages) {
                parsed.deinit();
                break;
            }
        }
        if (next_cursor == null) {
            parsed.deinit();
            break;
        }

        defer parsed.deinit();

        if (owned_cursor) |old| allocator.free(old);
        const copied_cursor = try allocator.dupe(u8, next_cursor.?);
        owned_cursor = copied_cursor;

        switch (direction) {
            .after => {
                if (comptime @hasField(Params, "after")) {
                    params.after = copied_cursor;
                }
                if (comptime @hasField(Params, "before")) {
                    params.before = null;
                }
            },
            .before => {
                if (comptime @hasField(Params, "before")) {
                    params.before = copied_cursor;
                }
                if (comptime @hasField(Params, "after")) {
                    params.after = null;
                }
            },
        }
    }
}

/// Return whether a parsed list response indicates more pages.
pub fn hasMoreFromListResponse(comptime Response: type, value: *const Response) bool {
    if (!@hasField(Response, "has_more")) return false;

    const has_more = @field(value.*, "has_more");
    if (comptime @TypeOf(has_more) != bool) return false;
    return has_more;
}

/// Return the next `after` cursor from a list response, if it has more pages.
pub fn nextAfterFromListResponse(comptime Response: type, value: *const Response) ?[]const u8 {
    if (!hasMoreFromListResponse(Response, value)) return null;
    return cursorField(Response, value, "last_id");
}

/// Return the next `before` cursor from a list response, if present.
pub fn nextBeforeFromListResponse(comptime Response: type, value: *const Response) ?[]const u8 {
    if (!hasMoreFromListResponse(Response, value)) return null;
    return cursorField(Response, value, "first_id");
}

/// Check whether a type looks like an OpenAI-style list response for pagination.
///
/// The helper is intentionally permissive: it validates the cursor contract
/// (`has_more`, `last_id`, `first_id`) but does not enforce page item field
/// contents. It returns false when the expected cursor fields are missing or
/// typed incompatibly.
pub fn isOpenAIListResponse(comptime Response: type) bool {
    return comptime blk: {
        if (!@hasField(Response, "has_more")) break :blk false;
        if (!@hasField(Response, "data")) break :blk false;
        if (!@hasField(Response, "first_id")) break :blk false;
        if (!@hasField(Response, "last_id")) break :blk false;

        const zero: Response = std.mem.zeroes(Response);

        const has_more = @field(zero, "has_more");
        if (@TypeOf(has_more) != bool) break :blk false;

        const first_id = @field(zero, "first_id");
        const last_id = @field(zero, "last_id");
        const first_ok = @TypeOf(first_id) == ?[]const u8 or @TypeOf(first_id) == []const u8;
        const last_ok = @TypeOf(last_id) == ?[]const u8 or @TypeOf(last_id) == []const u8;
        if (!first_ok or !last_ok) break :blk false;

        break :blk true;
    };
}

fn cursorField(comptime Response: type, value: *const Response, comptime field_name: []const u8) ?[]const u8 {
    if (!@hasField(Response, field_name)) return null;

    const field = @field(value.*, field_name);
    if (comptime @TypeOf(field) == ?[]const u8) {
        return if (field) |cursor| cursor else null;
    }
    if (comptime @TypeOf(field) == []const u8) {
        return field;
    }
    return null;
}

test "pagination helper on synthetic list response" {
    const TestResponse = struct {
        data: []const u8,
        has_more: bool,
        first_id: ?[]const u8,
        last_id: []const u8,
    };

    var value = TestResponse{
        .data = &[_]u8{},
        .has_more = true,
        .first_id = "first",
        .last_id = "last",
    };
    try std.testing.expect(hasMoreFromListResponse(TestResponse, &value));
    try std.testing.expectEqualStrings("last", nextAfterFromListResponse(TestResponse, &value).?);
    try std.testing.expectEqualStrings("first", nextBeforeFromListResponse(TestResponse, &value).?);

    var last_page = TestResponse{
        .data = &[_]u8{},
        .has_more = false,
        .first_id = null,
        .last_id = "last",
    };
    try std.testing.expect(!hasMoreFromListResponse(TestResponse, &last_page));
    try std.testing.expect(nextBeforeFromListResponse(TestResponse, &last_page) == null);
}

test "pagination contract check for list-shaped responses" {
    const ListResponse = struct {
        data: []const u8,
        has_more: bool,
        first_id: ?[]const u8,
        last_id: []const u8,
    };

    const NonListResponse = struct {
        id: []const u8,
        created: u64,
    };

    try std.testing.expect(isOpenAIListResponse(ListResponse));
    try std.testing.expect(!isOpenAIListResponse(NonListResponse));
}

test "auto paginate after advances through pages" {
    const MockListResponse = struct {
        data: []const []const u8,
        has_more: bool,
        first_id: ?[]const u8,
        last_id: ?[]const u8,
    };

    const MockParams = struct {
        after: ?[]const u8 = null,
        limit: ?u32 = null,
    };

    const pages = [_][]const u8{
        "{\"data\":[\"a\",\"b\"],\"has_more\":true,\"first_id\":\"a\",\"last_id\":\"b\"}",
        "{\"data\":[\"c\"],\"has_more\":false,\"first_id\":\"c\",\"last_id\":\"c\"}",
    };

    const Fetcher = struct {
        page: usize = 0,

        fn fetch(
            self: *@This(),
            allocator: std.mem.Allocator,
            _: MockParams,
        ) !std.json.Parsed(MockListResponse) {
            const payload = pages[self.page];
            self.page += 1;
            return std.json.parseFromSlice(MockListResponse, allocator, payload, .{});
        }
    };

    const Visited = struct {
        count: usize = 0,
        total_items: usize = 0,

        fn on_page(
            self: *@This(),
            page: std.json.Parsed(MockListResponse),
            _: usize,
        ) !bool {
            self.count += 1;
            self.total_items += page.value.data.len;
            return true;
        }
    };

    var fetcher = Fetcher{};
    var visited = Visited{};
    try auto_paginate_after(
        MockListResponse,
        MockParams,
        std.testing.allocator,
        .{
            .after = null,
            .limit = null,
        },
        &fetcher,
        Fetcher.fetch,
        &visited,
        Visited.on_page,
        .{ .max_pages = 10 },
    );
    try std.testing.expectEqual(@as(usize, 2), visited.count);
    try std.testing.expectEqual(@as(usize, 3), visited.total_items);
}
