const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const ListParams = struct {
    after: ?[]const u8 = null,
    limit: ?u32 = null,
    metadata: ?std.json.Value = null,
};

pub const ListCheckpointsParams = struct {
    after: ?[]const u8 = null,
    limit: ?u32 = null,
};

pub const ListEventsParams = struct {
    after: ?[]const u8 = null,
    limit: ?u32 = null,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    fn appendListParams(writer: anytype, params: ListParams, first: *bool) !void {
        if (params.after) |after| {
            try common.appendOptionalQueryParam(writer, first, "after", after);
        }
        if (params.limit) |limit| {
            try common.appendOptionalQueryParamU64(writer, first, "limit", @as(u64, limit));
        }
        if (params.metadata) |meta| {
            _ = meta;
        }
    }

    fn appendBasicList(writer: anytype, after: ?[]const u8, limit: ?u32, first: *bool) !void {
        if (after) |a| {
            try common.appendOptionalQueryParam(writer, first, "after", a);
        }
        if (limit) |l| {
            try common.appendOptionalQueryParamU64(writer, first, "limit", @as(u64, l));
        }
    }

    fn sendJsonTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendJsonTyped(self.transport, allocator, method, path, value, T);
    }

    fn sendJsonTypedWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
        comptime T: type,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            method,
            path,
            value,
            T,
            request_opts,
        );
    }

    fn sendNoBodyTyped(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendNoBodyTyped(self.transport, allocator, method, path, T);
    }

    fn sendNoBodyTypedWithOptions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(T) {
        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            method,
            path,
            T,
            request_opts,
        );
    }

    /// POST /fine_tuning/alpha/graders/run
    pub fn run(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateEvalRunRequest,
    ) errors.Error!std.json.Parsed(gen.EvalRun) {
        return self.run_with_options(allocator, body, null);
    }

    pub fn run_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateEvalRunRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.EvalRun) {
        return self.run_grader_with_options(allocator, body, request_opts);
    }

    /// POST /fine_tuning/alpha/graders/validate
    pub fn validate(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateEvalRunRequest,
    ) errors.Error!std.json.Parsed(gen.EvalRun) {
        return self.validate_with_options(allocator, body, null);
    }

    pub fn validate_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateEvalRunRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.EvalRun) {
        return self.validate_grader_with_options(allocator, body, request_opts);
    }

    /// POST /fine_tuning/alpha/graders/run
    pub fn run_grader(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateEvalRunRequest,
    ) errors.Error!std.json.Parsed(gen.EvalRun) {
        return self.run_grader_with_options(allocator, body, null);
    }

    pub fn run_grader_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateEvalRunRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.EvalRun) {
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            "/fine_tuning/alpha/graders/run",
            body,
            gen.EvalRun,
            request_opts,
        );
    }

    /// POST /fine_tuning/alpha/graders/validate
    pub fn validate_grader(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateEvalRunRequest,
    ) errors.Error!std.json.Parsed(gen.EvalRun) {
        return self.validate_grader_with_options(allocator, body, null);
    }

    pub fn validate_grader_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateEvalRunRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.EvalRun) {
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            "/fine_tuning/alpha/graders/validate",
            body,
            gen.EvalRun,
            request_opts,
        );
    }

    pub fn create_fine_tuning_checkpoint_permission(
        self: *const Resource,
        allocator: std.mem.Allocator,
        checkpoint_id: []const u8,
        body: gen.CreateFineTuningCheckpointPermissionRequest,
    ) errors.Error!std.json.Parsed(gen.FineTuningCheckpointPermission) {
        return self.create_checkpoint_permission_with_options(allocator, checkpoint_id, body, null);
    }

    pub fn create_fine_tuning_checkpoint_permission_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        checkpoint_id: []const u8,
        body: gen.CreateFineTuningCheckpointPermissionRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.FineTuningCheckpointPermission) {
        return self.create_checkpoint_permission_with_options(allocator, checkpoint_id, body, request_opts);
    }

    pub fn delete_fine_tuning_checkpoint_permission(
        self: *const Resource,
        allocator: std.mem.Allocator,
        checkpoint_id: []const u8,
        permission_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteFineTuningCheckpointPermissionResponse) {
        return self.delete_checkpoint_permission_with_options(allocator, checkpoint_id, permission_id, null);
    }

    pub fn delete_fine_tuning_checkpoint_permission_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        checkpoint_id: []const u8,
        permission_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeleteFineTuningCheckpointPermissionResponse) {
        return self.delete_checkpoint_permission_with_options(allocator, checkpoint_id, permission_id, request_opts);
    }

    pub fn list_fine_tuning_checkpoint_permissions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        checkpoint_id: []const u8,
        params: ListCheckpointsParams,
    ) errors.Error!std.json.Parsed(gen.ListFineTuningCheckpointPermissionResponse) {
        return self.list_checkpoint_permissions_with_options(allocator, checkpoint_id, params, null);
    }

    pub fn list_fine_tuning_checkpoint_permissions_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        checkpoint_id: []const u8,
        params: ListCheckpointsParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListFineTuningCheckpointPermissionResponse) {
        return self.list_checkpoint_permissions_with_options(allocator, checkpoint_id, params, request_opts);
    }

    /// POST /fine_tuning/checkpoints/{fine_tuned_model_checkpoint}/permissions
    pub fn create_checkpoint_permission(
        self: *const Resource,
        allocator: std.mem.Allocator,
        checkpoint_id: []const u8,
        body: gen.CreateFineTuningCheckpointPermissionRequest,
    ) errors.Error!std.json.Parsed(gen.FineTuningCheckpointPermission) {
        return self.create_checkpoint_permission_with_options(allocator, checkpoint_id, body, null);
    }

    pub fn create_checkpoint_permission_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        checkpoint_id: []const u8,
        body: gen.CreateFineTuningCheckpointPermissionRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.FineTuningCheckpointPermission) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/fine_tuning/checkpoints/{s}/permissions", .{checkpoint_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            path,
            body,
            gen.FineTuningCheckpointPermission,
            request_opts,
        );
    }

    /// DELETE /fine_tuning/checkpoints/{fine_tuned_model_checkpoint}/permissions/{permission_id}
    pub fn delete_checkpoint_permission(
        self: *const Resource,
        allocator: std.mem.Allocator,
        checkpoint_id: []const u8,
        permission_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteFineTuningCheckpointPermissionResponse) {
        return self.delete_checkpoint_permission_with_options(allocator, checkpoint_id, permission_id, null);
    }

    pub fn delete_checkpoint_permission_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        checkpoint_id: []const u8,
        permission_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeleteFineTuningCheckpointPermissionResponse) {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/fine_tuning/checkpoints/{s}/permissions/{s}", .{ checkpoint_id, permission_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .DELETE,
            path,
            gen.DeleteFineTuningCheckpointPermissionResponse,
            request_opts,
        );
    }

    /// GET /fine_tuning/checkpoints/{fine_tuned_model_checkpoint}/permissions
    pub fn list_checkpoint_permissions(
        self: *const Resource,
        allocator: std.mem.Allocator,
        checkpoint_id: []const u8,
        params: ListCheckpointsParams,
    ) errors.Error!std.json.Parsed(gen.ListFineTuningCheckpointPermissionResponse) {
        return self.list_checkpoint_permissions_with_options(allocator, checkpoint_id, params, null);
    }

    pub fn list_checkpoint_permissions_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        checkpoint_id: []const u8,
        params: ListCheckpointsParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListFineTuningCheckpointPermissionResponse) {
        var buf: [320]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/fine_tuning/checkpoints/{s}/permissions", .{checkpoint_id});
        var first = true;
        try appendBasicList(w, params.after, params.limit, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ListFineTuningCheckpointPermissionResponse,
            request_opts,
        );
    }

    /// POST /fine_tuning/jobs
    pub fn create_job(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateFineTuningJobRequest,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        return self.create_job_with_options(allocator, body, null);
    }

    pub fn create_job_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateFineTuningJobRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        return self.sendJsonTypedWithOptions(
            allocator,
            .POST,
            "/fine_tuning/jobs",
            body,
            gen.FineTuningJob,
            request_opts,
        );
    }

    pub fn create_fine_tuning_job(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateFineTuningJobRequest,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        return self.create_job_with_options(allocator, body, null);
    }

    pub fn create_fine_tuning_job_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateFineTuningJobRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        return self.create_job_with_options(allocator, body, request_opts);
    }

    /// GET /fine_tuning/jobs
    pub fn list_jobs(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ListPaginatedFineTuningJobsResponse) {
        return self.list_jobs_with_options(allocator, params, null);
    }

    pub fn list_jobs_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListPaginatedFineTuningJobsResponse) {
        var buf: [320]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/fine_tuning/jobs");
        var first = true;
        try appendListParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ListPaginatedFineTuningJobsResponse,
            request_opts,
        );
    }

    pub fn list_paginated_fine_tuning_jobs(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ListPaginatedFineTuningJobsResponse) {
        return self.list_jobs_with_options(allocator, params, null);
    }

    pub fn list_paginated_fine_tuning_jobs_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListPaginatedFineTuningJobsResponse) {
        return self.list_jobs_with_options(allocator, params, request_opts);
    }

    /// GET /fine_tuning/jobs/{fine_tuning_job_id}
    pub fn retrieve_job(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        return self.retrieve_job_with_options(allocator, job_id, null);
    }

    pub fn retrieve_job_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/fine_tuning/jobs/{s}", .{job_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.FineTuningJob,
            request_opts,
        );
    }

    pub fn retrieve_fine_tuning_job(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        return self.retrieve_job_with_options(allocator, job_id, null);
    }

    pub fn retrieve_fine_tuning_job_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        return self.retrieve_job_with_options(allocator, job_id, request_opts);
    }

    /// POST /fine_tuning/jobs/{fine_tuning_job_id}/cancel
    pub fn cancel_job(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        return self.cancel_job_with_options(allocator, job_id, null);
    }

    pub fn cancel_job_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/fine_tuning/jobs/{s}/cancel", .{job_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .POST,
            path,
            gen.FineTuningJob,
            request_opts,
        );
    }

    pub fn cancel_fine_tuning_job(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        return self.cancel_job_with_options(allocator, job_id, null);
    }

    pub fn cancel_fine_tuning_job_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        return self.cancel_job_with_options(allocator, job_id, request_opts);
    }

    /// POST /fine_tuning/jobs/{fine_tuning_job_id}/pause
    pub fn pause_job(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        return self.pause_job_with_options(allocator, job_id, null);
    }

    pub fn pause_job_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/fine_tuning/jobs/{s}/pause", .{job_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .POST,
            path,
            gen.FineTuningJob,
            request_opts,
        );
    }

    pub fn pause_fine_tuning_job(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        return self.pause_job_with_options(allocator, job_id, null);
    }

    pub fn pause_fine_tuning_job_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        return self.pause_job_with_options(allocator, job_id, request_opts);
    }

    /// POST /fine_tuning/jobs/{fine_tuning_job_id}/resume
    pub fn resume_job(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        return self.resume_job_with_options(allocator, job_id, null);
    }

    pub fn resume_job_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/fine_tuning/jobs/{s}/resume", .{job_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .POST,
            path,
            gen.FineTuningJob,
            request_opts,
        );
    }

    pub fn resume_fine_tuning_job(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        return self.resume_job_with_options(allocator, job_id, null);
    }

    pub fn resume_fine_tuning_job_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.FineTuningJob) {
        return self.resume_job_with_options(allocator, job_id, request_opts);
    }

    /// GET /fine_tuning/jobs/{fine_tuning_job_id}/checkpoints
    pub fn list_job_checkpoints(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        params: ListCheckpointsParams,
    ) errors.Error!std.json.Parsed(gen.ListFineTuningJobCheckpointsResponse) {
        return self.list_job_checkpoints_with_options(allocator, job_id, params, null);
    }

    pub fn list_job_checkpoints_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        params: ListCheckpointsParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListFineTuningJobCheckpointsResponse) {
        var buf: [320]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/fine_tuning/jobs/{s}/checkpoints", .{job_id});
        var first = true;
        try appendBasicList(w, params.after, params.limit, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ListFineTuningJobCheckpointsResponse,
            request_opts,
        );
    }

    pub fn list_fine_tuning_job_checkpoints(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        params: ListCheckpointsParams,
    ) errors.Error!std.json.Parsed(gen.ListFineTuningJobCheckpointsResponse) {
        return self.list_job_checkpoints_with_options(allocator, job_id, params, null);
    }

    pub fn list_fine_tuning_job_checkpoints_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        params: ListCheckpointsParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListFineTuningJobCheckpointsResponse) {
        return self.list_job_checkpoints_with_options(allocator, job_id, params, request_opts);
    }

    /// GET /fine_tuning/jobs/{fine_tuning_job_id}/events
    pub fn list_job_events(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        params: ListEventsParams,
    ) errors.Error!std.json.Parsed(gen.ListFineTuningJobEventsResponse) {
        return self.list_job_events_with_options(allocator, job_id, params, null);
    }

    pub fn list_job_events_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        params: ListEventsParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListFineTuningJobEventsResponse) {
        var buf: [320]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/fine_tuning/jobs/{s}/events", .{job_id});
        var first = true;
        try appendBasicList(w, params.after, params.limit, &first);
        const path = fbs.getWritten();
        return self.sendNoBodyTypedWithOptions(
            allocator,
            .GET,
            path,
            gen.ListFineTuningJobEventsResponse,
            request_opts,
        );
    }

    pub fn list_fine_tuning_events(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        params: ListEventsParams,
    ) errors.Error!std.json.Parsed(gen.ListFineTuningJobEventsResponse) {
        return self.list_job_events_with_options(allocator, job_id, params, null);
    }

    pub fn list_fine_tuning_events_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        job_id: []const u8,
        params: ListEventsParams,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListFineTuningJobEventsResponse) {
        return self.list_job_events_with_options(allocator, job_id, params, request_opts);
    }
};
