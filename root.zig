//! Oh My Posh: the whole prompt config, its layout and a palette of the theme's colors.

const std = @import("std");

/// The Oh My Posh prompt config; build one with `from`.
pub const App = @import("App.zig");
/// Colors from the theme.
pub const from = App.from;
/// The adapter the app writes JSON configs with, so a config needs only this package.
pub const json_adapter = @import("kosm_json").adapter;
/// The adapter the app writes TOML configs with.
pub const toml_adapter = @import("kosm_toml").adapter;

test {
    std.testing.refAllDecls(@This());
    std.testing.refAllDecls(App);
    std.testing.refAllDecls(App.Block);
    std.testing.refAllDecls(App.Segment);
}
