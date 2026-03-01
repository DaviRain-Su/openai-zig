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

    const env_api_key = try readOptionalEnvVar(allocator, "OPENAI_API_KEY");
    defer if (env_api_key) |val| allocator.free(val);
    const env_deepseek_api_key = try readOptionalEnvVar(allocator, "DEEPSEEK_API_KEY");
    defer if (env_deepseek_api_key) |val| allocator.free(val);
    const env_base_url = try readOptionalEnvVar(allocator, "OPENAI_BASE_URL");
    defer if (env_base_url) |val| allocator.free(val);
    const env_model = try readOptionalEnvVar(allocator, "OPENAI_MODEL");
    defer if (env_model) |val| allocator.free(val);
    const env_organization = try readOptionalEnvVar(allocator, "OPENAI_ORGANIZATION");
    defer if (env_organization) |val| allocator.free(val);
    const env_project = try readOptionalEnvVar(allocator, "OPENAI_PROJECT");
    defer if (env_project) |val| allocator.free(val);
    const env_timeout_ms = try readOptionalEnvInt(allocator, "OPENAI_TIMEOUT_MS");
    const env_max_retries = try readOptionalEnvInt(allocator, "OPENAI_MAX_RETRIES");
    const env_retry_base_delay_ms = try readOptionalEnvInt(allocator, "OPENAI_RETRY_BASE_DELAY_MS");

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
            break :blk env_api_key orelse env_deepseek_api_key orelse defaults.api_key;
        } else env_api_key orelse env_deepseek_api_key orelse defaults.api_key;

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
        api_key = try allocator.dupe(u8, env_api_key orelse env_deepseek_api_key orelse defaults.api_key);
        base_url = try allocator.dupe(u8, env_base_url orelse defaults.base_url);
        model = try allocator.dupe(u8, env_model orelse defaults.model);
        organization = if (env_organization) |value| try allocator.dupe(u8, value) else null;
        project = if (env_project) |value| try allocator.dupe(u8, value) else null;
        timeout_ms = env_timeout_ms orelse defaults.timeout_ms;
        max_retries = if (env_max_retries) |value| if (value <= std.math.maxInt(u8))
            @as(u8, @intCast(value))
        else
            defaults.max_retries
        else
            defaults.max_retries;
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

fn readOptionalEnvInt(allocator: std.mem.Allocator, key: []const u8) !?u64 {
    const raw = std.process.getEnvVarOwned(allocator, key) catch |err| switch (err) {
        error.EnvironmentVariableNotFound => return null,
        else => return err,
    };
    defer allocator.free(raw);
    return std.fmt.parseInt(u64, raw, 10) catch null;
}
