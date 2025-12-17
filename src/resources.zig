const audio_mod = @import("resources/audio.zig");
const chat_mod = @import("resources/chat.zig");
const models_mod = @import("resources/models.zig");
const files_mod = @import("resources/files.zig");
const completions_mod = @import("resources/completions.zig");
const embeddings_mod = @import("resources/embeddings.zig");
const images_mod = @import("resources/images.zig");

pub const audio = audio_mod;
pub const chat = chat_mod;
pub const models = models_mod;
pub const files = files_mod;
pub const completions = completions_mod;
pub const embeddings = embeddings_mod;
pub const images = images_mod;

pub const AudioResource = audio_mod.Resource;
pub const ChatResource = chat_mod.Resource;
pub const ModelsResource = models_mod.Resource;
pub const FilesResource = files_mod.Resource;
pub const CompletionsResource = completions_mod.Resource;
pub const EmbeddingsResource = embeddings_mod.Resource;
pub const ImagesResource = images_mod.Resource;
