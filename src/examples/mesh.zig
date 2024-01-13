const std = @import("std");
const cam = @import("../graphics/camera.zig");
const colors = @import("../colors.zig");
const debug = @import("../debug.zig");
const graphics = @import("../platform/graphics.zig");
const images = @import("../images.zig");
const input = @import("../platform/input.zig");
const math = @import("../math.zig");
const modules = @import("../modules.zig");
const mesh = @import("../graphics/mesh.zig");

const emissive_shader_builtin = @import("../graphics/shaders/emissive.glsl.zig");

const Vec3 = math.Vec3;
const Mat4 = math.Mat4;
const Color = colors.Color;

var time: f32 = 0.0;
var mesh_test: ?mesh.Mesh = null;
var camera: cam.Camera = undefined;

// -- This module exercises loading and drawing a mesh --

pub fn registerModule() !void {
    const meshExample = modules.Module {
        .name = "mesh_example",
        .init_fn = on_init,
        .tick_fn = on_tick,
        .draw_fn = on_draw,
        .cleanup_fn = on_cleanup,
    };

    try modules.registerModule(meshExample);
}

fn on_init() void {
    debug.log("Mesh example module initializing", .{});

    graphics.setClearColor(colors.white);

    // Make a perspective camera, with a 90 degree FOV
    camera = cam.Camera.init(90.0, 0.01, 50.0, Vec3.up());
    camera.position = Vec3.new(0.0, 0.0, 0.0);
    camera.direction = Vec3.new(0.0, 0.0, 1.0);

    // Load the base color texture for the mesh
    const base_texture_file = "meshes/SciFiHelmet_BaseColor_512.png";
    var base_img: images.Image = images.loadFile(base_texture_file) catch {
        debug.log("Assets: Error loading image asset: {s}", .{base_texture_file});
        return;
    };
    const tex_base = graphics.Texture.init(&base_img);

    // Load the emissive texture for the mesh
    const emissive_texture_file = "meshes/SciFiHelmet_Emissive_512.png";
    var emissive_img: images.Image = images.loadFile(emissive_texture_file) catch {
        debug.log("Assets: Error loading image asset: {s}", .{emissive_texture_file});
        return;
    };
    const tex_emissive = graphics.Texture.init(&emissive_img);

    // Make our emissive shader from one that is pre-compiled
    const shader = graphics.Shader.initFromBuiltin(.{}, emissive_shader_builtin);
    if(shader == null) {
        debug.log("Could not get emissive shader", .{});
        return;
    }

    // Create a material out of our shader and textures
    const material = graphics.Material.init(.{
        .shader = shader.?,
        .texture_0 = tex_base,
        .texture_1 = tex_emissive,
    });

    // Load our mesh!
    mesh_test = mesh.Mesh.initFromFile("meshes/SciFiHelmet.gltf", .{.material = material});
}

fn on_tick(delta: f32) void {
    // There is a built in fly mode, but you can also just set the position / direction
    camera.runFlyCamera(delta * 0.01, false);

    time += delta * 0.01;
}

fn on_draw() void {
    // Exit early if we have no mesh loaded
    if(mesh_test == null)
        return;

    const proj_view_matrix = camera.getProjView();

    var model = Mat4.translate(Vec3.new(2.0, 0.0, -3.0));
    model = model.mul(Mat4.rotate(time * 0.6, Vec3.new(0.0, 1.0, 0.0 )));

    const sin_val = std.math.sin(time * 0.006) + 0.5;
    mesh_test.?.material.params.draw_color = Color.new(sin_val, sin_val, sin_val, 1.0);
    mesh_test.?.draw(proj_view_matrix, model);

    model = Mat4.translate(Vec3.new(-2.0, 0.0, -3.0 ));
    mesh_test.?.draw(proj_view_matrix, model);
}

fn on_cleanup() void {
    debug.log("Mesh example module cleaning up", .{});

    if(mesh_test == null)
        return;

    mesh_test.?.deinit();
}
