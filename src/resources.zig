const audio_mod = @import("resources/audio.zig");
const chat_mod = @import("resources/chat.zig");
const models_mod = @import("resources/models.zig");
const files_mod = @import("resources/files.zig");

pub const audio = audio_mod;
pub const chat = chat_mod;
pub const models = models_mod;
pub const files = files_mod;

pub const AudioResource = audio_mod.Resource;
pub const ChatResource = chat_mod.Resource;
pub const ModelsResource = models_mod.Resource;
pub const FilesResource = files_mod.Resource;
