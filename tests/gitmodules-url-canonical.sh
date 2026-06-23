#!/usr/bin/env bash
# For every entry in .gitmodules, pin that:
#   url = https://github.com/MenkeTechnologies/<path-basename>
#
# (trailing `/` and `.git` accepted)
#
# The .gitmodules file is the source of truth for where every
# submodule clones from. A drifted URL has three failure modes:
#
#   1. Fresh clone fails or pulls from wrong repo. `git submodule
#      update --init --recursive` on a new machine clones the
#      WRONG repo, which then "works" up to the recorded pointer
#      SHA but starts to fail on any subsequent `--remote` update
#      that fetches from the wrong remote.
#   2. Personal-fork URL accidentally committed
#      (github.com/contributor/foo.git instead of the org).
#      Org members appear to be cloning their own forks; CI
#      runs against a stale fork instead of org-main.
#   3. http:// instead of https:// — modern git pushes warn but
#      still work, until a future git update enforces https-only
#      for github.com (the security trajectory).
#
# Pattern enforced: https://github.com/MenkeTechnologies/<basename>
# where <basename> is the last segment of the `path = ...` field.
# Trailing `/` and `.git` are stripped before comparison; both
# are accepted GitHub URL forms.
#
# Why this matters for the audit graph: iter-64 pins Cargo.toml's
# `repository` against the submodule dir. Iter-76 pins
# .gitmodules' `url` against the same dir. Together they ensure
# the three URLs that point at "the same GitHub repo"
# (.gitmodules url, Cargo.toml repository, the actual github.com
# path) all agree — drift in any one is caught.
#
# 64/64 entries green at iter-76 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if [[ ! -f .gitmodules ]]; then
    echo "SKIP  no .gitmodules"
    exit 0
fi

# Parse .gitmodules into (path, url) pairs. Emit one line per
# pair: "<path>\t<url>".
pairs=$(awk '
    BEGIN{path=""; url=""}
    /^\[submodule/{
        if (path != "" && url != "") print path "\t" url
        path=""; url=""
    }
    /^\tpath = /{path=$3}
    /^\turl = /{url=$3}
    END{
        if (path != "" && url != "") print path "\t" url
    }
' .gitmodules)

checked=0
bad=0

while IFS=$'\t' read -r path url; do
    [[ -n "$path" && -n "$url" ]] || continue
    checked=$((checked + 1))

    # Normalize: strip trailing `/` and `.git`.
    norm="${url%/}"
    norm="${norm%.git}"

    # Basename of path.
    base="${path##*/}"
    expected="https://github.com/MenkeTechnologies/$base"

    # In-progress rename exception: zpwr-clip-engine was renamed to zpwr-daw on
    # GitHub, so the url is the new .../zpwr-daw.git while the submodule directory
    # still lags at zpwr-clip-engine. A deliberate, known transitional state —
    # same exception already encoded in submodule-integrity.sh / docs-brand-
    # consistency.sh / docs-index-html-present.sh. Drop once the dir is renamed.
    if [[ "$base" == "zpwr-clip-engine" && "$norm" == "https://github.com/MenkeTechnologies/zpwr-daw" ]]; then
        echo "PASS  $path: url=$url (zpwr-clip-engine → zpwr-daw rename in progress)"
    elif [[ "$norm" == "$expected" ]]; then
        echo "PASS  $path: url=$url"
    else
        echo "FAIL  $path: url=$url (expected $expected — basename of path)"
        bad=$((bad + 1))
        ok=0
    fi
done <<< "$pairs"

echo "---"
echo "Summary: $checked .gitmodules entries checked, $bad with non-canonical URL"

[[ $ok -eq 1 ]] && exit 0 || exit 1
