#!/usr/bin/env bash
# For every Rust submodule's release.yml, pin that the workflow is
# triggered by `push: tags: ['v*']` (or variants thereof — the
# canonical semver-tag pattern across the org).
#
# Catches the failure mode where someone bumps + tags a release but
# the workflow doesn't fire because the trigger expects a different
# tag shape (e.g. `tags: ['release-*']` for a renamed pattern, or
# missing `tags:` block entirely with only workflow_dispatch).
# Silent failure: the user thinks the release is shipping but no
# job ever runs, no GitHub Release is created, no formula bumps.
#
# Accepts any of:
#   on: push: tags: ['v*']
#   on: push: tags: [v*]
#   on: push: tags: ["v*"]
#   on: push: tags: - 'v*'
#   on: push: { tags: ['v*'] }
#   on: { push: { tags: ['v*'] } }
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

paths=()
while IFS= read -r line; do
    paths+=("${line#$'\tpath = '}")
done < <(grep $'^\tpath = ' .gitmodules)

init_count=0
for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] && init_count=$((init_count + 1))
done
if [[ $init_count -eq 0 ]]; then
    echo "SKIP  no submodules initialized"
    exit 0
fi

checked=0
missing=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    rel="$p/.github/workflows/release.yml"
    [[ -f "$rel" ]] || continue
    checked=$((checked + 1))

    # Look for tags: with a value matching ['v*'] / [v*] / "v*" / - 'v*' patterns.
    # Need to handle yaml's many equivalent forms; grep for the substring
    # `v*` adjacent to `tags:` (within ~5 lines).
    has_tag_trigger=0
    if awk '
        /tags:/ { in_tags = 1; lines = 0 }
        in_tags {
            lines++
            if (lines > 5) in_tags = 0
            # Inline form: tags: ["v*"] / tags: [ "v*" ] / tags: ["v*", ...]
            if ($0 ~ /tags:[^#]*[\047"]?v\*/) { print "match"; exit }
            # List form: tags:\n  - "v*"
            if ($0 ~ /^[[:space:]]*-[[:space:]]+[\047"]?v\*[\047"]?/) { print "match"; exit }
        }
    ' "$rel" | grep -q match; then
        has_tag_trigger=1
    fi

    if [[ $has_tag_trigger -eq 1 ]]; then
        echo "PASS  $rel: triggers on push tags v*"
    else
        echo "FAIL  $rel: no \`tags: ['v*']\` trigger found — release workflow won't fire on \`git push --tags\`"
        missing=$((missing + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked release.yml files checked, $missing missing v* tag trigger"

[[ $ok -eq 1 ]] && exit 0 || exit 1
