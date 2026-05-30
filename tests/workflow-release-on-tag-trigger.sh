#!/usr/bin/env bash
# For every workflow yml that creates a GitHub release
# (calls `gh release create` or uses
# `softprops/action-gh-release`), pin that the workflow
# is triggered by one of:
#
#   push.tags        (e.g., push: { tags: ['v*'] })
#   push.tags-ignore (negative filter, still tag-based)
#   workflow_dispatch (manual)
#   release          (GitHub release event)
#
# A release-creating workflow that triggers on
# `push: { branches: [main] }` produces a NEW GitHub
# release on EVERY commit to main. Failure modes:
#
#   1. Release pollution: the Releases tab fills with
#      one entry per merge, not one per intentional
#      release. Users see hundreds of auto-generated
#      "Release v0.0.1-abc1234" entries and can't
#      find the actual milestone releases.
#
#   2. Version conflict: `gh release create v1.2.3`
#      fails on the second push because the tag
#      already exists. Subsequent runs either hang on
#      the conflict or produce error releases that
#      need manual cleanup.
#
#   3. Notification noise: Watchers and subscribers
#      get release-published notifications on every
#      merge. They unsubscribe.
#
#   4. CI cost: release-build workflows are typically
#      expensive (multi-arch matrix, full optimization,
#      sometimes cross-compilation). Running on every
#      push wastes minutes; running only on tags
#      bounds the cost.
#
#   5. Tag-version desync: tag v1.2.3 might be pushed
#      from a DIFFERENT commit than the release
#      workflow's pushed-to-main commit. The release
#      assets then reflect main's HEAD, not the
#      tagged version — silent version-asset mismatch.
#
# Correct pattern:
#
#   on:
#     push:
#       tags:
#         - 'v*'
#     workflow_dispatch:        # manual fallback
#       inputs:
#         tag: { ... }
#
# This restricts the workflow to fire on intentional
# tag pushes (`git tag v1.2.3 && git push --tags`),
# with an explicit manual escape hatch for
# rebuild-from-tag scenarios.
#
# Detection:
#   - find workflows that call gh release create or
#     use softprops/action-gh-release
#   - require their `on:` block to include push.tags,
#     workflow_dispatch, OR release event
#
# Pairs with workflow security defense + release
# correctness:
#   workflow-no-write-all          — least privilege
#   workflow-uses-pinned           — action ref pin
#   workflow-cargo-release-locked  — release build flag
#   workflow-release-on-tag-trigger (this) — correct trigger
#
# 24/24 release-creating workflows have tag/dispatch
# trigger at iter-207 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi

checked=0
bad_trigger=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    # Quick filter: does the workflow create a release?
    if ! grep -qE 'gh release|softprops/action-gh-release' "$wf"; then
        continue
    fi
    checked=$((checked + 1))
    result=$(python3 - "$wf" <<'PY'
import sys, yaml
try:
    d = yaml.safe_load(open(sys.argv[1]))
except Exception:
    print('BAD'); sys.exit()
if not isinstance(d, dict):
    print('BAD'); sys.exit()
on = d.get('on', d.get(True))
if isinstance(on, dict):
    keys = list(on.keys())
    if 'workflow_dispatch' in keys or 'release' in keys:
        print('OK'); sys.exit()
    push = on.get('push')
    if isinstance(push, dict) and ('tags' in push or 'tags-ignore' in push):
        print('OK'); sys.exit()
elif isinstance(on, list):
    if 'workflow_dispatch' in on or 'release' in on:
        print('OK'); sys.exit()
elif isinstance(on, str):
    if on in ('workflow_dispatch', 'release'):
        print('OK'); sys.exit()
print('BAD')
PY
)
    if [[ "$result" == "BAD" ]]; then
        echo "FAIL  $wf: creates release but not triggered by push.tags / workflow_dispatch / release event — pollutes Releases tab on every push"
        bad_trigger=$((bad_trigger + 1))
        ok=0
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked release-creating workflows checked, $bad_trigger with non-tag/dispatch trigger"

[[ $ok -eq 1 ]] && exit 0 || exit 1
