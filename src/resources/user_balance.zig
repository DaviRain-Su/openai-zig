const std = @import("std");
const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");
const common = @import("common.zig");

pub const UserBalanceInfo = struct {
    currency: []const u8 = "",
    total_balance: []const u8 = "",
    granted_balance: []const u8 = "",
    topped_up_balance: []const u8 = "",
};

pub const GetUserBalanceResponse = struct {
    is_available: bool = false,
    balance_infos: []const UserBalanceInfo = &.{},
};

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    pub fn get_user_balance(
        self: *const Resource,
        allocator: std.mem.Allocator,
    ) errors.Error!std.json.Parsed(GetUserBalanceResponse) {
        return self.get_user_balance_with_options(allocator, null);
    }

    pub fn get_user_balance_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(GetUserBalanceResponse) {
        return common.sendNoBodyTypedWithOptions(
            self.transport,
            allocator,
            .GET,
            "/user/balance",
            GetUserBalanceResponse,
            request_opts,
        );
    }

    pub fn balance(
        self: *const Resource,
        allocator: std.mem.Allocator,
    ) errors.Error!std.json.Parsed(GetUserBalanceResponse) {
        return self.get_user_balance(allocator);
    }

    pub fn balance_with_options(
        self: *const Resource,
        allocator: std.mem.Allocator,
        request_opts: ?transport_mod.Transport.RequestOptions,
    ) errors.Error!std.json.Parsed(GetUserBalanceResponse) {
        return self.get_user_balance_with_options(allocator, request_opts);
    }
};

test "user balance response can parse common shape" {
    const parsed = try std.json.parseFromSlice(
        GetUserBalanceResponse,
        std.testing.allocator,
        "{\"is_available\":true,\"balance_infos\":[{\"currency\":\"USD\",\"total_balance\":\"9.50\",\"granted_balance\":\"1.00\",\"topped_up_balance\":\"8.50\",\"bonus\":\"ignore\"}]}",
        .{ .ignore_unknown_fields = true, .allocate = .alloc_always },
    );
    defer parsed.deinit();

    try std.testing.expectEqual(true, parsed.value.is_available);
    try std.testing.expectEqual(@as(usize, 1), parsed.value.balance_infos.len);
    try std.testing.expectEqualStrings("USD", parsed.value.balance_infos[0].currency);
    try std.testing.expectEqualStrings("9.50", parsed.value.balance_infos[0].total_balance);
}
