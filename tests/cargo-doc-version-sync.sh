#!/usr/bin/env bash
# For every submodule that ships both Cargo.toml AND docs/*.html, pin
# that the version claimed in the docs matches the Cargo.toml version.
#
# Catches the failure mode seen 2026-05-30 with powerliners: Cargo.toml
# was at "0.2.1" while docs/report.html still claimed "v0.0.8" because
# the docs got refreshed via per-stat batches that missed the version
# field. Without this gate, the meta-repo's public docs lie about which
# release is current.
#
# Methodology:
#   1. Read top-level Cargo.toml version (or src-tauri/Cargo.toml if no
#      top-level — Audio-Haxor / traderview Tauri layout).
#   2. Grep docs/*.html for vN.N.N and version "N.N.N" patterns.
#   3. If the docs mention a version at all, the highest one mentioned
#      must equal Cargo's version. (Older versions can still appear in
#      changelog / migration sections — we only fail when the LATEST
#      doc-claimed version is BEHIND Cargo.)
#
# Designed for `submodules: true` CI checkout. SKIPs cleanly when no
# submodules are initialized.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
ok=1

# Collect all submodule paths from .gitmodules
paths=()
while IFS= read -r line; do
    paths+=("${line#$'\tpath = '}")
done < <(grep $'^\tpath = ' .gitmodules)

if [[ ${#paths[@]} -eq 0 ]]; then
    echo "FAIL  no submodules found in .gitmodules"
    exit 1
fi

# Detect whether submodules are initialized.
init_count=0
for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] && init_count=$((init_count + 1))
done
if [[ $init_count -eq 0 ]]; then
    echo "SKIP  no submodules initialized (need 'git submodule update --init')"
    exit 0
fi

# Compare highest semver-looking version in doc vs Cargo for each repo.
# Returns 0 if equal, 1 if doc is behind Cargo, 2 if doc has no version mention.
version_gt() {
    # Lexically compare X.Y.Z dotted versions. Returns 0 if $1 > $2.
    local IFS=.
    local -a a=($1) b=($2)
    local i
    for ((i = 0; i < ${#a[@]}; i++)); do
        local av="${a[i]:-0}"
        local bv="${b[i]:-0}"
        if (( 10#$av > 10#$bv )); then return 0; fi
        if (( 10#$av < 10#$bv )); then return 1; fi
    done
    return 1
}

checked=0
behind=0
for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue

    # Must have docs/*.html
    if ! ls "$p"/docs/*.html >/dev/null 2>&1; then
        continue
    fi

    # Locate version. Top-level Cargo.toml wins UNLESS it's a workspace
    # root with no version field — fall through to src-tauri/Cargo.toml
    # (Audio-Haxor and other Tauri apps put their version there).
    cargo_ver=""
    if [[ -f "$p/Cargo.toml" ]]; then
        cargo_ver=$(grep -m1 -E '^version[[:space:]]*=[[:space:]]*"' "$p/Cargo.toml" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
    fi
    if [[ -z "$cargo_ver" && -f "$p/src-tauri/Cargo.toml" ]]; then
        cargo_ver=$(grep -m1 -E '^version[[:space:]]*=[[:space:]]*"' "$p/src-tauri/Cargo.toml" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
    fi
    if [[ -z "$cargo_ver" ]]; then
        continue
    fi

    # Highest version mentioned in docs, EXCLUDING lines that reference
    # other languages/tools by name. The strykelang docs mention Perl
    # version sigils ($^V, v5.20.0, v5.38.2) as compat targets — those
    # aren't strykelang release versions and would produce false WARNs.
    doc_max=$(grep -h -E 'v[0-9]+\.[0-9]+\.[0-9]+' "$p"/docs/*.html 2>/dev/null \
            | grep -viE 'perl|python|rust [0-9]|fusevm [0-9]|nodejs|node\.js|\$\^V|v5\.[0-9]+\.[0-9]+' \
            | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' \
            | sed 's/^v//' \
            | sort -V \
            | tail -1)

    checked=$((checked + 1))

    if [[ -z "$doc_max" ]]; then
        # No version mentioned in docs — informational only.
        echo "INFO  $p: Cargo $cargo_ver, no version string in docs/*.html"
        continue
    fi

    if [[ "$doc_max" == "$cargo_ver" ]]; then
        echo "PASS  $p: Cargo $cargo_ver == max doc version v$doc_max"
        continue
    fi

    if version_gt "$cargo_ver" "$doc_max"; then
        echo "FAIL  $p: Cargo at $cargo_ver but docs/*.html highest version is only v$doc_max"
        ok=0
        behind=$((behind + 1))
    else
        # Doc claims a HIGHER version than Cargo. Usually a Cargo.toml
        # that wasn't bumped before tagging — informational, not failing,
        # because some repos cut tags from CI without bumping Cargo first.
        echo "WARN  $p: docs claim v$doc_max but Cargo.toml is still at $cargo_ver (Cargo bump pending?)"
    fi
done

echo "---"
echo "Summary: $checked submodules checked, $behind with docs behind Cargo"

[[ $ok -eq 1 ]] && exit 0 || exit 1
