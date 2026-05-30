#!/usr/bin/env bash
# For every Homebrew formula's `desc "..."` field, pin that
# the value does NOT contain placeholder markers: TODO,
# FIXME, XXX, TBD, "placeholder".
#
# Same rationale as iter-141 (cargo-side equivalent for
# Cargo.toml description):
#
#   - desc renders in `brew info <name>` info card
#   - desc shows in `brew search <pattern>` results
#   - desc is the SEO meta-description on formulae.brew.sh
#   - desc appears in Homebrew's machine-readable formula
#     index (used by homebrew-bundle, dependency analysis,
#     etc.)
#
# Placeholder text in any of these contexts signals
# "abandoned" or "in-development, not for use" — even when
# the formula's other fields (sha256, url, install) are
# fully correct. The placeholder catches the user's eye
# before any other field's quality does.
#
# Detection: case-insensitive word-boundary regex on TODO,
# FIXME, XXX, TBD, placeholder.
#
# The brew formula desc shape catalog now has FIVE gates:
#
#   iter-75:  presence (field exists at all)
#   iter-136: length ≤ 80
#   iter-137: starts with capital or digit
#   iter-138: no trailing period
#   iter-142: no placeholder markers (this gate)
#
# Mirror of the cargo description shape catalog from iter-141.
#
# 10/10 formulas green at iter-142 add — pure regression floor.
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

    if echo "$desc" | grep -qiE '\b(TODO|FIXME|XXX|TBD|placeholder)\b'; then
        echo "FAIL  $f: desc contains placeholder marker — \"$desc\""
        bad=$((bad + 1))
        ok=0
    else
        echo "PASS  $f"
    fi
done

echo "---"
echo "Summary: $checked formulas checked, $bad with placeholder markers in desc"

[[ $ok -eq 1 ]] && exit 0 || exit 1
