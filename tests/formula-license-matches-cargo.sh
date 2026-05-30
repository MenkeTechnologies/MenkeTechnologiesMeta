#!/usr/bin/env bash
# For every brew formula → submodule pair, pin that the formula's
# `license` field matches the Cargo.toml `license` field.
#
# Matching is SPDX-aware: if Cargo declares an OR'd dual license
# (e.g., `license = "MIT OR Apache-2.0"`), the formula must declare
# ONE of the alternatives (e.g., `license "MIT"` is valid).
#
# Catches the failure mode where Cargo.toml's license changes
# (e.g., MIT → "MIT OR Apache-2.0" relicensing) but the formula's
# license field doesn't follow. brew's `brew audit` enforces the
# formula license but doesn't check it against the source crate's
# declared license — so a stale formula license can ship without
# obvious symptoms, misrepresenting what the user is installing.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if [[ ! -d homebrew-menketech/Formula ]]; then
    echo "SKIP  homebrew-menketech not initialized"
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

# SPDX OR-set membership: is $1 an alternative inside $2?
# e.g., is_alternative "MIT" "MIT OR Apache-2.0" → 0 (yes)
# e.g., is_alternative "GPL-3.0" "MIT OR Apache-2.0" → 1 (no)
is_alternative() {
    local pick="$1" full="$2"
    case "$full" in
        *" OR "*|*" or "*)
            # Split on OR / or; trim whitespace; check each piece.
            local IFS_save="$IFS"
            local p
            for p in $(printf '%s\n' "$full" | sed -E 's/ [Oo][Rr] /\n/g'); do
                p="$(echo "$p" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')"
                if [[ "$p" == "$pick" ]]; then
                    IFS="$IFS_save"
                    return 0
                fi
            done
            IFS="$IFS_save"
            return 1
            ;;
        *)
            [[ "$pick" == "$full" ]]
            ;;
    esac
}

for stem in "${!formula_to_repo[@]}"; do
    rb="homebrew-menketech/Formula/${stem}.rb"
    repo="${formula_to_repo[$stem]}"
    [[ -f "$rb" ]] || continue
    [[ -d "$repo" ]] || continue

    cargo=""
    if [[ -f "$repo/Cargo.toml" ]] && grep -qE '^\[package\]' "$repo/Cargo.toml"; then
        cargo="$repo/Cargo.toml"
    elif [[ -f "$repo/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$repo/src-tauri/Cargo.toml"; then
        cargo="$repo/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    formula_lic=$(grep -m1 -E '^[[:space:]]*license[[:space:]]+"' "$rb" | sed -E 's/.*"([^"]+)".*/\1/')
    cargo_lic=$(grep -m1 -E '^license *= *"' "$cargo" | sed 's/.*"\([^"]*\)".*/\1/')

    [[ -n "$formula_lic" && -n "$cargo_lic" ]] || continue
    checked=$((checked + 1))

    if is_alternative "$formula_lic" "$cargo_lic"; then
        echo "PASS  $stem ↔ $repo: formula '$formula_lic' matches Cargo '$cargo_lic'"
    else
        echo "FAIL  $stem ↔ $repo: formula '$formula_lic' not in Cargo OR-set '$cargo_lic'"
        mismatched=$((mismatched + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked formula ↔ Cargo license pairs checked, $mismatched mismatched"

[[ $ok -eq 1 ]] && exit 0 || exit 1
