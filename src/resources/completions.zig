const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const CreateCompletionRequest = gen.CreateCompletionRequest;
pub const CreateCompletionResponse = gen.CreateCompletionResponse;
pub const CreateCompletionRawRequest = std.json.Value;

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    pub const StreamCompletionEventHandler = *const fn (
        user_ctx: ?*anyopaque,
        event: std.json.Parsed(std.json.Value),
    ) errors.Error!void;

    pub const StreamCompletionDoneHandler = *const fn (user_ctx: ?*anyopaque) errors.Error!void;

    /// POST /completions -> dynamic JSON
    pub fn create_completion(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRequest,
    ) errors.Error!std.json.Parsed(CreateCompletionResponse) {
        return common.sendJsonTyped(
            self.transport,
            allocator,
            .POST,
            "/completions",
            req,
            CreateCompletionResponse,
        );
    }

    pub fn create_completion_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(CreateCompletionResponse) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            "/completions",
            req,
            CreateCompletionResponse,
            request_opts,
        );
    }

    /// POST /completions (raw JSON payload)
    pub fn create_completion_raw(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRawRequest,
    ) errors.Error!std.json.Parsed(CreateCompletionResponse) {
        return common.sendJsonTyped(
            self.transport,
            allocator,
            .POST,
            "/completions",
            req,
            CreateCompletionResponse,
        );
    }

    /// POST /completions (raw JSON payload with request options)
    pub fn create_completion_raw_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRawRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(CreateCompletionResponse) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            "/completions",
            req,
            CreateCompletionResponse,
            request_opts,
        );
    }

    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRequest,
    ) errors.Error!std.json.Parsed(CreateCompletionResponse) {
        return self.create_completion(allocator, req);
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(CreateCompletionResponse) {
        return self.create_completion_with_options(allocator, req, request_opts);
    }

    /// POST /completions (raw JSON payload)
    pub fn create_raw(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRawRequest,
    ) errors.Error!std.json.Parsed(CreateCompletionResponse) {
        return self.create_completion_raw(allocator, req);
    }

    /// POST /completions (raw JSON payload with request options)
    pub fn create_raw_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRawRequest,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(CreateCompletionResponse) {
        return self.create_completion_raw_with_options(allocator, req, request_opts);
    }

    /// POST /completions (streaming)
    pub fn create_completion_stream(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRequest,
        on_event: StreamCompletionEventHandler,
        user_ctx: ?*anyopaque,
    ) errors.Error!void {
        return self.create_completion_stream_with_done(
            allocator,
            req,
            on_event,
            user_ctx,
            null,
            null,
        );
    }

    pub fn create_completion_stream_with_done(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRequest,
        on_event: StreamCompletionEventHandler,
        user_ctx: ?*anyopaque,
        on_done: ?StreamCompletionDoneHandler,
        done_ctx: ?*anyopaque,
    ) errors.Error!void {
        return self.create_completion_stream_with_options_and_done(
            allocator,
            req,
            on_event,
            user_ctx,
            null,
            on_done,
            done_ctx,
        );
    }

    pub fn create_completion_stream_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRequest,
        on_event: StreamCompletionEventHandler,
        user_ctx: ?*anyopaque,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!void {
        return self.create_completion_stream_with_options_and_done(
            allocator,
            req,
            on_event,
            user_ctx,
            request_opts,
            null,
            null,
        );
    }

    pub fn create_completion_stream_with_options_and_done(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRequest,
        on_event: StreamCompletionEventHandler,
        user_ctx: ?*anyopaque,
        request_opts: ?transport_mod.Transport.RequestOptions,
        on_done: ?StreamCompletionDoneHandler,
        done_ctx: ?*anyopaque,
    ) errors.Error!void {
        var stream_req = req;
        stream_req.stream = true;

        var body_writer = std.io.Writer.Allocating.init(allocator);
        defer body_writer.deinit();

        var json_stream: std.json.Stringify = .{
            .writer = &body_writer.writer,
            .options = .{ .emit_null_optional_fields = false },
        };
        json_stream.write(stream_req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        try common.sendStreamTypedWithDoneWithOptions(
            self.transport,
            allocator,
            .POST,
            "/completions",
            &.{
                .{ .name = "Accept", .value = "text/event-stream" },
                .{ .name = "Content-Type", .value = "application/json" },
            },
            payload,
            std.json.Value,
            on_event,
            user_ctx,
            on_done,
            done_ctx,
            request_opts,
        );
    }

    pub fn create_completion_stream_raw(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRawRequest,
        on_event: StreamCompletionEventHandler,
        user_ctx: ?*anyopaque,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!void {
        return self.create_completion_stream_raw_with_done_and_options(
            allocator,
            req,
            on_event,
            user_ctx,
            request_opts,
            null,
            null,
        );
    }

    pub fn create_completion_stream_raw_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRawRequest,
        on_event: StreamCompletionEventHandler,
        user_ctx: ?*anyopaque,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!void {
        return self.create_completion_stream_raw_with_done_and_options(
            allocator,
            req,
            on_event,
            user_ctx,
            request_opts,
            null,
            null,
        );
    }

    pub fn create_completion_stream_raw_with_done(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRawRequest,
        on_event: StreamCompletionEventHandler,
        user_ctx: ?*anyopaque,
        on_done: ?StreamCompletionDoneHandler,
        done_ctx: ?*anyopaque,
    ) errors.Error!void {
        return self.create_completion_stream_raw_with_done_and_options(
            allocator,
            req,
            on_event,
            user_ctx,
            null,
            on_done,
            done_ctx,
        );
    }

    pub fn create_completion_stream_raw_with_done_and_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRawRequest,
        on_event: StreamCompletionEventHandler,
        user_ctx: ?*anyopaque,
        request_opts: ?transport_mod.Transport.RequestOptions,
        on_done: ?StreamCompletionDoneHandler,
        done_ctx: ?*anyopaque,
    ) errors.Error!void {
        var body_writer = std.io.Writer.Allocating.init(allocator);
        defer body_writer.deinit();

        var json_stream: std.json.Stringify = .{
            .writer = &body_writer.writer,
            .options = .{ .emit_null_optional_fields = false },
        };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        try common.sendStreamTypedWithDoneWithOptions(
            self.transport,
            allocator,
            .POST,
            "/completions",
            &.{
                .{ .name = "Accept", .value = "text/event-stream" },
                .{ .name = "Content-Type", .value = "application/json" },
            },
            payload,
            std.json.Value,
            on_event,
            user_ctx,
            on_done,
            done_ctx,
            request_opts,
        );
    }

    pub fn create_raw_with_options_stream(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRawRequest,
        on_event: StreamCompletionEventHandler,
        user_ctx: ?*anyopaque,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!void {
        return self.create_completion_stream_raw(
            allocator,
            req,
            on_event,
            user_ctx,
            request_opts,
        );
    }

    pub fn create_stream(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRequest,
        on_event: StreamCompletionEventHandler,
        user_ctx: ?*anyopaque,
    ) errors.Error!void {
        return self.create_completion_stream(allocator, req, on_event, user_ctx);
    }

    pub fn create_with_options_stream(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateCompletionRequest,
        on_event: StreamCompletionEventHandler,
        user_ctx: ?*anyopaque,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!void {
        return self.create_completion_stream_with_options(allocator, req, on_event, user_ctx, request_opts);
    }
};

test "create completion request omits null optional fields" {
    const req = CreateCompletionRequest{
        .model = "test-model",
        .prompt = "prompt-text",
    };

    var writer = std.io.Writer.Allocating.init(std.testing.allocator);
    defer writer.deinit();
    var json_stream: std.json.Stringify = .{
        .writer = &writer.writer,
        .options = .{ .emit_null_optional_fields = false },
    };
    try json_stream.write(req);

    const body = writer.written();
    const parsed = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        body,
        .{},
    );
    defer parsed.deinit();

    const expected = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"model\":\"test-model\",\"prompt\":\"prompt-text\"}",
        .{},
    );
    defer expected.deinit();

    try std.testing.expect(std.json.eql(parsed.value, expected.value));
}

test "create completion request includes suffix payload" {
    const req = CreateCompletionRequest{
        .model = "test-model",
        .prompt = "prompt-text",
        .suffix = "suffix-text",
    };

    var writer = std.io.Writer.Allocating.init(std.testing.allocator);
    defer writer.deinit();
    var json_stream: std.json.Stringify = .{
        .writer = &writer.writer,
        .options = .{ .emit_null_optional_fields = false },
    };
    try json_stream.write(req);

    const body = writer.written();
    const parsed = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        body,
        .{},
    );
    defer parsed.deinit();

    const expected = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        "{\"model\":\"test-model\",\"prompt\":\"prompt-text\",\"suffix\":\"suffix-text\"}",
        .{},
    );
    defer expected.deinit();

    try std.testing.expect(std.json.eql(parsed.value, expected.value));
}
