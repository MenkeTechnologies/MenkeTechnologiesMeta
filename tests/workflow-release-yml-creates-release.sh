#!/usr/bin/env bash
# For every workflow yml whose filename is `release.yml`
# (or `Release.yml` / `RELEASE.yml`), pin that the file
# invokes a release-creating action:
#
#   gh release create               (GitHub CLI)
#   softprops/action-gh-release@<v> (action)
#   actions/create-release@<v>      (deprecated but still
#                                    counts as release-
#                                    creating intent)
#   ncipollo/release-action@<v>     (community action)
#
# Why this semantic gate matters:
#
# A workflow named `release.yml` signals INTENT to the
# repo's readers and to GitHub Actions:
#
#   - Contributors see `release.yml` and assume it's
#     the release pipeline. They may add steps to it
#     thinking those steps will run when releases are
#     created.
#   - GitHub renders the file under "Release" semantics
#     in the Actions tab if the trigger is
#     `on: { release: ... }` (some UI flows infer
#     filename intent for grouping).
#   - The repo's README badges often link
#     `release.yml`'s status as "release pipeline
#     health" — a non-release workflow under that name
#     misrepresents the badge.
#
# A `release.yml` that DOESN'T actually call a release-
# creating action is one of:
#
#   1. Wrong filename: the workflow is a CI/build job
#      that was mistakenly named `release.yml`. Should
#      be renamed `ci.yml` or `build.yml`.
#
#   2. Half-finished workflow: an in-progress release
#      pipeline that hasn't gotten to the release-
#      create step yet. Should be marked draft or
#      moved to a feature branch until ready.
#
#   3. Broken release pipeline: the release-create step
#      was deleted during a refactor without renaming
#      the file. Now `release.yml` runs but doesn't
#      release. Catches the case where the file's
#      purpose was abandoned but the name survived.
#
# All three are signals worth catching at PR time.
#
# Detection:
#   - filter workflow files to basenames matching
#     case-insensitive `release.yml`
#   - require one of the canonical release-creating
#     patterns somewhere in the file
#
# Pairs with workflow-release-on-tag-trigger (iter-207
# — release-creators trigger on tags) and workflow-
# cargo-release-locked (release builds use --locked).
# This gate completes the release-pipeline integrity
# triangle: filename ↔ trigger ↔ release-action.
#
# 24/24 release.yml files call a release-creator at
# iter-212 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
missing=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    bn=$(basename "$wf" .yml)
    # Case-insensitive match for "release"
    bn_lower=$(echo "$bn" | tr '[:upper:]' '[:lower:]')
    [[ "$bn_lower" == "release" ]] || continue
    checked=$((checked + 1))

    # Look for any release-creating pattern
    if ! grep -qE 'gh release create|softprops/action-gh-release@|actions/create-release@|ncipollo/release-action@' "$wf"; then
        echo "FAIL  $wf: named release.yml but doesn't call gh release create / softprops/action-gh-release / actions/create-release / ncipollo/release-action — wrong filename, half-finished, or broken pipeline"
        missing=$((missing + 1))
        ok=0
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked release.yml files checked, $missing without release-creating action"

[[ $ok -eq 1 ]] && exit 0 || exit 1
