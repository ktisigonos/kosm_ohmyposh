# kosm_ohmyposh

Oh My Posh for kosm: the whole prompt config, owned by kosm.

The app writes the prompt config whole (JSON, or TOML by the file's extension), in Oh My
Posh's config version 4: the blocks and their segments, and a `palette` of the theme's colors
that segments name as `p:<name>`. Lay the prompt out in your kosmos, and point Oh My Posh at the
file once:

```fish
oh-my-posh init fish --config ~/.config/oh-my-posh/kosm.json | source
```

Field names are Oh My Posh's, and every field left null or empty is not written, so Oh My
Posh's default applies. A segment's color is a palette name (`.{ .palette = "accent" }`, written
`p:accent`, so it follows the kosmos), a color of its own (`.{ .color = ... }`), or one of Oh My
Posh's words (`.{ .text = "transparent" }`). Color templates name palette colors the same way:
`{{ if .Root }}p:error{{ end }}`. New shells pick changes up.

`from(theme)` fills the palette: `foreground` and `background`, the roles `accent`,
`secondary`, `success`, `warning` and `error`, then the palette's colors by name (`black`,
`white`, `gray`, `red`, `orange`, ..., `pink`). `custom` adds names of your own, such as
derived prompt colors. Without `blocks`, the prompt is `default_blocks`: a powerline of the path
on the accent, git on the secondary (the warning with changes, the success when ahead), and a
failed command's exit code on the error.

```zig
var prompt = kosm_ohmyposh.from(theme);
prompt.custom = &.{.{ .name = "git-changed", .color = theme.palette.teal }};
prompt.blocks = &.{.{ .segments = &.{
    .{ .type = .path, .style = .powerline, .background = .{ .palette = "accent" }, .template = " {{ .Path }} ",
       .options = &.{.{ .path = "style", .value = .{ .string = "unique" } }} },
    .{ .type = .git, .style = .powerline, .background = .{ .palette = "secondary" },
       .background_templates = &.{"{{ if .Working.Changed }}p:git-changed{{ end }}"} },
} }};
```

## Fields

| Field | Default |
|---|---|
| `file` | `~/.config/oh-my-posh/kosm.json` |
| `final_space` | null: Oh My Posh's (no space) |
| `console_title_template` | null: the shell's title |
| `colors` | `foreground`, `background`, the roles and the palette's names; null leaves a name out |
| `custom` | none; `.{ .name, .color }` entries after `colors` |
| `blocks` | `default_blocks`; each `type`, `alignment`, `newline`, `filler`, `overflow`, `leading_diamond`, `trailing_diamond`, `segments` |
| segments | `type`, `style`, `foreground`, `background`, `foreground_templates`, `background_templates`, `template`, `leading_diamond`, `trailing_diamond`, `powerline_symbol`, `invert_powerline`, `options`, `extra` |
| `extra` | none; settings the fields don't cover, by path (`transient_prompt.template`) |
