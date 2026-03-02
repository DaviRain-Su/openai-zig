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

    var models = try client.models().list_models(gpa);
    defer models.deinit();

    std.debug.print("Models list: {d} items\n", .{models.value.data.len});
    for (models.value.data, 0..) |model_value, idx| {
        std.debug.print("  [{d}] ", .{idx});
        printModel(model_value);
    }
}

fn printModel(model: sdk.generated.Model) void {
    const safe_id = if (std.unicode.utf8ValidateSlice(model.id)) model.id else "[invalid utf8]";
    const safe_object = if (std.unicode.utf8ValidateSlice(model.object)) model.object else "[invalid utf8]";
    const safe_owner = if (std.unicode.utf8ValidateSlice(model.owned_by)) model.owned_by else "[invalid utf8]";

    std.debug.print(
        "id={s} object={s} owned_by={s}\n",
        .{ safe_id, safe_object, safe_owner },
    );
}
