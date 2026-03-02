const std = @import("std");

pub fn isDeepSeek(base_url: []const u8) bool {
    const trimmed_base = std.mem.trim(u8, base_url, " \t\n\r");
    return std.mem.indexOf(u8, trimmed_base, "deepseek") != null;
}

pub fn isDeepSeekBaseUrl(base_url: []const u8) bool {
    return isDeepSeek(base_url);
}

pub fn deepSeekBetaBase(allocator: std.mem.Allocator, base_url: []const u8) ![]u8 {
    const trimmed_base = std.mem.trim(u8, base_url, " \t\n\r");

    if (std.mem.endsWith(u8, trimmed_base, "/beta")) {
        return allocator.dupe(u8, trimmed_base);
    }

    if (std.mem.endsWith(u8, trimmed_base, "/")) {
        return std.fmt.allocPrint(allocator, "{s}/beta", .{std.mem.trimRight(u8, trimmed_base, "/")});
    }

    if (std.mem.endsWith(u8, trimmed_base, "/v1")) {
        if (trimmed_base.len <= 3) {
            return allocator.dupe(u8, "https://api.deepseek.com/beta");
        }
        const host_base = trimmed_base[0 .. trimmed_base.len - 3];
        const normalized_host_base = std.mem.trimRight(u8, host_base, "/");
        return std.fmt.allocPrint(allocator, "{s}/beta", .{normalized_host_base});
    }

    const normalized_base = std.mem.trimRight(u8, trimmed_base, "/");
    return std.fmt.allocPrint(allocator, "{s}/beta", .{normalized_base});
}

pub fn withoutStream(comptime Request: type, request: Request) Request {
    comptime {
        if (!@hasField(Request, "stream")) {
            return request;
        }
    }
    var fallback_request = request;
    fallback_request.stream = null;
    return fallback_request;
}

pub fn skipIfDeepSeek(base_url: []const u8, feature: []const u8) bool {
    if (!isDeepSeek(base_url)) return false;
    std.debug.print("{s} endpoint unavailable on DeepSeek compatibility API (skipped).\n", .{feature});
    return true;
}
