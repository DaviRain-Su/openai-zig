const std = @import("std");
const sdk = @import("openai_zig");
const config = @import("config");

fn tryListModels(
    client: *sdk.Client,
    allocator: std.mem.Allocator,
    maybe_opts: ?sdk.transport.Transport.RequestOptions,
) !void {
    const models = if (maybe_opts) |request_opts|
        try client.models().list_models_with_options(allocator, request_opts)
    else
        try client.models().list_models(allocator);

    defer models.deinit();
    std.debug.print("models returned: {d}\n", .{models.value.data.len});
}

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

    std.debug.print("1) default request\n", .{});
    tryListModels(&client, gpa, null) catch |err| {
        std.debug.print("default request failed: {s}\n", .{@errorName(err)});
    };

    std.debug.print("2) request override (timeout/retries)\n", .{});
    tryListModels(&client, gpa, .{ .timeout_ms = 1000, .max_retries = 0 }) catch |err| {
        std.debug.print("override request failed: {s}\n", .{@errorName(err)});
    };

    std.debug.print("3) cloned client with options\n", .{});
    var scoped = try client.with_options(gpa, .{
        .max_retries = 1,
        .retry_base_delay_ms = 10,
    });
    defer scoped.deinit();
    tryListModels(&scoped, gpa, null) catch |err| {
        std.debug.print("scoped client request failed: {s}\n", .{@errorName(err)});
    };
}
