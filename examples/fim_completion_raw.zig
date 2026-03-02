const std = @import("std");
const sdk = @import("openai_zig");
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

    const request_json = try std.fmt.allocPrint(
        gpa,
        "{{\"model\":\"{s}\",\"prompt\":\"def fib(a):\",\"suffix\":\"    return fib(a - 1) + fib(a - 2)\",\"max_tokens\":128,\"echo\":false,\"temperature\":0.7,\"stream\":false,\"extra_field\":\"fim-compat\"}}",
        .{conf.model},
    );
    defer gpa.free(request_json);

    var payload = try std.json.parseFromSlice(std.json.Value, gpa, request_json, .{});
    defer payload.deinit();

    const response = client.completions().create_completion_raw(gpa, payload.value) catch |err| {
        std.debug.print("create_completion_raw failed: {s}\n", .{@errorName(err)});
        return;
    };
    defer response.deinit();

    if (response.value.choices.len == 0) {
        std.debug.print("Raw FIM completion has no choices.\n", .{});
        return;
    }

    const text = response.value.choices[0].text;
    std.debug.print("FIM raw completion:\n{s}\n", .{text});
}
