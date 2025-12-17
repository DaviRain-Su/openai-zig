const std = @import("std");
const sdk = @import("openai_zig");

pub fn main() !void {
    var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa_impl.deinit();
    const gpa = gpa_impl.allocator();

    const api_key = try readApiKey(gpa, "config/api_key.txt");
    defer gpa.free(api_key);

    if (api_key.len == 0) {
        std.debug.print("API key missing; set config/api_key.txt\n", .{});
        return;
    }

    var client = try sdk.initClient(gpa, .{
        .base_url = "https://api.deepseek.com/v1",
        .api_key = api_key,
    });
    defer client.deinit();

    var models = try client.models().list_models(gpa);
    defer models.deinit();

    var out: std.io.Writer.Allocating = .init(gpa);
    defer out.deinit();
    var stream: std.json.Stringify = .{ .writer = &out.writer, .options = .{} };
    try stream.write(models.value);

    std.debug.print("Models list:\n{s}\n", .{out.written()});
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
