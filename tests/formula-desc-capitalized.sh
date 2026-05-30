#!/usr/bin/env bash
# For every Homebrew formula's `desc "..."` field, pin that
# the first character is uppercase A-Z or a digit 0-9.
#
# Homebrew's style guide and `brew audit --strict` both require
# the desc to start with a capital letter (or digit — for
# version-prefixed descriptions like "1:1 Rust port of..."
# which intentionally lead with the ratio number).
#
# Rendering contexts that show capitalization:
#
#   - `brew info <name>` second line: lowercased lead reads
#     as a fragment ("ust port of awk in Rust" — starting
#     "ust" mid-sentence looks broken).
#   - `brew search` table: each row's desc column is read
#     left-to-right; capitalization signals "this is the
#     start of a new descriptive sentence" vs continuation.
#   - formulae.brew.sh formula page: desc renders as the
#     `<meta description>` and the on-page subtitle. Both
#     contexts expect sentence-case.
#
# Allowed first characters: [A-Z] (canonical sentence-case)
# or [0-9] (digit-leading descriptions like "1:1 Rust port"
# from powerliners — intentional content that conveys the
# ratio).
#
# Rejected: lowercase a-z, punctuation, special chars.
#
# Detection: extract desc, check the first byte (assuming
# ASCII for description first chars — UTF-8 leading chars
# like em-dashes would be rejected, but no current desc
# starts with one).
#
# Pairs with iter-75 (desc presence), iter-136 (desc length).
# Three gates now pin desc presence, length, and starting
# character — every common style-guide concern for the brew
# desc field.
#
# 10/10 formulas green at iter-137 add — pure regression
# floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

formulas_dir="homebrew-menketech/Formula"
if [[ ! -d "$formulas_dir" ]]; then
    echo "SKIP  $formulas_dir not initialized"
    exit 0
fi

checked=0
bad=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))

    desc=$(grep -m1 -oE '^\s+desc *"[^"]+"' "$f" | sed 's/.*"\([^"]*\)".*/\1/')
    if [[ -z "$desc" ]]; then
        continue  # presence checked by iter-75
    fi

    first="${desc:0:1}"
    if echo "$first" | grep -qE '^[A-Z0-9]$'; then
        echo "PASS  $f: desc starts with '$first'"
    else
        echo "FAIL  $f: desc starts with '$first' (expected [A-Z] or [0-9]): \"$desc\""
        bad=$((bad + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked formulas checked, $bad with non-capital desc start"

[[ $ok -eq 1 ]] && exit 0 || exit 1
