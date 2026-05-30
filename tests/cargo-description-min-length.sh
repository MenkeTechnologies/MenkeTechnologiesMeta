#!/usr/bin/env bash
# For every Rust submodule's package Cargo.toml, pin that the
# `description` field has at least 20 characters. Below 20 chars
# is too short to be informative on crates.io's crate card,
# `cargo search` output, or IDE tooltips.
#
# Crates.io best practice (from registry guidelines): descriptions
# should be a meaningful blurb. Examples that fail at < 20 chars:
#   - "A CLI tool"        (10 chars) — generic, gives no info
#   - "Web framework"     (13 chars) — could be anything
#   - "TUI in Rust"       (11 chars) — no topic, no purpose
#
# Iter-27 covered the upper bound (150 chars hard cap, 100 char
# soft warn). This gate covers the lower bound. Together they
# define a meaningful range for the description field.
#
# Current floor across umbrella (iter-53 audit): storageshower
# is shortest at 24 chars ("Cyberpunk disk usage TUI"). All
# others 45+ chars. Add-time clean — gate prevents future
# truncation regressions.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

paths=()
while IFS= read -r line; do
    paths+=("${line#$'\tpath = '}")
done < <(grep $'^\tpath = ' .gitmodules)

init_count=0
for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] && init_count=$((init_count + 1))
done
if [[ $init_count -eq 0 ]]; then
    echo "SKIP  no submodules initialized"
    exit 0
fi

checked=0
short=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    desc=$(grep -m1 -E '^description *= *"' "$cargo" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$desc" ]] || continue

    checked=$((checked + 1))
    len=${#desc}

    if (( len < 20 )); then
        echo "FAIL  $cargo: description $len chars < 20 — too short to be informative on crates.io"
        echo "        full text: '$desc'"
        short=$((short + 1))
        ok=0
    else
        echo "PASS  $cargo: description $len chars"
    fi
done

echo "---"
echo "Summary: $checked Cargo.toml descriptions checked, $short under 20-char floor"

[[ $ok -eq 1 ]] && exit 0 || exit 1
