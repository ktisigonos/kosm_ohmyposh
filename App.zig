//! oh-my-posh's palette: named colors a prompt config uses as `p:<name>`. The app replaces the
//! config's `palette` object and nothing else, so the prompt's layout stays the user's.

const App = @This();

const std = @import("std");
const kosm = @import("kosm");

/// The prompt config, JSON or TOML by its extension. It must hold a `palette` already (`{}` is
/// enough). Default: `~/.config/oh-my-posh/config.json`.
file: []const u8 = "~/.config/oh-my-posh/config.json",
/// The theme's colors, each written under its field name (`p:red`). null: not written.
colors: Colors = .{},
/// Colors of the user's own names, written after `colors`, in order: `.{ .name =
/// "git-changed", .color = ... }`. A name used twice, here or in `colors`, fails. Default: none.
custom: []const Entry = &.{},

/// The palette names the theme fills, each `p:<field name>`.
pub const Colors = struct {
    /// Text: white, or black in light mode.
    foreground: ?kosm.Color = null,
    /// Backgrounds: black, or white in light mode, with the theme's background alpha.
    background: ?kosm.Color = null,
    /// The palette's black.
    black: ?kosm.Color = null,
    /// The palette's white.
    white: ?kosm.Color = null,
    /// The palette's gray.
    gray: ?kosm.Color = null,
    /// The wheel's red.
    red: ?kosm.Color = null,
    /// The wheel's orange.
    orange: ?kosm.Color = null,
    /// The wheel's yellow.
    yellow: ?kosm.Color = null,
    /// The wheel's lime.
    lime: ?kosm.Color = null,
    /// The wheel's green.
    green: ?kosm.Color = null,
    /// The wheel's teal.
    teal: ?kosm.Color = null,
    /// The wheel's cyan.
    cyan: ?kosm.Color = null,
    /// The wheel's sky.
    sky: ?kosm.Color = null,
    /// The wheel's blue.
    blue: ?kosm.Color = null,
    /// The wheel's purple.
    purple: ?kosm.Color = null,
    /// The wheel's magenta.
    magenta: ?kosm.Color = null,
    /// The wheel's pink.
    pink: ?kosm.Color = null,
};

/// One color under a name of the user's.
pub const Entry = struct {
    /// The name segments use after `p:`.
    name: []const u8,
    /// The color.
    color: kosm.Color,
};

/// Every `colors` name from the theme.
pub fn from(theme: kosm.Theme) App {
    const palette = theme.palette;
    var colors: Colors = .{
        .foreground = theme.roles.foreground,
        .background = theme.asBackground(theme.roles.background),
    };
    inline for (@typeInfo(Colors).@"struct".field_names[2..]) |name| @field(colors, name) = @field(palette, name);
    return .{ .colors = colors };
}

/// Replaces the config's `palette` with the set colors. With none set, the config is not read.
pub fn apply(self: App, output: *kosm.Output) !void {
    var entries: std.ArrayList(kosm.Value.Entry) = .empty;
    inline for (@typeInfo(Colors).@"struct".field_names) |name| {
        if (@field(self.colors, name)) |color| try entries.append(output.allocator, .{ .key = name, .value = .{ .color = color } });
    }
    for (self.custom, 0..) |entry, index| {
        if (entry.name.len == 0) return output.fail(self.file, "custom entry {d} has no name", .{index});
        for (entries.items) |earlier| {
            if (std.mem.eql(u8, earlier.key, entry.name)) return output.fail(self.file, "palette name '{s}' is used twice; keep one", .{entry.name});
        }
        try entries.append(output.allocator, .{ .key = entry.name, .value = .{ .color = entry.color } });
    }
    if (entries.items.len == 0) return;
    var config = try output.edit(.{ .files = self.file });
    try config.set("palette", kosm.Value{ .table = entries.items });
}

const testing = std.testing;
const root = @import("root.zig");

const Fixture = struct {
    tmp: testing.TmpDir,
    arena: std.heap.ArenaAllocator,
    plan: kosm.Plan,
    diagnostics: kosm.Diagnostics = .{},
    warnings: kosm.Warnings = undefined,
    home_buffer: [std.Io.Dir.max_path_bytes]u8 = undefined,
    output: kosm.Output = undefined,

    fn init(fixture: *Fixture, name: []const u8, config: []const u8) !void {
        fixture.* = .{ .tmp = testing.tmpDir(.{}), .arena = .init(testing.allocator), .plan = .init(testing.allocator, testing.io) };
        try fixture.tmp.dir.createDirPath(testing.io, ".config/oh-my-posh");
        try fixture.tmp.dir.writeFile(testing.io, .{ .sub_path = try std.fmt.allocPrint(fixture.arena.allocator(), ".config/oh-my-posh/{s}", .{name}), .data = config });
        fixture.warnings = .init(fixture.arena.allocator());
        const length = try fixture.tmp.dir.realPath(testing.io, &fixture.home_buffer);
        fixture.output = .{
            .allocator = fixture.arena.allocator(),
            .home = fixture.home_buffer[0..length],
            .adapters = &.{ root.json_adapter, root.toml_adapter },
            .plan = &fixture.plan,
            .diagnostics = &fixture.diagnostics,
            .warnings = &fixture.warnings,
            .app = "ohmyposh",
        };
    }

    fn deinit(fixture: *Fixture) void {
        fixture.plan.deinit();
        fixture.arena.deinit();
        fixture.tmp.cleanup();
    }

    fn planned(fixture: *Fixture, display_path: []const u8) []const u8 {
        for (fixture.plan.files.items) |file| {
            if (std.mem.eql(u8, file.display_path, display_path)) return file.new;
        }
        return "(not planned)";
    }
};

const prompt_json =
    \\{
    \\  "version": 3,
    \\  "palette": { "old": "#000000" },
    \\  "blocks": [{ "type": "prompt", "segments": [{ "type": "time", "background": "p:blue" }] }]
    \\}
    \\
;

test "the palette is replaced whole and the rest of the config is kept" {
    var fixture: Fixture = undefined;
    try fixture.init("config.json", prompt_json);
    defer fixture.deinit();
    const app: App = .{
        .colors = .{ .blue = kosm.hex("267180"), .red = kosm.hex("80333c") },
        .custom = &.{.{ .name = "git-changed", .color = kosm.hex("268078") }},
    };
    try app.apply(&fixture.output);
    try testing.expectEqualStrings(
        \\{
        \\  "version": 3,
        \\  "palette": {"red": "#80333c", "blue": "#267180", "git-changed": "#268078"},
        \\  "blocks": [{ "type": "prompt", "segments": [{ "type": "time", "background": "p:blue" }] }]
        \\}
        \\
    , fixture.planned("~/.config/oh-my-posh/config.json"));
}

test "from fills every name, a TOML config works, and a repeated name or missing palette fails" {
    var fixture: Fixture = undefined;
    try fixture.init("prompt.toml", "version = 3\npalette = {}\n");
    defer fixture.deinit();
    var app = from(kosm.Theme.from(.{ .palette = .{ .black = kosm.hex("041c26"), .white = kosm.hex("a3c5cc") }, .mode = .dark }));
    app.file = "~/.config/oh-my-posh/prompt.toml";
    try app.apply(&fixture.output);
    const written = fixture.planned("~/.config/oh-my-posh/prompt.toml");
    try testing.expect(std.mem.startsWith(u8, written, "version = 3\npalette = { foreground = \"#a3c5cc\", background = \"#041c26\", black = \"#041c26\", "));
    try testing.expect(std.mem.indexOf(u8, written, "pink = \"#") != null);

    app.custom = &.{.{ .name = "red", .color = kosm.hex("ff0000") }};
    try testing.expectError(error.AppFailed, app.apply(&fixture.output));
    try testing.expectEqualStrings("palette name 'red' is used twice; keep one", fixture.diagnostics.message());

    var bare: Fixture = undefined;
    try bare.init("config.json", "{ \"version\": 3 }\n");
    defer bare.deinit();
    const one: App = .{ .colors = .{ .red = kosm.hex("ff0000") } };
    try testing.expectError(error.NoMatch, one.apply(&bare.output));
    const none: App = .{};
    try none.apply(&bare.output);
    try testing.expect(!bare.plan.hasChanges());
}
