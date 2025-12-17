const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

pub const MultipartRequest = struct {
    content_type: []const u8,
    body: []const u8,
};

pub const ListParams = struct {
    limit: ?u32 = null,
    after: ?[]const u8 = null,
    before: ?[]const u8 = null,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn appendListParams(writer: anytype, params: ListParams, sep_start: []const u8) !void {
        var sep = sep_start;
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
    }

    fn sendJson(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(value) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        const resp = try self.transport.request(method, path, &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = "application/json" },
        }, payload);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    fn sendNoBody(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        const resp = try self.transport.request(method, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// Organization-level certificates
    pub fn list_org_certificates(self: *const Resource, allocator: std.mem.Allocator, params: ListParams) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/organization/certificates");
        try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn upload_certificate(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        const resp = try self.transport.request(.POST, "/organization/certificates", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = payload.content_type },
        }, payload.body);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    pub fn activate_org_certificates(self: *const Resource, allocator: std.mem.Allocator) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendNoBody(allocator, .POST, "/organization/certificates/activate");
    }

    pub fn deactivate_org_certificates(self: *const Resource, allocator: std.mem.Allocator) errors.Error!std.json.Parsed(std.json.Value) {
        return self.sendNoBody(allocator, .POST, "/organization/certificates/deactivate");
    }

    pub fn get_certificate(
        self: *const Resource,
        allocator: std.mem.Allocator,
        certificate_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/certificates/{s}", .{certificate_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn modify_certificate(
        self: *const Resource,
        allocator: std.mem.Allocator,
        certificate_id: []const u8,
        body: std.json.Value,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/certificates/{s}", .{certificate_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJson(allocator, .POST, path, body);
    }

    pub fn delete_certificate(
        self: *const Resource,
        allocator: std.mem.Allocator,
        certificate_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/certificates/{s}", .{certificate_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .DELETE, path);
    }

    /// Project-level certificates
    pub fn list_project_certificates(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/organization/projects/{s}/certificates", .{project_id});
        try appendListParams(w, params, "?");
        const path = fbs.getWritten();
        return self.sendNoBody(allocator, .GET, path);
    }

    pub fn activate_project_certificates(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/certificates/activate", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .POST, path);
    }

    pub fn deactivate_project_certificates(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/certificates/deactivate", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(allocator, .POST, path);
    }
};
