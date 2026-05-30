#!/usr/bin/env bash
# For every submodule with a README.md, pin that every Markdown ToC
# anchor link `[label](#anchor)` points at a header that GitHub's
# anchor-slug algorithm would produce. Catches the failure mode where
# a section gets renamed (e.g. `## [0x02] INSTALL` → `## [0x02] BUILD
# FROM SOURCE`) but the ToC link `(#0x02-install)` is left pointing at
# the old slug. The link still LOOKS valid; GitHub silently renders it
# as a broken jump that lands at the top of the page.
#
# GitHub's slug algorithm (simplified, matches gfm-spec):
#   1. Lowercase entire header text.
#   2. Drop everything except alphanumerics, hyphens, and the literal
#      backtick-delimited code-span chars (which stay as-is).
#   3. Replace spaces with hyphens.
#   4. Collapse multiple hyphens.
#   5. Trim leading/trailing hyphens.
#
# Markdown's `[\[0x02\] Installation](#0x02-installation)` style (the
# brackets are escaped) is the canonical pattern in the Tier 1 READMEs.
# We slugify the actual `## [0x02] INSTALLATION` header and compare.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
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

# Slugify a header per GitHub's gfm anchor convention.
# Critical: GitHub does NOT collapse consecutive hyphens — a header
# `Foo -- Bar` becomes `foo---bar` (3 hyphens, preserving the original
# `--` between hyphens-from-spaces). The trailing newline is required
# so callers building a newline-delimited slug blob get distinct lines.
slugify() {
    # GitHub gfm anchor convention (gemoji-slugger):
    # 1. Lowercase
    # 2. Drop backslashes (markdown escape character in source headers)
    # 3. Drop anything that's not alphanumeric, underscore, space, or hyphen
    # 4. Spaces -> hyphens (one at a time; no collapse)
    # NO leading/trailing hyphen trim — GitHub preserves them. A header
    # `## > STATUS` legitimately slugs to `-status` (with leading hyphen
    # from the `>` getting space-converted).
    printf '%s\n' "$1" \
        | tr '[:upper:]' '[:lower:]' \
        | tr -d '\\' \
        | sed 's/[^a-z0-9_ -]//g' \
        | tr ' ' '-'
}

checked=0
broken=0

# Restrict to Tier 1 + meta-style submodules that use the [0xNN] header
# convention with a ToC. The zsh-* plugins use different README shapes.
candidates=(
    strykelang zshrs fusevm lsofrs temprs awkrs iftoprs nmaprs
    Audio-Haxor traderview powerliners zpwr storageshower
)

for p in "${candidates[@]}"; do
    [[ -d "$p" && -f "$p/README.md" ]] || continue

    # Collect all # / ## / ### header slugs into a newline-delimited blob.
    # macOS ships bash 3.x without robust associative arrays — fall back
    # to grep -Fx for membership tests.
    header_slugs=$(
        grep -E '^#{1,6} ' "$p/README.md" | while IFS= read -r line; do
            text="${line#*' '}"
            slugify "$text"
        done
    )

    # Collect all `(#anchor)` references and verify each is in header_slugs.
    while IFS= read -r anchor; do
        [[ -z "$anchor" ]] && continue
        case "$anchor" in
            ''|'#') continue ;;
        esac
        anchor="${anchor#'#'}"
        checked=$((checked + 1))
        if ! grep -Fxq -- "$anchor" <<< "$header_slugs"; then
            echo "FAIL  $p/README.md: anchor '#$anchor' has no matching header (slug computed via GitHub gfm rules)"
            broken=$((broken + 1))
            ok=0
        fi
    done < <(grep -oE '\]\(#[^)]+\)' "$p/README.md" | sed 's/^](//; s/)$//')
done

echo "---"
echo "Summary: $checked ToC anchors checked, $broken broken (no matching header)"

[[ $ok -eq 1 ]] && exit 0 || exit 1
