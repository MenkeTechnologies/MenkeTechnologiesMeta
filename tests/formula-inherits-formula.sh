#!/usr/bin/env bash
# For every Homebrew formula in homebrew-menketech/Formula/*.rb,
# pin that the class declaration inherits from `Formula`:
#
#   class FormulaName < Formula
#     ...
#   end
#
# Homebrew requires every formula's Ruby class to inherit from
# the `Formula` base class. The base class provides:
#
#   - DSL methods: url, sha256, depends_on, bin.install,
#     test do, livecheck do, etc.
#   - Lifecycle hooks: install, post_install, uninstall,
#     caveats, head, etc.
#   - Auto-registration in the brew formulary on file load
#
# Without `< Formula`, the Ruby class is a plain Object subclass
# — the DSL methods are undefined, every reference fails with
# `NoMethodError`. `brew install` errors at the very first DSL
# call (typically `url ...` on the second line of the file):
#
#   Error: undefined method `url' for #<Object:0x...>
#
# The mistake is easy to make in three scenarios:
#   - Hand-writing a formula from scratch and forgetting the
#     base class (Ruby allows bare `class Foo`)
#   - Inheriting from a custom intermediary (e.g.,
#     `class Foo < MyBaseFormula`) where the intermediary
#     itself doesn't inherit from Formula (chain broken)
#   - Generated formulas where the template's base class
#     variable wasn't substituted
#
# Detection: regex on `^class <Name> < Formula` (with optional
# whitespace). Variant inheritance via custom intermediate
# classes that themselves inherit from Formula are RARE in
# this tap (none today), so the gate enforces the direct form;
# if a custom base class is later needed, the gate must be
# extended with an allowlist of intermediate-base names.
#
# Pairs with iter-119 (class name matches filename) — together
# they pin BOTH the class identity and the inheritance contract
# at formula load time. Without these gates, an unloadable
# formula ships to users and fails at install with cryptic
# Ruby errors.
#
# 10/10 formulas green at iter-120 add — pure regression floor.
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
    if grep -qE '^class [A-Za-z0-9]+ < Formula' "$f"; then
        class_line=$(grep -m1 -E '^class ' "$f")
        echo "PASS  $f: $class_line"
    else
        echo "FAIL  $f: no \`class <Name> < Formula\` declaration — formula will fail to load (NoMethodError on first DSL call)"
        bad=$((bad + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked formulas checked, $bad without canonical \`< Formula\` inheritance"

[[ $ok -eq 1 ]] && exit 0 || exit 1
