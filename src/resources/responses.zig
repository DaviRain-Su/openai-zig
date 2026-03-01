const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");

pub const CreateResponseRequest = gen.CreateResponse;
pub const CountInputTokensRequest = gen.TokenCountsBody;
pub const CompactResponseRequest = gen.CompactResponseMethodPublicBody;
pub const DeleteResponseResponse = struct {
    id: []const u8 = "",
    object: []const u8 = "",
    deleted: bool = false,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    /// POST /responses
    pub fn create_response(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateResponseRequest,
    ) errors.Error!std.json.Parsed(gen.Response) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        const resp = try self.transport.request(.POST, "/responses", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = "application/json" },
        }, payload);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.Response, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /responses
    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateResponseRequest,
    ) errors.Error!std.json.Parsed(gen.Response) {
        return self.create_response(allocator, req);
    }

    /// GET /responses/{response_id}
    pub fn get_response(
        self: *const Resource,
        allocator: std.mem.Allocator,
        response_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Response) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/responses/{s}", .{response_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.GET, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.Response, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// GET /responses/{response_id}
    pub fn retrieve(
        self: *const Resource,
        allocator: std.mem.Allocator,
        response_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Response) {
        return self.get_response(allocator, response_id);
    }

    /// DELETE /responses/{response_id}
    pub fn delete_response(
        self: *const Resource,
        allocator: std.mem.Allocator,
        response_id: []const u8,
    ) errors.Error!std.json.Parsed(DeleteResponseResponse) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/responses/{s}", .{response_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.DELETE, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(DeleteResponseResponse, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// DELETE /responses/{response_id}
    pub fn delete(
        self: *const Resource,
        allocator: std.mem.Allocator,
        response_id: []const u8,
    ) errors.Error!std.json.Parsed(DeleteResponseResponse) {
        return self.delete_response(allocator, response_id);
    }

    /// POST /responses/{response_id}/cancel
    pub fn cancel_response(
        self: *const Resource,
        allocator: std.mem.Allocator,
        response_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Response) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/responses/{s}/cancel", .{response_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.POST, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.Response, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /responses/{response_id}/cancel
    pub fn cancel(
        self: *const Resource,
        allocator: std.mem.Allocator,
        response_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Response) {
        return self.cancel_response(allocator, response_id);
    }

    /// GET /responses/{response_id}/input_items
    pub fn list_input_items(
        self: *const Resource,
        allocator: std.mem.Allocator,
        response_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ResponseItemList) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/responses/{s}/input_items", .{response_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.GET, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.ResponseItemList, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /responses/input_tokens
    pub fn count_input_tokens(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CountInputTokensRequest,
    ) errors.Error!std.json.Parsed(gen.TokenCountsResource) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        const resp = try self.transport.request(.POST, "/responses/input_tokens", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = "application/json" },
        }, payload);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.TokenCountsResource, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /responses/input_tokens
    pub fn count_tokens(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CountInputTokensRequest,
    ) errors.Error!std.json.Parsed(gen.TokenCountsResource) {
        return self.count_input_tokens(allocator, req);
    }

    /// POST /responses/compact
    pub fn compact(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CompactResponseRequest,
    ) errors.Error!std.json.Parsed(gen.CompactResource) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        const resp = try self.transport.request(.POST, "/responses/compact", &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = "application/json" },
        }, payload);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.CompactResource, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }
};
