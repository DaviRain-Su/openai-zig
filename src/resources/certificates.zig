const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

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

    fn appendListParams(writer: anytype, params: ListParams, first: *bool) !void {
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, first, "limit", @as(u64, limit));
        }
        try common.appendOptionalQueryParam(writer, first, "after", params.after);
        try common.appendOptionalQueryParam(writer, first, "before", params.before);
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

    fn sendMultipartWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        payload: MultipartRequest,
        comptime T: type,
        req_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendMultipartTypedWithOptions(
            self.transport,
            allocator,
            method,
            path,
            payload,
            T,
            req_opts,
        );
    }

    /// Organization-level certificates
    pub fn list_org_certificates(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ListCertificatesResponse) {
        return self.list_org_certificates_with_options(allocator, params, null);
    }

    pub fn list_org_certificates_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListCertificatesResponse) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/organization/certificates");
        var first = true;
        try appendListParams(w, params, &first);
        const path = fbs.getWritten();

        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ListCertificatesResponse,
            request_opts,
        );
    }

    pub fn list_organization_certificates(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ListCertificatesResponse) {
        return self.list_org_certificates(allocator, params);
    }

    pub fn upload_certificate(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.Certificate) {
        return self.upload_certificate_with_options(allocator, payload, null);
    }

    pub fn upload_certificate_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Certificate) {
        return self.sendMultipartWithOptions(
            allocator,
            .POST,
            "/organization/certificates",
            payload,
            gen.Certificate,
            request_opts,
        );
    }

    pub fn activate_org_certificates(
        self: *const Resource,
        allocator: std.mem.Allocator,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        return self.activate_org_certificates_with_options(allocator, null);
    }

    pub fn activate_org_certificates_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .POST,
            "/organization/certificates/activate",
            gen.ToggleCertificatesRequest,
            request_opts,
        );
    }

    pub fn activate_organization_certificates(
        self: *const Resource,
        allocator: std.mem.Allocator,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        return self.activate_org_certificates(allocator);
    }

    pub fn deactivate_org_certificates(
        self: *const Resource,
        allocator: std.mem.Allocator,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        return self.deactivate_org_certificates_with_options(allocator, null);
    }

    pub fn deactivate_org_certificates_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .POST,
            "/organization/certificates/deactivate",
            gen.ToggleCertificatesRequest,
            request_opts,
        );
    }

    pub fn deactivate_organization_certificates(
        self: *const Resource,
        allocator: std.mem.Allocator,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        return self.deactivate_org_certificates(allocator);
    }

    pub fn get_certificate(
        self: *const Resource,
        allocator: std.mem.Allocator,
        certificate_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Certificate) {
        return self.get_certificate_with_options(allocator, certificate_id, null);
    }

    pub fn get_certificate_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        certificate_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Certificate) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/certificates/{s}", .{certificate_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(allocator, .GET, path, gen.Certificate, request_opts);
    }

    pub fn modify_certificate(
        self: *const Resource,
        allocator: std.mem.Allocator,
        certificate_id: []const u8,
        body: gen.ModifyCertificateRequest,
    ) errors.Error!std.json.Parsed(gen.Certificate) {
        return self.modify_certificate_with_options(allocator, certificate_id, body, null);
    }

    pub fn modify_certificate_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        certificate_id: []const u8,
        body: gen.ModifyCertificateRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Certificate) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/certificates/{s}", .{certificate_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.Certificate,
            request_opts,
        );
    }

    pub fn delete_certificate(
        self: *const Resource,
        allocator: std.mem.Allocator,
        certificate_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteCertificateResponse) {
        return self.delete_certificate_with_options(allocator, certificate_id, null);
    }

    pub fn delete_certificate_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        certificate_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeleteCertificateResponse) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/certificates/{s}", .{certificate_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .DELETE,
            path,
            gen.DeleteCertificateResponse,
            request_opts,
        );
    }

    /// Project-level certificates
    pub fn list_project_certificates(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ListCertificatesResponse) {
        return self.list_project_certificates_with_options(allocator, project_id, params, null);
    }

    pub fn list_project_certificates_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListCertificatesResponse) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/organization/projects/{s}/certificates", .{project_id});
        var first = true;
        try appendListParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ListCertificatesResponse,
            request_opts,
        );
    }

    pub fn activate_project_certificates(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        return self.activate_project_certificates_with_options(allocator, project_id, null);
    }

    pub fn activate_project_certificates_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/certificates/activate", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .POST,
            path,
            gen.ToggleCertificatesRequest,
            request_opts,
        );
    }

    pub fn deactivate_project_certificates(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        return self.deactivate_project_certificates_with_options(allocator, project_id, null);
    }

    pub fn deactivate_project_certificates_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/projects/{s}/certificates/deactivate", .{project_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .POST,
            path,
            gen.ToggleCertificatesRequest,
            request_opts,
        );
    }

    pub fn list(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ListCertificatesResponse) {
        return self.list_org_certificates(allocator, params);
    }

    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.Certificate) {
        return self.upload_certificate(allocator, payload);
    }

    pub fn activate(
        self: *const Resource,
        allocator: std.mem.Allocator,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        return self.activate_org_certificates(allocator);
    }

    pub fn deactivate(
        self: *const Resource,
        allocator: std.mem.Allocator,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        return self.deactivate_org_certificates(allocator);
    }

    pub fn get(
        self: *const Resource,
        allocator: std.mem.Allocator,
        certificate_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Certificate) {
        return self.get_certificate(allocator, certificate_id);
    }

    pub fn modify(
        self: *const Resource,
        allocator: std.mem.Allocator,
        certificate_id: []const u8,
        body: gen.ModifyCertificateRequest,
    ) errors.Error!std.json.Parsed(gen.Certificate) {
        return self.modify_certificate(allocator, certificate_id, body);
    }

    pub fn delete(
        self: *const Resource,
        allocator: std.mem.Allocator,
        certificate_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteCertificateResponse) {
        return self.delete_certificate(allocator, certificate_id);
    }

    pub fn list_project(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ListCertificatesResponse) {
        return self.list_project_certificates(allocator, project_id, params);
    }

    pub fn activate_project(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        return self.activate_project_certificates(allocator, project_id);
    }

    pub fn deactivate_project(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        return self.deactivate_project_certificates(allocator, project_id);
    }

    pub fn list_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListCertificatesResponse) {
        return self.list_org_certificates_with_options(allocator, params, request_opts);
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        payload: MultipartRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Certificate) {
        return self.upload_certificate_with_options(allocator, payload, request_opts);
    }

    pub fn activate_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        return self.activate_org_certificates_with_options(allocator, request_opts);
    }

    pub fn deactivate_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        return self.deactivate_org_certificates_with_options(allocator, request_opts);
    }

    pub fn get_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        certificate_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Certificate) {
        return self.get_certificate_with_options(allocator, certificate_id, request_opts);
    }

    pub fn modify_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        certificate_id: []const u8,
        body: gen.ModifyCertificateRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Certificate) {
        return self.modify_certificate_with_options(allocator, certificate_id, body, request_opts);
    }

    pub fn delete_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        certificate_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeleteCertificateResponse) {
        return self.delete_certificate_with_options(allocator, certificate_id, request_opts);
    }

    pub fn list_project_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        params: ListParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListCertificatesResponse) {
        return self.list_project_certificates_with_options(allocator, project_id, params, request_opts);
    }

    pub fn activate_project_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        return self.activate_project_certificates_with_options(allocator, project_id, request_opts);
    }

    pub fn deactivate_project_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        project_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ToggleCertificatesRequest) {
        return self.deactivate_project_certificates_with_options(allocator, project_id, request_opts);
    }
};
