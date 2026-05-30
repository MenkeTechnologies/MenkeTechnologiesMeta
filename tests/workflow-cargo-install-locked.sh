#!/usr/bin/env bash
# For every workflow yml step `run:` block that invokes
# `cargo install`, pin that the command includes the
# `--locked` flag (or its alias `--frozen`).
#
# `cargo install` without `--locked` resolves dependencies
# at install time, ignoring the Cargo.lock file shipped
# with the crate's published release. Three concrete
# failure modes:
#
#   1. Supply-chain regression: a transitive dep ships a
#      "compatible" minor version (per semver) that
#      breaks the binary's build or behavior. CI runs
#      fail with cryptic compile errors that depend on
#      the exact moment the runner resolved the
#      dependency graph. The same workflow file ran
#      yesterday and runs today with different outputs.
#
#   2. Malicious typosquat / package takeover: a dep's
#      maintainer account is compromised and a malicious
#      patch release lands on crates.io. Without
#      --locked, the install pulls the latest patch (or
#      minor); WITH --locked, the install pulls the
#      version pinned in the published Cargo.lock that
#      shipped at release time. The window of exposure
#      drops from "every CI run since the compromise" to
#      "only if the user explicitly upgrades the install
#      target."
#
#   3. Unreproducible builds: re-running an old workflow
#      file from a year ago produces a different binary
#      than the original run because the dependency
#      resolution drifts forward. Bisecting a regression
#      that originated in a dependency becomes
#      impossible — you can't go back to the original
#      state.
#
# `--locked` makes cargo refuse to update Cargo.lock at
# install time. The installed binary uses EXACTLY the
# dependency versions the crate's author tested and
# published.
#
# `--frozen` is a stricter variant: --locked PLUS no
# network access for dep resolution. Either flag
# satisfies this gate.
#
# Why this isn't already caught by other tooling:
#
#   - `cargo install` (without --locked) is the form
#     shown in 90% of crate READMEs and crates.io
#     install instructions. The default is unsafe;
#     hardening requires an explicit flag.
#   - Cargo doesn't warn when `--locked` is omitted.
#   - Renovate/Dependabot don't flag this in workflow
#     files (they treat the cargo command as opaque).
#
# Detection: regex for `cargo install` in `run:`
# blocks, then check the same line OR continuation
# lines for `--locked` or `--frozen`. Comments
# excluded.
#
# Pairs with:
#   cargo-deps-no-exact-pin (crate-side dep pinning)
#   cargo-lock-committed (forces lockfile presence)
#   cargo-lock-version-sync (Cargo.toml ↔ Cargo.lock
#     consistency)
#   workflow-cargo-release-locked (release builds use
#     --locked)
#
# This gate covers the install-time leg of the same
# supply-chain hardening category.
#
# 17/17 cargo install invocations use --locked at
# iter-198 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
unlocked=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    while IFS= read -r match; do
        ln_num="${match%%:*}"
        text="${match#*:}"
        stripped=$(echo "$text" | sed -E 's/^[[:space:]]*//')
        case "$stripped" in
            \#*) continue ;;
        esac
        # Skip if line is part of a comment block, or is a yaml comment
        if ! echo "$stripped" | grep -qE 'cargo install\b'; then
            continue
        fi
        checked=$((checked + 1))
        # Check for --locked or --frozen on the same line, or
        # within a 3-line window (for line-continuation cases)
        window=$(sed -n "${ln_num},$((ln_num + 2))p" "$wf")
        if ! echo "$window" | grep -qE -- '(--locked|--frozen)\b'; then
            echo "FAIL  $wf:$ln_num: cargo install missing --locked — supply-chain drift risk. Line: $text"
            unlocked=$((unlocked + 1))
            ok=0
        fi
    done < <(grep -nE 'cargo install' "$wf" 2>/dev/null || true)
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked cargo install invocations checked, $unlocked without --locked/--frozen"

[[ $ok -eq 1 ]] && exit 0 || exit 1
