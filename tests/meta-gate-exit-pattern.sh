#!/usr/bin/env bash
# Meta self-audit extension: every tests/*.sh audit gate must
# end with ONE of two canonical exit patterns:
#
#   1. `[[ $ok -eq 1 ]] && exit 0 || exit 1`
#      The standard pass/fail gate pattern. The $ok variable
#      tracks whether any check failed during the gate's
#      walk; the final line propagates pass/fail to the
#      caller's exit code.
#
#   2. `exit 0`
#      The informational-only gate pattern. These gates
#      print findings or counts but never make a pass/fail
#      decision. iter-133 (canonical exit codes) ensures
#      exit 0 is the only allowed code for informational
#      gates.
#
# TWELFTH recursive meta-self-audit gate.
#
# Why the canonical patterns:
#
#   - PREDICTABILITY: a reviewer reading the END of a gate
#     file knows exactly how the gate signals success or
#     failure. Mixed exit patterns (e.g., `exit $?`,
#     `exit "$rc"`, naked `exit`) introduce ambiguity
#     about what the gate's exit semantics actually are.
#
#   - GREP-ABILITY: `tail -1 tests/*.sh` produces a
#     one-line-per-gate summary of exit semantics when the
#     convention holds. Ad-hoc exit patterns break the
#     summary format.
#
#   - SAFETY: the `[[ $ok -eq 1 ]] && exit 0 || exit 1`
#     form has a subtle property — when $ok is unset (e.g.,
#     due to a bug earlier in the script), `set -u`
#     (mandatory per iter-175) makes the test fail with
#     `unbound variable`, which propagates as exit 1.
#     Variant forms like `exit $ok` would propagate the
#     unbound-variable status differently.
#
# Detection: look at the last non-blank line of each gate.
# Match against the two canonical patterns. Anything else
# fails.
#
# Self-exempt because this gate's own last line below
# matches pattern 1.
#
# Pairs with iter-133 (canonical exit codes 0/1) and
# iter-102 (Summary line). iter-133 pins WHICH codes are
# allowed; iter-176 pins HOW those codes are propagated to
# the final exit line.
#
# 166 pass/fail + 2 informational = 168/168 audit gates
# green at iter-176 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

CANONICAL_PASSFAIL='[[ $ok -eq 1 ]] && exit 0 || exit 1'
CANONICAL_INFO='exit 0'

checked=0
bad=0

for f in tests/*.sh; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))

    last_line=$(tail -5 "$f" | grep -vE '^[[:space:]]*$' | tail -1)

    case "$last_line" in
        "$CANONICAL_PASSFAIL"|"$CANONICAL_INFO")
            : # pass
            ;;
        *)
            echo "FAIL  $f: last line is \"$last_line\" — expected \"$CANONICAL_PASSFAIL\" or \"$CANONICAL_INFO\""
            bad=$((bad + 1))
            ok=0
            ;;
    esac
done

echo "---"
echo "Summary: $checked audit gates checked, $bad with non-canonical final exit pattern"

[[ $ok -eq 1 ]] && exit 0 || exit 1
