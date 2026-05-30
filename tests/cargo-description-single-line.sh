#!/usr/bin/env bash
# For every Cargo.toml `description` field, pin that the
# value is a SINGLE-LINE string (no `"""` multi-line form).
#
# TOML's `"""` triple-quoted form allows literal newlines
# in the string value. Cargo accepts this for the
# description field, but downstream rendering contexts
# don't:
#
#   - crates.io's CARD VIEW renders description as a
#     one-line tagline. A multi-line string gets either
#     truncated at the first newline (cutting off the
#     bulk of the content) or rendered with literal
#     `\n` escape sequences (looking broken).
#
#   - `cargo search` OUTPUT shows description as a one-
#     line column. Embedded newlines collapse to spaces;
#     the user sees a mashed-together blob instead of
#     the intended structure.
#
#   - DOCS.RS subtitle uses description verbatim. The
#     CSS doesn't handle multi-line gracefully —
#     content past the first line either overflows the
#     subtitle area or gets clipped.
#
#   - SEO META: <meta description> tags are HTML-spec
#     SINGLE LINE. Newlines in the value violate the
#     spec; some search-engine crawlers truncate at the
#     first newline, others reject the whole tag.
#
# Cargo's manifest grammar accepts `"""..."""` but the
# rendering ecosystem doesn't. Forcing single-line keeps
# the description compatible with every consumer.
#
# Detection: regex on `description = """` (triple-
# quoted form). Single-line `description = "..."` is
# accepted regardless of length (length is iter-27's
# concern).
#
# Pairs with the cargo description shape catalog:
#
#   iter-27:  length ≤ 150
#   iter-47:  no trailing period
#   iter-53:  length ≥ 20
#   iter-94:  no URL inside
#   iter-141: no TODO/FIXME placeholders
#   iter-143: starts with capital or digit
#   iter-151: no double-space
#   iter-178: no 5+ ALL-CAPS shouty
#   iter-190: single-line (this gate)
#
# 27/27 crates green at iter-190 add — pure regression
# floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi

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

    if ! grep -qE '^description *= *"' "$cargo"; then
        continue
    fi
    checked=$((checked + 1))

    if grep -qE '^description *= *"""' "$cargo"; then
        echo "FAIL  $cargo: description uses triple-quote multi-line form — downstream renderers expect single-line"
        bad=$((bad + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked descriptions checked, $bad multi-line"

[[ $ok -eq 1 ]] && exit 0 || exit 1
