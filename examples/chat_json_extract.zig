const std = @import("std");
const sdk = @import("openai_zig");
const errors = sdk.errors;
const config = @import("config");

const ExampleError = error{BadResponse};

fn firstContentString(val: std.json.Value) ExampleError![]const u8 {
    const root_obj = switch (val) {
        .object => |o| o,
        else => return ExampleError.BadResponse,
    };
    const choices_val = root_obj.get("choices") orelse return ExampleError.BadResponse;
    const choices_arr = switch (choices_val) {
        .array => |a| a,
        else => return ExampleError.BadResponse,
    };
    if (choices_arr.items.len == 0) return ExampleError.BadResponse;
    const choice_obj = switch (choices_arr.items[0]) {
        .object => |o| o,
        else => return ExampleError.BadResponse,
    };
    const msg_val = choice_obj.get("message") orelse return ExampleError.BadResponse;
    const msg_obj = switch (msg_val) {
        .object => |o| o,
        else => return ExampleError.BadResponse,
    };
    const content_val = msg_obj.get("content") orelse return ExampleError.BadResponse;
    return switch (content_val) {
        .string => |s| s,
        else => ExampleError.BadResponse,
    };
}

pub fn main() !void {
    var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa_impl.deinit();
    const gpa = gpa_impl.allocator();

    var conf = try config.load(gpa, "config/config.toml");
    defer conf.deinit(gpa);

    if (conf.api_key.len == 0) {
        std.debug.print("API key missing; set config/config.toml\n", .{});
        return;
    }

    var client = try sdk.initClient(gpa, .{
        .base_url = conf.base_url,
        .api_key = conf.api_key,
    });
    defer client.deinit();

    const system_prompt =
        \\The user will provide some exam text. Please parse the "question" and "answer" and output them in JSON format.
        \\EXAMPLE INPUT:
        \\Which is the highest mountain in the world? Mount Everest.
        \\EXAMPLE JSON OUTPUT:
        \\{
        \\  "question": "Which is the highest mountain in the world?",
        \\  "answer": "Mount Everest"
        \\}
    ;

    const user_prompt = "Which is the longest river in the world? The Nile River.";

    const messages = [_]sdk.resources.chat.ChatMessage{
        .{ .role = "system", .content = system_prompt },
        .{ .role = "user", .content = user_prompt },
    };

    // response_format: {"type":"json_object"}
    const resp_fmt_str = "{\"type\":\"json_object\"}";
    var resp_fmt = try std.json.parseFromSlice(std.json.Value, gpa, resp_fmt_str, .{});
    defer resp_fmt.deinit();

    var resp = client.chat().create_chat_completion(gpa, .{
        .model = conf.model,
        .messages = &messages,
        .response_format = resp_fmt.value,
    }) catch |err| {
        std.debug.print("Request failed: {s}\n", .{@errorName(err)});
        return;
    };
    defer resp.deinit();

    const content_str = firstContentString(resp.value) catch |e| {
        std.debug.print("Unexpected response shape: {s}\n", .{@errorName(e)});
        return;
    };

    const parsed = std.json.parseFromSlice(std.json.Value, gpa, content_str, .{}) catch {
        std.debug.print("Content is not valid JSON\n", .{});
        return;
    };
    defer parsed.deinit();

    var out = std.io.Writer.Allocating.init(gpa);
    defer out.deinit();
    var stream: std.json.Stringify = .{ .writer = &out.writer, .options = .{} };
    try stream.write(parsed.value);

    std.debug.print("Parsed JSON content:\n{s}\n", .{out.written()});
}
