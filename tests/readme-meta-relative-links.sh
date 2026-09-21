#!/usr/bin/env bash
# Pin that every RELATIVE link in the meta README resolves to a path that
# exists in the repo.
#
# The README links to the things it documents: `[bin/pull-all](bin/pull-all)`,
# `[docs/INVENTIONS.md](docs/INVENTIONS.md)`, `[bin/icon-assets/](bin/icon-assets)`.
# The [0x04] HELPER SCRIPTS table alone is one such link per row. When a
# script is renamed or moved, the table keeps the old path — the row still
# describes a real tool, so nothing about the prose looks wrong, and the
# link just 404s on github.com for every reader who clicks it.
#
# Relative links are exactly the class no external checker covers: a link
# checker pointed at the rendered page tests the https:// URLs, and
# readme-meta-toc-anchors.sh tests the `#fragment` links. The
# repo-relative ones in between had nothing.
#
# Scope is deliberately the meta README only, matching the other
# readme-meta-* gates. Submodule READMEs reference each other's paths and
# upstream sources they are ports of (ztunnel cites OpenVPN's
# src/openvpn/ssl_ncp.c; awkrs documents a src/jit.rs it has REMOVED),
# so the same check there would be almost entirely false positives.
#
# Skipped by design:
#   - absolute URLs (https://, http://, mailto:) — network, not the tree
#   - pure `#fragment` links — readme-meta-toc-anchors.sh owns those
#   - a `#fragment` suffix on a real path is stripped before the test
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

readme="README.md"
if [[ ! -f "$readme" ]]; then
    echo "SKIP  no $readme at the meta repo root"
    exit 0
fi

checked=0
dead=0

while IFS= read -r target; do
    [[ -z "$target" ]] && continue
    case "$target" in
        http://*|https://*|mailto:*|'#'*) continue ;;
    esac
    # Drop any #fragment; `docs/x.md#section` is the file docs/x.md.
    target="${target%%#*}"
    [[ -z "$target" ]] && continue
    # Angle-bracket form: [label](<path with spaces>)
    target="${target#<}"
    target="${target%>}"

    checked=$((checked + 1))
    if [[ -e "$target" ]]; then
        echo "PASS  $target"
    else
        echo "FAIL  $readme: relative link '$target' resolves to nothing (404s on github.com)"
        dead=$((dead + 1))
        ok=0
    fi
done < <(grep -oE '\]\([^)]+\)' "$readme" | sed 's/^](//; s/)$//')

echo "---"
echo "Summary: $checked relative links checked, $dead resolving to nothing"

[[ $ok -eq 1 ]] && exit 0 || exit 1
