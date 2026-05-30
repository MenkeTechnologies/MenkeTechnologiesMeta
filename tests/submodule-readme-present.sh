#!/usr/bin/env bash
# For every initialized submodule, pin that a README file
# exists at the repo root. Accepts README.md, Readme.md,
# readme.md, or extension-less README (in that priority
# order, matching GitHub's auto-detection).
#
# A submodule without a README has several failure modes:
#
#   1. GitHub repo page renders an EMPTY landing area
#      below the file tree. Visitors landing on the repo
#      see no description, no install instructions, no
#      example. The repo looks abandoned or placeholder.
#
#   2. crates.io page for Rust submodules displays the
#      Cargo.toml `description` field as the entire
#      project blurb. Without a README, there is no
#      examples section, no usage block, no API
#      summary — crates.io's "Documentation" tab is
#      empty and docs.rs is the only fallback.
#
#   3. Homebrew tap's `brew info <formula>` shows the
#      formula's `desc` (single line) and links to the
#      `homepage` URL. If that URL is the GitHub repo
#      and the repo has no README, users following the
#      link land on an empty page — confusing for a
#      shipped Homebrew tap.
#
#   4. zinit's plugin discovery (for the user's zsh
#      plugin submodules) follows the GitHub repo URL
#      to surface README content in the plugin
#      browser. No README = no plugin description in
#      zinit's UI.
#
#   5. SEO: GitHub generates the repo's <meta
#      description> tag from the README's first
#      heading + paragraph. No README = no SEO
#      content; the repo doesn't surface in search
#      results for relevant queries.
#
# The convention is universal: every public repo
# should have a README. Even a 5-line README beats no
# README because it signals "this is a real project,
# here is what it does."
#
# Detection: filesystem check for `<submodule>/README.md`
# (most common), `<submodule>/Readme.md`, `<submodule>/
# readme.md`, or extension-less `<submodule>/README`.
# GitHub renders all four; the gate accepts any.
#
# 64/64 submodules have README at iter-194 add — pure
# regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if [[ ! -f .gitmodules ]]; then
    echo "SKIP  no .gitmodules"
    exit 0
fi

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
missing=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    checked=$((checked + 1))

    found=0
    for cand in "$p/README.md" "$p/Readme.md" "$p/readme.md" "$p/README"; do
        if [[ -f "$cand" ]]; then
            found=1
            break
        fi
    done

    if [[ $found -eq 0 ]]; then
        echo "FAIL  $p: no README file at repo root — GitHub page, crates.io, brew info, zinit, and SEO all expect one"
        missing=$((missing + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked submodules checked, $missing without README"

[[ $ok -eq 1 ]] && exit 0 || exit 1
