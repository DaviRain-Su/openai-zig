const std = @import("std");
const sdk = @import("openai_zig");
const errors = sdk.errors;
const config = @import("config");
const compat = @import("provider_compat.zig");

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

    if (compat.skipIfDeepSeek(conf.base_url, "vector_stores")) return;

    const res = client.vector_stores().list_vector_stores(gpa, .{
        .limit = null,
        .order = "desc",
        .after = null,
        .before = null,
    }) catch |err| {
        switch (err) {
            errors.Error.NotFoundError => {
                std.debug.print("vector_stores endpoint unavailable on this provider (HTTP 404).\n", .{});
                return;
            },
            errors.Error.BadRequestError => {
                std.debug.print("vector_stores request rejected (BadRequest).\n", .{});
                return;
            },
            errors.Error.HttpError => {
                std.debug.print("HTTP transport error (likely invalid key).\n", .{});
                return;
            },
            else => return err,
        }
    };
    defer res.deinit();

    var out_writer = std.io.Writer.Allocating.init(gpa);
    defer out_writer.deinit();

    var json_stream: std.json.Stringify = .{ .writer = &out_writer.writer };
    try json_stream.write(res.value);
    std.debug.print("vector_stores response:\n{s}\n", .{out_writer.written()});
}
