#!/usr/bin/env bash
# For every Homebrew formula in homebrew-menketech/Formula/*.rb,
# pin that the main `url "..."` field references a github.com
# release tarball under the MenkeTechnologies org.
#
# Pattern enforced (the url MUST start with):
#   https://github.com/MenkeTechnologies/
#
# This pins three things at once:
#
#   1. Org boundary: the url cannot drift to a personal fork
#      (github.com/contributor/foo/...) or a third-party mirror.
#      `brew install` would still work — Homebrew doesn't care
#      where the tarball comes from — but the org would lose
#      attribution and CDN/integrity guarantees.
#   2. Protocol: https:// only. http:// downloads work but
#      transparent tarball MITM is trivial; Homebrew's sha256
#      verification catches it at install time, but the gap
#      between fetch and verify is enough for opportunistic
#      attacks on shared coffee-shop Wi-Fi.
#   3. Hosting: github.com only — not a re-host on a personal
#      S3 bucket, dropbox, or pastebin. These work today but
#      bit-rot on a 5-year horizon when the personal account
#      lapses; the canonical GitHub release URL is durable.
#
# This gate is intentionally LESS strict than iter-19
# (release-builds-formula-bins) and iter-48
# (formula-release-targets) which check the binary-distribution
# pipeline end-to-end. Iter-77 catches the simplest URL-shape
# drift before it can cascade.
#
# 10/10 formulas green at iter-77 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

formulas_dir="homebrew-menketech/Formula"
if [[ ! -d "$formulas_dir" ]]; then
    echo "SKIP  $formulas_dir not initialized"
    exit 0
fi

checked=0
no_url=0
bad_url=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))

    # Take the FIRST top-level `url "..."` line (ignores
    # bottle/livecheck nested urls which use a different syntax).
    url=$(grep -m1 -oE '^\s+url *"[^"]+"' "$f" | sed 's/.*"\([^"]*\)".*/\1/')

    if [[ -z "$url" ]]; then
        echo "FAIL  $f: no top-level url \"...\" field"
        no_url=$((no_url + 1))
        ok=0
        continue
    fi

    if [[ "$url" =~ ^https://github\.com/MenkeTechnologies/ ]]; then
        echo "PASS  $f: url=$url"
    else
        echo "FAIL  $f: url=$url (expected to start with https://github.com/MenkeTechnologies/)"
        bad_url=$((bad_url + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked formulas checked, $no_url without url, $bad_url with non-canonical url"

[[ $ok -eq 1 ]] && exit 0 || exit 1
