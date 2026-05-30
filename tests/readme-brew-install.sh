#!/usr/bin/env bash
# For every Rust submodule that has a corresponding formula in the
# homebrew-menketech tap, pin that its README.md mentions `brew install`
# somewhere.
#
# Catches the UX failure mode: each Rust binary is now `brew install`-able
# through the unified MenkeTechnologies tap, but a user landing on the
# repo's GitHub README has no way to discover that path. Without an
# explicit `brew install <name>` in the README, the only documented
# install path is `cargo install` or build-from-source — both slower
# and more friction.
#
# Mapping repo → formula is most-direct-name (formula filename minus .rb):
#   awkrs.rb        → awkrs
#   iftoprs.rb      → iftoprs
#   lsofrs.rb       → lsofrs
#   nmaprs.rb       → nmaprs
#   powerliners.rb  → powerliners
#   storageshower.rb → storageshower
#   stryke.rb       → strykelang (binary stryke, repo strykelang)
#   temprs.rb       → temprs
#   zshrs.rb        → zshrs
#   zshrs-all.rb    → zshrs (umbrella variant, same repo)
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
ok=1

# Map formula stem → submodule path.
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

# Detect submodules-initialized state
if [[ ! -d homebrew-menketech/Formula ]]; then
    echo "SKIP  no submodules initialized (homebrew-menketech not checked out)"
    exit 0
fi

# Build deduplicated list of repos to check (skip the zshrs-all → zshrs
# duplicate). Iterate over actual formula files so a new formula added
# without a mapping entry gets surfaced.
declare -A seen_repos
for f in homebrew-menketech/Formula/*.rb; do
    stem=$(basename "$f" .rb)
    # zshrs-all is the umbrella; its README check is covered by zshrs.
    [[ "$stem" == "zshrs-all" ]] && continue
    repo="${formula_to_repo[$stem]:-}"
    if [[ -z "$repo" ]]; then
        echo "WARN  formula $stem.rb has no repo mapping in this test — add an entry to formula_to_repo[]"
        continue
    fi
    seen_repos[$repo]=1
done

checked=0
missing=0
for repo in "${!seen_repos[@]}"; do
    if [[ ! -f "$repo/README.md" ]]; then
        echo "FAIL  $repo: has a tap formula but no README.md to verify"
        missing=$((missing + 1))
        ok=0
        continue
    fi
    checked=$((checked + 1))
    if grep -qE 'brew install' "$repo/README.md"; then
        echo "PASS  $repo: README.md mentions brew install"
    else
        echo "FAIL  $repo: README.md doesn't mention brew install (formula is in the tap)"
        missing=$((missing + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked README.md files checked, $missing missing brew install instructions"

[[ $ok -eq 1 ]] && exit 0 || exit 1
