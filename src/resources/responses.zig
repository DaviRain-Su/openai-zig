const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

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
        return common.sendJsonTyped(
            self.transport,
            allocator,
            .POST,
            "/responses",
            req,
            gen.Response,
        );
    }

    pub fn create_response_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateResponseRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Response) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            "/responses",
            req,
            gen.Response,
            request_opts,
        );
    }

    /// POST /responses
    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateResponseRequest,
    ) errors.Error!std.json.Parsed(gen.Response) {
        return self.create_response(allocator, req);
    }

    pub fn create_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateResponseRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Response) {
        return self.create_response_with_options(allocator, req, request_opts);
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
        return common.sendNoBodyTyped(self.transport, allocator, .GET, path, gen.Response);
    }

    pub fn get_response_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        response_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Response) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/responses/{s}", .{response_id}) catch {
            return errors.Error.SerializeError;
        };
        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            .GET,
            path,
            gen.Response,
            request_opts,
        );
    }

    /// GET /responses/{response_id}
    pub fn retrieve(
        self: *const Resource,
        allocator: std.mem.Allocator,
        response_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Response) {
        return self.get_response(allocator, response_id);
    }

    pub fn retrieve_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        response_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Response) {
        return self.get_response_with_options(allocator, response_id, request_opts);
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
        return common.sendNoBodyTyped(self.transport, allocator, .DELETE, path, DeleteResponseResponse);
    }

    pub fn delete_response_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        response_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(DeleteResponseResponse) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/responses/{s}", .{response_id}) catch {
            return errors.Error.SerializeError;
        };
        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            .DELETE,
            path,
            DeleteResponseResponse,
            request_opts,
        );
    }

    /// DELETE /responses/{response_id}
    pub fn delete(
        self: *const Resource,
        allocator: std.mem.Allocator,
        response_id: []const u8,
    ) errors.Error!std.json.Parsed(DeleteResponseResponse) {
        return self.delete_response(allocator, response_id);
    }

    pub fn delete_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        response_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(DeleteResponseResponse) {
        return self.delete_response_with_options(allocator, response_id, request_opts);
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
        return common.sendNoBodyTyped(self.transport, allocator, .POST, path, gen.Response);
    }

    pub fn cancel_response_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        response_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Response) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/responses/{s}/cancel", .{response_id}) catch {
            return errors.Error.SerializeError;
        };
        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            path,
            gen.Response,
            request_opts,
        );
    }

    /// POST /responses/{response_id}/cancel
    pub fn cancel(
        self: *const Resource,
        allocator: std.mem.Allocator,
        response_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.Response) {
        return self.cancel_response(allocator, response_id);
    }

    pub fn cancel_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        response_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Response) {
        return self.cancel_response_with_options(allocator, response_id, request_opts);
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
        return common.sendNoBodyTyped(self.transport, allocator, .GET, path, gen.ResponseItemList);
    }

    pub fn list_input_items_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        response_id: []const u8,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ResponseItemList) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/responses/{s}/input_items", .{response_id}) catch {
            return errors.Error.SerializeError;
        };
        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            .GET,
            path,
            gen.ResponseItemList,
            request_opts,
        );
    }

    /// POST /responses/input_tokens
    pub fn count_input_tokens(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CountInputTokensRequest,
    ) errors.Error!std.json.Parsed(gen.TokenCountsResource) {
        return common.sendJsonTyped(
            self.transport,
            allocator,
            .POST,
            "/responses/input_tokens",
            req,
            gen.TokenCountsResource,
        );
    }

    pub fn count_input_tokens_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CountInputTokensRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.TokenCountsResource) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            "/responses/input_tokens",
            req,
            gen.TokenCountsResource,
            request_opts,
        );
    }

    /// POST /responses/input_tokens
    pub fn count_tokens(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CountInputTokensRequest,
    ) errors.Error!std.json.Parsed(gen.TokenCountsResource) {
        return self.count_input_tokens(allocator, req);
    }

    pub fn count_tokens_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CountInputTokensRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.TokenCountsResource) {
        return self.count_input_tokens_with_options(allocator, req, request_opts);
    }

    /// POST /responses/compact
    pub fn compact(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CompactResponseRequest,
    ) errors.Error!std.json.Parsed(gen.CompactResource) {
        return common.sendJsonTyped(
            self.transport,
            allocator,
            .POST,
            "/responses/compact",
            req,
            gen.CompactResource,
        );
    }

    pub fn compact_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CompactResponseRequest,
        request_opts: transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.CompactResource) {
        return common.sendJsonTypedWithOptions(
            self.transport,
            allocator,
            .POST,
            "/responses/compact",
            req,
            gen.CompactResource,
            request_opts,
        );
    }
};
