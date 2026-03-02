const std = @import("std");
const sdk = @import("openai_zig");
const config = @import("config");
const errors = sdk.errors;
const compat = @import("provider_compat.zig");

const ListFilePageStats = struct {
    pages: usize = 0,
    files: usize = 0,
};

const ListFilePageContext = struct {
    fn onPage(ctx: *ListFilePageStats, page: std.json.Parsed(sdk.generated.ListFilesResponse), page_index: usize) !bool {
        _ = page_index;
        ctx.pages += 1;
        ctx.files += page.value.data.len;

        std.debug.print("auto page {d}: count={d}, has_more={}\n", .{
            ctx.pages,
            page.value.data.len,
            page.value.has_more,
        });
        return true;
    }
};

const FilesListFetcher = struct {
    files: *const sdk.resources.files.Resource,

    fn fetch(self: *const FilesListFetcher, allocator: std.mem.Allocator, params: sdk.resources.files.ListFilesParams) !std.json.Parsed(sdk.generated.ListFilesResponse) {
        return self.files.list_files(allocator, params);
    }
};

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

    if (compat.skipIfDeepSeek(conf.base_url, "files")) return;

    const files_resource = client.files();
    var fetcher = FilesListFetcher{ .files = &files_resource };

    var stats = ListFilePageStats{};
    sdk.pagination.auto_paginate_after(
        sdk.generated.ListFilesResponse,
        sdk.resources.files.ListFilesParams,
        gpa,
        .{
            .limit = 2,
            .after = null,
            .purpose = null,
            .order = null,
        },
        &fetcher,
        FilesListFetcher.fetch,
        &stats,
        ListFilePageContext.onPage,
        .{},
    ) catch |err| {
        if (err == errors.Error.NotFoundError) {
            std.debug.print("files endpoint unavailable on this provider (HTTP 404).\n", .{});
            return;
        }
        return err;
    };

    if (stats.pages == 0) {
        std.debug.print("no files returned.\n", .{});
        return;
    }

    std.debug.print("total files visited: {d} in {d} pages\n", .{ stats.files, stats.pages });
}
