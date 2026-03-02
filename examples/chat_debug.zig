const std = @import("std");
const sdk = @import("openai_zig");
const config = @import("config");

pub fn main() !void {
    var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa_impl.deinit();
    const gpa = gpa_impl.allocator();

    var conf = try config.load(gpa, "config/config.toml");
    defer conf.deinit(gpa);

    if (conf.api_key.len == 0) {
        std.debug.print("API key missing\n", .{});
        return;
    }

    var client = try sdk.initClient(gpa, .{
        .base_url = conf.base_url,
        .api_key = conf.api_key,
        .timeout_ms = conf.timeout_ms,
        .organization = conf.organization,
        .project = conf.project,
        .max_retries = conf.max_retries,
        .retry_base_delay_ms = conf.retry_base_delay_ms,
    });
    defer client.deinit();

    const messages = [_]sdk.resources.chat.ChatMessage{ .{ .role = "user", .content = "用中文说你是谁" } };
    var body_writer: std.io.Writer.Allocating = .init(gpa);
    defer body_writer.deinit();
    const req = struct {
        model: []const u8,
        messages: []const sdk.resources.chat.ChatMessage,
    }{ .model = conf.model, .messages = &messages };
    try std.json.stringify(req, .{}, body_writer.writer());
    const payload = body_writer.written();

    const headers = [_]std.http.Header{
        .{ .name = "Accept", .value = "application/json" },
        .{ .name = "Content-Type", .value = "application/json" },
    };

    const transport = client.raw_transport();
    const resp = try transport.request(.POST, "/chat/completions", &headers, payload);
    defer transport.allocator.free(resp.body);

    std.debug.print("status={d}\n", .{resp.status});
    std.debug.print("body={s}\n", .{resp.body});

    const val = try std.json.parseFromSlice(std.json.Value, gpa, resp.body, .{ .ignore_unknown_fields = true });
    defer val.deinit();

    const typed = std.json.parseFromSlice(sdk.generated.CreateChatCompletionResponse, gpa, resp.body, .{ .ignore_unknown_fields = true }) catch |err| {
        std.debug.print("typed parse err: {}\\n", .{err});
        return;
    };
    defer typed.deinit();

    std.debug.print("typed ok id={s} choices={d}\n", .{ typed.value.id, typed.value.choices.len });
}
