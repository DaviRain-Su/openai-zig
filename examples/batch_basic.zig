const std = @import("std");
const sdk = @import("openai_zig");
const errors = sdk.errors;
const config = @import("config");

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

    const batch_resource = client.batch();

    const batches = batch_resource.list_batches(gpa, .{
        .after = null,
        .limit = 5,
    }) catch |err| {
        switch (err) {
            errors.Error.NotFoundError => {
                std.debug.print("batch endpoint unavailable on this provider (HTTP 404).\n", .{});
                return;
            },
            errors.Error.HttpError, errors.Error.BadRequestError => {
                std.debug.print("batch list request failed: {s}\n", .{@errorName(err)});
                return;
            },
            else => return err,
        }
    };
    defer batches.deinit();

    std.debug.print("batch list has_more: {}\n", .{batches.value.has_more});

    var out: std.io.Writer.Allocating = .init(gpa);
    defer out.deinit();
    var json_stream: std.json.Stringify = .{ .writer = &out.writer, .options = .{ .emit_null_optional_fields = false } };
    try json_stream.write(batches.value);
    std.debug.print("batch list response:\n{s}\n", .{out.written()});

    if (batches.value.data.len == 0) {
        std.debug.print("no batch jobs.\n", .{});
        return;
    }

    const first_id = batches.value.data[0].id;
    const first_batch = batch_resource.retrieve_batch(gpa, first_id) catch |err| {
        switch (err) {
            errors.Error.NotFoundError => {
                std.debug.print("batch retrieve endpoint unavailable on this provider (HTTP 404).\n", .{});
                return;
            },
            else => return err,
        }
    };
    defer first_batch.deinit();

    var batch_out: std.io.Writer.Allocating = .init(gpa);
    defer batch_out.deinit();
    var batch_stream: std.json.Stringify = .{ .writer = &batch_out.writer, .options = .{ .emit_null_optional_fields = false } };
    try batch_stream.write(first_batch.value);
    std.debug.print("first batch detail:\n{s}\n", .{batch_out.written()});
}
