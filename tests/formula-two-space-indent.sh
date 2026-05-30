#!/usr/bin/env bash
# For every Homebrew formula in homebrew-menketech/Formula/*.rb,
# pin that the file uses 2-space indentation (no tabs, no odd
# indent depth).
#
# Homebrew's style guide and `brew style` both enforce 2-space
# indentation for Ruby code in formulas. The reasons:
#
#   - Ruby community convention: every popular Ruby style
#     guide (RuboCop, Standard, Airbnb) defaults to 2-space.
#     Homebrew aligns with the broader Ruby ecosystem.
#   - brew audit --strict: explicitly flags tab-indented or
#     non-2-space-multiple indent lines.
#   - Diff readability: when formulas are auto-bumped by the
#     release.yml workflow (sha256 + url update), the
#     resulting diff is line-oriented. Inconsistent indent
#     within the same file makes the diff harder to read.
#   - Editor consistency: Ruby's `def`/`end` block structure
#     uses indent to communicate nesting. Mixed depths (e.g.,
#     3-space inside a 2-space file) break the visual block
#     guides that modern editors render.
#
# Convention enforced: every non-empty non-comment line that
# has any indentation must:
#   1. Start with spaces (no tabs)
#   2. Have an even number of leading spaces (0, 2, 4, 6, ...)
#
# Detection: walk every line, skip empty/comment, check leading
# whitespace. Tabs flagged separately from odd-space depths.
#
# The brew formula gate family now totals 14 (after iter-150):
#   structure:    iter-119 (class name), iter-120 (inheritance)
#   load-time:    iter-89 (def install), iter-88 (test do)
#   integrity:    iter-74 (sha256), iter-77 (canonical url),
#                 iter-123 (binary url), iter-98 (version match)
#   metadata:     iter-75 (desc + homepage)
#   desc shape:   iter-136 (length), iter-137 (capital),
#                 iter-138 (no period), iter-142 (no placeholder)
#   execution:    iter-115 (system array), iter-121 (assert)
#   style:        iter-150 (this gate) — 2-space indent
#
# 10/10 formulas green at iter-150 add — pure regression floor.
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
    local_bad=0

    line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Skip empty + comments.
        stripped="${line#"${line%%[![:space:]]*}"}"
        case "$stripped" in
            ""|\#*) continue ;;
        esac

        # Extract leading whitespace.
        indent="${line%%[![:space:]]*}"

        # Tab check.
        if [[ "$indent" == *$'\t'* ]]; then
            echo "FAIL  $f:$line_num: tab in indent — Ruby convention is 2-space"
            local_bad=1
            ok=0
            bad=$((bad + 1))
            break
        fi

        # Even-depth check.
        n=${#indent}
        if [[ $((n % 2)) -ne 0 ]]; then
            echo "FAIL  $f:$line_num: odd indent ($n spaces) — Ruby convention is 2-space multiples"
            local_bad=1
            ok=0
            bad=$((bad + 1))
            break
        fi
    done < "$f"

    [[ $local_bad -eq 0 ]] && echo "PASS  $f: 2-space indent throughout"
done

echo "---"
echo "Summary: $checked formulas checked, $bad with non-2-space indent"

[[ $ok -eq 1 ]] && exit 0 || exit 1
