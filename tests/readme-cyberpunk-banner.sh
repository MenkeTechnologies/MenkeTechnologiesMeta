#!/usr/bin/env bash
# For every FIRST-PARTY submodule, pin that its README opens with the
# canonical MenkeTechnologies "cyberpunk" banner: a fenced ASCII-art
# block at the very top (the figlet/ANSI-Shadow wordmark every product
# README leads with — strykelang, zshrs, the stryke-* packages, the
# Rust CLIs, the audio stack, etc.).
#
# Why pin it: the banner is the house style — a reader landing on any
# MenkeTechnologies repo should see the same cyberpunk wordmark, not a
# bare `# title` markdown heading. A plain README reads as an unfinished
# or third-party repo. Caught MenkeTechnologiesPublications (+4 others)
# shipping a plain `# Heading` instead of the banner.
#
# Detection (font-agnostic — the org uses ANSI Shadow AND the figlet
# "standard" slash font): within the first few non-blank lines the
# README must open a ``` fence, and that fenced block must contain at
# least 3 "art" lines — non-trivial-length lines whose characters are
# mostly NON-alphanumeric (figlet art is box-drawing / slashes / blocks,
# not words). A fenced shell snippet (high alphanumeric) does NOT count.
#
# Exempt: third-party FORKS mirrored in the org (fzf-tab, zsh-z, zunit,
# revolver, …). Those keep their upstream README verbatim so authorship
# is not misattributed; imposing the house banner on a fork would be
# dishonest. The allowlist is explicit and forks-only — first-party
# repos are never exempted.
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

# Third-party forks mirrored in the org — keep their upstream README,
# so the house banner is not required. Forks ONLY; never first-party.
is_fork() {
    case "$1" in
        fzf-tab|fzf-zsh-plugin|fasd-simple|jhipster-oh-my-zsh-plugin|kubectl-aliases|revolver|zunit|zsh-z|zsh-docker-aliases)
            return 0 ;;
    esac
    return 1
}

# Returns 0 if the README opens with a cyberpunk ASCII-art banner.
# LC_ALL=C so awk byte-processes the multibyte box-drawing banner
# (en_US.UTF-8 awk aborts with "towc: multibyte conversion failure").
# In byte mode each box-drawing glyph is 3 non-alphanumeric bytes, so
# the art-line alphanumeric ratio is still near zero — the threshold
# holds for both ANSI-Shadow (█╗║) and figlet "standard" (_/\|) banners.
has_banner() {
    LC_ALL=C awk '
        BEGIN { seen = 0; in_fence = 0; art = 0; found_fence = 0 }
        # Locate the opening fence within the first few non-blank lines.
        !found_fence {
            if ($0 ~ /^[ \t]*$/) next
            seen++
            if ($0 ~ /^[ \t]*```/) { found_fence = 1; in_fence = 1; next }
            if (seen > 4) { exit 1 }   # banner must sit at the very top
            next
        }
        in_fence {
            if ($0 ~ /^[ \t]*```/) { exit (art >= 3 ? 0 : 1) }
            line = $0
            n = length(line)
            if (n >= 18) {
                alnum = 0
                for (i = 1; i <= n; i++) {
                    c = substr(line, i, 1)
                    if (c ~ /[A-Za-z0-9]/) alnum++
                }
                if (alnum / n < 0.35) art++
            }
            next
        }
        END { exit (art >= 3 ? 0 : 1) }
    ' "$1"
}

readme_of() {
    for n in README.md Readme.md readme.md README; do
        [[ -f "$1/$n" ]] && { echo "$1/$n"; return 0; }
    done
    return 1
}

checked=0
missing=0
forks=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    name="${p##*/}"

    if is_fork "$name"; then
        echo "SKIP  $p: third-party fork (upstream README kept)"
        forks=$((forks + 1))
        continue
    fi

    readme=$(readme_of "$p") || { echo "FAIL  $p: no README file"; missing=$((missing + 1)); ok=0; continue; }

    checked=$((checked + 1))
    if has_banner "$readme"; then
        echo "PASS  $readme: opens with the cyberpunk ASCII-art banner"
    else
        echo "FAIL  $readme: no cyberpunk banner — README must open with a fenced ASCII-art wordmark (see strykelang/zshrs/stryke-* READMEs)"
        missing=$((missing + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked first-party READMEs checked, $missing without the cyberpunk banner, $forks forks exempted"

[[ $ok -eq 1 ]] && exit 0 || exit 1
