#!/usr/bin/env bash
# For every committed Cargo.lock across the umbrella, pin that
# the file's format `version` line is >= 3.
#
# Cargo.lock format history:
#
#   v1: Cargo 1.30 (2018) — original format
#   v2: Cargo 1.41 (Jan 2020) — added `package.checksum` field
#   v3: Cargo 1.53 (Jun 2021) — introduced `[[patch.unused]]`
#                                 and changed sorting
#   v4: Cargo 1.78 (May 2024) — current default; stable lock
#                                 across cargo versions
#
# Why >= 3 specifically:
#
#   - v1 lacks `package.checksum` — fresh `cargo build` re-fetches
#     every dep without integrity verification (supply-chain gap)
#   - v2 fixes that but has known issues with patched-dep
#     resolution that v3 cleaned up
#   - v3+ is the modern baseline for reproducible builds; the
#     org's CI relies on `cargo build --locked` (iter-32) which
#     assumes a usable lock format
#
# Failure mode if v1 or v2 lock is committed:
#   - Modern cargo (>= 1.78) silently upgrades to v4 on next
#     build, generating a diff on EVERY local build
#   - Older cargo cohabits but produces lock conflicts in PRs
#     between v1/v2 maintainers and v4 maintainers
#   - `cargo audit` and `cargo deny` may bail with "lock format
#     too old" on v1
#
# Test threshold: version >= 3. Allows v3 (current minimum for
# the supply-chain integrity feature set) and v4 (current
# default). Rejects v1 and v2 as too old to support modern
# tooling.
#
# 27/27 Cargo.lock files at v4 at iter-78 add — pure regression
# floor against a downgrade (or stale-cargo-generated lock
# slipping through review).
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
too_old=0
no_version=0

while IFS= read -r lock; do
    [[ -f "$lock" ]] || continue
    checked=$((checked + 1))

    # Cargo.lock starts with a top-level `version = N` line
    # (outside any [[package]] block — first line of the file
    # in the modern format).
    v=$(awk '
        /^version *= *[0-9]+/ {
            match($0, /[0-9]+/)
            print substr($0, RSTART, RLENGTH)
            exit
        }
        /^\[\[package\]\]/ { exit }
    ' "$lock")

    if [[ -z "$v" ]]; then
        echo "FAIL  $lock: no top-level \`version =\` line (corrupt or pre-v1 format)"
        no_version=$((no_version + 1))
        ok=0
        continue
    fi

    if [[ "$v" -ge 3 ]]; then
        echo "PASS  $lock: format version $v"
    else
        echo "FAIL  $lock: format version $v (need >= 3 for modern cargo / supply-chain features)"
        too_old=$((too_old + 1))
        ok=0
    fi
done < <(find . -name 'Cargo.lock' -not -path '*/target/*' -not -path '*/vendor/*' -not -path './.git/*' 2>/dev/null)

echo "---"
echo "Summary: $checked Cargo.lock files checked, $no_version without version header, $too_old at v1/v2"

[[ $ok -eq 1 ]] && exit 0 || exit 1
