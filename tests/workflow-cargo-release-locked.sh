#!/usr/bin/env bash
# For every workflow `run:` line invoking `cargo build|test|
# check|run|install --release`, pin that the invocation also
# includes `--locked`.
#
# Why `--locked` matters for release-mode CI:
#
#   - Without --locked, Cargo allows the resolver to UPDATE
#     Cargo.lock on the fly when a published-version pattern
#     newly resolves to a higher minor/patch version than
#     what the lock recorded. Successive CI runs of the same
#     commit can produce DIFFERENT bytecode if a dep got a
#     patch release between the two runs.
#   - For release.yml workflows (the binary distribution
#     pipeline), this means the tarball uploaded as
#     v1.2.3 on day 1 differs from a tarball you'd rebuild
#     from the same commit on day 30. Supply-chain auditors
#     can't reproduce the binary. Bisecting a regression that
#     turns out to be a dep-bug becomes impossible because
#     "the same commit" produces different builds.
#   - For CI workflows, the variability means a green build
#     today doesn't guarantee a green build tomorrow — and
#     when CI breaks, it breaks for what looks like no reason
#     (no commits, just a dep patch release that changed
#     resolution).
#
# `--locked` forces Cargo to use Cargo.lock VERBATIM and fail
# if any required dep isn't already locked. Combined with
# iter-78 (Cargo.lock format v3+) and iter-32 (release-locked-
# build), every release becomes a deterministic input → output
# mapping.
#
# Detection: lines matching `cargo (build|test|check|run|install)
# --release` that don't ALSO contain `--locked`. Comment lines
# (starting with `#` after whitespace strip) are skipped — they
# documentation references, not actual invocations.
#
# 90/90 workflow files green at iter-113 add — pure regression
# floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
unlocked=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))

    while IFS= read -r match; do
        ln_num="${match%%:*}"
        text="${match#*:}"
        stripped=$(echo "$text" | sed -E 's/^[[:space:]]*//')
        # Skip comment lines (documentation).
        case "$stripped" in
            \#*) continue ;;
        esac
        if echo "$stripped" | grep -qE 'cargo (build|test|check|run|install) --release\b' && ! echo "$stripped" | grep -qE -- '--locked'; then
            echo "FAIL  $wf:$ln_num: cargo --release without --locked — non-reproducible build. Line: $text"
            unlocked=$((unlocked + 1))
            ok=0
        fi
    done < <(grep -nE 'cargo (build|test|check|run|install) --release\b' "$wf" 2>/dev/null || true)
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
echo "Summary: $checked workflow files checked, $unlocked cargo --release lines without --locked"

[[ $ok -eq 1 ]] && exit 0 || exit 1
