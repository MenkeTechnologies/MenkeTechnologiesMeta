#!/usr/bin/env bash
# For every `docs/` directory across the umbrella, pin that
# `docs/index.html` exists.
#
# GitHub Pages serves docs/ as a site root and routes `/` →
# `index.html`. Without an index.html, visitors hitting the bare
# URL get either:
#   - A 404 page (GitHub Pages default)
#   - A directory listing (if enabled) — leaks internal structure
#     and gives no entry point
#
# Every iter-26 GH Pages homepage URL (https://menketechnologies.
# github.io/<repo>/) depends on this file existing. If a submodule
# accidentally deletes docs/index.html (rename to something else,
# or it gets cleared by a regeneration script), the iter-26
# homepage link silently 404s on crates.io and in the README
# badge — but the package still appears to build and publish
# cleanly. Slow-burn drift.
#
# Excludes vendored docs/ paths (powerliners/vendor/powerline/docs)
# — those ship third-party docs that we don't own and don't
# expose via GH Pages.
#
# Coverage at iter-61 add: 44/44 first-party docs/ directories
# have index.html. Pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
missing=0

while IFS= read -r d; do
    case "$d" in
        *vendor*|*node_modules*|*target*) continue ;;
    esac
    checked=$((checked + 1))
    if [[ ! -f "$d/index.html" ]]; then
        echo "FAIL  $d: missing index.html (GH Pages homepage will 404)"
        missing=$((missing + 1))
        ok=0
    else
        echo "PASS  $d/index.html"
    fi
done < <(find . -path './.git' -prune -o -path './MenkeTechnologiesPublications' -prune -o -type d -name docs -print 2>/dev/null)

echo "---"
echo "Summary: $checked first-party docs/ directories checked, $missing without index.html"

[[ $ok -eq 1 ]] && exit 0 || exit 1
