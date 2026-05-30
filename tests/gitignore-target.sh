#!/usr/bin/env bash
# For every Rust submodule, pin that the repo-local .gitignore
# excludes `target/` (Cargo build artifacts).
#
# Many MenkeTechnologies developers have a global `~/.gitignore_global`
# that ignores `target/` system-wide, so missing repo-local rules
# don't immediately bite. But a new contributor cloning without
# that global config (default on fresh CI runners, contributor
# workstations, Docker images) WOULD `git add` build artifacts —
# and a 200 MB `cargo build` output gets accidentally committed.
#
# The fix is one line: `/target/` (or unrooted `target/`) in
# .gitignore. This test pins that one line.
#
# Caught 2026-05-30: powerliners had no .gitignore at all (only
# protected by the user's ~/.gitignore_global). Other 26 Rust
# submodules already correct.
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

checked=0
missing_gi=0
no_target=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    # Skip non-Rust repos.
    [[ -f "$p/Cargo.toml" || -f "$p/src-tauri/Cargo.toml" ]] || continue

    checked=$((checked + 1))

    gi="$p/.gitignore"
    if [[ ! -f "$gi" ]]; then
        echo "FAIL  $p: no .gitignore — global config protects this dev, fresh CI clones would commit target/"
        missing_gi=$((missing_gi + 1))
        ok=0
        continue
    fi

    # Match `target/`, `target`, `/target/`, `/target` — all valid forms.
    # Reject only-comment-or-blank matches.
    if grep -qE '^/?target/?$' "$gi"; then
        echo "PASS  $p/.gitignore: target/ excluded"
    else
        echo "FAIL  $p/.gitignore: no target/ exclusion rule found"
        no_target=$((no_target + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked Rust submodules checked, $missing_gi without .gitignore, $no_target without target/ rule"

[[ $ok -eq 1 ]] && exit 0 || exit 1
