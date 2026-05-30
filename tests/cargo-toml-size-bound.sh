#!/usr/bin/env bash
# For every Cargo.toml file across the umbrella, pin that the
# file is at most 500 lines (sanity bound for manifest bloat).
#
# Why 500 lines:
#
#   - Cargo's TOML manifest is a CONFIGURATION file, not a
#     program. Most published crates land at 50-150 lines
#     including comments. The 90th percentile of crates.io
#     manifests is well under 300 lines.
#   - A 500+ line Cargo.toml almost always means:
#     1. Too many [[bin]] entries that should be split into
#        a sub-crate (workspace member) per binary
#     2. Excessive [features] permutations (the cargo-hf
#        author guideline is "if you have more than ~10
#        features you probably want a sub-crate")
#     3. Inline dependency tables (`foo = { version = "1.0",
#        features = ["a", "b", ...], optional = true,
#        package = "foo-impl", ... }`) that should be
#        moved to workspace-level dependency declarations
#     4. Verbose [profile.*] sections that should be
#        extracted to a workspace root for inheritance
#     5. Dead code (commented-out alternative configs,
#        history of refactor attempts)
#
#   - PR review burden: every line of Cargo.toml is
#     semantically dense. A 500-line manifest takes more
#     than 10 minutes of careful read; reviewers shortcut
#     past the middle, missing typos and version
#     inconsistencies.
#
#   - rust-analyzer / cargo metadata indexing: Cargo
#     re-parses the manifest on every command and on every
#     file save in IDE workflows. Larger manifests slow
#     down the inner loop more than developers notice.
#
# Detection: wc -l on each Cargo.toml under submodule paths,
# compare against 500. Excludes target/ and vendor/ (Cargo
# generates Cargo.toml files inside these for build state;
# not ours to enforce).
#
# 38/38 Cargo.toml files green at iter-170 add — pure
# regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

MAX_LINES=500

checked=0
oversize=0

while IFS= read -r f; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))

    lines=$(wc -l < "$f" | tr -d ' ')
    if [[ "$lines" -gt "$MAX_LINES" ]]; then
        echo "FAIL  $f: $lines lines (max $MAX_LINES) — consider workspace split, feature consolidation, or dead-code prune"
        oversize=$((oversize + 1))
        ok=0
    fi
done < <(find . -name 'Cargo.toml' -not -path '*/target/*' -not -path '*/vendor/*' -not -path './.git/*' 2>/dev/null)

echo "---"
echo "Summary: $checked Cargo.toml files checked, $oversize over $MAX_LINES lines"

[[ $ok -eq 1 ]] && exit 0 || exit 1
