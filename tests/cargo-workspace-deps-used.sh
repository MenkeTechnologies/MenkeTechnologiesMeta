#!/usr/bin/env bash
# For every Cargo.toml workspace root that declares
# `[workspace.dependencies]`, pin that every entry in the
# table is actually referenced by at least one crate within
# the workspace (root crate or any sub-crate) via either:
#
#   <dep>.workspace = true
# OR
#   <dep> = { workspace = true, ... }
#
# Orphan entries in [workspace.dependencies] are:
#
#   - DEAD CODE in the manifest. The workspace resolver reads
#     them, validates them, and ignores them. Pure noise.
#   - DEPENDENCY BLOAT: cargo metadata commands resolve the
#     orphan dep's transitive graph as part of workspace
#     planning even though no crate actually uses it. Slows
#     down `cargo metadata`, `cargo tree`, and IDE indexing.
#   - REVIEW NOISE: a contributor reviewing the workspace
#     root sees the entry and assumes it's used somewhere,
#     pivoting attention to "where" before discovering it's
#     orphaned. Burns review minutes.
#   - VERSION DRIFT MAGNET: an orphan entry's version doesn't
#     get bumped when sub-crates bump their own deps. The
#     orphan's version progressively diverges from "current"
#     (since nothing forces it forward) until it's months
#     out of date — at which point a future use of it would
#     pull a stale version unless the developer notices and
#     bumps.
#
# Detection: walk every Cargo.toml under the workspace root,
# scan for `<dep>.workspace = true` patterns OR
# `<dep> = { ... workspace = true ... }` patterns. Set
# difference between declared workspace deps and used deps.
# The workspace root itself is INCLUDED (a Cargo.toml that is
# BOTH workspace root AND a [package] crate uses workspace
# deps from its own table; zshrs/Cargo.toml is this pattern).
#
# 36/36 workspace deps green at iter-145 add — pure regression
# floor against orphan accumulation.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi

output=$(python3 - "$root" << 'PY'
import os, re, sys
ROOT = sys.argv[1]

total = 0
problems = []

for r, _, files in os.walk(ROOT):
    # Skip vendored upstream trees (Helix tree-sitter grammar sources,
    # JUCE, node_modules) — those ship third-party Cargo.toml we don't own.
    if ('.git' in r or 'target' in r or 'vendor' in r
            or 'runtime/grammars/sources' in r or 'libs/JUCE' in r
            or 'node_modules' in r):
        continue
    if 'Cargo.toml' not in files:
        continue
    path = f'{r}/Cargo.toml'
    content = open(path).read()
    if '[workspace.dependencies]' not in content:
        continue
    m = re.search(r'(?ms)^\[workspace\.dependencies\]\n(.*?)(?=\n\[|\Z)', content)
    if not m:
        continue
    ws_deps = []
    for ln in m.group(1).splitlines():
        ln = ln.strip()
        if not ln or ln.startswith('#'):
            continue
        nm = re.match(r'^([a-zA-Z0-9_-]+) *=', ln)
        if nm:
            ws_deps.append(nm.group(1))
    if not ws_deps:
        continue

    used = set()
    for sr, _, sf in os.walk(r):
        if 'Cargo.toml' not in sf:
            continue
        sub_path = f'{sr}/Cargo.toml'
        sub_content = open(sub_path).read()
        for dep in ws_deps:
            esc = re.escape(dep)
            if re.search(rf'(?m)^{esc} *= *\{{[^}}]*workspace *= *true', sub_content):
                used.add(dep)
            elif re.search(rf'(?m)^{esc}\.workspace *= *true', sub_content):
                used.add(dep)

    for dep in ws_deps:
        total += 1
        if dep not in used:
            problems.append(f'{path}: orphan workspace dep "{dep}"')

print(f'COUNT {total} {len(problems)}')
for p in problems:
    print(p)
PY
)

count_line=$(echo "$output" | grep '^COUNT ' | head -1)
total=$(echo "$count_line" | awk '{print $2}')
orphan=$(echo "$count_line" | awk '{print $3}')

if [[ "$orphan" -gt 0 ]]; then
    echo "$output" | grep -v '^COUNT ' | while IFS= read -r line; do
        [[ -n "$line" ]] && echo "FAIL  $line"
    done
    ok=0
fi

echo "---"
echo "Summary: $total workspace.dependencies entries checked, $orphan orphaned (no crate uses them)"

[[ $ok -eq 1 ]] && exit 0 || exit 1
