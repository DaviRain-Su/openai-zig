const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

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
    ) errors.Error!std.json.Parsed(gen.ListAuditLogsResponse) {
        return self.list_audit_logs_with_options(allocator, params, null);
    }

    pub fn list_audit_logs_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListAuditLogsParams,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListAuditLogsResponse) {
        var buf: [1024]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const writer = fbs.writer();
        try writer.writeAll("/organization/audit_logs");

        var first = true;
        if (params.effective_at) |range| {
            if (range.gt) |v| {
                try common.appendOptionalQueryParamU64(writer, &first, "effective_at[gt]", v);
            }
            if (range.gte) |v| {
                try common.appendOptionalQueryParamU64(writer, &first, "effective_at[gte]", v);
            }
            if (range.lt) |v| {
                try common.appendOptionalQueryParamU64(writer, &first, "effective_at[lt]", v);
            }
            if (range.lte) |v| {
                try common.appendOptionalQueryParamU64(writer, &first, "effective_at[lte]", v);
            }
        }

        if (params.project_ids) |vals| {
            for (vals) |v| {
                try common.appendQueryParam(writer, &first, "project_ids[]", v);
            }
        }

        if (params.event_types) |vals| {
            for (vals) |v| {
                try common.appendQueryParam(writer, &first, "event_types[]", v);
            }
        }
        if (params.actor_ids) |vals| {
            for (vals) |v| {
                try common.appendQueryParam(writer, &first, "actor_ids[]", v);
            }
        }
        if (params.actor_emails) |vals| {
            for (vals) |v| {
                try common.appendQueryParam(writer, &first, "actor_emails[]", v);
            }
        }
        if (params.resource_ids) |vals| {
            for (vals) |v| {
                try common.appendQueryParam(writer, &first, "resource_ids[]", v);
            }
        }
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, &first, "limit", @as(u64, limit));
        }
        try common.appendOptionalQueryParam(writer, &first, "after", params.after);
        try common.appendOptionalQueryParam(writer, &first, "before", params.before);

        const path = fbs.getWritten();

        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            .GET,
            path,
            gen.ListAuditLogsResponse,
            request_opts,
        );
    }

    pub fn list(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListAuditLogsParams,
    ) errors.Error!std.json.Parsed(gen.ListAuditLogsResponse) {
        return self.list_audit_logs(allocator, params);
    }

    pub fn list_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListAuditLogsParams,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListAuditLogsResponse) {
        return self.list_audit_logs_with_options(allocator, params, request_opts);
    }
};
