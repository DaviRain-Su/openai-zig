const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const gen = @import("../generated/types.zig");
const common = @import("common.zig");

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
        return common.sendNoBodyTyped(self.transport, allocator, .GET, "/models", gen.ListModelsResponse);
    }

    pub fn list_models_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListModelsResponse) {
        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            .GET,
            "/models",
            gen.ListModelsResponse,
            request_opts,
        );
    }

    /// GET /models
    pub fn list(self: *const Resource, allocator: std.mem.Allocator) errors.Error!std.json.Parsed(gen.ListModelsResponse) {
        return self.list_models(allocator);
    }

    /// GET /models
    pub fn list_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.ListModelsResponse) {
        return self.list_models_with_options(allocator, request_opts);
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
        return common.sendNoBodyTyped(self.transport, allocator, .GET, path, gen.Model);
    }

    pub fn retrieve_model_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        model: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Model) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/models/{s}", .{model}) catch {
            return errors.Error.SerializeError;
        };
        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            .GET,
            path,
            gen.Model,
            request_opts,
        );
    }

    /// GET /models/{model}
    pub fn retrieve(self: *const Resource, allocator: std.mem.Allocator, model: []const u8) errors.Error!std.json.Parsed(gen.Model) {
        return self.retrieve_model(allocator, model);
    }

    pub fn retrieve_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        model: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.Model) {
        return self.retrieve_model_with_options(allocator, model, request_opts);
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
        return common.sendNoBodyTyped(self.transport, allocator, .DELETE, path, gen.DeleteModelResponse);
    }

    pub fn delete_model_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        model: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeleteModelResponse) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/models/{s}", .{model}) catch {
            return errors.Error.SerializeError;
        };
        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            .DELETE,
            path,
            gen.DeleteModelResponse,
            request_opts,
        );
    }

    /// DELETE /models/{model}
    pub fn delete(self: *const Resource, allocator: std.mem.Allocator, model: []const u8) errors.Error!std.json.Parsed(gen.DeleteModelResponse) {
        return self.delete_model(allocator, model);
    }

    pub fn delete_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        model: []const u8,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(gen.DeleteModelResponse) {
        return self.delete_model_with_options(allocator, model, request_opts);
    }
};
