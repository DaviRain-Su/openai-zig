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

    if (compat.skipIfDeepSeek(conf.base_url, "embeddings")) return;

    const emb = client.embeddings().create(gpa, .{
        .input = .{ .string = "Hello from OpenAI Zig SDK." },
        .model = .{ .string = "text-embedding-3-small" },
        .encoding_format = null,
        .dimensions = null,
        .user = null,
    }) catch |err| {
        switch (err) {
            errors.Error.NotFoundError => {
                std.debug.print("embeddings endpoint unavailable on this provider (HTTP 404).\n", .{});
                return;
            },
            errors.Error.HttpError, errors.Error.BadRequestError => {
                std.debug.print("embeddings request failed: {s}\n", .{@errorName(err)});
                return;
            },
            else => return err,
        }
    };
    defer emb.deinit();

    var emb_out = std.io.Writer.Allocating.init(gpa);
    defer emb_out.deinit();
    var emb_stream: std.json.Stringify = .{ .writer = &emb_out.writer, .options = .{ .emit_null_optional_fields = false } };
    try emb_stream.write(emb.value);
    std.debug.print("Embeddings response:\n{s}\n", .{emb_out.written()});

    if (compat.skipIfDeepSeek(conf.base_url, "moderations")) return;

    const mod = client.moderations().create(gpa, .{
        .input = .{ .string = "You are a helpful assistant." },
        .model = .{ .string = "text-moderation-latest" },
    }) catch |err| {
        switch (err) {
            errors.Error.NotFoundError => {
                std.debug.print("moderations endpoint unavailable on this provider (HTTP 404).\n", .{});
                return;
            },
            errors.Error.HttpError, errors.Error.BadRequestError => {
                std.debug.print("moderations request failed: {s}\n", .{@errorName(err)});
                return;
            },
            else => return err,
        }
    };
    defer mod.deinit();

    var mod_out = std.io.Writer.Allocating.init(gpa);
    defer mod_out.deinit();
    var mod_stream: std.json.Stringify = .{ .writer = &mod_out.writer, .options = .{ .emit_null_optional_fields = false } };
    try mod_stream.write(mod.value);
    std.debug.print("Moderations response:\n{s}\n", .{mod_out.written()});
}
