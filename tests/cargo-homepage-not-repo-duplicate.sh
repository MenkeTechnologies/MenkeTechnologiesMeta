#!/usr/bin/env bash
# For every Rust crate that ships docs/index.html, pin that
# Cargo.toml's `homepage` field is DISTINCT from its `repository`
# field — specifically, that homepage points at the GitHub Pages
# docs URL rather than duplicating the repo URL.
#
# Iter-26 bulk-added the homepage field across 25 missing crates,
# using https://menketechnologies.github.io/<repo>/ where docs/
# existed and GitHub repo URL otherwise. This gate catches the
# inverse drift: a crate that HAS docs/ but its homepage still
# points at the repo (typically temprs/storageshower-style legacy
# state that predates the iter-26 convention).
#
# Why homepage matters distinct from repository: crates.io shows
# both as separate links on the crate page. If both point at the
# same URL, the "Homepage" link adds zero value — and worse,
# signals to the crate-page reader that there's no separate docs
# site. The correct pattern: homepage → docs entry point,
# repository → GitHub source. Both visible, both useful.
#
# Allowlist: crates without docs/ legitimately keep homepage ==
# repository (storageshower, spring-boot-rest-generator). The
# duplicate is the correct state when no docs URL exists.
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
dupe=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    # Only enforce when docs/ exists — otherwise the dupe is a
    # legitimate fallback (no docs URL available).
    [[ -f "$p/docs/index.html" ]] || continue

    homepage=""
    if grep -qE '^homepage\.workspace *= *true' "$cargo"; then
        ws_root="$p/Cargo.toml"
        if [[ -f "$ws_root" ]] && grep -qE '^\[workspace\.package\]' "$ws_root"; then
            homepage=$(awk '
                /^\[workspace\.package\]/ { in_ws = 1; next }
                /^\[/                     { in_ws = 0 }
                in_ws && /^homepage *= *"/ {
                    match($0, /"[^"]*"/)
                    print substr($0, RSTART + 1, RLENGTH - 2)
                    exit
                }
            ' "$ws_root")
        fi
    fi
    if [[ -z "$homepage" ]]; then
        homepage=$(grep -m1 -E '^homepage *= *"' "$cargo" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
    fi
    repo=$(grep -m1 -E '^repository *= *"' "$cargo" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$homepage" && -n "$repo" ]] || continue

    checked=$((checked + 1))

    # Normalize — strip trailing slash for comparison.
    h_norm="${homepage%/}"
    r_norm="${repo%/}"

    if [[ "$h_norm" == "$r_norm" ]]; then
        echo "FAIL  $cargo: homepage and repository both point at $h_norm — but docs/ exists, so homepage should be https://menketechnologies.github.io/${p##*/}/"
        dupe=$((dupe + 1))
        ok=0
    else
        echo "PASS  $cargo: homepage=$homepage distinct from repository=$repo"
    fi
done

echo "---"
echo "Summary: $checked crates with docs/ checked, $dupe with homepage == repository duplication"

[[ $ok -eq 1 ]] && exit 0 || exit 1
