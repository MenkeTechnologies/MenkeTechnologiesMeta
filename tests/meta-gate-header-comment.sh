#!/usr/bin/env bash
# Meta self-audit extension: every tests/*.sh audit gate must
# have a header comment block on line 2 (immediately after
# the bash shebang on line 1).
#
# NINTH recursive meta-self-audit gate. The convention from
# iter-1 onwards is:
#
#   #!/usr/bin/env bash
#   # <human-readable description of what this gate checks>
#   # <multi-line rationale, drift introduction patterns,
#   #  pairs-with cross-references to other iter-N gates>
#   set -uo pipefail
#   root="$(cd "$(dirname "$0")/.." && pwd)"
#   ...
#
# The line-2 comment is the FIRST thing a reader sees after
# the shebang. It serves as the gate's:
#
#   - SUBJECT LINE: when a contributor `cat`s the file to
#     understand what it does, line 2 is the answer at a
#     glance.
#   - PR REVIEW HOOK: GitHub's PR diff renderer shows the
#     first few lines of any modified file. A missing
#     header means the reviewer has to scroll to find the
#     intent.
#   - GREP HOOK: `head -2 tests/*.sh` produces a one-line-
#     per-gate summary table when the convention holds.
#     Bootstrap gates without headers break the summary.
#   - SELF-DOCUMENTATION: the gate's reason for existing
#     should be readable in the file itself, not buried in
#     a commit message or external doc.
#
# Bootstrap allowlist: gates added BEFORE the convention
# emerged from iter-1.
#
#   bin-scripts.sh  (pre-loop original)
#     This gate predates the iter-1 convention. Its line 2
#     is `set -uo pipefail` directly. The gate works; the
#     style preceded the documentation discipline. Future
#     refactor could backfill a header, but the meta-only
#     scope from CLAUDE.md preserves it as-is for now.
#
# Self-exempt because this gate's own header IS line 2,
# satisfying the rule.
#
# Pairs with iter-65 / iter-99 / iter-100 / iter-101 /
# iter-102 / iter-133 / iter-158 / iter-172. Nine recursive
# self-audit gates now cover every dimension a gate file
# can drift on:
#
#   iter-65:  SHAPE       — shebang, pipefail, exec, root
#   iter-99:  WIRING      — invoked from ci.yml
#   iter-100: PORTABILITY — python3 skip fallback
#   iter-101: SCOPE       — find . excludes .git/
#   iter-102: OUTPUT      — Summary line
#   iter-133: EXIT CODES  — 0 or 1 only
#   iter-158: NAMING      — kebab-case filename
#   iter-172: SIZE BOUND  — ≤ 250 lines
#   iter-173: HEADER      — line-2 comment (this gate)
#
# 164 non-allowlisted gates green at iter-173 add — pure
# regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

# Bootstrap allowlist: gates from before the iter-1
# convention.
declare -A BOOTSTRAP_ALLOW=(
    [bin-scripts.sh]="pre-loop original gate, predates header convention"
)

checked=0
bad=0
allowlisted=0

for f in tests/*.sh; do
    [[ -f "$f" ]] || continue
    base=$(basename "$f")

    line2=$(sed -n '2p' "$f")

    if echo "$line2" | grep -qE '^#'; then
        : # silent pass
    elif [[ -n "${BOOTSTRAP_ALLOW[$base]:-}" ]]; then
        echo "WARN  $f: line 2 is \"$line2\" — ALLOWLISTED (${BOOTSTRAP_ALLOW[$base]})"
        allowlisted=$((allowlisted + 1))
    else
        echo "FAIL  $f: line 2 is \"$line2\" — expected header comment (#...)"
        bad=$((bad + 1))
        ok=0
    fi
    checked=$((checked + 1))
done

echo "---"
echo "Summary: $checked audit gates checked, $bad without line-2 header ($allowlisted bootstrap-allowlisted)"

[[ $ok -eq 1 ]] && exit 0 || exit 1
