#!/usr/bin/env bash
# For every Homebrew formula in homebrew-menketech/Formula/*.rb,
# pin that the Ruby `class FormulaName < Formula` line uses a
# name equal to the TitleCased form of the filename basename
# (with hyphens converted to camelcase boundaries).
#
# Homebrew loads formulas by:
#   1. Parsing `<tap>/Formula/<name>.rb`
#   2. require_relative-ing the file
#   3. Looking up a Ruby constant matching the kebab-to-camel
#      conversion of <name>
#
# If the class name doesn't match the expected form:
#
#   Error: undefined method `install' for nil:NilClass
#
# (Because the formula registry lookup returns nil — the class
# Homebrew expected to find isn't defined under that name.)
# The failure is at load time, not at audit time. `brew install
# <name>` from the user's perspective fails with an opaque
# nil-method error.
#
# Naming convention enforced:
#
#   awkrs.rb           → class Awkrs           (no hyphens, no change)
#   zshrs.rb           → class Zshrs           (single word, TitleCase)
#   zshrs-all.rb       → class ZshrsAll        (hyphen → CamelCase boundary)
#   spring-boot-rest.rb → class SpringBootRest  (multi-hyphen)
#
# Algorithm: split filename basename on `-`, TitleCase each
# segment, concatenate. Compare against the actual `class ...`
# line in the file.
#
# 10/10 formulas green at iter-119 add — pure regression floor
# against accidental class-name typo during a formula rename
# or template generation.
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
mismatch=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))

    base=$(basename "$f" .rb)
    # Convert kebab-case → CamelCase: split on -, title-case each, join.
    expected=$(echo "$base" | awk -F- '{
        out = ""
        for (i = 1; i <= NF; i++) {
            out = out toupper(substr($i, 1, 1)) substr($i, 2)
        }
        print out
    }')

    class_line=$(grep -m1 -E '^class ' "$f" | awk '{print $2}')

    if [[ "$class_line" == "$expected" ]]; then
        echo "PASS  $f: class $class_line matches filename"
    else
        echo "FAIL  $f: class \"$class_line\" doesn't match expected \"$expected\" (from filename $base.rb)"
        mismatch=$((mismatch + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked formulas checked, $mismatch class-name mismatches"

[[ $ok -eq 1 ]] && exit 0 || exit 1
