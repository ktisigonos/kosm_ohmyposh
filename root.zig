//! oh-my-posh: the palette a prompt config's `p:` colors come from.

const std = @import("std");

/// The oh-my-posh palette; build one with `from`.
pub const App = @import("App.zig");
/// Colors from the theme.
pub const from = App.from;
/// The adapter the app edits JSON configs with, so a config needs only this package.
pub const json_adapter = @import("kosm_json").adapter;
/// The adapter the app edits TOML configs with.
pub const toml_adapter = @import("kosm_toml").adapter;

test {
    std.testing.refAllDecls(@This());
    std.testing.refAllDecls(App);
}
