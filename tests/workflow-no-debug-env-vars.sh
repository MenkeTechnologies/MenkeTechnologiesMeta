#!/usr/bin/env bash
# For every workflow yml, pin that no `env:` block (at
# workflow, job, or step level) sets the secret-leaking
# debug environment variables:
#
#   ACTIONS_STEP_DEBUG=true
#   ACTIONS_RUNNER_DEBUG=true
#   GIT_TRACE=1 (any non-empty value)
#   GIT_CURL_VERBOSE=1 (any non-empty value)
#   GIT_TRACE_PACKET=1
#   GIT_TRACE_PERFORMANCE=1
#
# These are GitHub Actions / git's debug-mode flags.
# Each one exposes content that the runner's masking
# layer doesn't fully protect:
#
#   ACTIONS_STEP_DEBUG=true:
#     GitHub's official "enable debug logging" flag.
#     Includes:
#       - Pre-masking content (secrets masked AFTER
#         the debug write, so partial pre-mask content
#         can leak)
#       - Full environment variable dumps at step
#         boundaries (every env: value, including
#         resolved ${{ secrets.* }} values)
#       - Conditional expression evaluation traces
#         (the ${{ }} resolutions before masking)
#       - Input/output artifact paths and contents
#         (uploaded files visible in log)
#
#   ACTIONS_RUNNER_DEBUG=true:
#     Lower-level runner debugging. Adds:
#       - Process environment at runner boot
#         (GITHUB_TOKEN value pre-masking)
#       - Network request/response details for the
#         runner-API protocol
#       - File-system operations log
#
#   GIT_TRACE=1:
#     Git's protocol-level trace. Includes:
#       - All HTTP request URLs (which contain auth
#         tokens in some auth schemes)
#       - All ref-spec content
#       - Authentication header values for HTTP and
#         HTTPS Basic auth
#
#   GIT_CURL_VERBOSE=1:
#     Worse than GIT_TRACE. Adds:
#       - Full curl `-v` output for every HTTPS
#         request: connection info, certificate
#         details, request headers (Authorization!),
#         response headers, partial body content.
#       - GH_TOKEN values are visible in plaintext
#         Authorization: Bearer <token> lines.
#
#   GIT_TRACE_PACKET=1 / GIT_TRACE_PERFORMANCE=1:
#     Lower-level packet-protocol trace. Same
#     auth-leak risk as GIT_TRACE.
#
# Correct pattern: enable debug mode PER-RUN via the
# GitHub UI's "Re-run all jobs with debug logging"
# button. That flag is scoped to a single run and the
# org's audit log records who enabled it. Hardcoding
# debug in the workflow file:
#
#   - Leaks secrets on EVERY run (including releases,
#     deploys, scheduled jobs, dependabot updates).
#   - Survives PR merges silently.
#   - Doesn't show in audit log who enabled it.
#   - Persists across runner image rotations.
#
# Detection: regex for `ACTIONS_STEP_DEBUG`,
# `ACTIONS_RUNNER_DEBUG`, `GIT_TRACE` (any variant),
# `GIT_CURL_VERBOSE` in YAML key context (env: block
# keys). Catches both literal-true and expression
# forms (the leak risk is identical regardless of
# value form).
#
# Pairs with workflow security defense family
# (no-env-dump, no-secret-echo, no-id-token-write).
# Adds the per-flag-name family for known
# secret-leaking debug vars.
#
# 0/90 workflows set debug env vars at iter-197 add —
# pure regression floor.
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
            \#*) continue ;;
        esac
        # Must be a key (followed by colon or =, on a YAML key line)
        if echo "$stripped" | grep -qE '^(ACTIONS_STEP_DEBUG|ACTIONS_RUNNER_DEBUG|GIT_TRACE(_PACKET|_PERFORMANCE)?|GIT_CURL_VERBOSE)\s*:'; then
            echo "FAIL  $wf:$ln_num: debug env var leaks secrets in CI logs — enable per-run via GitHub UI instead. Line: $text"
            risky=$((risky + 1))
            ok=0
        fi
    done < <(grep -nE '^(\s*)(ACTIONS_STEP_DEBUG|ACTIONS_RUNNER_DEBUG|GIT_TRACE(_PACKET|_PERFORMANCE)?|GIT_CURL_VERBOSE)\s*:' "$wf" 2>/dev/null || true)
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflow files checked, $risky debug-env-var uses"

[[ $ok -eq 1 ]] && exit 0 || exit 1
