#!/usr/bin/env bash
# For every brew formula, pin that the upstream release.yml actually
# BUILDS the binaries the formula intends to install via bin.install.
#
# Two failure modes this catches:
#   (a) Formula adds a new bin.install entry but release.yml's build
#       command uses explicit --bin flags that don't include it. The
#       release tarball lacks the binary; `brew install` errors out
#       at install time with "no such file" once the tarball unpacks.
#   (b) Inverse: formula keeps an old bin.install for a binary that
#       got removed from release.yml's build set.
#
# Coverage interpretation:
#   - If release.yml uses `cargo build [--release] [--locked]` WITHOUT
#     any --bin flags, the workspace builds ALL [[bin]] targets — every
#     formula bin is implicitly covered.
#   - If release.yml uses one or more --bin flags, only the named bins
#     get built. Each formula bin must appear in the --bin set.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
ok=1

if [[ ! -d homebrew-menketech/Formula ]]; then
    echo "SKIP  no submodules initialized (homebrew-menketech not checked out)"
    exit 0
fi

declare -A formula_to_repo
formula_to_repo[awkrs]=awkrs
formula_to_repo[iftoprs]=iftoprs
formula_to_repo[lsofrs]=lsofrs
formula_to_repo[nmaprs]=nmaprs
formula_to_repo[powerliners]=powerliners
formula_to_repo[storageshower]=storageshower
formula_to_repo[stryke]=strykelang
formula_to_repo[temprs]=temprs
formula_to_repo[zshrs]=zshrs

# Extract bin.install names from a formula.
formula_bins() {
    awk '
        /def install/ { in_install = 1; next }
        in_install && /^[[:space:]]*end[[:space:]]*$/ { in_install = 0 }
        in_install && /bin\.install/ {
            s = $0
            while (match(s, /"[^"]+"/)) {
                print substr(s, RSTART + 1, RLENGTH - 2)
                s = substr(s, RSTART + RLENGTH)
            }
        }
    ' "$1"
}

# Extract --bin args from a release.yml. Returns "ALL" if release.yml
# has a cargo build line with no explicit --bin flag (workspace builds
# every [[bin]] target by default).
#
# Handles line continuations: yaml `run: |` blocks with `cargo build \`
# trailing-slash continuations are joined before --bin scanning. Without
# this, multi-line release.yml files that use `--bin powerline \` style
# would be misclassified as "implicit ALL build" by single-line greps.
release_bins() {
    local rel="$1"
    # Join lines ending in backslash, then re-split.
    local joined
    joined=$(awk '
        /\\$/ {
            line = line substr($0, 1, length($0) - 1) " "
            next
        }
        { print line $0; line = "" }
        END { if (line != "") print line }
    ' "$rel")
    if grep -qE -- 'cargo build[^|&\n]*--bin ' <<< "$joined"; then
        grep -E -- 'cargo build' <<< "$joined" \
            | grep -oE -- '--bin +[A-Za-z0-9._-]+' \
            | sed 's/^--bin *//' \
            | sort -u
    else
        if grep -qE 'cargo build[^|&\n]*--release' <<< "$joined"; then
            echo "ALL"
        fi
    fi
}

checked=0
missing=0

for stem in "${!formula_to_repo[@]}"; do
    rb="homebrew-menketech/Formula/${stem}.rb"
    repo="${formula_to_repo[$stem]}"
    [[ -f "$rb" ]] || continue
    [[ -d "$repo" ]] || continue
    rel="$repo/.github/workflows/release.yml"
    if [[ ! -f "$rel" ]]; then
        echo "INFO  $stem: $repo has no .github/workflows/release.yml"
        continue
    fi

    f_bins=$(formula_bins "$rb" | sort -u | tr '\n' ' ')
    r_bins=$(release_bins "$rel" | tr '\n' ' ')

    checked=$((checked + 1))

    # Strip trailing whitespace.
    f_bins="${f_bins% }"
    r_bins="${r_bins% }"

    if [[ "$r_bins" == "ALL" ]]; then
        echo "PASS  $stem: release.yml builds workspace (all [[bin]] targets implicit) — covers [$f_bins]"
        continue
    fi

    if [[ -z "$r_bins" ]]; then
        echo "FAIL  $stem: release.yml has no detectable cargo build line"
        missing=$((missing + 1))
        ok=0
        continue
    fi

    # Verify every f_bin appears in r_bins.
    missing_bins=""
    for b in $f_bins; do
        if ! echo " $r_bins " | grep -qE " $b "; then
            missing_bins="$missing_bins $b"
        fi
    done

    if [[ -z "$missing_bins" ]]; then
        echo "PASS  $stem: release.yml --bin set [$r_bins] covers formula bin.install [$f_bins]"
    else
        echo "FAIL  $stem: release.yml --bin set [$r_bins] is missing formula bins:$missing_bins"
        missing=$((missing + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked formula↔release pairs checked, $missing with build/install mismatches"

[[ $ok -eq 1 ]] && exit 0 || exit 1
