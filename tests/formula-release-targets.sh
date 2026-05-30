#!/usr/bin/env bash
# For every brew formula → submodule pair, pin that the target
# triples embedded in the formula URLs (one per platform/arch
# combo) match the `target:` matrix entries in the submodule's
# release.yml.
#
# Catches the failure mode where release.yml drops a target from
# its build matrix but the formula still has a URL for that
# target — `brew install` 404s on the missing tarball. Inverse:
# release.yml adds a target but the formula doesn't surface it,
# leaving users on that platform unable to brew-install.
#
# Test scopes the grep to `target: <triple>` lines (actual matrix
# entries) — NOT comments that mention a triple. Real iter-48 false
# positive: awkrs release.yml had `# x86_64-apple-darwin dropped`
# in a comment, which the naive grep matched and falsely classified
# as a build target.
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

for stem in "${!formula_to_repo[@]}"; do
    rb="homebrew-menketech/Formula/${stem}.rb"
    repo="${formula_to_repo[$stem]}"
    [[ -f "$rb" ]] || continue
    [[ -d "$repo" ]] || continue
    rel="$repo/.github/workflows/release.yml"
    [[ -f "$rel" ]] || continue

    # Extract triples from formula URLs (which look like
    # `<name>-vX.Y.Z-<triple>.tar.gz`).
    formula_triples=$(grep -oE '(aarch64|x86_64)-(apple-darwin|unknown-linux-gnu|pc-windows-msvc)' "$rb" 2>/dev/null | sort -u | tr '\n' ' ')

    # Extract triples from release.yml's matrix — ONLY `target: <triple>`
    # lines, not comments or descriptions.
    release_triples=$(grep -oE 'target: *(aarch64|x86_64)-(apple-darwin|unknown-linux-gnu|pc-windows-msvc)' "$rel" 2>/dev/null \
                      | sed 's/target: *//' | sort -u | tr '\n' ' ')

    checked=$((checked + 1))
    if [[ "$formula_triples" == "$release_triples" ]]; then
        echo "PASS  $stem ↔ $repo: [$formula_triples]"
    else
        echo "FAIL  $stem ↔ $repo: formula triples [$formula_triples] != release.yml matrix [$release_triples]"
        mismatched=$((mismatched + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked formula ↔ release.yml pairs checked, $mismatched mismatched"

[[ $ok -eq 1 ]] && exit 0 || exit 1
