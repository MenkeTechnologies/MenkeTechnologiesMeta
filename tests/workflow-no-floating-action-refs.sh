#!/usr/bin/env bash
# For every workflow yml step `uses:` field, pin that the
# action reference is NOT a floating branch / unstable tag:
#
#   @main, @master, @HEAD, @latest, @dev, @develop,
#   @trunk, @next, @canary
#
# Acceptable forms:
#
#   @v4, @v4.1, @v4.1.0        version-tag pin
#   @<40-hex-sha>              full-sha pin (most secure)
#   @stable                    accepted (dtolnay convention)
#
# Why floating refs are dangerous:
#
#   - Behavior drift: the same workflow file produces
#     different builds across runs because the resolved
#     action source changes between runs. Two runs of the
#     same PR commit can fail differently — one yesterday
#     when upstream `@main` was at SHA X, one today when
#     it's at SHA Y. The git diff shows nothing.
#
#   - Security exposure window: a compromise of the
#     action's main branch (maintainer account
#     compromise, malicious PR merged) affects every
#     workflow using `@main` IMMEDIATELY on next run.
#     With `@v4` pinning, the compromise must produce a
#     malicious v4.X release before exposure — providing
#     a maintainer-review and community-monitoring
#     window where the attack can be detected and
#     mitigated.
#
#   - Reproducibility: bisecting a regression that
#     originated in an action update is impossible
#     because "the same workflow file" produces different
#     binaries. Without action-version log, you can't
#     correlate "this CI run with this action SHA" to
#     "this binary."
#
#   - Supply-chain audit: organizations that need to
#     audit which third-party code their CI runs cannot
#     answer "what version of actions/checkout did we
#     run on 2026-03-15?" with floating refs. Pinning
#     gives a deterministic answer.
#
# `@stable` is an EXCEPTION because:
#   - It's a dtolnay/rust-toolchain convention meaning
#     "latest stable Rust release"
#   - The action itself is at a pinned major version
#     (@vN); the @stable resolves the Rust toolchain
#     version, not the action's code
#   - dtolnay's action is widely trusted in the Rust
#     ecosystem
#
# Detection: extract every `uses: <ref>@<rev>` value.
# Skip `./` (local reusable workflows) and `docker://`
# (docker image refs). For the remainder, if the ref
# after @ is in the floating-name set, fail.
#
# Pairs with workflow security defense + reproducibility
# family:
#   workflow-uses-pinned             — requires @ presence
#   workflow-deprecated-action-versions — major version floor
#   workflow-no-floating-action-refs (this) — reject branch refs
#   workflow-cache-action-v4-floor   — cache@v4+
#   workflow-upload-artifact-v4-floor — artifact@v4+
#
# 0/90 workflows use floating refs at iter-204 add —
# pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
floating=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    while IFS= read -r match; do
        ln_num="${match%%:*}"
        text="${match#*:}"
        stripped=$(echo "$text" | sed -E 's/^[[:space:]]*//')
        case "$stripped" in
            \#*) continue ;;
        esac
        # Extract the ref value: `uses: NAME@REF` (possibly with leading -)
        # Skip docker:// and ./ prefixes
        ref_value=$(echo "$stripped" | sed -nE 's/^-?\s*uses:\s*([^[:space:]]+)\s*$/\1/p')
        [[ -z "$ref_value" ]] && continue
        case "$ref_value" in
            docker://*|./*) continue ;;
        esac
        # Extract part after @
        after_at="${ref_value##*@}"
        # Skip if no @ (different gate covers that)
        [[ "$after_at" == "$ref_value" ]] && continue
        checked=$((checked + 1))
        # Check for floating ref
        case "$after_at" in
            main|master|HEAD|latest|dev|develop|trunk|next|canary)
                echo "FAIL  $wf:$ln_num: floating action ref \`@$after_at\` — pin to @vN, @vN.M.P, or @<sha>. Line: $text"
                floating=$((floating + 1))
                ok=0
                ;;
        esac
    done < <(grep -nE '^\s*-?\s*uses:' "$wf" 2>/dev/null || true)
done < <(find . -path './.git' -prune \
    -o -path '*/grammars/sources/*' -prune \
    -o -path '*/_deps/*' -prune \
    -o -path '*/libs/JUCE/*' -prune \
    -o -path '*/clap-libs/*' -prune \
    -o -path '*/clap-juce-extensions/*' -prune \
    -o -path '*/node_modules/*' -prune \
    -o -path '*/vendor/*' -prune \
    -o -path '*/target/*' -prune \
    -o -path '*/third_party/*' -prune \
    -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked uses references checked, $floating floating refs"

[[ $ok -eq 1 ]] && exit 0 || exit 1
