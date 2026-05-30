#!/usr/bin/env bash
# For every Homebrew formula file in homebrew-menketech/
# Formula/*.rb, pin that the file is at most 200 lines.
#
# Why 200 lines:
#
#   - A canonical brew formula is 30-80 lines: class header,
#     desc/homepage/url/sha256, depends_on (if any),
#     def install (typically 3-10 lines for Rust bin
#     installs), test do (3-10 lines). 200 lines is more
#     than 2x the canonical upper.
#   - 200+ line formulas typically signal:
#     1. Excessive options (deprecated post-2020;
#        Homebrew moved options into separate formulas)
#     2. Long install method doing too much (should be
#        delegated to the source's own build/install
#        targets via system call)
#     3. Bottle blocks for many OS/arch variants stored
#        in the same file (modern Homebrew stores these
#        out-of-band)
#     4. Inline patches stored as DATA strings (should be
#        external `patch :p1, ...` references with the
#        diff as a separate file)
#     5. Dead code from old formula versions
#
#   - PR REVIEW: tap maintainers review formula updates
#     per release. A 200-line formula change diff is
#     review-fatigue inducing; subtle changes get missed.
#   - brew audit: longer formulas take longer to audit
#     and produce noisier output; multiplied across CI
#     runs.
#
# Detection: wc -l on each *.rb file, compare against 200.
#
# Pairs with iter-169 (workflow yml 1000 lines) and
# iter-170 (Cargo.toml 500 lines). Three file-size sanity
# gates encoding "config files past a threshold need a
# split" for the three main config-file types in the
# umbrella.
#
# 10/10 formulas green at iter-171 add — pure regression
# floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

MAX_LINES=200

formulas_dir="homebrew-menketech/Formula"
if [[ ! -d "$formulas_dir" ]]; then
    echo "SKIP  $formulas_dir not initialized"
    exit 0
fi

checked=0
oversize=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))

    lines=$(wc -l < "$f" | tr -d ' ')
    if [[ "$lines" -gt "$MAX_LINES" ]]; then
        echo "FAIL  $f: $lines lines (max $MAX_LINES) — consider extracting patches, bottles, or install delegation"
        oversize=$((oversize + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked formulas checked, $oversize over $MAX_LINES lines"

[[ $ok -eq 1 ]] && exit 0 || exit 1
