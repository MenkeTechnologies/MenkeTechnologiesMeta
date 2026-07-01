#!/usr/bin/env bash
# For every workflow yml step `run:` block, pin that no
# `git clone` command uses a non-https URL scheme:
#
#   http://     unencrypted git protocol
#   git://      unauthenticated unencrypted (RETIRED by
#               github.com in March 2022)
#   ssh://      SSH key required (breaks runner setup in
#               most cases; uses key persistence which is
#               its own footgun)
#   git@        SSH SCP-style URL (`git@github.com:foo/bar`)
#
# Why https-only for git clone in CI:
#
#   - MITM: same risk as iter-184 (no http downloads).
#     git:// and http:// are unencrypted; an attacker can
#     substitute the cloned repo's content.
#
#   - github.com RETIRED git:// support entirely in
#     March 2022. Any workflow still using
#     `git clone git://github.com/...` is broken at the
#     protocol level — clones fail with "Connection
#     refused" or "Could not resolve host" depending on
#     network setup.
#
#   - SSH KEY DEPENDENCE: `ssh://` and `git@` URLs
#     require an SSH key configured on the runner. In CI,
#     this means either:
#       1. Adding a deploy key via secrets (which then
#          persists in the runner's git config — a
#          secret leak vector)
#       2. Using the actions/checkout step's
#          `ssh-key:` input (limited to its own
#          checkout)
#       3. Using ssh-agent forwarding (complex and
#          attack-surface-expanding)
#     None are needed for cloning PUBLIC repos, which is
#     the typical CI use case. Https handles public
#     repos without any auth.
#
# Allowlist:
#   - https://...     (correct)
#   - file:///...     (local clones during testing — not
#                     a CI pattern, no allowlist needed)
#
# Detection: regex on `git clone` followed by a non-https
# URL scheme. `http://`, `git://`, `ssh://`, or `git@`
# (the SCP-style SSH URL form) all FAIL.
#
# Pairs with iter-184 (no http:// curl/wget) and
# iter-76 (.gitmodules URL canonical form, https only).
# All three pin "git operations use https" across
# different surfaces:
#
#   iter-76:  .gitmodules submodule URLs
#   iter-184: curl/wget downloads
#   iter-186: git clone commands (this gate)
#
# FIFTEENTH security gate in the workflow defense family.
#
# 0/90 workflows use non-https clones at iter-186 add —
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
        if echo "$stripped" | grep -qE 'git clone\s+(http://|git://|ssh://|git@)'; then
            echo "FAIL  $wf:$ln_num: git clone uses non-https URL — use https:// for public repos. Line: $text"
            risky=$((risky + 1))
            ok=0
        fi
    done < <(grep -nE 'git clone' "$wf" 2>/dev/null || true)
done < <(find . -path './.git' -prune \
    -o -path '*/grammars/sources/*' -prune \
    -o -path '*/build/_deps/*' -prune \
    -o -path '*/clap-libs/*' -prune \
    -o -path '*/clap-juce-extensions/*' -prune \
    -o -path '*/node_modules/*' -prune \
    -o -path '*/vendor/*' -prune \
    -o -path '*/target/*' -prune \
    -o -path '*/third_party/*' -prune \
    -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflow files checked, $risky non-https git clone uses"

[[ $ok -eq 1 ]] && exit 0 || exit 1
