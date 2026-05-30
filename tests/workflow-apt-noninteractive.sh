#!/usr/bin/env bash
# For every workflow yml step `run:` block that invokes
# `apt-get install` or `apt install`, pin that the
# command runs non-interactively. Acceptable forms:
#
#   apt-get install -y <pkg>
#   apt-get install --yes <pkg>
#   apt-get install -q <pkg>          (quiet, less-prompty)
#   DEBIAN_FRONTEND=noninteractive apt-get install ...
#   apt install -y <pkg>
#
# Without one of these, apt-get install hits an
# interactive prompt:
#
#   Do you want to continue? [Y/n]
#
# On a CI runner with no stdin, the prompt waits
# forever. The job appears to hang at the install
# step, no output advances, and the runner kills it
# at the job timeout (default 6 hours per GitHub
# Actions; with our timeout-bounds gate, sooner).
# Symptoms:
#
#   - Job sits at "Installing packages..." for the
#     full timeout
#   - No useful error in logs (the prompt is buffered,
#     never displayed)
#   - Re-running produces the identical hang
#   - Wastes CI minutes; consumes runner quota
#
# Worse failure mode: `dpkg --configure` post-install
# step also prompts (e.g., for service-restart
# confirmation on libc6 upgrade). DEBIAN_FRONTEND=
# noninteractive sets the env-var that dpkg and apt
# both check before showing prompts; that's the
# safest single-fix form on Debian-derived systems.
#
# GitHub-hosted ubuntu-latest runners SET
# DEBIAN_FRONTEND=noninteractive by default in the
# runner image, so `apt-get install -y` works without
# additional env-var. But containerized jobs
# (`container: ubuntu:24.04`) DO NOT inherit that
# default and need `-y` AND/OR the env-var
# explicitly.
#
# This gate accepts any of: -y, --yes, -q,
# DEBIAN_FRONTEND env-var on the same line.
# Continuation lines (backslash) within 3-line window
# are also scanned.
#
# Detection: grep for `apt-get install` / `apt
# install` in run blocks. Within the line and the
# next 2 lines (for `\`-continuation), require one
# of the non-interactive markers.
#
# Pairs with workflow security defense family + perf
# (timeout-bounds, no-deprecated-runners). Adds anti-
# CI-hang to the family.
#
# 54/54 apt-get install invocations are non-interactive
# at iter-201 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
interactive=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    while IFS= read -r match; do
        ln_num="${match%%:*}"
        text="${match#*:}"
        stripped=$(echo "$text" | sed -E 's/^[[:space:]]*//')
        case "$stripped" in
            \#*) continue ;;
        esac
        if ! echo "$stripped" | grep -qE '\bapt(-get)?\s+install\b'; then
            continue
        fi
        checked=$((checked + 1))
        # Window: this line + next 2 lines (handles `\`-continuation)
        window=$(sed -n "${ln_num},$((ln_num + 2))p" "$wf")
        if ! echo "$window" | grep -qE -- '(-y\b|--yes\b|-q\b|DEBIAN_FRONTEND=noninteractive)'; then
            echo "FAIL  $wf:$ln_num: apt-get install without -y / --yes / DEBIAN_FRONTEND=noninteractive — CI hangs on prompt. Line: $text"
            interactive=$((interactive + 1))
            ok=0
        fi
    done < <(grep -nE '\bapt(-get)?\s+install\b' "$wf" 2>/dev/null || true)
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked apt install invocations checked, $interactive interactive (will hang in CI)"

[[ $ok -eq 1 ]] && exit 0 || exit 1
