//! One of a block's segments: a piece of the prompt, such as the path or git's state. Every
//! field left null or empty is not written, so Oh My Posh's default applies.

const kosm = @import("kosm");

/// What the segment shows.
type: Type,
/// How it joins its neighbors. Default: `.plain`.
style: Style = .plain,
/// The text's color. null: Oh My Posh's.
foreground: ?Color = null,
/// The background. null: none.
background: ?Color = null,
/// Templates tried in order; the first giving text sets the foreground, such as
/// `{{ if .Root }}p:error{{ end }}`. Default: none.
foreground_templates: []const []const u8 = &.{},
/// Templates tried in order; the first giving text sets the background. Default: none.
background_templates: []const []const u8 = &.{},
/// What the segment writes, a Go template (`" {{ .Path }} "`). null: the segment's own.
template: ?[]const u8 = null,
/// The symbol a `.diamond` segment starts with. null: none.
leading_diamond: ?[]const u8 = null,
/// The symbol a `.diamond` segment ends with. null: none.
trailing_diamond: ?[]const u8 = null,
/// The symbol after a `.powerline` segment. null: Oh My Posh's arrow.
powerline_symbol: ?[]const u8 = null,
/// Whether the powerline symbol points the other way, for a right-aligned block. null: false.
invert_powerline: ?bool = null,
/// The segment's own options by path, such as `.{ .path = "time_format", .value = .{ .string =
/// "15:04:05" } }` for `time`. Default: none.
options: []const kosm.Setting = &.{},
/// Settings the fields don't cover, by path inside the segment, such as `cache`. One repeating
/// a set field fails the apply. Default: none.
extra: []const kosm.Setting = &.{},

/// A color as Oh My Posh takes it.
pub const Color = union(enum) {
    /// A name of the app's palette, written `p:<name>`, so it follows `colors`: `.{ .palette =
    /// "accent" }`.
    palette: []const u8,
    /// A color of its own.
    color: kosm.Color,
    /// Oh My Posh's own words, written as they are: `transparent`, `foreground`, `background`,
    /// `parentForeground`, `parentBackground`.
    text: []const u8,
};

/// How a segment joins its neighbors.
pub const Style = enum { plain, powerline, diamond, accordion };

/// Oh My Posh's segments.
pub const Type = enum {
    angular,
    antigravity,
    argocd,
    aspire,
    aurelia,
    aws,
    az,
    azd,
    azfunc,
    battery,
    bazel,
    brewfather,
    buf,
    bun,
    carbonintensity,
    cds,
    cf,
    cftarget,
    claude,
    clojure,
    cmake,
    copilot,
    copilot_cli,
    connection,
    crystal,
    dart,
    deno,
    docker,
    dotnet,
    dvc,
    elixir,
    executiontime,
    firebase,
    flutter,
    fortran,
    fossil,
    gcp,
    git,
    gitversion,
    go,
    gradle,
    haskell,
    helm,
    http,
    ipify,
    java,
    jujutsu,
    julia,
    kotlin,
    kubectl,
    language,
    lastfm,
    lua,
    mercurial,
    mojo,
    mvn,
    nba,
    nbgv,
    nightscout,
    nim,
    @"nix-shell",
    node,
    npm,
    nx,
    ocaml,
    orthodoxcal,
    os,
    owm,
    path,
    pear,
    perl,
    php,
    plastic,
    pnpm,
    project,
    pulumi,
    python,
    quasar,
    r,
    ramadan,
    react,
    root,
    ruby,
    rust,
    sapling,
    session,
    shell,
    sitecore,
    spotify,
    status,
    strava,
    svelte,
    svn,
    swift,
    sysinfo,
    talosctl,
    taskwarrior,
    tauri,
    terraform,
    text,
    time,
    timewarrior,
    todoist,
    ui5tooling,
    umbraco,
    uno,
    unity,
    upgrade,
    v,
    vala,
    vimode,
    wakatime,
    winget,
    winreg,
    withings,
    xmake,
    yarn,
    ytm,
    zig,
    zvm,
};
