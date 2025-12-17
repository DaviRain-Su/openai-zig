const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    pub fn create_speech(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Audio.createSpeech");
    }

    pub fn create_transcription(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Audio.createTranscription");
    }

    pub fn create_translation(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Audio.createTranslation");
    }

    pub fn create_voice_consent(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Audio.createVoiceConsent");
    }

    pub fn list_voice_consents(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Audio.listVoiceConsents");
    }

    pub fn get_voice_consent(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Audio.getVoiceConsent");
    }

    pub fn update_voice_consent(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Audio.updateVoiceConsent");
    }

    pub fn delete_voice_consent(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Audio.deleteVoiceConsent");
    }

    pub fn create_voice(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Audio.createVoice");
    }
};
