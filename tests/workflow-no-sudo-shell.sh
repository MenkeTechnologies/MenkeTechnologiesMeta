#!/usr/bin/env bash
# For every workflow yml step `run:` block, pin that no
# command opens an INTERACTIVE ROOT SHELL via:
#
#   sudo -i       # interactive login shell as root
#   sudo -s       # interactive non-login shell as root
#   sudo su       # switch user to root via su
#   sudo su -     # switch user with login profile
#
# Why this matters even on ephemeral CI runners:
#
#   - SCOPE CREEP: a step that needs ONE root command
#     (e.g., `sudo apt-get install foo`) should invoke
#     that one command via sudo, not open a root shell
#     and run multiple commands. The bounded `sudo cmd`
#     form makes the privileged operations grep-able and
#     reviewable.
#
#   - AUDIT TRAIL: workflow logs record what each command
#     emitted. A `sudo -i` opens a shell where all
#     subsequent commands run as root — their individual
#     commands are still logged but the AUTHORIZATION
#     CONTEXT for each is invisible (was this `apt-get`
#     intentional or did the shell hand it execution
#     via PATH search?).
#
#   - SHELL PROFILE INHERITANCE: `sudo -i` sources
#     `/root/.bashrc`, `/root/.profile`, and friends.
#     Those files can contain configured commands,
#     aliases, environment variables. A workflow step
#     that ASSUMES a clean shell environment can break
#     unpredictably depending on what's in root's
#     profile.
#
#   - SECURITY: an `eval`-style attack vector inside a
#     `sudo -i` shell context elevates to root rather
#     than running as the runner user. The blast radius
#     of any other security gate's miss (iter-107 no
#     eval, iter-112 no script-injection, etc.)
#     multiplies.
#
# Correct pattern: invoke individual commands with sudo:
#
#   sudo apt-get update
#   sudo apt-get install -y libfoo-dev
#
# Each invocation is reviewable in isolation.
#
# Detection: regex matching:
#   sudo -i
#   sudo -s
#   sudo su
#   sudo su -
#
# Pairs with iter-179 (no git config --global) and the
# rest of the workflow security defense family. TENTH
# security gate.
#
# 0/90 workflows use interactive sudo shells at iter-181
# add — pure regression floor.
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
        if echo "$stripped" | grep -qE '\bsudo\s+(-i\b|su\b|-s\b)'; then
            echo "FAIL  $wf:$ln_num: interactive root shell — use `sudo <cmd>` form per command. Line: $text"
            risky=$((risky + 1))
            ok=0
        fi
    done < <(grep -nE '\bsudo\b' "$wf" 2>/dev/null || true)
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflow files checked, $risky interactive-root-shell uses"

[[ $ok -eq 1 ]] && exit 0 || exit 1
