#!/usr/bin/env bash
# Meta self-audit extension: every audit gate must use ONLY
# the canonical exit codes 0 (PASS) and 1 (FAIL).
#
# Why this matters for CI integration:
#
#   - GitHub Actions interprets exit code 0 as step-success
#     and any non-zero as step-failure. Distinguishing
#     between exit 1 / exit 2 / exit 127 / etc. is the
#     caller's responsibility.
#   - Aggregator scripts (org-wide audit dashboard, nightly
#     digests, etc.) typically rely on the binary
#     pass-or-fail signal. Mixing in exit 2 ("usage error"),
#     exit 77 ("skip" per autotools convention), exit 130
#     ("SIGINT") etc. produces dashboard categories that
#     nobody actually tracks.
#   - shellcheck warns on hardcoded exit codes outside the
#     range typically used by shell scripts; the warning
#     surfaces as a noisy lint annotation.
#   - Bash's automatic exit on errored commands (set -e
#     equivalent for some sections) interacts with exit codes
#     in ways that change between bash versions. Sticking to
#     0/1 minimizes the surface for version-dependent
#     behavior.
#
# Allowed exit-code expressions:
#   exit 0       — success path
#   exit 1       — failure path
#   exit $VAR    — derived from a computed variable
#                  (used by gates where the failure cause maps
#                   to a count rather than a binary flag)
#
# Forbidden:
#   exit 2 / 3 / 77 / etc. — non-canonical numeric codes
#
# Self-exempt because the gate's own description references
# exit codes verbatim.
#
# 127/127 audit gates use canonical exit codes at iter-133 add
# — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
non_canonical=0

for f in tests/*.sh; do
    [[ -f "$f" ]] || continue
    [[ "$(basename "$f")" == "meta-canonical-exit-codes.sh" ]] && continue
    checked=$((checked + 1))
    local_bad=0

    while IFS= read -r match; do
        ln_num="${match%%:*}"
        text="${match#*:}"
        stripped=$(echo "$text" | sed -E 's/^[[:space:]]*//')
        case "$stripped" in
            \#*) continue ;;
        esac
        code=$(echo "$stripped" | grep -oE '\bexit ([0-9]+|\$[a-zA-Z_]+)' | head -1 | awk '{print $2}')
        [[ -z "$code" ]] && continue
        case "$code" in
            0|1|\$*) continue ;;
            *)
                echo "FAIL  $f:$ln_num: non-canonical exit $code — use 0 (PASS) or 1 (FAIL). Line: $text"
                non_canonical=$((non_canonical + 1))
                local_bad=1
                ok=0
                ;;
        esac
    done < <(grep -nE '\bexit [0-9]+' "$f" 2>/dev/null || true)
done

echo "---"
echo "Summary: $checked audit gates checked, $non_canonical non-canonical exit-code uses"

[[ $ok -eq 1 ]] && exit 0 || exit 1
