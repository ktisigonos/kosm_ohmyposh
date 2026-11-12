//! Oh My Posh's prompt config, generated whole: its blocks and segments, and a palette of the
//! theme's colors that segments name as `p:<name>`. Field names are Oh My Posh's.

const App = @This();

const std = @import("std");
const kosm = @import("kosm");

/// The config kosm owns, JSON or TOML by its extension; point `oh-my-posh init` at it
/// (`--config ~/.config/oh-my-posh/kosm.json`). Default: `~/.config/oh-my-posh/kosm.json`.
file: []const u8 = "~/.config/oh-my-posh/kosm.json",
/// Whether a space follows the prompt. null: false.
final_space: ?bool = null,
/// The terminal window's title, a Go template. null: the shell's.
console_title_template: ?[]const u8 = null,
/// The theme's colors in the palette, each under its field name (`p:accent`). null: not written.
colors: Colors = .{},
/// Palette colors of the user's own names, written after `colors`, in order: `.{ .name =
/// "git-changed", .color = ... }`. A name used twice, here or in `colors`, fails. Default: none.
custom: []const Entry = &.{},
/// The prompt's blocks. Default: `default_blocks`, a powerline of the path, git and a failed
/// command's status in the palette's colors.
blocks: []const Block = default_blocks,
/// Settings the fields don't cover, by path (`transient_prompt.template`). One repeating a set
/// field fails the apply. Default: none.
extra: []const kosm.Setting = &.{},

/// One of `blocks`.
pub const Block = @import("Block.zig");
/// One of a block's segments.
pub const Segment = @import("Segment.zig");

/// The palette names the theme fills, each `p:<field name>`.
pub const Colors = struct {
    /// Text: the foreground role.
    foreground: ?kosm.Color = null,
    /// Backgrounds: the background role, opaque, as terminals draw text backgrounds.
    background: ?kosm.Color = null,
    /// The accent role.
    accent: ?kosm.Color = null,
    /// The secondary role.
    secondary: ?kosm.Color = null,
    /// The success role.
    success: ?kosm.Color = null,
    /// The warning role.
    warning: ?kosm.Color = null,
    /// The error role.
    @"error": ?kosm.Color = null,
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

/// One palette color under a name of the user's.
pub const Entry = struct {
    /// The name segments use after `p:`.
    name: []const u8,
    /// The color.
    color: kosm.Color,
};

/// The powerline symbol: a right-pointing triangle.
const arrow = "\u{e0b0}";

/// The base's prompt: the path on the accent, git on the secondary (the warning with changes,
/// the success when ahead), and a failed command's exit code on the error, each in the
/// background's color.
pub const default_blocks: []const Block = &.{.{ .segments = &.{
    .{
        .type = .path,
        .style = .powerline,
        .powerline_symbol = arrow,
        .foreground = .{ .palette = "background" },
        .background = .{ .palette = "accent" },
        .template = " {{ .Path }} ",
    },
    .{
        .type = .git,
        .style = .powerline,
        .powerline_symbol = arrow,
        .foreground = .{ .palette = "background" },
        .background = .{ .palette = "secondary" },
        .background_templates = &.{
            "{{ if or (.Working.Changed) (.Staging.Changed) }}p:warning{{ end }}",
            "{{ if gt .Ahead 0 }}p:success{{ end }}",
        },
        .template = " {{ .HEAD }} ",
    },
    .{
        .type = .status,
        .style = .powerline,
        .powerline_symbol = arrow,
        .foreground = .{ .palette = "background" },
        .background = .{ .palette = "error" },
        .template = " {{ .Code }} ",
    },
} }};

/// Every `colors` name from the theme: the roles, then the palette's colors.
pub fn from(theme: kosm.Theme) App {
    const roles = theme.roles;
    var colors: Colors = .{
        .foreground = roles.foreground,
        .background = roles.background,
        .accent = roles.accent,
        .secondary = roles.secondary,
        .success = roles.success,
        .warning = roles.warning,
        .@"error" = roles.@"error",
    };
    inline for (@typeInfo(Colors).@"struct".field_names[7..]) |name| @field(colors, name) = @field(theme.palette, name);
    return .{ .colors = colors };
}

/// Writes the whole config.
pub fn apply(self: App, output: *kosm.Output) !void {
    const allocator = output.allocator;
    var entries: std.ArrayList(kosm.Value.Entry) = .empty;
    try entries.appendSlice(allocator, &.{
        .{ .key = "$schema", .value = .{ .string = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json" } },
        .{ .key = "version", .value = .{ .integer = 4 } },
    });
    if (self.final_space) |space| try entries.append(allocator, .{ .key = "final_space", .value = .{ .boolean = space } });
    if (self.console_title_template) |title| try entries.append(allocator, .{ .key = "console_title_template", .value = .{ .string = title } });
    const palette = try self.paletteEntries(output);
    if (palette.len != 0) try entries.append(allocator, .{ .key = "palette", .value = .{ .table = palette } });
    const blocks = try allocator.alloc(kosm.Value, self.blocks.len);
    for (self.blocks, blocks) |block, *value| value.* = try self.blockValue(output, block);
    try entries.append(allocator, .{ .key = "blocks", .value = .{ .list = blocks } });
    const own = try kosm.Setting.leaves(allocator, .{ .table = entries.items });
    const all = try kosm.Setting.withExtras(output, self.file, own, self.extra, .{});
    try output.generate(.{ .file = self.file }, try kosm.Setting.tree(allocator, all));
}

/// The set `colors`, then `custom`; a name used twice fails.
fn paletteEntries(self: App, output: *kosm.Output) ![]const kosm.Value.Entry {
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
    return entries.items;
}

fn blockValue(self: App, output: *kosm.Output, block: Block) !kosm.Value {
    var entries: std.ArrayList(kosm.Value.Entry) = .empty;
    try appendFields(output.allocator, &entries, block, &.{"segments"});
    const segments = try output.allocator.alloc(kosm.Value, block.segments.len);
    for (block.segments, segments) |segment, *value| value.* = try self.segmentValue(output, segment);
    try entries.append(output.allocator, .{ .key = "segments", .value = .{ .list = segments } });
    return .{ .table = entries.items };
}

/// A segment's fields, then its `options` under `options`, then its extras; an option or extra
/// repeating a set field fails.
fn segmentValue(self: App, output: *kosm.Output, segment: Segment) !kosm.Value {
    const allocator = output.allocator;
    var entries: std.ArrayList(kosm.Value.Entry) = .empty;
    try appendFields(allocator, &entries, segment, &.{ "options", "extra" });
    const own = try kosm.Setting.leaves(allocator, .{ .table = entries.items });
    const added = try allocator.alloc(kosm.Setting, segment.options.len + segment.extra.len);
    for (segment.options, added[0..segment.options.len]) |option, *setting| {
        setting.* = .{ .path = try allocator.print("options.{s}", .{option.path}), .value = option.value };
    }
    @memcpy(added[segment.options.len..], segment.extra);
    const all = try kosm.Setting.withExtras(output, self.file, own, added, .{});
    return kosm.Setting.tree(allocator, all);
}

/// The set fields of `value` but the `skipped` ones, by their names.
fn appendFields(allocator: std.mem.Allocator, entries: *std.ArrayList(kosm.Value.Entry), value: anytype, comptime skipped: []const []const u8) !void {
    inline for (@typeInfo(@TypeOf(value)).@"struct".field_names) |name| {
        if (comptime isSkipped(name, skipped)) continue;
        if (try valueOf(allocator, @field(value, name))) |field| try entries.append(allocator, .{ .key = name, .value = field });
    }
}

fn isSkipped(comptime name: []const u8, comptime skipped: []const []const u8) bool {
    for (skipped) |skip| {
        if (std.mem.eql(u8, name, skip)) return true;
    }
    return false;
}

/// A field's value as Oh My Posh takes it; null when it is not set or empty.
fn valueOf(allocator: std.mem.Allocator, field: anytype) std.mem.Allocator.Error!?kosm.Value {
    const T = @TypeOf(field);
    if (T == []const u8) return .{ .string = field };
    if (T == []const []const u8) {
        if (field.len == 0) return null;
        const items = try allocator.alloc(kosm.Value, field.len);
        for (field, items) |text, *item| item.* = .{ .string = text };
        return .{ .list = items };
    }
    if (T == Segment.Color) return switch (field) {
        .palette => |name| .{ .string = try allocator.print("p:{s}", .{name}) },
        .color => |color| .{ .color = color },
        .text => |text| .{ .string = text },
    };
    return switch (@typeInfo(T)) {
        .optional => if (field) |present| try valueOf(allocator, present) else null,
        .bool => .{ .boolean = field },
        .@"enum" => .{ .string = @tagName(field) },
        else => @compileError("Oh My Posh has no value of type " ++ @typeName(T)),
    };
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

    fn init(fixture: *Fixture) !void {
        fixture.* = .{ .tmp = testing.tmpDir(.{}), .arena = .init(testing.allocator), .plan = .init(testing.allocator, testing.io) };
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

test "blocks and segments are written by Oh My Posh's names, colors as palette names or hex" {
    var fixture: Fixture = undefined;
    try fixture.init();
    defer fixture.deinit();
    const app: App = .{
        .final_space = true,
        .colors = .{ .accent = kosm.hex("2e8799") },
        .custom = &.{.{ .name = "git-changed", .color = kosm.hex("268078") }},
        .blocks = &.{.{ .newline = true, .segments = &.{
            .{ .type = .@"nix-shell" },
            .{
                .type = .session,
                .style = .diamond,
                .foreground = .{ .color = kosm.hex("a3c5cc") },
                .background = .{ .palette = "accent" },
                .foreground_templates = &.{"{{ if .Root }}p:error{{ end }}"},
                .template = " {{ .UserName }} ",
                .trailing_diamond = ">",
                .options = &.{.{ .path = "time_format", .value = .{ .string = "15:04:05" } }},
                .extra = &.{.{ .path = "cache.duration", .value = .{ .string = "1h" } }},
            },
        } }},
        .extra = &.{.{ .path = "transient_prompt.template", .value = .{ .string = "> " } }},
    };
    try app.apply(&fixture.output);
    try testing.expectEqualStrings(
        \\{
        \\  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
        \\  "version": 4,
        \\  "final_space": true,
        \\  "palette": {
        \\    "accent": "#2e8799",
        \\    "git-changed": "#268078"
        \\  },
        \\  "blocks": [
        \\    {
        \\      "type": "prompt",
        \\      "alignment": "left",
        \\      "newline": true,
        \\      "segments": [
        \\        {
        \\          "type": "nix-shell",
        \\          "style": "plain"
        \\        },
        \\        {
        \\          "type": "session",
        \\          "style": "diamond",
        \\          "foreground": "#a3c5cc",
        \\          "background": "p:accent",
        \\          "foreground_templates": [
        \\            "{{ if .Root }}p:error{{ end }}"
        \\          ],
        \\          "template": " {{ .UserName }} ",
        \\          "trailing_diamond": ">",
        \\          "options": {
        \\            "time_format": "15:04:05"
        \\          },
        \\          "cache": {
        \\            "duration": "1h"
        \\          }
        \\        }
        \\      ]
        \\    }
        \\  ],
        \\  "transient_prompt": {
        \\    "template": "> "
        \\  }
        \\}
        \\
    , fixture.planned("~/.config/oh-my-posh/kosm.json"));
}

test "from fills the roles and the palette, and the default prompt names them" {
    var fixture: Fixture = undefined;
    try fixture.init();
    defer fixture.deinit();
    const app = from(kosm.Theme.from(.{ .palette = .{ .black = kosm.hex("041c26"), .white = kosm.hex("a3c5cc") }, .mode = .dark }));
    try app.apply(&fixture.output);
    const written = fixture.planned("~/.config/oh-my-posh/kosm.json");
    try testing.expect(std.mem.indexOf(u8, written, "\"foreground\": \"#a3c5cc\",\n    \"background\": \"#041c26\",\n    \"accent\": \"#") != null);
    try testing.expect(std.mem.indexOf(u8, written, "\"pink\": \"#") != null);
    inline for (.{ "p:accent", "p:secondary", "p:warning", "p:success", "p:error", "p:background" }) |name| {
        try testing.expect(std.mem.indexOf(u8, written, name) != null);
    }
}

test "a repeated palette name, or an option or extra repeating a field, fails" {
    var fixture: Fixture = undefined;
    try fixture.init();
    defer fixture.deinit();
    const repeated: App = .{ .colors = .{ .red = kosm.hex("ff0000") }, .custom = &.{.{ .name = "red", .color = kosm.hex("ff0000") }} };
    try testing.expectError(error.AppFailed, repeated.apply(&fixture.output));
    try testing.expectEqualStrings("palette name 'red' is used twice; keep one", fixture.diagnostics.message());
    const option: App = .{ .blocks = &.{.{ .segments = &.{.{
        .type = .time,
        .options = &.{.{ .path = "a", .value = .{ .integer = 1 } }},
        .extra = &.{.{ .path = "options.a", .value = .{ .integer = 2 } }},
    }} }} };
    try testing.expectError(error.AppFailed, option.apply(&fixture.output));
    const extra: App = .{ .blocks = &.{.{ .segments = &.{.{ .type = .time, .template = "x", .extra = &.{.{ .path = "template", .value = .{ .string = "y" } }} }} }} };
    try testing.expectError(error.AppFailed, extra.apply(&fixture.output));
    try testing.expectEqualStrings("(not planned)", fixture.planned("~/.config/oh-my-posh/kosm.json"));
}
