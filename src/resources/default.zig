const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

pub const MultipartRequest = struct {
    content_type: []const u8,
    body: []const u8,
};

pub const BinaryResponse = struct {
    allocator: std.mem.Allocator,
    data: []u8,

    pub fn deinit(self: *BinaryResponse) void {
        self.allocator.free(self.data);
    }
};

pub const ListParams = struct {
    limit: ?u32 = null,
    order: ?[]const u8 = null,
    after: ?[]const u8 = null,
    before: ?[]const u8 = null,
    user: ?[]const u8 = null,
};

pub const CreateAdminApiKeyRequest = struct {
    name: []const u8,
};

pub const DeletedContainer = struct {
    id: []const u8,
    object: []const u8,
    deleted: bool,
};

pub const DeletedContainerFile = struct {
    id: []const u8,
    object: []const u8,
    deleted: bool,
};

pub const DeleteAdminApiKeyResponse = struct {
    id: []const u8,
    object: []const u8,
    deleted: bool,
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
        try common.appendOptionalQueryParam(writer, first, "order", params.order);
        try common.appendOptionalQueryParam(writer, first, "after", params.after);
        try common.appendOptionalQueryParam(writer, first, "before", params.before);
        try common.appendOptionalQueryParam(writer, first, "user", params.user);
    }

    fn sendJson(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        value: anytype,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
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

        const parsed = std.json.parseFromSlice(T, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    fn sendNoBody(
        self: *const Resource,
        allocator: std.mem.Allocator,
        method: std.http.Method,
        path: []const u8,
        comptime T: type,
    ) errors.Error!std.json.Parsed(T) {
        const resp = try self.transport.request(method, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(T, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// Containers
    pub fn list_containers(self: *const Resource, allocator: std.mem.Allocator, params: ListParams) errors.Error!std.json.Parsed(gen.ContainerListResource) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/containers");
        var first = true;
        try appendListParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBody(gen.ContainerListResource, allocator, .GET, path);
    }

    pub fn create_container(self: *const Resource, allocator: std.mem.Allocator, body: gen.CreateContainerBody) errors.Error!std.json.Parsed(gen.ContainerResource) {
        return self.sendJson(gen.ContainerResource, allocator, .POST, "/containers", body);
    }

    pub fn retrieve_container(self: *const Resource, allocator: std.mem.Allocator, container_id: []const u8) errors.Error!std.json.Parsed(gen.ContainerResource) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/containers/{s}", .{container_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(gen.ContainerResource, allocator, .GET, path);
    }

    pub fn delete_container(self: *const Resource, allocator: std.mem.Allocator, container_id: []const u8) errors.Error!std.json.Parsed(DeletedContainer) {
        var path_buf: [160]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/containers/{s}", .{container_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(DeletedContainer, allocator, .DELETE, path);
    }

    pub fn create_container_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        container_id: []const u8,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.ContainerFileResource) {
        var path_buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/containers/{s}/files", .{container_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.POST, path, &.{
            .{ .name = "Accept", .value = "application/json" },
            .{ .name = "Content-Type", .value = payload.content_type },
        }, payload.body);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.ContainerFileResource, allocator, body, .{ .ignore_unknown_fields = true }) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    pub fn list_container_files(
        self: *const Resource,
        allocator: std.mem.Allocator,
        container_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ContainerFileListResource) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/containers/{s}/files", .{container_id});
        var first = true;
        try appendListParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBody(gen.ContainerFileListResource, allocator, .GET, path);
    }

    pub fn retrieve_container_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        container_id: []const u8,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ContainerFileResource) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/containers/{s}/files/{s}", .{ container_id, file_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(gen.ContainerFileResource, allocator, .GET, path);
    }

    pub fn delete_container_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        container_id: []const u8,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(DeletedContainerFile) {
        var buf: [240]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/containers/{s}/files/{s}", .{ container_id, file_id }) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(DeletedContainerFile, allocator, .DELETE, path);
    }

    pub fn retrieve_container_file_content(
        self: *const Resource,
        container_id: []const u8,
        file_id: []const u8,
    ) errors.Error!BinaryResponse {
        var buf: [280]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/containers/{s}/files/{s}/content", .{ container_id, file_id }) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.GET, path, &.{}, null);
        return BinaryResponse{
            .allocator = self.transport.allocator,
            .data = resp.body,
        };
    }

    /// Admin API keys
    pub fn list_admin_api_keys(self: *const Resource, allocator: std.mem.Allocator) errors.Error!std.json.Parsed(gen.ApiKeyList) {
        return self.sendNoBody(gen.ApiKeyList, allocator, .GET, "/organization/admin_api_keys");
    }

    pub fn create_admin_api_key(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateAdminApiKeyRequest,
    ) errors.Error!std.json.Parsed(gen.AdminApiKey) {
        return self.sendJson(gen.AdminApiKey, allocator, .POST, "/organization/admin_api_keys", req);
    }

    pub fn get_admin_api_key(
        self: *const Resource,
        allocator: std.mem.Allocator,
        key_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.AdminApiKey) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/admin_api_keys/{s}", .{key_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(gen.AdminApiKey, allocator, .GET, path);
    }

    pub fn delete_admin_api_key(
        self: *const Resource,
        allocator: std.mem.Allocator,
        key_id: []const u8,
    ) errors.Error!std.json.Parsed(DeleteAdminApiKeyResponse) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/organization/admin_api_keys/{s}", .{key_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(DeleteAdminApiKeyResponse, allocator, .DELETE, path);
    }

    pub fn admin_api_keys_list(self: *const Resource, allocator: std.mem.Allocator) errors.Error!std.json.Parsed(gen.ApiKeyList) {
        return self.list_admin_api_keys(allocator);
    }

    pub fn admin_api_keys_create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateAdminApiKeyRequest,
    ) errors.Error!std.json.Parsed(gen.AdminApiKey) {
        return self.create_admin_api_key(allocator, req);
    }

    pub fn admin_api_keys_get(
        self: *const Resource,
        allocator: std.mem.Allocator,
        key_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.AdminApiKey) {
        return self.get_admin_api_key(allocator, key_id);
    }

    pub fn admin_api_keys_delete(
        self: *const Resource,
        allocator: std.mem.Allocator,
        key_id: []const u8,
    ) errors.Error!std.json.Parsed(DeleteAdminApiKeyResponse) {
        return self.delete_admin_api_key(allocator, key_id);
    }

    /// Responses helpers
    pub fn get_input_token_counts(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.TokenCountsBody,
    ) errors.Error!std.json.Parsed(gen.TokenCountsResource) {
        return self.sendJson(gen.TokenCountsResource, allocator, .POST, "/responses/input_tokens", body);
    }

    pub fn getinputtokencounts(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.TokenCountsBody,
    ) errors.Error!std.json.Parsed(gen.TokenCountsResource) {
        return self.get_input_token_counts(allocator, body);
    }

    pub fn compact_conversation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CompactResponseMethodPublicBody,
    ) errors.Error!std.json.Parsed(gen.CompactResource) {
        return self.sendJson(gen.CompactResource, allocator, .POST, "/responses/compact", body);
    }

    pub fn compactconversation(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CompactResponseMethodPublicBody,
    ) errors.Error!std.json.Parsed(gen.CompactResource) {
        return self.compact_conversation(allocator, body);
    }

    /// ChatKit sessions and threads
    pub fn create_chat_session(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateChatSessionBody,
    ) errors.Error!std.json.Parsed(gen.ChatSessionResource) {
        return self.sendJson(gen.ChatSessionResource, allocator, .POST, "/chatkit/sessions", body);
    }

    pub fn create_chat_session_method(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateChatSessionBody,
    ) errors.Error!std.json.Parsed(gen.ChatSessionResource) {
        return self.create_chat_session(allocator, body);
    }

    pub fn create_session(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateChatSessionBody,
    ) errors.Error!std.json.Parsed(gen.ChatSessionResource) {
        return self.create_chat_session(allocator, body);
    }

    pub fn cancel_chat_session(
        self: *const Resource,
        allocator: std.mem.Allocator,
        session_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ChatSessionResource) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/chatkit/sessions/{s}/cancel", .{session_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(gen.ChatSessionResource, allocator, .POST, path);
    }

    pub fn cancel_chat_session_method(
        self: *const Resource,
        allocator: std.mem.Allocator,
        session_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ChatSessionResource) {
        return self.cancel_chat_session(allocator, session_id);
    }

    pub fn cancel_session(
        self: *const Resource,
        allocator: std.mem.Allocator,
        session_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ChatSessionResource) {
        return self.cancel_chat_session(allocator, session_id);
    }

    pub fn list_threads(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ThreadListResource) {
        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.writeAll("/chatkit/threads");
        var first = true;
        try appendListParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBody(gen.ThreadListResource, allocator, .GET, path);
    }

    pub fn list_threads_method(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ThreadListResource) {
        return self.list_threads(allocator, params);
    }

    /// POST /chatkit/threads
    pub fn create_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateThreadRequest,
    ) errors.Error!std.json.Parsed(gen.ThreadResource) {
        return self.sendJson(gen.ThreadResource, allocator, .POST, "/chatkit/threads", body);
    }

    pub fn retrieve_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ThreadResource) {
        return self.get_thread(allocator, thread_id);
    }

    pub fn list_items(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ThreadItemListResource) {
        return self.list_thread_items(allocator, thread_id, params);
    }

    pub fn get_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ThreadResource) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/chatkit/threads/{s}", .{thread_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(gen.ThreadResource, allocator, .GET, path);
    }

    pub fn get_thread_method(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ThreadResource) {
        return self.get_thread(allocator, thread_id);
    }

    pub fn delete_thread(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeletedThreadResource) {
        var buf: [200]u8 = undefined;
        const path = std.fmt.bufPrint(&buf, "/chatkit/threads/{s}", .{thread_id}) catch {
            return errors.Error.SerializeError;
        };
        return self.sendNoBody(gen.DeletedThreadResource, allocator, .DELETE, path);
    }

    pub fn delete_thread_method(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeletedThreadResource) {
        return self.delete_thread(allocator, thread_id);
    }

    pub fn list_thread_items(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ThreadItemListResource) {
        var buf: [280]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        try w.print("/chatkit/threads/{s}/items", .{thread_id});
        var first = true;
        try appendListParams(w, params, &first);
        const path = fbs.getWritten();
        return self.sendNoBody(gen.ThreadItemListResource, allocator, .GET, path);
    }

    pub fn list_thread_items_method(
        self: *const Resource,
        allocator: std.mem.Allocator,
        thread_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ThreadItemListResource) {
        return self.list_thread_items(allocator, thread_id, params);
    }

    pub fn list(
        self: *const Resource,
        allocator: std.mem.Allocator,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ContainerListResource) {
        return self.list_containers(allocator, params);
    }

    pub fn create(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CreateContainerBody,
    ) errors.Error!std.json.Parsed(gen.ContainerResource) {
        return self.create_container(allocator, body);
    }

    pub fn retrieve(
        self: *const Resource,
        allocator: std.mem.Allocator,
        container_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ContainerResource) {
        return self.retrieve_container(allocator, container_id);
    }

    pub fn delete(
        self: *const Resource,
        allocator: std.mem.Allocator,
        container_id: []const u8,
    ) errors.Error!std.json.Parsed(DeletedContainer) {
        return self.delete_container(allocator, container_id);
    }

    pub fn create_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        container_id: []const u8,
        payload: MultipartRequest,
    ) errors.Error!std.json.Parsed(gen.ContainerFileResource) {
        return self.create_container_file(allocator, container_id, payload);
    }

    pub fn list_files(
        self: *const Resource,
        allocator: std.mem.Allocator,
        container_id: []const u8,
        params: ListParams,
    ) errors.Error!std.json.Parsed(gen.ContainerFileListResource) {
        return self.list_container_files(allocator, container_id, params);
    }

    pub fn get_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        container_id: []const u8,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ContainerFileResource) {
        return self.retrieve_container_file(allocator, container_id, file_id);
    }

    pub fn retrieve_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        container_id: []const u8,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.ContainerFileResource) {
        return self.retrieve_container_file(allocator, container_id, file_id);
    }

    pub fn delete_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        container_id: []const u8,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(DeletedContainerFile) {
        return self.delete_container_file(allocator, container_id, file_id);
    }

    pub fn content(
        self: *const Resource,
        container_id: []const u8,
        file_id: []const u8,
    ) errors.Error!BinaryResponse {
        return self.retrieve_container_file_content(container_id, file_id);
    }

    pub fn list_api_keys(
        self: *const Resource,
        allocator: std.mem.Allocator,
    ) errors.Error!std.json.Parsed(gen.ApiKeyList) {
        return self.list_admin_api_keys(allocator);
    }

    pub fn create_api_key(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateAdminApiKeyRequest,
    ) errors.Error!std.json.Parsed(gen.AdminApiKey) {
        return self.create_admin_api_key(allocator, req);
    }

    pub fn get_api_key(
        self: *const Resource,
        allocator: std.mem.Allocator,
        key_id: []const u8,
    ) errors.Error!std.json.Parsed(gen.AdminApiKey) {
        return self.get_admin_api_key(allocator, key_id);
    }

    pub fn delete_api_key(
        self: *const Resource,
        allocator: std.mem.Allocator,
        key_id: []const u8,
    ) errors.Error!std.json.Parsed(DeleteAdminApiKeyResponse) {
        return self.delete_admin_api_key(allocator, key_id);
    }

    pub fn get_input_tokens(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.TokenCountsBody,
    ) errors.Error!std.json.Parsed(gen.TokenCountsResource) {
        return self.get_input_token_counts(allocator, body);
    }

    pub fn compact(
        self: *const Resource,
        allocator: std.mem.Allocator,
        body: gen.CompactResponseMethodPublicBody,
    ) errors.Error!std.json.Parsed(gen.CompactResource) {
        return self.compact_conversation(allocator, body);
    }
};
