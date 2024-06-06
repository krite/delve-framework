const std = @import("std");
const debug = @import("debug.zig");
const zstbi = @import("zstbi");

// var gpa = std.heap.GeneralPurposeAllocator(.{}){};
// const allocator = gpa.allocator();
const allocator = std.heap.c_allocator;

pub const Image = zstbi.Image;

pub fn init() void {
    debug.log("Image zstbi init", .{});
    zstbi.init(allocator);
}

pub fn deinit() void {
    debug.log("Image zstbi deinit", .{});
    zstbi.deinit();
}

pub fn loadFile(file_path: [:0]const u8) !Image {
    debug.log("Loading image from file: {s}", .{file_path});
    defer debug.log("Done loading image from file: {s}", .{file_path});

    // const file = try std.fs.cwd().openFile(
    //     file_path,
    //     .{}, // mode is read only by default
    // );
    // defer file.close();
    //
    // const file_stat = try file.stat();
    // const file_size: usize = @as(usize, @intCast(file_stat.size));
    //
    // const contents = try file.reader().readAllAlloc(allocator, file_size);
    // defer allocator.free(contents);
    //
    // debug.log("Read {d} bytes", .{file_size});
    //
    // return loadBytes(contents);

    return Image.loadFromFile(file_path, 0);
}

pub fn loadBytes(image_bytes: []const u8) !Image {
    debug.log("Loading image bytes", .{});
    defer debug.log("Done loading image bytes", .{});
    return Image.loadFromMemory(image_bytes, 0);
}
