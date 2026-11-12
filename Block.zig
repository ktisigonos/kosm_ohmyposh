//! One of the prompt's blocks: segments on one line, aligned left or right. Every field left
//! null is not written, so Oh My Posh's default applies.

const Segment = @import("Segment.zig");

/// The main prompt, or the one right of the cursor. Default: `.prompt`.
type: Type = .prompt,
/// Which edge of the terminal the block keeps to. Default: `.left`.
alignment: Alignment = .left,
/// Whether the block starts on a new line. null: false.
newline: ?bool = null,
/// Text repeated to fill the gap up to a right-aligned block. null: none.
filler: ?[]const u8 = null,
/// What a right-aligned block does when it no longer fits. null: it overlaps.
overflow: ?Overflow = null,
/// The symbol the block starts with. null: none.
leading_diamond: ?[]const u8 = null,
/// The symbol the block ends with. null: none.
trailing_diamond: ?[]const u8 = null,
/// The segments, in order. Default: none.
segments: []const Segment = &.{},

/// A block's kind.
pub const Type = enum { prompt, rprompt };

/// The edge a block keeps to.
pub const Alignment = enum { left, right };

/// What a right-aligned block does when it no longer fits.
pub const Overflow = enum { @"break", hide };
