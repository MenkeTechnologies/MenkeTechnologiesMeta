#!/usr/bin/env bash
set -euo pipefail

# Shared MenkeTechnologies GUI app-icon generator.
#
# Renders the canonical cyberpunk brand icon (neon grid + chamfered frame,
# accent glyph + wordmark) at the exact geometry of the reference icon
# (zterm). One accent hue per app; the bright highlight tint is derived
# automatically. The glyph and wordmark are pinned to a fixed width via
# SVG `textLength`, so every app's icon fills the frame identically
# regardless of how many characters the monogram/wordmark has — this is
# what keeps all icons the same visual size.
#
# Usage:
#   gen-app-icon.sh ACCENT GLYPH WORDMARK OUT_PNG [OUT_SVG]
#     ACCENT    accent hue, #rrggbb
#     GLYPH     centered monogram (e.g. ZC, PDF, '>_')
#     WORDMARK  wordmark strip (e.g. ZCONTAINER)
#     OUT_PNG   1024x1024 master PNG to write
#     OUT_SVG   optional: also write the source SVG here
#
# The vendored Orbitron typeface (bin/icon-assets/Orbitron-VF.ttf) is used
# via a local fontconfig, so no system font install is required.

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
FONT_DIR=$SCRIPT_DIR/icon-assets

ACCENT=${1:?accent hue required}
GLYPH=${2:?glyph required}
WORDMARK=${3:?wordmark required}
OUT_PNG=${4:?output png required}
OUT_SVG=${5:-}

command -v rsvg-convert >/dev/null || { echo "rsvg-convert not installed (brew install librsvg)" >&2; exit 1; }
[[ -f $FONT_DIR/Orbitron-VF.ttf ]] || { echo "missing $FONT_DIR/Orbitron-VF.ttf" >&2; exit 1; }

# Derive the bright highlight tint: blend the accent ~55% toward white.
read -r AR AG AB <<<"$(printf '%d %d %d' "0x${ACCENT:1:2}" "0x${ACCENT:3:2}" "0x${ACCENT:5:2}")"
lighten() { local c=$1; printf '%d' $(( c + (255 - c) * 55 / 100 )); }
ACCENT2=$(printf '#%02x%02x%02x' "$(lighten "$AR")" "$(lighten "$AG")" "$(lighten "$AB")")

# XML-escape the glyph (handles '>' '<' '&' in monograms like '>_').
xml_escape() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }
GLYPH_X=$(xml_escape "$GLYPH")
WORD_X=$(xml_escape "$WORDMARK")

# Local fontconfig so rsvg-convert finds Orbitron without a system install.
FC=$(mktemp -t mtechicon_fc.XXXXXX.conf)
FCCACHE=$(mktemp -d -t mtechicon_fccache.XXXXXX)
trap 'command rm -rf "$FC" "$FCCACHE"' EXIT
cat >"$FC" <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>$(cd "$FONT_DIR" && pwd)</dir>
  <cachedir>$FCCACHE</cachedir>
</fontconfig>
EOF
export FONTCONFIG_FILE=$FC

# Pinned widths: every glyph fills 520px, every wordmark 600px. lengthAdjust
# spacingAndGlyphs scales the run to that exact width so 2-char and 4-char
# monograms render at the same footprint.
SVG=$(cat <<EOF
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#0b1020"/>
      <stop offset="1" stop-color="#04060c"/>
    </linearGradient>
    <linearGradient id="ink" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="$ACCENT2"/>
      <stop offset="1" stop-color="$ACCENT"/>
    </linearGradient>
    <pattern id="grid" width="64" height="64" patternUnits="userSpaceOnUse">
      <path d="M64 0 H0 V64" fill="none" stroke="$ACCENT" stroke-width="1.5" opacity="0.10"/>
    </pattern>
    <filter id="glow" x="-40%" y="-40%" width="180%" height="180%">
      <feGaussianBlur stdDeviation="9" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>

  <rect x="0" y="0" width="1024" height="1024" rx="180" fill="url(#bg)"/>
  <rect x="0" y="0" width="1024" height="1024" rx="180" fill="url(#grid)"/>

  <!-- chamfered cyberpunk frame (cut corners) -->
  <path d="M 232 150 H 792 L 874 232 V 792 L 792 874 H 232 L 150 792 V 232 Z"
        fill="none" stroke="url(#ink)" stroke-width="14" filter="url(#glow)"/>
  <g fill="none" stroke="$ACCENT2" stroke-width="10" stroke-linecap="square" filter="url(#glow)">
    <path d="M 150 300 V 232 L 218 232"/>
    <path d="M 874 300 V 232 L 806 232"/>
    <path d="M 150 724 V 792 L 218 792"/>
    <path d="M 874 724 V 792 L 806 792"/>
  </g>

  <!-- accent glyph (monogram), width-pinned so all icons match size -->
  <text x="512" y="600" font-family="Orbitron" font-weight="900" font-size="340"
        textLength="520" lengthAdjust="spacingAndGlyphs"
        fill="url(#ink)" text-anchor="middle" filter="url(#glow)">$GLYPH_X</text>

  <!-- wordmark strip, width-pinned -->
  <text x="512" y="782" font-family="Orbitron" font-weight="700" font-size="92"
        textLength="600" lengthAdjust="spacingAndGlyphs"
        fill="$ACCENT" text-anchor="middle" opacity="0.9">$WORD_X</text>
</svg>
EOF
)

printf '%s' "$SVG" | rsvg-convert -w 1024 -h 1024 -o "$OUT_PNG"
[[ -n $OUT_SVG ]] && printf '%s\n' "$SVG" >"$OUT_SVG"
exit 0
