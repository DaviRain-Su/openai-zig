const std = @import("std");
const sdk = @import("openai_zig");
const config = @import("config");
const errors = sdk.errors;

pub fn main() !void {
    var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa_impl.deinit();
    const gpa = gpa_impl.allocator();

    var conf = try config.load(gpa, "config/config.toml");
    defer conf.deinit(gpa);
    if (conf.api_key.len == 0) {
        std.debug.print("API key missing; set config/config.toml\n", .{});
        return;
    }

    var client = try sdk.initClient(gpa, .{
        .base_url = conf.base_url,
        .api_key = conf.api_key,
        .timeout_ms = conf.timeout_ms,
        .organization = conf.organization,
        .project = conf.project,
        .max_retries = conf.max_retries,
        .retry_base_delay_ms = conf.retry_base_delay_ms,
    });
    defer client.deinit();

    var page = sdk.resources.files.ListFilesParams{
        .limit = 2,
        .after = null,
        .purpose = null,
        .order = null,
    };

    var after: ?[]const u8 = null;
    var total_files: u64 = 0;
    var page_index: u8 = 0;
    defer if (after) |cursor| gpa.free(cursor);

    while (page_index < 30) : (page_index += 1) {
        page.after = after;

        const files_page = client.files().list_files(gpa, page) catch |err| {
            if (err == errors.Error.NotFoundError) {
                std.debug.print("files endpoint unavailable on this provider (HTTP 404).\n", .{});
                return;
            }
            return err;
        };
        defer files_page.deinit();

        if (files_page.value.data.len == 0) {
            std.debug.print("no files returned on page {d}\n", .{page_index + 1});
            return;
        }

        total_files += files_page.value.data.len;
        const ResponseType = @TypeOf(files_page.value);
        const has_more = sdk.pagination.hasMoreFromListResponse(ResponseType, &files_page.value);
        const next_after = sdk.pagination.nextAfterFromListResponse(ResponseType, &files_page.value);
        const next_before = sdk.pagination.nextBeforeFromListResponse(ResponseType, &files_page.value);

        std.debug.print("page {d} => items={d}, has_more={}\n", .{ page_index + 1, files_page.value.data.len, has_more });
        if (next_after) |cursor| {
            std.debug.print("  after={s}\n", .{cursor});
        }
        if (next_before) |cursor| {
            std.debug.print("  before={s}\n", .{cursor});
        }

        if (!has_more or next_after == null) break;
        const next_cursor = next_after.?;
        const next_copy = try gpa.dupe(u8, next_cursor);
        if (after) |old| gpa.free(old);
        after = next_copy;
    }

    std.debug.print("total files visited: {d}\n", .{total_files});
}
