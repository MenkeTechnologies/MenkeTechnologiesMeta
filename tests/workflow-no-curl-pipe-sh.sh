#!/usr/bin/env bash
# For every workflow yml across the umbrella, pin that no step
# uses the pattern `curl ... | sh` or `wget ... | bash` (a.k.a.
# curl-pipe-to-shell).
#
# Why this matters as a security regression-floor:
#
#   1. SUPPLY-CHAIN ATTACK SURFACE: curl-pipe-sh trusts the
#      remote endpoint to deliver code that's safe to execute
#      AT THIS EXACT MOMENT under the workflow's privileges. Any
#      DNS hijack, TLS downgrade, or upstream-host compromise
#      becomes an instant remote code execution with full
#      access to:
#        - Repo secrets (PAT, CRATES_IO_TOKEN, NPM_TOKEN, etc.)
#        - The cloned source tree (can write malicious commits
#          into next push)
#        - Other GitHub-org repositories (depending on token
#          scope)
#   2. NO AUDIT TRAIL: the executed script's source disappears
#      after the run; nothing in the workflow's logs preserves
#      what was actually run. Forensics post-incident has
#      nothing to compare against the expected behavior.
#   3. NO VERSION PIN: the remote install script can change
#      under you without changing your workflow's git history.
#      A workflow that worked yesterday silently runs different
#      code today.
#
# Org policy enforced by this gate: ALL external install tools
# must be pinned to a specific GitHub Actions reference
# (`uses: actions/setup-rust@v1`), a specific sha256-verified
# release artifact, or a Cargo/npm/etc. install with a pinned
# version. No curl/wget piped to interpreter.
#
# Detection: lines containing `curl ... | sh` or
# `curl ... | bash` or same with `wget`. The pattern is the
# shell substring `| sh` / `| bash` immediately after a
# `curl`/`wget` command. Comments inside step `run:` blocks
# that DESCRIBE the antipattern (e.g., "don't curl|sh this")
# would false-trigger; this gate accepts that low false-positive
# rate as the cost of catching the actual antipattern.
#
# 90/90 workflow files green at iter-106 add — pure regression
# floor against accidental supply-chain footgun introduction.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
risky=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))
    if grep -qE 'curl[^|]+\|[[:space:]]*(sh|bash)\b|wget[^|]+\|[[:space:]]*(sh|bash)\b' "$wf"; then
        while IFS= read -r match; do
            echo "FAIL  $wf: curl-pipe-shell pattern — $match"
            risky=$((risky + 1))
            ok=0
        done < <(grep -nE 'curl[^|]+\|[[:space:]]*(sh|bash)|wget[^|]+\|[[:space:]]*(sh|bash)' "$wf")
    fi
done < <(find . -path './.git' -prune \
    -o -path '*/grammars/sources/*' -prune \
    -o -path '*/build/_deps/*' -prune \
    -o -path '*/clap-libs/*' -prune \
    -o -path '*/clap-juce-extensions/*' -prune \
    -o -path '*/node_modules/*' -prune \
    -o -path '*/vendor/*' -prune \
    -o -path '*/target/*' -prune \
    -o -path '*/third_party/*' -prune \
    -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflow files checked, $risky lines with curl-pipe-shell pattern"

[[ $ok -eq 1 ]] && exit 0 || exit 1
