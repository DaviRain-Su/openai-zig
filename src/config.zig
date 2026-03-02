const std = @import("std");
const toml = @import("toml");

pub const Config = struct {
    api_key: []const u8,
    base_url: []const u8,
    model: []const u8,
    organization: ?[]const u8,
    project: ?[]const u8,
    timeout_ms: ?u64,
    max_retries: u8,
    retry_base_delay_ms: u64,

    pub fn deinit(self: *Config, allocator: std.mem.Allocator) void {
        allocator.free(self.api_key);
        allocator.free(self.base_url);
        allocator.free(self.model);
        if (self.organization) |v| allocator.free(v);
        if (self.project) |v| allocator.free(v);
    }
};

pub fn load(allocator: std.mem.Allocator, path: []const u8) !Config {
    const defaults = .{
        .api_key = "",
        .base_url = "https://api.deepseek.com/v1",
        .model = "deepseek-chat",
        .organization = null,
        .project = null,
        .timeout_ms = null,
        .max_retries = 2,
        .retry_base_delay_ms = 500,
    };

    var api_key: ?[]const u8 = null;
    var base_url: ?[]const u8 = null;
    var model: ?[]const u8 = null;
    var organization: ?[]const u8 = null;
    var project: ?[]const u8 = null;
    var timeout_ms: ?u64 = null;
    var max_retries: ?u8 = null;
    var retry_base_delay_ms: ?u64 = null;
    errdefer if (api_key) |val| allocator.free(val);
    errdefer if (base_url) |val| allocator.free(val);
    errdefer if (model) |val| allocator.free(val);
    errdefer if (organization) |val| allocator.free(val);
    errdefer if (project) |val| allocator.free(val);

    const env_api_key = try readOptionalEnvVarFrom(allocator, &.{ "OPENAI_API_KEY", "DEEPSEEK_API_KEY" });
    defer if (env_api_key) |val| allocator.free(val);
    const env_base_url = try readOptionalEnvVarFrom(allocator, &.{ "OPENAI_BASE_URL", "DEEPSEEK_BASE_URL" });
    defer if (env_base_url) |val| allocator.free(val);
    const env_model = try readOptionalEnvVarFrom(allocator, &.{ "OPENAI_MODEL", "DEEPSEEK_MODEL" });
    defer if (env_model) |val| allocator.free(val);
    const env_organization = try readOptionalEnvVarFrom(allocator, &.{"OPENAI_ORGANIZATION"});
    defer if (env_organization) |val| allocator.free(val);
    const env_project = try readOptionalEnvVarFrom(allocator, &.{"OPENAI_PROJECT"});
    defer if (env_project) |val| allocator.free(val);
    const env_timeout_ms = try readOptionalEnvIntFrom(allocator, &.{ "OPENAI_TIMEOUT_MS", "DEEPSEEK_TIMEOUT_MS" });
    const env_max_retries = try readOptionalEnvIntFrom(allocator, &.{ "OPENAI_MAX_RETRIES", "DEEPSEEK_MAX_RETRIES" });
    const env_retry_base_delay_ms = try readOptionalEnvIntFrom(
        allocator,
        &.{ "OPENAI_RETRY_BASE_DELAY_MS", "DEEPSEEK_RETRY_BASE_DELAY_MS" },
    );

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
            break :blk env_api_key orelse defaults.api_key;
        } else env_api_key orelse defaults.api_key;

        const base_url_src = if (table.keys.get("base_url")) |val| blk: {
            if (val == .String) break :blk val.String;
            break :blk env_base_url orelse defaults.base_url;
        } else env_base_url orelse defaults.base_url;

        const model_src = if (table.keys.get("model")) |val| blk: {
            if (val == .String) break :blk val.String;
            break :blk env_model orelse defaults.model;
        } else env_model orelse defaults.model;

        const organization_src = if (table.keys.get("organization")) |val| blk: {
            if (val == .String) break :blk val.String;
            break :blk env_organization;
        } else env_organization;

        const project_src = if (table.keys.get("project")) |val| blk: {
            if (val == .String) break :blk val.String;
            break :blk env_project;
        } else env_project;

        const timeout_ms_src = if (table.keys.get("timeout_ms")) |val| blk: {
            if (val == .Integer and val.Integer >= 0) {
                break :blk @as(u64, @intCast(val.Integer));
            }
            break :blk env_timeout_ms orelse defaults.timeout_ms;
        } else if (env_timeout_ms) |value| blk: {
            break :blk value;
        } else defaults.timeout_ms;

        const max_retries_src = if (table.keys.get("max_retries")) |val| blk: {
            if (val == .Integer and val.Integer >= 0 and val.Integer <= std.math.maxInt(u8)) {
                break :blk @as(u8, @intCast(val.Integer));
            }
            if (env_max_retries) |value| {
                if (value <= std.math.maxInt(u8)) {
                    break :blk @as(u8, @intCast(value));
                }
            }
            break :blk defaults.max_retries;
        } else if (env_max_retries) |value| blk: {
            if (value <= std.math.maxInt(u8)) {
                break :blk @as(u8, @intCast(value));
            }
            break :blk defaults.max_retries;
        } else defaults.max_retries;

        const retry_base_delay_ms_src = if (table.keys.get("retry_base_delay_ms")) |val| blk: {
            if (val == .Integer and val.Integer >= 0) {
                break :blk @as(u64, @intCast(val.Integer));
            }
            break :blk env_retry_base_delay_ms orelse defaults.retry_base_delay_ms;
        } else if (env_retry_base_delay_ms) |value| blk: {
            break :blk value;
        } else defaults.retry_base_delay_ms;

        // Copy while the parsed table is still alive to avoid dangling references.
        api_key = try allocator.dupe(u8, api_key_src);
        base_url = try allocator.dupe(u8, base_url_src);
        model = try allocator.dupe(u8, model_src);
        if (organization_src) |organization_raw| {
            organization = try allocator.dupe(u8, organization_raw);
        } else {
            organization = null;
        }
        if (project_src) |project_raw| {
            project = try allocator.dupe(u8, project_raw);
        } else {
            project = null;
        }
        timeout_ms = timeout_ms_src;
        max_retries = max_retries_src;
        retry_base_delay_ms = retry_base_delay_ms_src;
    } else |_| {
        api_key = try allocator.dupe(u8, env_api_key orelse defaults.api_key);
        base_url = try allocator.dupe(u8, env_base_url orelse defaults.base_url);
        model = try allocator.dupe(u8, env_model orelse defaults.model);
        organization = if (env_organization) |value| try allocator.dupe(u8, value) else null;
        project = if (env_project) |value| try allocator.dupe(u8, value) else null;
        timeout_ms = env_timeout_ms orelse defaults.timeout_ms;
        max_retries = if (env_max_retries) |value| if (value <= std.math.maxInt(u8))
            @as(u8, @intCast(value))
        else
            defaults.max_retries else defaults.max_retries;
        retry_base_delay_ms = env_retry_base_delay_ms orelse defaults.retry_base_delay_ms;
    }

    return Config{
        .api_key = api_key.?,
        .base_url = base_url.?,
        .model = model.?,
        .organization = organization,
        .project = project,
        .timeout_ms = timeout_ms,
        .max_retries = max_retries.?,
        .retry_base_delay_ms = retry_base_delay_ms.?,
    };
}

fn readOptionalEnvVar(allocator: std.mem.Allocator, key: []const u8) !?[]const u8 {
    return std.process.getEnvVarOwned(allocator, key) catch |err| switch (err) {
        error.EnvironmentVariableNotFound => null,
        else => return err,
    };
}

fn readOptionalEnvVarFrom(allocator: std.mem.Allocator, keys: []const []const u8) !?[]const u8 {
    for (keys) |key| {
        if (try readOptionalEnvVar(allocator, key)) |value| {
            return value;
        }
    }
    return null;
}

fn readOptionalEnvIntFrom(allocator: std.mem.Allocator, keys: []const []const u8) !?u64 {
    for (keys) |key| {
        const raw = try readOptionalEnvVar(allocator, key);
        if (raw) |value| {
            defer allocator.free(value);
            const parsed = std.fmt.parseInt(u64, value, 10) catch continue;
            return parsed;
        }
    }
    return null;
}

test "config load resolves file values and fallback chain for missing file" {
    const gpa = std.heap.page_allocator;
    const cwd = std.fs.cwd();
    const pid = std.process.getSelfPid();

    var file_path_buf: [64]u8 = undefined;
    const file_path = try std.fmt.bufPrint(&file_path_buf, "tmp-openai-zig-config-{d}.toml", .{pid});
    {
        var file = try cwd.createFile(file_path, .{ .truncate = true, .read = true, .write = true });
        defer file.close();
        defer _ = cwd.deleteFile(file_path) catch {};

        try file.writer().print(
            \\api_key = "from-file"
            \\base_url = "https://api.example.com/v1"
            \\model = "file-model"
            \\organization = "org-file"
            \\project = "project-file"
            \\timeout_ms = 1234
            \\max_retries = 4
            \\retry_base_delay_ms = 888
        , .{});
    }

    var cfg = try load(gpa, file_path);
    defer cfg.deinit(gpa);

    try std.testing.expectEqualStrings("from-file", cfg.api_key);
    try std.testing.expectEqualStrings("https://api.example.com/v1", cfg.base_url);
    try std.testing.expectEqualStrings("file-model", cfg.model);
    try std.testing.expectEqualStrings("org-file", cfg.organization.?);
    try std.testing.expectEqualStrings("project-file", cfg.project.?);
    try std.testing.expectEqual(@as(?u64, 1234), cfg.timeout_ms);
    try std.testing.expectEqual(@as(u8, 4), cfg.max_retries);
    try std.testing.expectEqual(@as(u64, 888), cfg.retry_base_delay_ms);

    var missing_path_buf: [64]u8 = undefined;
    const missing_path = try std.fmt.bufPrint(&missing_path_buf, "tmp-openai-zig-config-missing-{d}.toml", .{pid});

    const env_api_key = try readOptionalEnvVarFrom(gpa, &.{ "OPENAI_API_KEY", "DEEPSEEK_API_KEY" });
    defer if (env_api_key) |value| gpa.free(value);
    const env_base_url = try readOptionalEnvVarFrom(gpa, &.{ "OPENAI_BASE_URL", "DEEPSEEK_BASE_URL" });
    defer if (env_base_url) |value| gpa.free(value);
    const env_model = try readOptionalEnvVarFrom(gpa, &.{ "OPENAI_MODEL", "DEEPSEEK_MODEL" });
    defer if (env_model) |value| gpa.free(value);
    const env_organization = try readOptionalEnvVarFrom(gpa, &.{"OPENAI_ORGANIZATION"});
    defer if (env_organization) |value| gpa.free(value);
    const env_project = try readOptionalEnvVarFrom(gpa, &.{"OPENAI_PROJECT"});
    defer if (env_project) |value| gpa.free(value);
    const env_timeout_ms = try readOptionalEnvIntFrom(gpa, &.{ "OPENAI_TIMEOUT_MS", "DEEPSEEK_TIMEOUT_MS" });
    const env_max_retries = try readOptionalEnvIntFrom(gpa, &.{ "OPENAI_MAX_RETRIES", "DEEPSEEK_MAX_RETRIES" });
    const env_retry_base_delay_ms = try readOptionalEnvIntFrom(
        gpa,
        &.{ "OPENAI_RETRY_BASE_DELAY_MS", "DEEPSEEK_RETRY_BASE_DELAY_MS" },
    );

    var fallback = try load(gpa, missing_path);
    defer fallback.deinit(gpa);

    const defaults = .{
        .base_url = "https://api.deepseek.com/v1",
        .model = "deepseek-chat",
        .max_retries = @as(u8, 2),
        .retry_base_delay_ms = @as(u64, 500),
    };

    try std.testing.expectEqualStrings(env_api_key orelse "", fallback.api_key);
    try std.testing.expectEqualStrings(env_base_url orelse defaults.base_url, fallback.base_url);
    try std.testing.expectEqualStrings(env_model orelse defaults.model, fallback.model);
    if (env_organization) |value| {
        try std.testing.expectEqualStrings(value, fallback.organization.?);
    } else {
        try std.testing.expect(fallback.organization == null);
    }
    if (env_project) |value| {
        try std.testing.expectEqualStrings(value, fallback.project.?);
    } else {
        try std.testing.expect(fallback.project == null);
    }
    try std.testing.expectEqual(if (env_timeout_ms) |v| v else @as(?u64, null), fallback.timeout_ms);
    const fallback_expected_retries = if (env_max_retries) |value|
        if (value <= std.math.maxInt(u8)) @as(u8, @intCast(value)) else defaults.max_retries
    else
        defaults.max_retries;
    try std.testing.expectEqual(fallback_expected_retries, fallback.max_retries);
    try std.testing.expectEqual(env_retry_base_delay_ms orelse defaults.retry_base_delay_ms, fallback.retry_base_delay_ms);
}
