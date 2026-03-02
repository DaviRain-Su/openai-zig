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
        printModel(gpa, model_value);
    }
}

fn printModel(allocator: std.mem.Allocator, value: std.json.Value) void {
    _ = allocator;
    const obj = switch (value) {
        .object => |o| o,
        else => {
            std.debug.print("<non-object model>\n", .{});
            return;
        },
    };

    if (!obj.contains("id")) {
        std.debug.print("<non-object model>\n", .{});
        return;
    }
    const fields = obj;

    std.debug.print("id=", .{});
    if (fields.get("id")) |id| {
        switch (id) {
            .string => |s| if (std.unicode.utf8ValidateSlice(s)) {
                std.debug.print("{s} ", .{s});
            } else {
                std.debug.print("<non-utf8-id> ", .{});
            },
            else => std.debug.print("<non-string-id> ", .{}),
        }
    } else {
        std.debug.print("<no-id> ", .{});
    }

    std.debug.print("object=", .{});
    if (fields.get("object")) |object| {
        switch (object) {
            .string => |s| if (std.unicode.utf8ValidateSlice(s)) {
                std.debug.print("{s} ", .{s});
            } else {
                std.debug.print("<non-utf8-object> ", .{});
            },
            else => std.debug.print("<non-string-object> ", .{}),
        }
    } else {
        std.debug.print("<no-object> ", .{});
    }

    std.debug.print("owned_by=", .{});
    if (fields.get("owned_by")) |owned_by| {
        switch (owned_by) {
            .string => |s| if (std.unicode.utf8ValidateSlice(s)) {
                std.debug.print("{s}\n", .{s});
            } else {
                std.debug.print("<non-utf8-owned-by>\n", .{});
            },
            else => std.debug.print("<non-string-owned-by>\n", .{}),
        }
    } else {
        std.debug.print("<no-owned-by>\n", .{});
    }
}

fn readBaseUrl(allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
    const file_result = std.fs.cwd().openFile(path, .{});
    if (file_result) |file| {
        defer file.close();
        const data = try file.readToEndAlloc(allocator, 512);
        const trimmed = std.mem.trim(u8, data, " \t\r\n");
        const copy = try allocator.alloc(u8, trimmed.len);
        @memcpy(copy, trimmed);
        allocator.free(data);
        return copy;
    } else |_| {
        return allocator.alloc(u8, 0);
    }
}
