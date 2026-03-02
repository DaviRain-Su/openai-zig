const std = @import("std");

pub fn isDeepSeek(base_url: []const u8) bool {
    return std.mem.indexOf(u8, base_url, "deepseek") != null;
}

pub fn isDeepSeekBaseUrl(base_url: []const u8) bool {
    return isDeepSeek(base_url);
}

pub fn deepSeekBetaBase(allocator: std.mem.Allocator, base_url: []const u8) ![]u8 {
    const trimmed_base = std.mem.trimRight(u8, base_url, "/");

    if (std.mem.endsWith(u8, trimmed_base, "/beta")) {
        return allocator.dupe(u8, trimmed_base);
    }

    if (std.mem.endsWith(u8, trimmed_base, "/v1")) {
        if (trimmed_base.len <= 3) {
            return allocator.dupe(u8, "https://api.deepseek.com/beta");
        }
        const host_base = trimmed_base[0 .. trimmed_base.len - 3];
        return std.fmt.allocPrint(allocator, "{s}/beta", .{host_base});
    }

    return std.fmt.allocPrint(allocator, "{s}/beta", .{trimmed_base});
}

pub fn skipIfDeepSeek(base_url: []const u8, feature: []const u8) bool {
    if (!isDeepSeek(base_url)) return false;
    std.debug.print("{s} endpoint unavailable on DeepSeek compatibility API (skipped).\n", .{feature});
    return true;
}
