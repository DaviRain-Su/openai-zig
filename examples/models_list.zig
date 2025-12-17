const std = @import("std");
const sdk = @import("openai_zig");
const config = @import("config.zig");

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
