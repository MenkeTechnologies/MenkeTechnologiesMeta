#!/usr/bin/env bash
# For every workflow yml step using `dtolnay/rust-
# toolchain`, pin that the `with:` block uses only
# canonical parameter keys per the action's
# action.yml schema.
#
# Canonical dtolnay/rust-toolchain with-keys:
#
#   toolchain    Rust toolchain version override
#                (defaults to the @<ref> in `uses:`,
#                e.g. @stable, @nightly, @1.85)
#   targets      Cross-compile target triple(s),
#                comma-separated or list
#   components   rustup components (clippy, rustfmt,
#                rust-src, miri, llvm-tools, etc.)
#                comma-separated or list
#   override     Whether to set as override for
#                the working directory (default
#                true)
#
# A non-canonical key in dtolnay/rust-toolchain
# `with:`:
#
#   - uses: dtolnay/rust-toolchain@stable
#     with:
#       toolchains: stable          # WRONG — plural
#       target: x86_64-...          # WRONG — singular
#       component: clippy           # WRONG — singular
#       profile: minimal            # WRONG — not in
#                                     dtolnay schema
#                                     (that's the
#                                      official
#                                      actions-rs
#                                      schema)
#
# GitHub Actions silently IGNORES unknown with-keys.
# The action runs with DEFAULTS:
#
#   - toolchains (plural) → ignored; the toolchain
#     from `@<ref>` is used; the contributor's
#     intent to override the ref (e.g., "use
#     1.78 specifically for this step despite the
#     workflow's @stable") is silently dropped
#
#   - target (singular) → ignored; no cross-
#     compile targets are added to rustup; `cargo
#     build --target x86_64-...` fails "target
#     not installed"; cross-compilation pipeline
#     broken
#
#   - component (singular) → ignored; no
#     components added; `cargo clippy` fails "no
#     such command"; subsequent steps requiring
#     clippy / rustfmt / miri / rust-src all fail
#     with confusing missing-tool errors
#
#   - profile (not in dtolnay schema) → ignored;
#     the user typed dtolnay's parameter but with
#     the OLD actions-rs/toolchain syntax;
#     contributor confusion between the two
#     similar actions
#
# Common typo sources:
#
#   toolchains          → toolchain        (plural)
#   rust_version        → toolchain        (different
#                                            name)
#   version             → toolchain        (synonym)
#   target              → targets          (singular)
#   target_list         → targets          (suffix)
#   target_triple       → targets          (suffix)
#   component           → components       (singular)
#   component_list      → components       (suffix)
#   profile             → (not in dtolnay; this is
#                          actions-rs/toolchain
#                          syntax confusion)
#   default             → override         (different
#                                            concept)
#
# Detection: YAML-parse each workflow. For every
# step with `uses: dtolnay/rust-toolchain@<v>`,
# check `with:` block keys against the canonical
# set.
#
# Pairs with canonical-keys family — fifteenth
# table:
#   workflow-{top,job,step}-canonical-keys
#   cargo-{bin,package,dep,profile,workspace,lib,
#          bench}-canonical-keys
#   workflow-checkout-canonical-with
#   workflow-cache-canonical-with
#   workflow-upload-artifact-canonical-with
#   workflow-download-artifact-canonical-with
#   workflow-rust-toolchain-canonical-with (this)
#
# Third-most-used action (178 uses) — covers the
# Rust toolchain setup leg of every Rust build.
#
# 178/178 dtolnay/rust-toolchain with-keys canonical
# at iter-234 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi

checked=0
bad=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    result=$(python3 - "$wf" <<'PY'
import sys, yaml
try:
    d = yaml.safe_load(open(sys.argv[1]))
except Exception:
    print('0|')
    sys.exit()
if not isinstance(d, dict):
    print('0|')
    sys.exit()
allowed = {'toolchain', 'targets', 'components', 'override'}
total = 0
bad = []
for jn, job in (d.get('jobs', {}) or {}).items():
    if not isinstance(job, dict):
        continue
    for i, step in enumerate(job.get('steps', []) or []):
        if not isinstance(step, dict):
            continue
        u = step.get('uses')
        if not isinstance(u, str):
            continue
        if 'dtolnay/rust-toolchain' not in u:
            continue
        total += 1
        w = step.get('with', {})
        if not isinstance(w, dict):
            continue
        sn = step.get('name', f'step #{i+1}')
        for k in w.keys():
            if k not in allowed:
                bad.append(f'{jn}/{sn}:{k}')
print(f"{total}|{';'.join(bad)}")
PY
)
    n="${result%%|*}"
    bads="${result#*|}"
    checked=$((checked + n))
    if [[ -n "$bads" ]]; then
        IFS=';' read -ra ba <<< "$bads"
        for b in "${ba[@]}"; do
            echo "FAIL  $wf: dtolnay/rust-toolchain $b — non-canonical with-key (silently ignored; default applied)"
            bad=$((bad + 1))
            ok=0
        done
    fi
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
echo "Summary: $checked dtolnay/rust-toolchain uses checked, $bad with non-canonical keys"

[[ $ok -eq 1 ]] && exit 0 || exit 1
