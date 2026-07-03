#!/usr/bin/env bash
# For every workflow yml that contains build, test, or
# linting commands (cargo build/test/check/clippy,
# npm/pnpm scripts, pytest, cargo install, etc.), pin
# that the workflow has at least one `actions/checkout`
# step.
#
# GitHub Actions does NOT auto-clone the repository
# into the runner workspace. The runner starts with an
# empty $GITHUB_WORKSPACE. Without an explicit
# `actions/checkout@v4` step, every file-touching
# command fails with cryptic errors:
#
#   $ cargo build
#   error: could not find `Cargo.toml` in
#   `/home/runner/work/<repo>/<repo>` or any
#   parent directory
#
#   $ pytest tests/
#   ERROR: file or directory not found: tests/
#
#   $ npm test
#   npm error code ENOENT
#   npm error syscall open
#   npm error path /home/runner/work/<repo>/<repo>/
#                  package.json
#
# The error is recoverable in the sense that adding
# checkout fixes it, but:
#
#   - First run after pushing the workflow file fails
#   - PR check shows red, blocking merge
#   - Debugging time wasted on the cryptic error
#     (contributors familiar with local builds often
#     misdiagnose as "missing dep" or "wrong working
#     directory" before realizing the workspace is
#     empty)
#   - Re-running the workflow without fixing it
#     produces the same error indefinitely
#
# The detection's "build/test command" matchers:
#
#   cargo build / test / check / clippy / run / install
#   npm / pnpm / yarn (run | test | build | install)
#   pytest / python -m pytest / tox
#   make / cmake / ninja
#   gradle / mvn
#   go (build | test | vet)
#   the shellcheck linter
#   ruby / bundle (exec | install)
#
# Workflows that ONLY use first-party setup actions
# (no run: blocks invoking build commands) might
# legitimately skip checkout — e.g., a workflow that
# only deploys a pre-built artifact downloaded from
# elsewhere. Those workflows don't trigger this gate.
#
# Detection: regex over `run:` blocks for build-
# command patterns. If a match exists, require at
# least one `actions/checkout` step somewhere in the
# workflow.
#
# Pairs with workflow security defense + correctness
# family. Adds anti-empty-workspace failure mode.
#
# 58/58 build-using workflows have checkout at
# iter-203 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
missing=0

build_re='cargo (build|test|check|clippy|run|install)|npm (run|test|build|install)|pnpm (run|test|build|install)|yarn (run|test|build|install)|pytest|python -m pytest|tox\b|^make\b|cmake\b|ninja\b|gradle\b|mvn\b|^go (build|test|vet)\b|shellcheck\b|bundle (exec|install)'

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    # Does the workflow use any build-like command?
    if ! grep -qE "$build_re" "$wf"; then
        continue
    fi
    checked=$((checked + 1))
    if ! grep -qE 'actions/checkout' "$wf"; then
        echo "FAIL  $wf: invokes build/test commands but has no actions/checkout step — runner workspace is empty"
        missing=$((missing + 1))
        ok=0
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
echo "Summary: $checked build-using workflows checked, $missing without checkout"

[[ $ok -eq 1 ]] && exit 0 || exit 1
