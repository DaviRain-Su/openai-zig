const std = @import("std");
const toml = @import("toml");

pub const Config = struct {
    api_key: []const u8,
    base_url: []const u8,

    pub fn deinit(self: *Config, allocator: std.mem.Allocator) void {
        allocator.free(self.api_key);
        allocator.free(self.base_url);
    }
};

pub fn load(allocator: std.mem.Allocator, path: []const u8) !Config {
    const defaults = .{
        .api_key = "",
        .base_url = "https://api.deepseek.com/v1",
    };

    var api_key: ?[]const u8 = null;
    var base_url: ?[]const u8 = null;
    errdefer if (api_key) |val| allocator.free(val);
    errdefer if (base_url) |val| allocator.free(val);

    if (std.fs.cwd().openFile(path, .{})) |file| {
        defer file.close();

        const contents = try file.readToEndAlloc(allocator, 8 * 1024);
        defer allocator.free(contents);

        var parser = try toml.parseContents(allocator, contents);
        defer parser.deinit();

        var table = try parser.parse();
        defer table.deinit();

        const api_key_src = if (table.keys.get("api_key")) |val| blk: {
            if (val == .String) break :blk val.String;
            break :blk defaults.api_key;
        } else defaults.api_key;

        const base_url_src = if (table.keys.get("base_url")) |val| blk: {
            if (val == .String) break :blk val.String;
            break :blk defaults.base_url;
        } else defaults.base_url;

        // Copy while the parsed table is still alive to avoid dangling references.
        api_key = try allocator.dupe(u8, api_key_src);
        base_url = try allocator.dupe(u8, base_url_src);
    } else |_| {
        api_key = try allocator.dupe(u8, defaults.api_key);
        base_url = try allocator.dupe(u8, defaults.base_url);
    }

    return Config{ .api_key = api_key.?, .base_url = base_url.? };
}
