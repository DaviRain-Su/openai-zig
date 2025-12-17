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

    var api_key_src: []const u8 = defaults.api_key;
    var base_url_src: []const u8 = defaults.base_url;

    if (std.fs.cwd().openFile(path, .{})) |file| {
        defer file.close();

        const contents = try file.readToEndAlloc(allocator, 8 * 1024);
        defer allocator.free(contents);

        var parser = try toml.parseContents(allocator, contents);
        defer parser.deinit();

        var table = try parser.parse();
        defer table.deinit();

        if (table.keys.get("api_key")) |val| {
            if (val == .String) {
                api_key_src = val.String;
            }
        }
        if (table.keys.get("base_url")) |val| {
            if (val == .String) {
                base_url_src = val.String;
            }
        }
    } else |_| {
        // missing config file: keep defaults
    }

    const api_key = try dup(allocator, api_key_src);
    const base_url = try dup(allocator, base_url_src);
    return Config{ .api_key = api_key, .base_url = base_url };
}

fn dup(allocator: std.mem.Allocator, src: []const u8) ![]const u8 {
    const buf = try allocator.alloc(u8, src.len);
    @memcpy(buf, src);
    return buf;
}
