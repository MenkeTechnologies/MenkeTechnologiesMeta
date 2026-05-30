#!/usr/bin/env bash
# For every workflow yml file across the umbrella, pin that
# the file size is at most 1000 lines (sanity bound).
#
# Why 1000 lines:
#
#   - GitHub Actions has a hard 1024 KB max per workflow file
#     (about 30,000 lines of typical YAML). 1000 lines is
#     well under the technical limit but represents the
#     practical readability boundary.
#   - Workflow files past 1000 lines almost always indicate
#     accumulated drift — multiple jobs that should be split
#     into separate workflow files (one per concern),
#     copy-paste of the same step pattern across many jobs
#     (should be extracted to a reusable workflow), or
#     dead code that nobody pruned.
#   - PR review of 1000+ line workflow changes is
#     dramatically slower; the rate of unreviewed bugs (env
#     var typos, copy-paste errors, conditional gaps) rises
#     sharply past the threshold.
#   - IDE workflow linters (GitHub's own VS Code extension,
#     `act`) load workflows into memory; very large files
#     introduce parser slowness that surprises contributors.
#
# Allowlist for legitimate large files:
#
#   .github/workflows/ci.yml  (this meta repo's CI aggregator)
#     This file invokes every audit gate via individual
#     `run:` steps. The line count grows with each gate
#     iteration. As of iter-169 it's at 2068 lines and will
#     continue growing — that's structurally required by
#     the aggregator pattern.
#
# When the meta ci.yml exceeds a future threshold (e.g.
# 5000 lines or refactor pressure), the right fix is to
# split it into multiple reusable workflows; until then,
# the allowlist documents the known oversize as
# legitimate.
#
# Detection: wc -l on each workflow, compare against 1000.
#
# 89/89 non-allowlisted workflows green at iter-169 add —
# pure regression floor against accidental sprawl.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

MAX_LINES=1000

# Allowlist: workflow paths that are intentionally large.
# Map paths to reason strings for documentation in the FAIL
# branch (if the file later shrinks, the entry can be removed).
declare -A ALLOWLIST=(
    [./.github/workflows/ci.yml]="meta-repo CI aggregator; grows with each audit-gate iteration; structurally required"
)

checked=0
oversize=0
allowlisted=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))

    lines=$(wc -l < "$wf" | tr -d ' ')
    if [[ "$lines" -gt "$MAX_LINES" ]]; then
        if [[ -n "${ALLOWLIST[$wf]:-}" ]]; then
            echo "WARN  $wf: $lines lines — ALLOWLISTED (${ALLOWLIST[$wf]})"
            allowlisted=$((allowlisted + 1))
        else
            echo "FAIL  $wf: $lines lines (max $MAX_LINES) — split into reusable workflows or remove dead code"
            oversize=$((oversize + 1))
            ok=0
        fi
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflows checked, $oversize over $MAX_LINES lines un-allowlisted ($allowlisted allowlisted)"

[[ $ok -eq 1 ]] && exit 0 || exit 1
