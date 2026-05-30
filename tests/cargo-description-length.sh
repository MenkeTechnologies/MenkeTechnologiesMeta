#!/usr/bin/env bash
# For every Rust submodule, pin that the package Cargo.toml has a
# `description` field within a reasonable length cap for crates.io
# display.
#
# crates.io search results truncate descriptions at ~100 chars in the
# card view; the crate page itself shows the full text but wraps
# awkwardly past ~150 chars. Style precedent from popular crates:
#   - serde:  50 chars
#   - tokio:  93 chars
#   - regex: 140 chars
#
# Thresholds:
#   <= 150: PASS
#   100-150: WARN (still acceptable, but flag for review)
#   > 150: FAIL (will visibly wrap/truncate, hurts discoverability)
#   missing: FAIL (mandatory field for crates.io)
#
# Test does NOT enforce the Homebrew formula 80-char cap on the Rust
# `description` field — the brew formula's own desc is a separate field
# and is enforced by homebrew-menketech's formula-consistency.rb.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
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
missing=0
too_long=0
warn_long=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    checked=$((checked + 1))

    desc=""
    if grep -qE '^description\.workspace *= *true' "$cargo"; then
        ws_root="$p/Cargo.toml"
        if [[ -f "$ws_root" ]] && grep -qE '^\[workspace\.package\]' "$ws_root"; then
            desc=$(awk '
                /^\[workspace\.package\]/ { in_ws = 1; next }
                /^\[/                     { in_ws = 0 }
                in_ws && /^description *= *"/ {
                    match($0, /"[^"]*"/)
                    print substr($0, RSTART + 1, RLENGTH - 2)
                    exit
                }
            ' "$ws_root")
        fi
    fi
    if [[ -z "$desc" ]]; then
        desc=$(grep -m1 -E '^description *= *"' "$cargo" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
    fi

    if [[ -z "$desc" ]]; then
        echo "FAIL  $cargo: no description field — required for crates.io publish"
        missing=$((missing + 1))
        ok=0
        continue
    fi

    len=${#desc}

    if (( len > 150 )); then
        echo "FAIL  $cargo: description $len chars > 150 — will visibly wrap on crate page + truncate in search"
        too_long=$((too_long + 1))
        ok=0
    elif (( len > 100 )); then
        echo "WARN  $cargo: description $len chars > 100 — borderline for crates.io search-card display"
        warn_long=$((warn_long + 1))
    else
        echo "PASS  $cargo: description $len chars"
    fi
done

echo "---"
echo "Summary: $checked package Cargo.toml files checked, $missing without description, $too_long over hard 150-char cap, $warn_long over soft 100-char cap"

[[ $ok -eq 1 ]] && exit 0 || exit 1
