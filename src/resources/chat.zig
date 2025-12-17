const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    pub fn list_chat_completions(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Chat.listChatCompletions");
    }

    pub fn create_chat_completion(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Chat.createChatCompletion");
    }

    pub fn get_chat_completion(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Chat.getChatCompletion");
    }

    pub fn update_chat_completion(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Chat.updateChatCompletion");
    }

    pub fn delete_chat_completion(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Chat.deleteChatCompletion");
    }

    pub fn get_chat_completion_messages(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Chat.getChatCompletionMessages");
    }
};
