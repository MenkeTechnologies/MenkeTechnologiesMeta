#!/usr/bin/env bash
# Meta self-audit extension: every tests/*.sh gate that invokes
# python3 (`python3 -c`, `python3 -`, or `python3 <<EOF`) must
# include a portable skip fallback near the top of the script:
#
#   if ! command -v python3 >/dev/null 2>&1; then
#       echo "SKIP  python3 not on PATH"
#       exit 0
#   fi
#
# Why this matters: most gates run on the ubuntu-latest runner
# which always bundles python3, but some org-internal CI flows
# use minimal containers (Docker BusyBox / Alpine + git-only
# images for fast pre-PR checks) that don't. A bare `python3`
# invocation in those contexts FAILS with `python3: command not
# found` — which the shell propagates as exit 127, marking the
# step as FAILED. False positive failures in CI then train
# everyone to ignore the audit output.
#
# Skip fallback turns "python3 unavailable" into a soft SKIP
# (exit 0 with informational message) rather than a hard fail.
# CI still passes; the gate's coverage that day is simply zero
# instead of being a noisy failure.
#
# Detection logic:
#   - Look for actual python3 invocations: the dash-c form, the
#     stdin form, the heredoc form. String mentions of python3
#     in comments or allowlists DON'T count (false-positives
#     those — e.g., a core_allowlist string referencing python3
#     as a brew formula name in the readme-brew-install gate).
#   - Verify presence of `command -v python3` or `which python3`
#     in the same file (the canonical skip-check forms).
#
# NB: this gate's detection regex is intentionally written below
# without the literal patterns in plain text — they appear only
# inside the grep call so this script doesn't self-match its
# own description.
#
# Same enforcement category as iter-65 (gate shape) and iter-99
# (gate wiring): catches gates that look right at static-eyeball
# review but fail in edge environments. The recursion ratchets
# tighter with each meta gate.
#
# Coverage at iter-100 add:
#   - 12 gates invoke python3
#   - 12 have command -v python3 skip fallback
#   - 0 missing
#
# Two gates lacked the fallback before iter-100: cargo-bin-name-
# field.sh (iter-79) and one other false-positive that wasn't
# actually invoking python3. Fixed cargo-bin-name-field.sh in
# the same commit that ships this gate.
#
# Total audit gates: 95
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
missing=0

for f in tests/*.sh; do
    [[ -f "$f" ]] || continue
    # Skip this gate itself — its comments and detection regex
    # reference the literal invocation patterns it audits for,
    # so it would self-match. The script is hand-verified to
    # follow the convention without needing the audit.
    [[ "$(basename "$f")" == "meta-python3-skip-fallback.sh" ]] && continue
    # Only check gates that actually invoke python3. Strip
    # comment lines first so docstring examples / regex
    # pattern strings (e.g., the catalog of expected
    # invocation forms in meta-python-heredoc-quoted.sh)
    # don't false-positive as real invocations.
    if ! grep -vE '^\s*#' "$f" | grep -qE 'python3 -c|python3 - "|python3 <<'; then
        continue
    fi
    checked=$((checked + 1))

    if grep -qE 'command -v python3|which python3' "$f"; then
        echo "PASS  $f: has python3 skip fallback"
    else
        echo "FAIL  $f: invokes python3 but has no \`command -v python3\` skip fallback"
        missing=$((missing + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked python3-invoking gates checked, $missing without skip fallback"

[[ $ok -eq 1 ]] && exit 0 || exit 1
