#!/usr/bin/env bash
# For every submodule whose release workflow targets the
# homebrew-menketech tap, pin that it references the
# `HOMEBREW_TAP_TOKEN` secret. A release.yml that checks out the tap
# WITHOUT this secret can only push when the tap is public + the
# default `github.token` has cross-repo write — which it does not.
#
# Catches the 2026-05-30 powerliners failure: release runs v0.0.7
# through v0.1.1 all completed the build job + created the GH Release,
# but the "Update Homebrew tap" job died at checkout with
# `Bad credentials` because either (a) HOMEBREW_TAP_TOKEN secret was
# missing entirely, or (b) the PAT inside had expired. The brew tap
# was stuck at v0.0.6 (with placeholder sha256) for 4 release cycles
# before the gap was noticed.
#
# This test catches case (a) at PR time — if a new submodule adds
# release.yml that bumps the tap but forgets HOMEBREW_TAP_TOKEN, fail
# fast. It cannot catch case (b) — PAT expiration is a runtime concern
# that needs the release-job log itself.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
ok=1

paths=()
while IFS= read -r line; do
    paths+=("${line#$'\tpath = '}")
done < <(grep $'^\tpath = ' .gitmodules)

# Detect submodules-initialized state
init_count=0
for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] && init_count=$((init_count + 1))
done
if [[ $init_count -eq 0 ]]; then
    echo "SKIP  no submodules initialized"
    exit 0
fi

checked=0
missing_secret=0
no_release_yml=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    # Only Rust-shipping submodules ship binaries via brew. Detect with
    # Cargo.toml OR src-tauri/Cargo.toml presence.
    has_cargo=0
    [[ -f "$p/Cargo.toml" || -f "$p/src-tauri/Cargo.toml" ]] && has_cargo=1
    [[ $has_cargo -eq 1 ]] || continue
    # Skip the tap repo itself — it doesn't need to write to itself.
    [[ "$p" == "homebrew-menketech" ]] && continue
    # Skip stryke-* connectors — they're library crates, not binaries
    # that ship via brew.
    [[ "$p" == stryke-* ]] && continue

    rel="$p/.github/workflows/release.yml"
    if [[ ! -f "$rel" ]]; then
        # Some library crates (traderview, fusevm, nmaprs maybe) don't
        # publish brew binaries. Informational only.
        no_release_yml=$((no_release_yml + 1))
        echo "INFO  $p: no .github/workflows/release.yml"
        continue
    fi
    checked=$((checked + 1))

    # Does this release.yml target homebrew-menketech at all?
    if grep -qE 'homebrew-menketech' "$rel"; then
        # Yes — it must reference HOMEBREW_TAP_TOKEN somewhere.
        if grep -qE 'HOMEBREW_TAP_TOKEN' "$rel"; then
            echo "PASS  $p: release.yml targets tap AND uses HOMEBREW_TAP_TOKEN"
        else
            echo "FAIL  $p: release.yml references homebrew-menketech but never uses HOMEBREW_TAP_TOKEN — tap-update step will fail with bad credentials"
            missing_secret=$((missing_secret + 1))
            ok=0
        fi
    else
        # Release without tap update is fine (e.g. crates.io-only push).
        echo "INFO  $p: release.yml exists but doesn't target homebrew-menketech (no tap-bump path)"
    fi
done

echo "---"
echo "Summary: $checked release.yml files checked, $missing_secret missing HOMEBREW_TAP_TOKEN, $no_release_yml without release.yml"

[[ $ok -eq 1 ]] && exit 0 || exit 1
