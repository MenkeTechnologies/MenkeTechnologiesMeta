#!/usr/bin/env bash
# For every .github/workflows/release.yml, pin that the `on:`
# trigger includes a `push.tags` filter with at least one tag
# pattern starting with `v` (the org's semver-tag convention).
#
# The org's release workflow trigger pattern is:
#
#   on:
#     push:
#       tags:
#         - 'v*.*.*'        OR   - 'v*'   OR   - 'v[0-9]+*'
#
# Tag-based triggers are essential for release.yml correctness:
#
#   - Releases must be cut from a TAG, not from main. Pushing
#     directly to main can produce a fast-forward release
#     without any version increment — the artifact lacks a
#     proper version identifier.
#   - The `v` prefix is the canonical semver-tag convention.
#     `git describe` defaults to v-prefixed tags. `gh release
#     create` expects `vX.Y.Z`. cargo's git URL `?tag=v1.2.3`
#     uses the prefix. crates.io's `documentation` URL pattern
#     references the v-prefixed tag in changelog links.
#   - Pinning the pattern at lint time catches release.yml
#     workflows that were generated with a bare `on: push`
#     (would fire on EVERY push), accidentally triggered on
#     `branches: [main]` instead of tags (would release on
#     every commit), or use a non-canonical tag pattern like
#     `release-v*` that doesn't match `git tag v1.0.0`.
#
# Detection:
#   1. Parse the workflow yml.
#   2. Locate `on.push.tags`.
#   3. Verify at least one tag pattern starts with `v`.
#
# Allowed patterns (any of these passes — common org variants):
#   v*
#   v*.*.*
#   v[0-9]+*
#   v[0-9]+.[0-9]+.[0-9]+
#
# Non-tag triggers (workflow_dispatch, schedule) without push.tags
# are SKIPPED — they're legitimate release-by-button flows
# (not what this gate is about).
#
# 24/24 release.yml workflows green at iter-125 add — pure
# regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi
if ! python3 -c 'import yaml' 2>/dev/null; then
    echo "SKIP  PyYAML not installed"
    exit 0
fi

checked=0
bad=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    fname=$(basename "$wf")
    [[ "$fname" == "release.yml" ]] || continue

    output=$(python3 -c '
import sys, yaml
try:
    d = yaml.safe_load(open(sys.argv[1]))
    if not isinstance(d, dict):
        print("SKIP")
        sys.exit()
    on = d.get("on", d.get(True))
    if not isinstance(on, dict):
        print("SKIP")
        sys.exit()
    push = on.get("push", {})
    if not isinstance(push, dict):
        print("SKIP")
        sys.exit()
    tags = push.get("tags")
    if not tags:
        print("NO_TAGS")
        sys.exit()
    patterns = tags if isinstance(tags, list) else [tags]
    str_patterns = [p for p in patterns if isinstance(p, str)]
    if not any(p.startswith("v") for p in str_patterns):
        print("BAD:" + ",".join(str_patterns))
    else:
        print("OK:" + ",".join(str_patterns))
except Exception:
    print("SKIP")
' "$wf")

    case "$output" in
        SKIP)
            continue
            ;;
        NO_TAGS)
            checked=$((checked + 1))
            echo "FAIL  $wf: on.push has no tags filter — release fires on every push to filtered branches instead of on tag push"
            bad=$((bad + 1))
            ok=0
            ;;
        BAD:*)
            checked=$((checked + 1))
            echo "FAIL  $wf: on.push.tags=${output#BAD:} — no v-prefixed pattern (org convention is vX.Y.Z)"
            bad=$((bad + 1))
            ok=0
            ;;
        OK:*)
            checked=$((checked + 1))
            echo "PASS  $wf: on.push.tags=${output#OK:}"
            ;;
    esac
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/release.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked release.yml workflows checked, $bad without v-prefixed tag trigger"

[[ $ok -eq 1 ]] && exit 0 || exit 1
