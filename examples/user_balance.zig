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

    if (!compat.isDeepSeek(conf.base_url)) {
        std.debug.print("user/balance endpoint is provider-specific (DeepSeek); skipped.\n", .{});
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

    var response = client.user_balance().get_user_balance(gpa) catch |err| {
        switch (err) {
            errors.Error.NotFoundError => {
                std.debug.print("user/balance endpoint unavailable on this provider (HTTP 404).\n", .{});
                return;
            },
            else => {
                std.debug.print("user/balance request failed: {s}\n", .{@errorName(err)});
                return;
            },
        }
    };
    defer response.deinit();

    std.debug.print("User balance available: {s}\n", .{if (response.value.is_available) "true" else "false"});
    for (response.value.balance_infos) |item| {
        std.debug.print("  - {s}: total={s}, granted={s}, topped_up={s}\n", .{
            item.currency,
            item.total_balance,
            item.granted_balance,
            item.topped_up_balance,
        });
    }
}
