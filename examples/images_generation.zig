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

    std.debug.print("Images generation: request image for prompt...\n", .{});

    const response = client.images().generate(gpa, .{
        .prompt = "A cinematic skyline at night with neon reflections in the rain",
        .model = null,
        .n = null,
        .quality = null,
        .response_format = "url",
        .output_format = null,
        .output_compression = null,
        .stream = null,
        .partial_images = null,
        .size = null,
        .moderation = null,
        .background = null,
        .style = null,
        .user = null,
    }) catch |err| {
        switch (err) {
            errors.Error.NotFoundError => {
                std.debug.print("images endpoint unavailable on this provider (HTTP 404).\n", .{});
                return;
            },
            errors.Error.BadRequestError => {
                std.debug.print("images request rejected (BadRequest).\n", .{});
                return;
            },
            errors.Error.HttpError => {
                std.debug.print("HTTP transport/authorization failure.\n", .{});
                return;
            },
            else => return err,
        }
    };
    defer response.deinit();

    if (response.value.data) |items| {
        for (items, 0..) |item, idx| {
            if (item.url) |url| {
                std.debug.print("image {d} url: {s}\n", .{ idx + 1, url });
            } else if (item.b64_json) |b64| {
                std.debug.print("image {d} base64 length: {d}\n", .{ idx + 1, b64.len });
            }
        }
    } else {
        std.debug.print("images response contains no data items.\n", .{});
    }
}
