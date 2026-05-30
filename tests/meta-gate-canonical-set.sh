#!/usr/bin/env bash
# Meta self-audit extension: every tests/*.sh audit gate must
# use EXACTLY `set -uo pipefail` (the canonical org form).
#
# ELEVENTH recursive meta-self-audit gate.
#
# Why exactly `set -uo pipefail`:
#
# Bash's `set` flags are individually composable but the org
# has standardized on the three-flag combination:
#
#   -u : treat unset variables as errors (catches typos in
#        variable names that would silently expand to empty)
#   -o pipefail : pipeline exit status reflects the last
#        command that failed (without this, only the LAST
#        command's exit status counts; failures earlier in
#        the pipe are masked)
#
# NOT included:
#
#   -e : "exit on error" — frequently MISUNDERSTOOD. -e
#        doesn't exit on errors inside `if`, `while`,
#        `until`, `&&`, `||`, or function calls. The "exits
#        on errors" mental model is wrong; -e produces
#        confusing behavior where some failures abort and
#        others don't. Gates use explicit error handling
#        (`|| { echo FAIL; ok=0; }`) which is more reliable.
#
#   -x : trace execution (debug only, never committed)
#
# Why uniformity matters:
#
#   - DEBUGGABILITY: when a gate misbehaves, the first
#     question is "what bash mode is it in?" Uniform set
#     line means the answer is constant across the
#     catalog.
#   - COPY-PASTE: gates are written by copy-pasting from
#     an existing gate. If existing gates have `set -e` /
#     `set -euo pipefail` / `set -uo pipefail` mixed,
#     the new gate inherits whichever was copied. Uniform
#     enforcement prevents inconsistent mode propagation.
#   - REVIEW CONFIDENCE: a reviewer checking new gate code
#     trusts the existing patterns hold. Mixed set lines
#     undermine that trust.
#
# Detection: extract the first `set ...` line, exact-match
# against `set -uo pipefail`.
#
# Pairs with iter-65 (presence of pipefail-bearing set line —
# any form accepted by iter-65 since it uses substring match
# for `pipefail`). iter-175 narrows from "has some pipefail"
# to "has exactly the canonical form."
#
# Self-exempt — this gate satisfies the rule because its own
# `set -uo pipefail` line below matches the canonical form.
#
# 167/167 audit gates green at iter-175 add — pure
# regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

CANONICAL="set -uo pipefail"

checked=0
bad=0

for f in tests/*.sh; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))

    set_line=$(grep -m1 -E '^set ' "$f")
    if [[ -z "$set_line" ]]; then
        # Missing entirely is caught by iter-65, not this
        # gate. Treat as not-applicable here.
        continue
    fi

    if [[ "$set_line" != "$CANONICAL" ]]; then
        echo "FAIL  $f: set line is \"$set_line\" — canonical org form is \"$CANONICAL\""
        bad=$((bad + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked audit gates checked, $bad with non-canonical set line"

[[ $ok -eq 1 ]] && exit 0 || exit 1
