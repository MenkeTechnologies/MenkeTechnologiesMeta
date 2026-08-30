#!/usr/bin/env bash
# Renders every brand SVG to PNG under branding/png/.
#
# The SVGs are the source of truth; everything under png/ is derived and is
# safe to delete and regenerate. Run this after touching any file here.
#
# Two substitutions happen on a temp copy of each source, never on the source:
#
#   1. `color` is set on the root element so `currentColor` resolves. librsvg
#      honours this.
#   2. `var(--neon, #xxxxxx)` is replaced textually. librsvg 2.62.3 does NOT
#      resolve CSS custom properties - it falls through to the fallback hex,
#      which is the void-ground accent, so a paper render would silently come
#      out with the void accent. Verified: a probe SVG with
#      style="--neon:#ff0000" and fill="var(--neon, #00b0ff)" renders #00b0ff.
#
# Ground colours come from ../logos-branches.html:9-14, which is where the
# five palettes are defined.
set -euo pipefail

here=$(cd -- "$(dirname -- "$0")" && pwd)
out=$here/png
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$out" "$out/branches"

VOID=#0b1020
PAPER=#ffffff

# tint <src> <ink> <neon> -> path to a temp svg with both inks resolved
tint() {
  local src=$1 ink=$2 neon=$3
  local dst=$tmp/$(basename "$src" .svg)-$(echo "$ink$neon" | tr -d '#').svg
  perl -0pe "s|<svg |<svg style=\"color:$ink\" |; s|var\\(--neon,\\s*#[0-9a-fA-F]{6}\\)|$neon|g" "$src" > "$dst"
  printf '%s' "$dst"
}

# square <src> <ink> <neon> <ground> <stem> <size...>
square() {
  local src=$1 ink=$2 neon=$3 ground=$4 stem=$5; shift 5
  local svg; svg=$(tint "$src" "$ink" "$neon")
  local s
  for s in "$@"; do
    rsvg-convert -w "$s" -h "$s" -b "$ground" -o "$out/$stem-$s.png" "$svg"
  done
}

# grounded <src> <stem> <size...> - self-grounded files, no ink to set
grounded() {
  local src=$1 stem=$2; shift 2
  local s
  for s in "$@"; do
    rsvg-convert -w "$s" -h "$s" -o "$out/$stem-$s.png" "$src"
  done
}

# wide <src> <ink> <neon> <ground> <stem> <width...> - 180x64 lockup
wide() {
  local src=$1 ink=$2 neon=$3 ground=$4 stem=$5; shift 5
  local svg; svg=$(tint "$src" "$ink" "$neon")
  local w
  for w in "$@"; do
    rsvg-convert -w "$w" -h $(( w * 64 / 180 )) -b "$ground" -o "$out/$stem-$w.png" "$svg"
  done
}

# --- parent, two-colour on both grounds ---------------------------------
square "$here/mark.svg"         '#8cdbff' '#00b0ff' "$VOID"  mark-void          512 128
square "$here/mark.svg"         '#0b1020' '#0069a8' "$PAPER" mark-paper         512 128
square "$here/mark-compact.svg" '#8cdbff' '#00b0ff' "$VOID"  mark-compact-void  256 64
square "$here/mark-compact.svg" '#0b1020' '#0069a8' "$PAPER" mark-compact-paper 256 64

# --- parent, one ink ----------------------------------------------------
square "$here/mark-mono.svg" '#0b1020' '#0b1020' "$PAPER" mark-mono-ink   512
square "$here/mark-mono.svg" '#ffffff' '#ffffff' "$VOID"  mark-mono-white 512

# --- lockup -------------------------------------------------------------
wide "$here/lockup.svg" '#8cdbff' '#00b0ff' "$VOID"  lockup-void  720 360
wide "$here/lockup.svg" '#0b1020' '#0069a8' "$PAPER" lockup-paper 720 360

# --- self-grounded ------------------------------------------------------
grounded "$here/favicon.svg"    favicon    128 64 32 16
grounded "$here/icon-1024.svg"  icon       1024 512 256 128
grounded "$here/avatar-1024.svg" avatar    1024 500

# --- branch marks -------------------------------------------------------
# name  hi tint   accent    paper accent
branches='mtaudio:#ff9fbd:#ff2a6d:#c4004f
mtpublishing:#ffd68a:#ffb020:#8a5a00
mtapp:#c9adff:#9d6bff:#5b2fb8
mtopensource:#a5f5bd:#2ee65f:#157a33'

while IFS=: read -r name hi accent paper_accent; do
  square "$here/branches/$name.svg" "$hi"      "$accent"       "$VOID"  "branches/$name-void"  512 128
  square "$here/branches/$name.svg" '#0b1020'  "$paper_accent" "$PAPER" "branches/$name-paper" 512 128
done <<< "$branches"

grounded "$here/branches/mtopensource-avatar-1024.svg" branches/mtopensource-avatar 1024 500

printf 'rendered %s files to %s\n' "$(find "$out" -name '*.png' | wc -l | tr -d ' ')" "$out"
