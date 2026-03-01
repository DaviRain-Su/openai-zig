const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const ProjectGrant = gen.InviteProjectGroupBody;
pub const InviteRequest = gen.InviteRequest;

pub const ListInvitesParams = struct {
    limit: ?u32 = null,
    after: ?[]const u8 = null,
    pub fn list(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListInvitesParams,
    ) errors.Error!std.json.Parsed(gen.InviteListResponse) {
        return self.list_invites(allocator, params);
    }

    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: InviteRequest,
    ) errors.Error!std.json.Parsed(gen.Invite) {
        return self.create_invite(allocator, req);
    }

    pub fn invite_user(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: InviteRequest,
    ) errors.Error!std.json.Parsed(gen.Invite) {
        return self.create_invite(allocator, req);
    }

    pub fn retrieve(
        self: *const Resource,
        allocator: std.mem.Allocator,
        invite_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Invite) {
        return self.retrieve_invite(allocator, invite_id);
    }

    pub fn delete(
        self: *const Resource,
        allocator: std.mem.Allocator,
        invite_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.InviteDeleteResponse) {
        return self.delete_invite(allocator, invite_id);
    }
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn sendJsonTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        return self.sendJsonTypedWithOptions(allocator, method, path, value, T, null);
    }

    fn sendJsonTypedWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
        comptime T: type,
        req_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            method,
            path,
            value,
            T,
            req_opts,
        );
    }

    fn sendNoBodyTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        return self.sendNoBodyTypedWithOptions(allocator, method, path, T, null);
    }

    fn sendNoBodyTypedWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
        req_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            method,
            path,
            T,
            req_opts,
        );
    }

    /// GET /organization/invites
    pub fn list_invites(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListInvitesParams,
    ) errors.Error!std.json.Parsed(gen.InviteListResponse) {
        return self.list_invites_with_options(allocator, params, null);
    }

    pub fn list_invites_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListInvitesParams,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.InviteListResponse) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const writer = fbs.writer();
        try writer.writeAll("/organization/invites");

        var first = true;
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, &first, "limit", @as(u64, limit));
        }
        try common.appendOptionalQueryParam(writer, &first, "after", params.after);
        const path = fbs.getWritten();

        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.InviteListResponse, request_opts);
    }

    /// POST /organization/invites
    pub fn create_invite(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: InviteRequest,
    ) errors.Error!std.json.Parsed(gen.Invite) {
        return self.create_invite_with_options(allocator, req, null);
    }

    pub fn create_invite_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: InviteRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Invite) {
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            "/organization/invites",
            req,
            gen.Invite,
            request_opts,
        );
    }

    /// GET /organization/invites/{invite_id}
    pub fn retrieve_invite(
        self: *const Resource,
        allocator: std.mem.Allocator,
        invite_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Invite) {
        return self.retrieve_invite_with_options(allocator, invite_id, null);
    }

    pub fn retrieve_invite_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        invite_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Invite) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/invites/{s}", .{invite_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.Invite, request_opts);
    }

    /// DELETE /organization/invites/{invite_id}
    pub fn delete_invite(
        self: *const Resource,
        allocator: std.mem.Allocator,
        invite_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.InviteDeleteResponse) {
        return self.delete_invite_with_options(allocator, invite_id, null);
    }

    pub fn delete_invite_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        invite_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.InviteDeleteResponse) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/organization/invites/{s}", .{invite_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .DELETE, path, gen.InviteDeleteResponse, request_opts);
    }

    pub fn list_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListInvitesParams,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.InviteListResponse) {
        return self.list_invites_with_options(allocator, params, request_opts);
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: InviteRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Invite) {
        return self.create_invite_with_options(allocator, req, request_opts);
    }

    pub fn retrieve_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        invite_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Invite) {
        return self.retrieve_invite_with_options(allocator, invite_id, request_opts);
    }

    pub fn delete_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        invite_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.InviteDeleteResponse) {
        return self.delete_invite_with_options(allocator, invite_id, request_opts);
    }
};
