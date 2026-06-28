#!/usr/bin/env bash
# For every Rust submodule, pin that .github/workflows/ci.yml runs the
# four canonical polish gates the meta-repo's docs/report.html claims:
#
#   fmt    — cargo fmt --all -- --check
#   clippy — cargo clippy ... -- -D warnings
#   doc    — RUSTDOCFLAGS="-D warnings" cargo doc --no-deps
#   test   — cargo test --locked
#
# Per docs/report.html lines 124-130:
#   "Every Rust crate in the meta repo must pass all four gates locally
#    and in CI before a tag is cut. The shared release flow then promotes
#    the binary to MenkeTechnologies/homebrew-menketech via the
#    HOMEBREW_TAP_TOKEN cross-repo write secret."
#
# A CI that omits one of these gates means the public doc claim is false
# and a regression in that gate could silently ship.
#
# Library-only crates and stryke-* connectors are in scope (they all
# share the same Rust quality bar). Non-Rust repos are skipped.
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

# Returns 0 if file contains a line matching the canonical gate pattern.
# Regexes tolerate `cargo --locked fmt` (flag-before-subcmd) and
# `cargo fmt --check` (no --all), since real-world ci.yml lines drift
# in flag order without losing the gate's semantics.
has_fmt() {
    grep -qE 'cargo[^|&\n]+fmt[^|&\n]*--check' "$1"
}
has_clippy() {
    grep -qE 'cargo[^|&\n]+clippy[^|&\n]*-D ?warnings' "$1"
}
has_doc() {
    # `cargo doc --no-deps` AND a RUSTDOCFLAGS env that contains -D warnings,
    # possibly on different lines (`env:` block vs `run:` step).
    if grep -qE 'cargo[^|&\n]+doc[^|&\n]*--no-deps' "$1" \
       && grep -qE 'RUSTDOCFLAGS:?\s*["'"'"']?-D ?warnings' "$1"; then
        return 0
    fi
    return 1
}
has_test() {
    grep -qE 'cargo[^|&\n]+(test|nextest)' "$1"
}

checked=0
missing=0
allowed=0

# Allowlist for repos that opt out of one or more gates intentionally.
# Each entry must be explicitly justified with the reason — opt-outs are
# permanent design choices, not "we'll fix it later" gaps. CI passes for
# allowed repos; the test still reports which gate was opt-outed so a
# regression in a non-opt-outed gate is still caught.
# Per-gate opt-out: gate_opt_out <repo> <gate> returns 0 if <repo> is allowed
# to skip <gate>. Opt-outs are permanent, documented design choices — never
# "we'll fix it later" gaps. A repo still FAILs on any gate it does NOT opt out
# of, so granular opt-outs keep the maximum surface enforced.
gate_opt_out() {
    # Whole-repo opt-outs (every gate excused).
    case "$1" in
        strykelang|zshrs|fusevm)
            # Massive codebases: mass-fmt churn would obscure the diff signal
            # and clippy false-positives at scale need brittle per-warn lists.
            return 0
            ;;
        Audio-Haxor|traderview)
            # Tauri v2 apps — canonical build is `pnpm tauri:build:ci` (cargo
            # wrapped with frontend bundling); the cargo subset is a means, not
            # the gate.
            return 0
            ;;
        api-rest-generator)
            # Mid-transition from Kotlin to Rust; Rust path still secondary.
            return 0
            ;;
    esac
    # Single-gate opt-outs.
    case "$1:$2" in
        vimlrs:doc)
            # Faithful-to-C ported doc comments carry [bracket] snippets that
            # trip rustdoc's intra-doc-link lint, so doc stays advisory (no
            # `-D warnings`); fmt + clippy + test are still enforced.
            return 0
            ;;
    esac
    return 1
}

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    [[ -f "$p/Cargo.toml" || -f "$p/src-tauri/Cargo.toml" ]] || continue

    ci="$p/.github/workflows/ci.yml"
    if [[ ! -f "$ci" ]]; then
        # Some library crates legitimately ship without a per-repo CI
        # (the workspace umbrella covers them). Skip with INFO.
        echo "INFO  $p: no .github/workflows/ci.yml"
        continue
    fi

    checked=$((checked + 1))
    miss=""
    excused=""
    for g in fmt clippy doc test; do
        "has_$g" "$ci" && continue
        if gate_opt_out "$p" "$g"; then excused="$excused $g"; else miss="$miss $g"; fi
    done

    if [[ -z "$miss" && -z "$excused" ]]; then
        echo "PASS  $p: ci.yml has fmt + clippy + doc + test gates"
    elif [[ -z "$miss" ]]; then
        echo "ALLOWED  $p: ci.yml enforces required gates (documented opt-out:$excused)"
        allowed=$((allowed + 1))
    else
        echo "FAIL  $p: ci.yml missing gate(s):$miss"
        missing=$((missing + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked Rust repos with ci.yml checked, $missing missing canonical gates, $allowed allowed by opt-out"

[[ $ok -eq 1 ]] && exit 0 || exit 1
