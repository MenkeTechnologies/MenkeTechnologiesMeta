#!/usr/bin/env bash
# Meta self-audit extension: every tests/*.sh audit gate file
# must be at most 250 lines.
#
# EIGHTH recursive meta-self-audit gate. The catalog now
# spans:
#
#   iter-65:  SHAPE       — shebang, pipefail, exec bit, root pattern
#   iter-99:  WIRING      — every gate invoked from ci.yml
#   iter-100: PORTABILITY — python3 skip fallback
#   iter-101: SCOPE       — find . excludes .git/
#   iter-102: OUTPUT      — Summary line in every post-bootstrap gate
#   iter-133: EXIT CODES  — every gate uses exit 0 / 1
#   iter-158: NAMING      — every gate uses kebab-case filename
#   iter-172: SIZE BOUND  — every gate is ≤ 250 lines (this gate)
#
# Why 250 lines:
#
#   - Each audit gate has one focused concern (per iter-1's
#     "ship one gate per iteration" rule). A focused single-
#     concern check fits in 100-200 lines including the
#     extensive header comment block that documents the
#     rationale.
#   - 250+ line gates typically signal:
#     1. The gate is doing multiple unrelated checks (split
#        into separate iter-N gates)
#     2. Complex parsing that should be delegated to Python
#        (the canonical pattern for non-trivial logic — see
#        iter-100's python3 skip fallback)
#     3. Embedded test fixtures or extensive example data
#        (move to a sibling .data file or to a comment
#        block)
#     4. Duplicate code that should be extracted to a
#        shared helper (rare; gates are intentionally
#        self-contained but a few would benefit)
#   - PR REVIEW: 250 lines is the upper bound of effective
#     code-review attention per pass; past it, defects in
#     the middle slip through.
#   - DEBUGGABILITY: a 250-line gate fits on 3-4 terminal
#     screens; longer gates require search-and-jump
#     navigation that slows incident response.
#
# Self-exempt because the gate's own header documents the
# pattern.
#
# Pairs with iter-169 / iter-170 / iter-171 (workflow,
# Cargo.toml, brew formula size bounds). Four file-size
# sanity gates encoding "config/code past a threshold needs
# split" across the umbrella's four main file types:
#
#   iter-169: workflow yml          ≤ 1000 lines
#   iter-170: Cargo.toml             ≤ 500 lines
#   iter-171: brew formula           ≤ 200 lines
#   iter-172: audit gate (this gate) ≤ 250 lines
#
# 164/164 audit gates green at iter-172 add — pure
# regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

MAX_LINES=250

checked=0
oversize=0

for f in tests/*.sh; do
    [[ -f "$f" ]] || continue
    [[ "$(basename "$f")" == "meta-gate-size-bound.sh" ]] && continue
    checked=$((checked + 1))

    lines=$(wc -l < "$f" | tr -d ' ')
    if [[ "$lines" -gt "$MAX_LINES" ]]; then
        echo "FAIL  $f: $lines lines (max $MAX_LINES) — split into multiple gates or delegate parsing to Python"
        oversize=$((oversize + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked audit gates checked, $oversize over $MAX_LINES lines"

[[ $ok -eq 1 ]] && exit 0 || exit 1
