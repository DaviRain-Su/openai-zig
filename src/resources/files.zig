const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    /// GET /files
    pub fn list_files(
        self: *const Resource,
        allocator: std.mem.Allocator,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        const resp = try self.transport.request(.GET, "/files", &.{
            .{ .name = "Accept", .value = "application/json" },
        }, null);
        const body = resp.body;
        defer self.transport.allocator.free(body);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{}) catch {
            return errors.Error.DeserializeError;
        };
        return parsed;
    }

    /// GET /files/{file_id}
    pub fn retrieve_file(
        self: *const Resource,
        allocator: std.mem.Allocator,
        file_id: []const u8,
    ) errors.Error!std.json.Parsed(std.json.Value) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/files/{s}", .{file_id}) catch {
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
