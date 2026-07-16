#!/usr/bin/env bash
# For every FREE/OSS Rust submodule with a LICENSE file, pin that the
# text matches the canonical MenkeTechnologies MIT template byte-for-byte.
#
# PAID products are exempt: they are NOT MIT-licensed (MIT would let
# anyone use, copy, and resell them for free, defeating the paid model).
# Detect a paid/proprietary product by the canonical marker
# `license = "UNLICENSED"` in its Cargo.toml and skip the MIT check —
# it ships its own proprietary LICENSE instead.
#
# Bulk-added in iter 10 (23 LICENSE files), expanded in iter 37 to
# 27 (Audio-Haxor caught + workspace-root fall-through fix in
# iter-10 test). All 27 share an identical SHA. This gate pins that
# uniformity so:
#
# 1. An edit to one LICENSE that drifts from the canonical form
#    (typo fix, year bump, copyright-holder change) gets caught at
#    PR time before it's left as an inconsistent across-repos state.
# 2. The "canonical" LICENSE template can evolve as ONE coordinated
#    update across all 27 repos rather than scattered edits.
#
# Hash: sha1 — fast, sufficient for byte-equality detection.
#
# Does NOT verify any specific text content; only that all 27 files
# match each other. The canonical hash is computed from the first
# LICENSE file found and the rest must equal it.
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

# Canonical LICENSE text — must match every Rust submodule's LICENSE.
canonical_text=$(cat <<'MIT_LICENSE'
MIT License

Copyright (c) 2026 MenkeTechnologies

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
MIT_LICENSE
)

# Compute canonical hash via shasum (BSD/macOS) or sha1sum (Linux).
if command -v shasum >/dev/null 2>&1; then
    canonical_sha=$(printf '%s\n' "$canonical_text" | shasum | awk '{print $1}')
elif command -v sha1sum >/dev/null 2>&1; then
    canonical_sha=$(printf '%s\n' "$canonical_text" | sha1sum | awk '{print $1}')
else
    echo "SKIP  no shasum/sha1sum tool available"
    exit 0
fi

checked=0
diverged=0
dual=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue

    # Scope: only MenkeTechnologies-authored Rust submodules. Third-party
    # zsh plugins (zsh-z, fzf-tab, kubectl-aliases, revolver, zunit, ...)
    # are vendored from upstream authors with their own LICENSE text;
    # forcing them to the canonical MenkeTechnologies MIT would
    # misattribute authorship. Detect by Cargo.toml presence — every
    # MenkeTechnologies Rust crate has one; every third-party zsh
    # plugin doesn't.
    [[ -f "$p/Cargo.toml" || -f "$p/src-tauri/Cargo.toml" ]] || continue

    # Paid / proprietary products are NOT MIT — skip them. The marker is
    # `license = "UNLICENSED"` in the package Cargo.toml; such repos ship
    # their own proprietary LICENSE (still pinned to exist by
    # license-file-present.sh) which must NOT match the canonical MIT.
    # Check BOTH the workspace-root and the src-tauri package Cargo.toml —
    # Tauri paid apps (Audio-Haxor) declare license in src-tauri/Cargo.toml
    # while the root is a license-less workspace.
    if grep -qhE '^license[[:space:]]*=[[:space:]]*"UNLICENSED"' \
        "$p/Cargo.toml" "$p/src-tauri/Cargo.toml" 2>/dev/null; then
        echo "SKIP  $p: proprietary (license=\"UNLICENSED\") — paid product, not MIT"
        continue
    fi

    # Free forks inherit the upstream project's OSI license and CANNOT
    # relicense to MIT (e.g. zmax forks Helix → MPL-2.0). When Cargo.toml
    # declares a recognized non-MIT OSI license, the repo is intentionally
    # not-MIT and the MIT-uniformity check does not apply; the LICENSE file
    # is still required to exist (license-file-present.sh).
    if grep -qhE '^license[[:space:]]*=[[:space:]]*"(MPL-2\.0|Apache-2\.0|GPL-[23]\.0[^"]*|LGPL-[^"]*|BSD-[23]-Clause)"' \
        "$p/Cargo.toml" "$p/src-tauri/Cargo.toml" 2>/dev/null; then
        decl=$(grep -hoE '^license[[:space:]]*=[[:space:]]*"[^"]+"' "$p/Cargo.toml" "$p/src-tauri/Cargo.toml" 2>/dev/null | head -1)
        echo "SKIP  $p: $decl — free fork, inherited non-MIT OSI license"
        continue
    fi

    if [[ ! -f "$p/LICENSE" ]]; then
        # Dual-license repos (nmaprs) ship LICENSE-MIT / LICENSE-APACHE
        # instead of a single LICENSE — accept either as canonical.
        if [[ -f "$p/LICENSE-MIT" ]]; then
            sha=$(shasum "$p/LICENSE-MIT" 2>/dev/null | awk '{print $1}')
            if [[ "$sha" == "$canonical_sha" ]]; then
                echo "PASS  $p: dual-license LICENSE-MIT matches canonical"
                dual=$((dual + 1))
            fi
        fi
        continue
    fi

    checked=$((checked + 1))
    sha=$(shasum "$p/LICENSE" 2>/dev/null | awk '{print $1}')

    if [[ "$sha" == "$canonical_sha" ]]; then
        echo "PASS  $p/LICENSE matches canonical"
    else
        echo "FAIL  $p/LICENSE diverges from canonical MenkeTechnologies MIT (sha $sha)"
        diverged=$((diverged + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked LICENSE files checked + $dual dual-license LICENSE-MIT, $diverged diverged from canonical"

[[ $ok -eq 1 ]] && exit 0 || exit 1
