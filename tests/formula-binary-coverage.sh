#!/usr/bin/env bash
# For every homebrew-menketech formula that maps to a Rust binary
# submodule, pin that the formula's `bin.install` calls cover the same
# set of binaries declared in the submodule's Cargo.toml `[[bin]]` blocks.
#
# Catches the failure mode where a release.yml ships multiple binaries
# (powerliners ships 5: powerline / powerline-daemon / powerline-config /
# powerline-render / powerline-lint) but the brew formula's install block
# only references one. `brew install powerliners` then quietly fails to
# install 4 of the 5 binaries; users hit `command not found` on the
# missing ones with no signal that they SHOULD be installed.
#
# Inverse failure: formula installs binaries that don't exist in
# Cargo.toml (rename, removal). `brew install` then errors out at
# `bin.install` because the file is missing in the unpacked tarball.
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

checked=0
mismatched=0

# Get the COMPLETE Cargo.toml [[bin]] name set for a submodule.
# Includes feature-gated bins (required-features = [...]) because the
# release.yml can enable features at build time — so a feature-gated
# bin can legitimately ship via brew if the release workflow opts in.
cargo_bins() {
    local cargo="$1"
    [[ -f "$cargo" ]] || return 1
    awk '
        /^\[\[bin\]\]/ { in_bin = 1; next }
        /^\[/          { in_bin = 0 }
        in_bin && /^name *= *"/ {
            match($0, /"[^"]*"/)
            print substr($0, RSTART + 1, RLENGTH - 2)
            in_bin = 0
        }
    ' "$cargo"
}

# Get bin.install args from a formula's install block.
formula_bins() {
    local rb="$1"
    awk '
        /def install/ { in_install = 1; next }
        in_install && /^[[:space:]]*end[[:space:]]*$/ { in_install = 0 }
        in_install && /bin\.install/ {
            # Match bin.install "X" OR bin.install "X", "Y", "Z"
            s = $0
            while (match(s, /"[^"]+"/)) {
                print substr(s, RSTART + 1, RLENGTH - 2)
                s = substr(s, RSTART + RLENGTH)
            }
        }
    ' "$rb"
}

for stem in "${!formula_to_repo[@]}"; do
    rb="homebrew-menketech/Formula/${stem}.rb"
    repo="${formula_to_repo[$stem]}"

    [[ -f "$rb" ]] || continue
    [[ -d "$repo" ]] || continue

    cargo="$repo/Cargo.toml"
    [[ -f "$cargo" ]] || cargo="$repo/src-tauri/Cargo.toml"
    [[ -f "$cargo" ]] || { echo "INFO  $stem.rb: $repo has no Cargo.toml"; continue; }

    declared=$(cargo_bins "$cargo" | sort -u | tr '\n' ' ')
    installed=$(formula_bins "$rb" | sort -u | tr '\n' ' ')

    # If Cargo.toml has zero [[bin]] blocks AND a src/main.rs, the implicit
    # binary is the package's own name.
    if [[ -z "$declared" ]]; then
        if [[ -f "$repo/src/main.rs" ]]; then
            implicit=$(grep -m1 -E '^name *= *"' "$cargo" | sed 's/.*"\([^"]*\)".*/\1/')
            [[ -n "$implicit" ]] && declared="$implicit "
        fi
    fi

    checked=$((checked + 1))

    # Subset check: every binary the formula installs MUST exist as a
    # [[bin]] in Cargo.toml. The reverse is NOT required: a [[bin]] can
    # exist for dev/internal use (gen-docs, bench-autoload, feature-gated
    # variants) without being shipped via brew. Catches typos / renames /
    # stale formula references but doesn't force formulas to install
    # everything.
    missing_in_cargo=""
    for i in $installed; do
        if ! echo " $declared " | grep -qE " $i "; then
            missing_in_cargo="$missing_in_cargo $i"
        fi
    done

    if [[ -z "$missing_in_cargo" ]]; then
        echo "PASS  $stem.rb: bin.install [$installed] is a subset of $repo/Cargo.toml [[bin]] declarations"
    else
        echo "FAIL  $stem.rb: bin.install references [$missing_in_cargo] but Cargo.toml has no [[bin]] for them — typo or stale rename"
        mismatched=$((mismatched + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked formula↔Cargo pairs checked, $mismatched mismatched"

[[ $ok -eq 1 ]] && exit 0 || exit 1
