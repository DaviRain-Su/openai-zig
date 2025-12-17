const std = @import("std");

pub const errors = @import("errors.zig");
pub const transport = @import("transport/http.zig");
pub const resources = @import("resources.zig");

pub const Client = @import("client.zig").Client;

pub fn initClient(allocator: std.mem.Allocator, opts: Client.Options) !Client {
    return Client.init(allocator, opts);
}
