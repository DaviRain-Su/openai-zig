const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    /// GET /models -> dynamic JSON (models list)
    pub fn list_models(
        self: *const Resource,
        allocator: std.mem.Allocator,
    ) errors.Error!std.json.Parsed(gen.ListModelsResponse) {
        const resp = try self.transport.request(.GET, "/models", &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.ListModelsResponse, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// GET /models/{model}
    pub fn retrieve_model(
        self: *const Resource,
        allocator: std.mem.Allocator,
        model: []const u8,
    ) errors.Error!std.json.Parsed(gen.Model) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/models/{s}", .{model}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.GET, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.Model, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// DELETE /models/{model}
    pub fn delete_model(
        self: *const Resource,
        allocator: std.mem.Allocator,
        model: []const u8,
    ) errors.Error!std.json.Parsed(gen.DeleteModelResponse) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/models/{s}", .{model}) catch {
            return errors.Error.SerializeError;
        };

        const resp = try self.transport.request(.DELETE, path, &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(gen.DeleteModelResponse, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }
};
