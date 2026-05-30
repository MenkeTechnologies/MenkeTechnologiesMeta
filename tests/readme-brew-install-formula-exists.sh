#!/usr/bin/env bash
# For every `brew install <name>` line found in any submodule's
# README.md (and the meta repo's own README/docs), pin that the named
# formula exists in homebrew-menketech/Formula/.
#
# Catches the failure mode where a README documents `brew install awks`
# (typo for `awkrs`), `brew install stryke-lang` (wrong name; formula
# is `stryke`), or `brew install zshrs-cli` (formula doesn't exist).
# Users copy-pasting from the README hit a `Error: No available
# formula` from brew. Easier to catch at PR time than after a release.
#
# Scope:
#   - Every submodule README.md
#   - The meta repo's own README.md + docs/index.html + docs/report.html
#   - Tap names recognized: any homebrew-menketech/Formula/*.rb stem,
#     plus standard `homebrew/core` names we deliberately reference
#     (pnpm, jq, etc.) via an explicit allowlist
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if [[ ! -d homebrew-menketech/Formula ]]; then
    echo "SKIP  no submodules initialized (homebrew-menketech not checked out)"
    exit 0
fi

# Build the tap formula set.
tap_formulas=$(
    for f in homebrew-menketech/Formula/*.rb; do
        basename "$f" .rb
    done
)

# Allowlist of upstream homebrew/core names that READMEs legitimately
# reference. These don't live in our tap but are real, installable
# formulas. Add explicitly so the test fails loudly on typos within
# our own ecosystem.
core_allowlist="jq pnpm tmux zsh node python3 git rustup ripgrep fd bat eza go cmake protobuf libpcap pkg-config openssl libsodium gh redis mongodb-community apache-spark librdkafka ccze"

# Extract all `brew install <name>` invocations from a file. Handles:
#   brew install foo
#   brew install foo bar baz   (multiple args on one line)
# Skips `brew install --HEAD ...`, `brew install --formula ...` flags.
# Skips lines containing template chars like ${} or shell-expansion
# placeholders (would-be false positives).
extract_brew_args() {
    # Strict command-line match: `brew install <name>...` must be the
    # entire line content (after optional leading whitespace and optional
    # trailing comment). Sentence-style mentions of "brew install" within
    # English prose are SKIPPED — they're not actual commands.
    #
    # Accepts:
    #   brew install foo
    #   brew install foo bar baz
    #   <whitespace>brew install foo    # trailing comment
    # Skips:
    #   "You may need to brew install something later"
    #   "...via `brew install spark-submit`..." (inline code)
    #   `brew install --HEAD foo`
    local f="$1"
    sed -nE '
        s|^[[:space:]]*brew install ([^#`]+)([[:space:]]*#.*)?$|\1|p
    ' "$f" 2>/dev/null \
        | grep -F -v '${' \
        | grep -F -v -- '--' \
        | tr -s ' ' '\n' \
        | grep -E '^[a-zA-Z][a-zA-Z0-9._-]*$' \
        | sort -u
}

is_valid_formula() {
    local name="$1"
    grep -qxF "$name" <<< "$tap_formulas" && return 0
    grep -qE "(^| )$name( |$)" <<< "$core_allowlist" && return 0
    return 1
}

# Build the search target list.
candidates=()
candidates+=(README.md)
candidates+=(docs/index.html)
candidates+=(docs/report.html)
while IFS= read -r p; do
    [[ -d "$p" && -f "$p/README.md" ]] || continue
    candidates+=("$p/README.md")
done < <(grep $'^\tpath = ' .gitmodules | sed 's|^\tpath = ||')

checked=0
broken=0
for f in "${candidates[@]}"; do
    [[ -f "$f" ]] || continue
    while IFS= read -r name; do
        [[ -z "$name" ]] && continue
        checked=$((checked + 1))
        if ! is_valid_formula "$name"; then
            echo "FAIL  $f: 'brew install $name' — no such formula in homebrew-menketech tap and not in upstream-core allowlist"
            broken=$((broken + 1))
            ok=0
        fi
    done < <(extract_brew_args "$f")
done

echo "---"
echo "Summary: $checked brew install args checked across README + docs, $broken referencing unknown formulas"

[[ $ok -eq 1 ]] && exit 0 || exit 1
