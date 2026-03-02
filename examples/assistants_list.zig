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

    if (compat.skipIfDeepSeek(conf.base_url, "assistants")) return;

    const assistants = client.assistants().list_assistants(gpa, .{}) catch |err| {
        switch (err) {
            errors.Error.NotFoundError => {
                std.debug.print("assistants endpoint unavailable on this provider (HTTP 404).\n", .{});
                return;
            },
            errors.Error.BadRequestError => {
                std.debug.print("assistants request rejected (HTTP 400).\n", .{});
                return;
            },
            errors.Error.HttpError => {
                std.debug.print("assistants request failed with HTTP-level error.\n", .{});
                return;
            },
            else => return err,
        }
    };
    defer assistants.deinit();

    std.debug.print("assistants count: {d}\n", .{assistants.value.data.len});

    for (assistants.value.data[0..@min(assistants.value.data.len, 3)]) |assistant| {
        std.debug.print(" - {s} ({s})\n", .{
            assistant.id,
            assistant.model,
        });
    }
}
