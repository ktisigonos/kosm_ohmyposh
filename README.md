# kosm_ohmyposh

oh-my-posh for kosm: the palette a prompt config's colors come from.

oh-my-posh lets a config name its colors once, in `palette`, and use them anywhere as
`p:<name>` (`"background": "p:blue"`). The app replaces that `palette` object with the set
colors and keeps everything else in the config byte for byte, so the prompt's layout stays
yours and only its colors follow the kosmos. JSON and TOML configs both work, picked by the
file's extension. The config needs a `palette` already, `"palette": {}` at the least. New
shells pick the colors up.

`from(theme)` sets every name in `colors`: `foreground` and `background`, then the palette's
colors by name (`black`, `white`, `gray`, `red`, `orange`, ..., `pink`). `custom` adds names of
your own, such as derived prompt colors:

```zig
var prompt = kosm_ohmyposh.from(theme);
prompt.file = "~/.config/oh-my-posh/prompt.json";
prompt.custom = &.{.{ .name = "git-changed", .color = theme.palette.cyan }};
```

## Fields

| Field | Default |
|---|---|
| `file` | `~/.config/oh-my-posh/config.json` |
| `colors` | `foreground`, `background` and the palette's names; null leaves a name out |
| `custom` | none; `.{ .name, .color }` entries after `colors` |
