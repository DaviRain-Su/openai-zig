const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

pub const Resource = struct {
    transport: *transport_mod.Transport,

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

    pub fn list_files(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Files.listFiles");
    }

    pub fn create_file(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Files.createFile");
    }

    pub fn delete_file(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Files.deleteFile");
    }

    pub fn retrieve_file(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Files.retrieveFile");
    }

    pub fn download_file(self: *const Resource) !void {
        _ = self;
        return errors.unimplemented("Files.downloadFile");
    }
};
