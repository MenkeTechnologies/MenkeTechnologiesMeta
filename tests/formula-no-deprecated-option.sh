#!/usr/bin/env bash
# For every Homebrew formula, pin that no `option`
# keyword is used in the formula DSL.
#
# `option "with-foo", "Enable foo support"` was the
# old way to expose build-time configuration to users
# (`brew install <formula> --with-foo`). Homebrew
# deprecated this in 2019 and started rejecting new
# core PRs with option blocks in 2020.
#
# Why deprecated:
#
#   - Reproducibility: a formula with options produces
#     DIFFERENT binaries depending on which options
#     were passed at install time. Two users on the
#     same OS, same brew version, same formula version
#     can end up with different binaries. brew's whole
#     model assumes 1 formula version = 1 binary;
#     options break that invariant.
#
#   - Bottle cache: brew's precompiled-bottle system
#     uploads ONE binary per formula version per
#     platform/arch combination. With options, the
#     number of possible binaries explodes (2^N for N
#     boolean options). The bottle cache can't track
#     them all, so option-using formulas force users
#     to BUILD FROM SOURCE every install — slow,
#     resource-heavy, error-prone on contributor
#     boxes without a full Xcode/build-essential
#     environment.
#
#   - Maintenance: option-conditional code in the
#     `install` block branches into multiple build
#     paths. Each path is a distinct maintenance
#     surface. Bug reports become "I installed with
#     --with-foo and..." with most maintainers
#     having no clue which option-combination the
#     reporter used.
#
#   - Discovery: users don't know which options exist
#     without reading the formula source. `brew
#     info` lists options but rarely surfaces them
#     prominently. Most users install with defaults
#     and never know about the alternative builds.
#
# Migration path: split into separate formulas. If
# formula `foo` has option `--with-bar`, the modern
# approach is two formulas: `foo` (without bar) and
# `foo-with-bar` (with bar baked in). Each has ONE
# binary, ONE bottle, ONE maintenance surface.
#
# Alternative for compile-time flags: hardcode the
# canonical build in the formula's install block,
# without exposing options to the user. If users want
# a different build, they can tap a fork with the
# alternate config.
#
# brew audit's `audit --strict --new` rejects option
# blocks in new formulas. Existing formulas can still
# use them, but tap formulas (us) inherit core's
# convention — stay option-free to keep the formulas
# core-PR-compatible if we ever want to upstream
# them.
#
# Detection: regex on `^\s+option\s+` (Ruby DSL
# keyword at the formula-body indent level).
#
# Pairs with the brew formula hygiene catalog
# (presence, install, test, desc shape, url
# canonical, etc.) — adds anti-deprecated-DSL.
#
# 0/10 formulas use option at iter-199 add — pure
# regression floor.
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

    if grep -qE '^\s+option\s+' "$f"; then
        ln=$(grep -nE '^\s+option\s+' "$f" | head -1 | cut -d: -f1)
        echo "FAIL  $f:$ln: deprecated option DSL — split into separate formulas or hardcode the canonical build"
        bad=$((bad + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked formulas checked, $bad with deprecated option blocks"

[[ $ok -eq 1 ]] && exit 0 || exit 1
