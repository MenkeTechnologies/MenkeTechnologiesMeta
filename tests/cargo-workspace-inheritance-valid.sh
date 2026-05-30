#!/usr/bin/env bash
# For every Cargo.toml that uses `<field>.workspace = true`
# inheritance, pin that the workspace root's
# `[workspace.package]` section declares the inherited field.
#
# Cargo's workspace inheritance (introduced in 1.64, October
# 2022): a sub-crate manifest can declare `edition.workspace =
# true` (or version, authors, license, etc.), and Cargo resolves
# the value from the workspace root's `[workspace.package]`
# table at build time.
#
# When the inheritance contract is broken — the sub-crate says
# `edition.workspace = true` but `[workspace.package]` doesn't
# declare an `edition` field, OR there's no `[workspace.package]`
# table at all — Cargo errors at the very first invocation:
#
#   error: `edition` was not set in the workspace, but the
#   member needs it
#
# The failure is at workspace-resolution time (every cargo
# command), so it manifests immediately. The user-facing impact
# is high though: the workspace becomes unusable until the
# inheritance contract is restored.
#
# How the drift sneaks in:
#   - Sub-crate gets `edition.workspace = true` copy-pasted
#     from another workspace where the root DID declare it,
#     but the destination root doesn't
#   - Workspace root's `[workspace.package]` section is
#     refactored / migrated and a field gets dropped without
#     updating dependent sub-crates
#   - New workspace added without scaffolding a
#     `[workspace.package]` table at all; one sub-crate
#     accidentally tries to inherit
#
# Algorithm:
#   1. For each Cargo.toml, find every `<field>.workspace = true`
#   2. Walk up the directory tree to find the workspace root
#      (the Cargo.toml containing `[workspace]`)
#   3. Verify the root's `[workspace.package]` declares <field>
#
# 7/7 inheritance references resolve at iter-122 add — pure
# regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi

results=$(python3 - "$root" << 'PY'
import os, re, sys
ROOT = sys.argv[1]

def find_workspace_root(start_dir):
    d = os.path.abspath(start_dir)
    while d != '/':
        cand = os.path.join(d, 'Cargo.toml')
        if os.path.isfile(cand):
            if '[workspace]' in open(cand).read():
                return cand
        if d == ROOT:
            break
        d = os.path.dirname(d)
    return None

checked = 0
problems = []

gitmodules_path = os.path.join(ROOT, '.gitmodules')
if not os.path.isfile(gitmodules_path):
    print(f"COUNT 0 0")
    sys.exit()

with open(gitmodules_path) as gm:
    for line in gm:
        if not line.startswith('\tpath = '):
            continue
        p = os.path.join(ROOT, line[len('\tpath = '):].rstrip())
        if not os.path.isdir(p):
            continue
        for candidate in (os.path.join(p, 'Cargo.toml'),
                          os.path.join(p, 'src-tauri/Cargo.toml')):
            if not os.path.isfile(candidate):
                continue
            content = open(candidate).read()
            ws_fields = re.findall(
                r'(?m)^([a-zA-Z][a-zA-Z0-9_-]*)\.workspace\s*=\s*true',
                content
            )
            if not ws_fields:
                continue
            ws_root = find_workspace_root(os.path.dirname(candidate))
            if not ws_root:
                problems.append(
                    f"{candidate}: uses workspace inheritance but no [workspace] root found"
                )
                continue
            ws_content = open(ws_root).read()
            wp_match = re.search(
                r'(?ms)^\[workspace\.package\]\n(.*?)(?=\n\[|\Z)',
                ws_content
            )
            if not wp_match:
                for f_ in ws_fields:
                    checked += 1
                    problems.append(
                        f"{candidate}: inherits {f_}.workspace=true but {ws_root} has no [workspace.package]"
                    )
                continue
            wp_fields = set(re.findall(
                r'(?m)^([a-zA-Z][a-zA-Z0-9_-]*)\s*=',
                wp_match.group(1)
            ))
            for f_ in ws_fields:
                checked += 1
                if f_ not in wp_fields:
                    problems.append(
                        f"{candidate}: inherits {f_}.workspace=true but {ws_root} [workspace.package] lacks {f_}"
                    )

print(f"COUNT {checked} {len(problems)}")
for p_ in problems:
    print(p_)
PY
)

count_line=$(echo "$results" | grep '^COUNT ' | head -1)
checked=$(echo "$count_line" | awk '{print $2}')
problems=$(echo "$count_line" | awk '{print $3}')

if [[ "$problems" -gt 0 ]]; then
    echo "$results" | grep -v '^COUNT ' | while IFS= read -r line; do
        [[ -n "$line" ]] && echo "FAIL  $line"
    done
    ok=0
fi

echo "---"
echo "Summary: $checked workspace-inheritance references checked, $problems unresolved"

[[ $ok -eq 1 ]] && exit 0 || exit 1
