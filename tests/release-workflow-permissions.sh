#!/usr/bin/env bash
# For every `.github/workflows/release.yml` across the umbrella,
# pin that the file declares either a top-level `permissions:`
# block OR an inline `contents: write` reference.
#
# GitHub Actions tightened the default token permissions in
# late 2023: new repos default to `contents: read` instead of
# the legacy `write-all`. release.yml workflows need
# `contents: write` to:
#
#   - Create GitHub Releases (gh release create)
#   - Upload release artifacts (tarballs, binaries, sha256
#     manifests)
#   - Tag the release commit
#   - Push the homebrew tap bump (cross-repo write via the
#     HOMEBREW_TAP_TOKEN PAT — also documented in iter-21's
#     workflow-tap-secret gate)
#
# Without explicit permissions, the workflow fails at the
# release-creation step with:
#
#   GraphQL: Resource not accessible by integration
#
# This is silently wrong — the workflow shows green on the
# build steps, fails on the release step. The error message
# doesn't mention permissions explicitly, sending the
# investigator down rabbit holes (wrong token, GitHub outage,
# rate limiting) before they discover the default-permissions
# tightening.
#
# Detection: presence of `permissions:` keyword or
# `contents: write` substring anywhere in the file. Both forms
# satisfy the gate; the canonical org pattern is:
#
#   permissions:
#     contents: write
#
# at workflow-top scope (job-scope is also acceptable for
# tighter scoping).
#
# 24/24 release.yml files green at iter-104 add — pure
# regression floor against accidental permissions omission
# in a new release workflow.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
missing=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))
    if grep -qE 'permissions:|contents: *write' "$wf"; then
        echo "PASS  $wf: permissions/contents:write declared"
    else
        echo "FAIL  $wf: no permissions: block or contents: write — release creation will fail with 'Resource not accessible by integration'"
        missing=$((missing + 1))
        ok=0
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
    -o -type f -path '*/.github/workflows/release.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked release.yml files checked, $missing without permissions or contents:write"

[[ $ok -eq 1 ]] && exit 0 || exit 1
