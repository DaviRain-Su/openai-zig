const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

/// Minimal request shape for POST /chat/completions (text content only).
pub const ChatMessage = struct {
    role: []const u8,
    content: []const u8,
};

pub const CreateChatCompletionRequest = struct {
    model: []const u8,
    messages: []const ChatMessage,
    max_tokens: ?u32 = null,
    temperature: ?f64 = null,
    stream: ?bool = null,
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    /// GET /chat/completions
    pub fn list_chat_completions(
        self: *const Resource,
        allocator: std.mem.Allocator,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        const resp = try self.transport.request(.GET, "/chat/completions", &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// POST /chat/completions -> dynamic JSON.
    pub fn create_chat_completion(
        self: *const Resource,
        allocator: std.mem.Allocator,
        req: CreateChatCompletionRequest,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var body_writer: std.io.Writer.Allocating = .init(allocator);
        defer body_writer.deinit();
        var json_stream: std.json.Stringify = .{ .writer = &body_writer.writer, .options = .{} };
        json_stream.write(req) catch {
            return errors.Error.SerializeError;
        };
        const payload = body_writer.written();

        const resp = try self.transport.request(.POST, "/chat/completions", &.{
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

    /// GET /chat/completions/{completion_id}
    pub fn get_chat_completion(
        self: *const Resource,
        allocator: std.mem.Allocator,
        completion_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/chat/completions/{s}", .{completion_id}) catch {
            return errors.Error.SerializeError;
        };

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

    /// POST /chat/completions/{completion_id} (generic JSON payload)
    pub fn update_chat_completion(
        self: *const Resource,
        allocator: std.mem.Allocator,
        completion_id: []const u8,
        payload: ?[]const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/chat/completions/{s}", .{completion_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.POST, path, &.{
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

    /// DELETE /chat/completions/{completion_id}
    pub fn delete_chat_completion(
        self: *const Resource,
        allocator: std.mem.Allocator,
        completion_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/chat/completions/{s}", .{completion_id}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.DELETE, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// GET /chat/completions/{completion_id}/messages
    pub fn get_chat_completion_messages(
        self: *const Resource,
        allocator: std.mem.Allocator,
        completion_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/chat/completions/{s}/messages", .{completion_id}) catch {
            return errors.Error.SerializeError;
        };

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
