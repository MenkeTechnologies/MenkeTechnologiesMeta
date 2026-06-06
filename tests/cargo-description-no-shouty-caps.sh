#!/usr/bin/env bash
# For every Cargo.toml `description` field, pin that the
# value contains no ALL-CAPS WORDS of 5+ letters.
#
# Cargo-side counterpart of iter-177 (brew formula desc, 4+
# threshold). The threshold differs intentionally:
#
#   Brew formula descs (iter-177): 4+ char threshold
#     - 2-3 letter acronyms ALL-CAPS allowed (AWK, JIT, TUI)
#     - 4+ letter ALL-CAPS catches TODO, shouty caps
#
#   Cargo crate descs (this gate): 5+ char threshold
#     - 2-3 letter AND 4-letter acronyms ALL-CAPS allowed
#       because cargo descs commonly include format names:
#       JSON, REST, HTTP, IPC, CSV, etc.
#     - 5+ letter ALL-CAPS catches FIXME, PLACEHOLDER,
#       URGENT, BROKEN, shouty caps
#
# Examples of legitimate 4-char acronyms in cargo descs
# (would FALSE-FAIL at the brew threshold):
#
#   stryke-arrow: "JSON in Apache Arrow / Parquet / IPC /
#                  CSV / JSON bridge..."
#   api-rest-generator: "REST in Spring Boot REST
#                                API generator..."
#
# TODO (4 chars) is NOT caught by this gate's threshold,
# but iter-141 catches it via word-boundary regex regardless
# of case. The two gates work together: iter-141 catches
# specific placeholder words by name; iter-178 catches
# arbitrary shouty 5+ char ALL-CAPS.
#
# Why 5+ for cargo specifically:
#
#   - cargo crate descs span a wider vocabulary than brew
#     formula descs (which describe brew-tap installables —
#     typically command-line tools with narrow acronym
#     vocab)
#   - 4-char tech acronyms (JSON, REST, HTTP, HTTPS, JSON,
#     CSV, YAML — wait YAML is 4 too) are ubiquitous in
#     cargo descs
#   - The placeholder words this gate's case-shape catches
#     are mostly 5+ chars (FIXME, PLACEHOLDER, BROKEN,
#     URGENT, MISSING)
#
# Detection: identical to iter-177 but with `^[A-Z]{5,}$`
# regex instead of `^[A-Z]{4,}$`.
#
# Pairs with iter-141 (TODO/FIXME placeholder via name),
# iter-177 (brew desc 4+ shouty), iter-143 (cargo desc
# capitalized first char). Four gates now pin the cargo
# description's casing discipline:
#
#   iter-141: name-based TODO/FIXME placeholder check
#   iter-143: first char is capital or digit
#   iter-178: no 5+ char ALL-CAPS shouty words (this gate)
#
# 27/27 crates green at iter-178 add — pure regression
# floor.
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
bad=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    desc=$(grep -m1 -E '^description *= *"' "$cargo" | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$desc" ]] || continue
    checked=$((checked + 1))

    for word in $desc; do
        clean=$(echo "$word" | tr -d '.,;:!?"()[]{}—–-/')
        if echo "$clean" | grep -qE '^[A-Z]{5,}$'; then
            echo "FAIL  $cargo: description contains shouty 5+ ALL-CAPS \"$clean\" — \"$desc\""
            bad=$((bad + 1))
            ok=0
            break
        fi
    done
done

echo "---"
echo "Summary: $checked descriptions checked, $bad with 5+ ALL-CAPS shouty words"

[[ $ok -eq 1 ]] && exit 0 || exit 1
