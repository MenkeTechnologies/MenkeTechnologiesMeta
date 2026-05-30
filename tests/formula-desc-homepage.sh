#!/usr/bin/env bash
# For every Homebrew formula in homebrew-menketech/Formula/*.rb,
# pin that the formula declares BOTH a `desc "..."` and a
# `homepage "..."` field.
#
# Homebrew renders both fields prominently:
#
#   `brew info <name>` output:
#     ==> foo: stable 1.2.3 (bottled)
#     <DESC>
#     <HOMEPAGE>
#
#   `brew search` and the formulae.brew.sh site index — both use
#   `desc` as the one-line summary.
#
# Missing `desc` produces output like:
#
#   ==> foo: stable 1.2.3
#     (description missing)
#     https://...
#
# Missing `homepage` skips the URL line entirely — the user has
# no way to find docs, repo, or contact without running
# `brew formulae` and digging.
#
# Both fields are REQUIRED by Homebrew's audit (`brew audit
# --strict <name>`) which the tap's CI enforces. But the tap
# audit only runs on `brew install` and `brew test` paths —
# formulas added to Formula/ but never installed pass through
# the gap. This gate catches them at lint time.
#
# Pattern checks:
#   - `desc "..."` (indented inside the formula class body)
#   - `homepage "..."` (same indentation)
#
# 10/10 formulas green at iter-75 add — pure regression floor.
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
no_desc=0
no_homepage=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))
    local_ok=1

    if ! grep -qE '^\s+desc *"' "$f"; then
        echo "FAIL  $f: no \`desc \"...\"\` field (brew info shows '(description missing)')"
        no_desc=$((no_desc + 1))
        local_ok=0
        ok=0
    fi

    if ! grep -qE '^\s+homepage *"' "$f"; then
        echo "FAIL  $f: no \`homepage \"...\"\` field (brew info hides URL line)"
        no_homepage=$((no_homepage + 1))
        local_ok=0
        ok=0
    fi

    [[ $local_ok -eq 1 ]] && echo "PASS  $f: desc + homepage declared"
done

echo "---"
echo "Summary: $checked formulas checked, $no_desc without desc, $no_homepage without homepage"

[[ $ok -eq 1 ]] && exit 0 || exit 1
