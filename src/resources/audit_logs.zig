const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

pub const Range = struct {
    gt: ?u64 = null,
    gte: ?u64 = null,
    lt: ?u64 = null,
    lte: ?u64 = null,
};

pub const ListAuditLogsParams = struct {
    effective_at: ?Range = null,
    project_ids: ?[]const []const u8 = null,
    event_types: ?[]const []const u8 = null,
    actor_ids: ?[]const []const u8 = null,
    actor_emails: ?[]const []const u8 = null,
    resource_ids: ?[]const []const u8 = null,
    limit: ?u32 = null,
    after: ?[]const u8 = null,
    before: ?[]const u8 = null,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    /// GET /organization/audit_logs
    pub fn list_audit_logs(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListAuditLogsParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [1024]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const writer = fbs.writer();
        try writer.writeAll("/organization/audit_logs");

        var sep: []const u8 = "?";
        if (params.effective_at) |range| {
            if (range.gt) |v| {
                try writer.print("{s}effective_at[gt]={d}", .{ sep, v });
                sep = "&";
            }
            if (range.gte) |v| {
                try writer.print("{s}effective_at[gte]={d}", .{ sep, v });
                sep = "&";
            }
            if (range.lt) |v| {
                try writer.print("{s}effective_at[lt]={d}", .{ sep, v });
                sep = "&";
            }
            if (range.lte) |v| {
                try writer.print("{s}effective_at[lte]={d}", .{ sep, v });
                sep = "&";
            }
        }

        if (params.project_ids) |vals| {
            for (vals) |v| {
                try writer.print("{s}project_ids[]={s}", .{ sep, v });
                sep = "&";
            }
        }
        if (params.event_types) |vals| {
            for (vals) |v| {
                try writer.print("{s}event_types[]={s}", .{ sep, v });
                sep = "&";
            }
        }
        if (params.actor_ids) |vals| {
            for (vals) |v| {
                try writer.print("{s}actor_ids[]={s}", .{ sep, v });
                sep = "&";
            }
        }
        if (params.actor_emails) |vals| {
            for (vals) |v| {
                try writer.print("{s}actor_emails[]={s}", .{ sep, v });
                sep = "&";
            }
        }
        if (params.resource_ids) |vals| {
            for (vals) |v| {
                try writer.print("{s}resource_ids[]={s}", .{ sep, v });
                sep = "&";
            }
        }
        if (params.limit) |limit| {
            try writer.print("{s}limit={d}", .{ sep, limit });
            sep = "&";
        }
        if (params.after) |after| {
            try writer.print("{s}after={s}", .{ sep, after });
            sep = "&";
        }
        if (params.before) |before| {
            try writer.print("{s}before={s}", .{ sep, before });
        }

        const path = fbs.getWritten();

        const resp = try self.transport.request(.GET, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }
};
