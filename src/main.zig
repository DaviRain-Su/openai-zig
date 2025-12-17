const std = @import("std");
const sdk = @import("openai_zig");
const errors = sdk.errors;

pub fn main() !void {
    var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa_impl.deinit();
    const gpa = gpa_impl.allocator();

    const api_key = try readApiKey(gpa, "config/api_key.txt");
    defer gpa.free(api_key);

    var client = try sdk.initClient(gpa, .{
        .base_url = "https://api.openai.com/v1",
        .api_key = api_key,
    });
    defer client.deinit();

    var models = client.models().list_models(gpa) catch |err| {
        if (err == errors.Error.HttpError) {
            std.debug.print("HTTP error (check API key/base URL)\n", .{});
            return;
        }
        return err;
    };
    defer models.deinit();

    var out: std.io.Writer.Allocating = .init(gpa);
    defer out.deinit();
    var stream: std.json.Stringify = .{ .writer = &out.writer, .options = .{} };
    try stream.write(models.value);
    const rendered = out.written();

    std.debug.print("Models list JSON:\n{s}\n", .{rendered});
}

test "client init/deinit" {
    const gpa = std.heap.page_allocator;
    const client = try sdk.initClient(gpa, .{
        .base_url = "https://api.openai.com/v1",
        .api_key = null,
    });
    defer client.deinit();
}

fn readApiKey(allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const data = try file.readToEndAlloc(allocator, 4 * 1024);
    const trimmed = std.mem.trim(u8, data, " \t\r\n");
    const copy = try allocator.alloc(u8, trimmed.len);
    @memcpy(copy, trimmed);
    allocator.free(data);
    return copy;
}
