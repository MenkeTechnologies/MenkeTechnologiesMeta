#!/usr/bin/env bash
# Meta self-audit extension: every tests/*.sh gate that uses
# `find .` to walk the meta repo tree MUST exclude the .git/
# directory in the same command.
#
# Why this matters: `.git/` is a massive tree of binary objects
# (pack files, refs, hooks, modules subdirs for every submodule).
# A find that descends into it:
#
#   1. SLOW: doubles or triples the gate runtime, especially in
#      CI where the repo's pack files are deep
#   2. NOISY: finds binary blob content that matches generic
#      patterns (e.g., `find . -name '*.toml'` returns Cargo.toml
#      AND .git/modules/*/info/exclude files copied from
#      submodules' .toml templates)
#   3. PRIVATE: leaks the structure of internal submodules'
#      git history into gate output, which then appears in PR
#      CI logs
#
# Accepted exclusion forms:
#   - `-path './.git' -prune`  (canonical org convention)
#   - `-not -path './.git/*'`  (alternative form, same semantics)
#   - `-not -path '*/.git/*'`  (matches submodule .git dirs too)
#   - any other -path/-prune pattern referencing `.git`
#
# Detection is intentionally LENIENT: as long as `find .` and
# `.git` appear together in the same find command, the gate
# passes. The strict canonical form is preferred but not
# enforced — the user-facing requirement is "don't scan .git",
# not "use my preferred syntax for not scanning .git".
#
# 23/23 find-using gates have a .git exclusion at iter-101 add
# — pure regression floor against accidental full-tree scans.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
missing=0

for f in tests/*.sh; do
    [[ -f "$f" ]] || continue
    # Skip this gate itself — its description references the
    # patterns it audits.
    [[ "$(basename "$f")" == "meta-find-excludes-git.sh" ]] && continue
    # Only check gates that actually use `find .`.
    if ! grep -qE '^[^#]*\<find \.' "$f"; then
        continue
    fi
    checked=$((checked + 1))

    # Lenient: find command line must reference .git somewhere
    # (the exclusion form may be -prune, -not -path, or others).
    if grep -qE '\<find \.[^#]*\.git' "$f"; then
        echo "PASS  $f: find . references .git exclusion"
    else
        echo "FAIL  $f: \`find .\` used without .git exclusion — scans .git/ tree unnecessarily"
        missing=$((missing + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked find-using gates checked, $missing without .git exclusion"

[[ $ok -eq 1 ]] && exit 0 || exit 1
