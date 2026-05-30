#!/usr/bin/env bash
# For every Homebrew formula's `desc "..."` field, pin that
# the value does NOT contain two consecutive ASCII spaces.
#
# Brew-side mirror of iter-151 (cargo-side equivalent for
# Cargo.toml description). Same rationale:
#
#   - Double-spaces are typos (dropped word leaving trailing
#     space adjacent to next word's leading space)
#   - Render in `brew info` and formulae.brew.sh as visible
#     gaps that look broken
#   - Confuse downstream parsers (formulae.brew.sh search
#     index, brew bundle inventory tools)
#   - Indicate hand-edited content with reduced editorial
#     polish
#
# Detection: grep for `  ` (two consecutive ASCII spaces) in
# the extracted desc string. The check is brew-side
# symmetric with iter-151 for cargo.
#
# The brew formula desc shape catalog now has SIX gates:
#
#   iter-75:  presence (field exists at all)
#   iter-136: length ≤ 80 chars
#   iter-137: starts with capital or digit
#   iter-138: no trailing period
#   iter-142: no placeholder markers (TODO/FIXME/XXX/TBD)
#   iter-152: no double-space (this gate — mirror of iter-151)
#
# Now FULLY SYMMETRIC with the cargo description shape
# catalog (iter-27 / 47 / 53 / 94 / 141 / 143 / 151).
#
# Six brew-side gates ↔ seven cargo-side gates. The cargo
# catalog has one extra (iter-53 length-floor ≥ 20) because
# cargo descriptions can be longer and the lower bound rules
# out one-word stubs; brew descs are length-capped at 80
# which forecloses the same drift.
#
# 10/10 formulas green at iter-152 add — pure regression
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
    [[ -n "$desc" ]] || continue

    if echo "$desc" | grep -qE '  '; then
        echo "FAIL  $f: desc contains double space — \"$desc\""
        bad=$((bad + 1))
        ok=0
    else
        echo "PASS  $f"
    fi
done

echo "---"
echo "Summary: $checked formulas checked, $bad with double-space in desc"

[[ $ok -eq 1 ]] && exit 0 || exit 1
