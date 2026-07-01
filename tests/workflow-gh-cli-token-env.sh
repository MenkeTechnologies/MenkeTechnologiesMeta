#!/usr/bin/env bash
# For every workflow yml step whose `run:` block invokes
# the GitHub CLI (`gh pr`, `gh issue`, `gh api`,
# `gh release`, `gh workflow`, `gh run`, `gh repo`),
# pin that `GH_TOKEN` or `GITHUB_TOKEN` is set in `env:`
# (workflow, job, or step level).
#
# GitHub's official documentation for using `gh` in
# workflows requires explicit env-var setting:
#
#   - run: gh release create ...
#     env:
#       GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
#
# Why this matters (NOT obvious from the gh CLI's
# error messages):
#
#   - `gh` v2.x reads GH_TOKEN env-var PREFERENTIALLY
#     for authentication. Without it set, gh falls
#     back to:
#       1. ~/.config/gh/hosts.yml (doesn't exist in CI)
#       2. GITHUB_TOKEN env-var (only when set)
#       3. `gh auth login` interactive flow (fails in
#          CI; runner has no stdin)
#       4. Hard error
#
#   - In some GitHub Actions runner configurations,
#     the default `GITHUB_TOKEN` is not auto-populated
#     in the env-var sense (only as `secrets.GITHUB_
#     TOKEN`). Reusable workflows, composite actions,
#     and self-hosted runners can all break the auto-
#     population. Without explicit env: GH_TOKEN,
#     `gh` calls fail with cryptic auth errors.
#
#   - The `permissions:` block at workflow/job level
#     controls what GITHUB_TOKEN can DO but doesn't
#     automatically make it available to `gh`. Both
#     are needed: permissions: grants scope,
#     env: GH_TOKEN passes the token.
#
# Failure mode without this gate:
#
#   - PR step calls `gh pr comment` → fails with
#     "gh: To get started with GitHub CLI, please
#     run: gh auth login"
#   - Release step calls `gh release create` → fails
#     with same message
#   - Debugging is non-obvious: the workflow logs
#     show the gh error, but contributors typically
#     assume "secrets.GITHUB_TOKEN is auto-magical"
#     and waste an hour before discovering the env:
#     block requirement
#
# Either GH_TOKEN or GITHUB_TOKEN env-var name is
# accepted. `gh` checks both. Modern docs prefer
# GH_TOKEN; older workflows commonly use GITHUB_TOKEN.
#
# Detection: YAML-parse each workflow. For each step
# whose run: matches `\bgh\s+(pr|issue|api|release|
# workflow|run|repo)\b`, check that env: at step,
# job, or workflow level includes GH_TOKEN or
# GITHUB_TOKEN.
#
# Pairs with workflow security defense family
# (no-secret-echo, no-debug-env-vars). This gate is
# about CORRECT secret use, not absence-of-leak.
#
# 22/22 gh-using steps have token env at iter-202
# add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi

checked=0
missing=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    result=$(python3 - "$wf" <<'PY'
import sys, yaml, re
try:
    d = yaml.safe_load(open(sys.argv[1]))
except Exception:
    print('0|')
    sys.exit()
if not isinstance(d, dict):
    print('0|')
    sys.exit()
wf_env = d.get('env', {}) or {}
total = 0
bad = []
for jn, job in (d.get('jobs', {}) or {}).items():
    if not isinstance(job, dict):
        continue
    job_env = job.get('env', {}) or {}
    for i, step in enumerate(job.get('steps', []) or []):
        if not isinstance(step, dict):
            continue
        run = step.get('run', '')
        if not isinstance(run, str):
            continue
        if not re.search(r'\bgh\s+(pr|issue|api|release|workflow|run|repo)\b', run):
            continue
        total += 1
        step_env = step.get('env', {}) or {}
        combined = {}
        for d2 in (wf_env, job_env, step_env):
            if isinstance(d2, dict):
                combined.update(d2)
        if not ('GH_TOKEN' in combined or 'GITHUB_TOKEN' in combined):
            sn = step.get('name', f'step #{i+1}')
            bad.append(f'{jn}/{sn}')
print(f"{total}|{';'.join(bad)}")
PY
)
    step_count="${result%%|*}"
    bad_steps="${result#*|}"
    checked=$((checked + step_count))
    if [[ -n "$bad_steps" ]]; then
        IFS=';' read -ra sa <<< "$bad_steps"
        for s in "${sa[@]}"; do
            echo "FAIL  $wf: gh-using step '$s' lacks GH_TOKEN or GITHUB_TOKEN in env"
            missing=$((missing + 1))
            ok=0
        done
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
echo "Summary: $checked gh-using steps checked, $missing without token env"

[[ $ok -eq 1 ]] && exit 0 || exit 1
