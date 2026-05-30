#!/usr/bin/env bash
# For every workflow yml step `run:` block, pin that no
# `rm -rf` command targets dangerous paths:
#
#   /              filesystem root
#   $HOME          user home directory
#   ~              shell-expanded home
#   ..             parent directory (escapes the repo)
#   *              shell glob at root scope
#   /*             explicit root glob
#
# Why this matters:
#
#   - CI runners are ephemeral, but `rm -rf /` (or close
#     variants like `rm -rf $HOME`) can wipe state that
#     the workflow depends on later:
#       - cached cargo dependencies
#       - cached npm modules
#       - the runner's git config (with persisted
#         credentials)
#       - SSH agent state
#       - the runner's own ~/.bashrc / ~/.profile
#         (which sources tool installs like rustup)
#
#   - On SELF-HOSTED RUNNERS, `rm -rf $HOME` is a
#     catastrophic wipe: the runner's actions state,
#     cached tool installs, and persistent caches
#     (which can be tens of GB) are destroyed. The
#     runner becomes unusable until manual recovery.
#
#   - SCRIPT-INJECTION AMPLIFIER: if any other security
#     gate's miss allows shell injection (iter-107 eval,
#     iter-112 github.event, iter-185 secret echo), the
#     attacker can use the rm pattern to wipe the
#     runner's state. The injection itself is the
#     vulnerability, but `rm -rf $HOME` is the maximum-
#     damage payload — the gate forces the injection
#     to use something less destructive.
#
#   - DRIFT INTRODUCTION: contributors copy-paste
#     `rm -rf $HOME/.cache/somerepo` from Stack Overflow
#     answers to "clean up before re-running" without
#     thinking about CI implications. The pattern then
#     ships to CI and runs every time, gradually wiping
#     persisted state.
#
# Detection: regex on `rm -[*]r[*]f?` (flags can be
# combined in any order: -rf, -fr, -Rf, -fR, --recursive
# --force, etc.) followed by one of the dangerous
# targets. Comments excluded.
#
# Allowed patterns (NOT flagged by this gate):
#
#   - rm -rf target/                  (cargo build dir,
#                                      relative path)
#   - rm -rf node_modules/            (npm artifacts)
#   - rm -rf .cache/                  (relative cache)
#   - rm -rf $RUNNER_TEMP/foo         (scoped temp)
#   - rm -f single-file.txt           (no -r recursive)
#
# Detection deliberately allows relative paths that don't
# start with `/` because the CI workspace IS the
# repo's working tree, and cleaning artifacts there is
# normal.
#
# Pairs with iter-180 (no chmod 777). Both pin "no
# overly broad filesystem operations." EIGHTEENTH
# security gate.
#
# 0/90 workflows use dangerous rm -rf at iter-189 add —
# pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
risky=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))
    while IFS= read -r match; do
        ln_num="${match%%:*}"
        text="${match#*:}"
        stripped=$(echo "$text" | sed -E 's/^[[:space:]]*//')
        case "$stripped" in
            \#*) continue ;;
        esac
        if echo "$stripped" | grep -qE 'rm\s+-[a-zA-Z]*r[a-zA-Z]*f?\s+(/(?![[:alnum:]])|\$HOME\b|~\b|\.\.|\*|/\*)'; then
            echo "FAIL  $wf:$ln_num: rm -rf targeting dangerous path — use scoped relative paths or \$RUNNER_TEMP. Line: $text"
            risky=$((risky + 1))
            ok=0
        fi
    done < <(grep -nE 'rm\s+-' "$wf" 2>/dev/null || true)
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflow files checked, $risky dangerous rm -rf uses"

[[ $ok -eq 1 ]] && exit 0 || exit 1
