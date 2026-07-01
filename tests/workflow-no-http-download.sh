#!/usr/bin/env bash
# For every workflow yml step `run:` block, pin that no
# `curl` / `wget` invocation downloads from a non-localhost
# `http://` URL.
#
# Why https-only matters:
#
#   - MITM ATTACKS: a CI runner's outbound traffic passes
#     through whatever upstream network exists (the GitHub
#     runner's egress, the org's self-hosted runner's
#     ISP, any intermediate corporate proxies). An
#     http:// download lets any party on the path
#     substitute the content with their own. The
#     downloaded artifact then runs with whatever
#     privileges the workflow has — typically write
#     access to the repo, the cache, and any secrets
#     in scope.
#
#   - DOWNGRADE ATTACKS: many download URLs accept both
#     http and https. A workflow that hardcodes http
#     bypasses the https upgrade that a browser would
#     trigger, locking in the insecure protocol.
#
#   - REPRODUCIBILITY: https endpoints have stable
#     certificates that downstream tooling can verify
#     against pinned CAs. http downloads have no
#     equivalent integrity check; a server that
#     accidentally serves stale content silently breaks
#     reproducibility without any error.
#
# Exclusions:
#
#   - http://localhost:<port>      (loopback — no MITM
#                                   risk on the runner's
#                                   own interface)
#   - http://127.0.0.1:<port>      (same)
#   - http://0.0.0.0:<port>        (same)
#
# These are used by health-check probes for sidecar
# services (LocalStack, Postgres, MongoDB, Redis,
# Kafka) that run as Docker services in the workflow
# job. Loopback http is the standard pattern for these
# probes and is safe by topology.
#
# Detection: regex on `curl|wget` followed by `http://`
# (not `https://`). Exclude loopback addresses.
# Comments excluded.
#
# Pairs with iter-106 (no curl-pipe-shell). Both gates
# narrow the curl/wget attack surface: iter-106 catches
# the pipe-to-interpreter pattern; iter-184 catches the
# insecure-protocol pattern. THIRTEENTH security gate.
#
# 0/90 workflows use non-localhost http downloads at
# iter-184 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
risky=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))
    while IFS= read -r match; do
        ln_num="${match%%:*}"
        text="${match#*:}"
        stripped=$(echo "$text" | sed -E 's/^[[:space:]]*//')
        case "$stripped" in
            \#*|name:*|-\ name:*) continue ;;
        esac
        if echo "$stripped" | grep -qE '(curl|wget)[^|]*http://'; then
            if echo "$stripped" | grep -qE 'http://(localhost|127\.0\.0\.1|0\.0\.0\.0)'; then
                continue
            fi
            echo "FAIL  $wf:$ln_num: curl/wget over http:// (MITM risk; use https://). Line: $text"
            risky=$((risky + 1))
            ok=0
        fi
    done < <(grep -nE '(curl|wget)' "$wf" 2>/dev/null || true)
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
echo "Summary: $checked workflow files checked, $risky non-localhost http downloads"

[[ $ok -eq 1 ]] && exit 0 || exit 1
