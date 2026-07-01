#!/usr/bin/env bash
# For every workflow yml, pin that the `needs:` dependency graph
# across all its jobs is ACYCLIC (a DAG).
#
# A cycle in needs (job A needs B, B needs C, C needs A) causes
# GitHub Actions to REJECT the workflow at upload time:
#
#   The workflow is not valid. .github/workflows/foo.yml
#   (Line: N, Col: M): Cycle detected in job dependency graph.
#
# Workflow vanishes from the Actions tab — same silent failure
# pattern as iter-68 / iter-82 / iter-85. PR check missing
# without any annotation explaining why.
#
# How a cycle gets introduced:
#   - Refactor: job B was renamed to C; another job that
#     depended on B was updated to needs: [C]; but C was a
#     downstream of A which itself now points at C through B's
#     old chain — circular.
#   - Cargo-cult: `needs: [test]` added to the `test` job itself
#     (one-node cycle) during a copy-paste from a template.
#   - Two engineers add reciprocal needs concurrently in
#     parallel PRs; both merge before review catches the cycle.
#
# Test uses DFS-based 3-color cycle detection (white/gray/black)
# — standard graph algorithm, O(V+E). Each workflow's graph is
# bounded (typically < 10 jobs), so the per-workflow cost is
# microseconds.
#
# Pairs with iter-85 (needs references exist) — together they
# pin the COMPLETENESS and ACYCLICITY of the needs DAG.
# References pointing at existing jobs but forming a cycle was
# the gap iter-85 left open.
#
# 90/90 workflow files green at iter-96 add — pure regression
# floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi
if ! python3 -c 'import yaml' 2>/dev/null; then
    echo "SKIP  PyYAML not installed"
    exit 0
fi

checked=0
cycles=0
parse_fail=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))

    output=$(python3 -c '
import sys, yaml
try:
    d = yaml.safe_load(open(sys.argv[1]))
    if not isinstance(d, dict):
        print("PARSE_FAIL")
        sys.exit()
    jobs = d.get("jobs", {}) or {}
    if not isinstance(jobs, dict):
        print("PARSE_FAIL")
        sys.exit()
    edges = {}
    for n, j in jobs.items():
        if not isinstance(j, dict):
            edges[n] = []
            continue
        needs = j.get("needs")
        if needs is None:
            edges[n] = []
        elif isinstance(needs, str):
            edges[n] = [needs]
        elif isinstance(needs, list):
            edges[n] = needs
        else:
            edges[n] = []

    # 3-color DFS cycle detection.
    WHITE, GRAY, BLACK = 0, 1, 2
    color = {n: WHITE for n in edges}
    cycle_path = []

    def visit(n, path):
        if color.get(n, WHITE) == GRAY:
            # cycle: from gray node back to itself via path
            idx = path.index(n) if n in path else 0
            cycle_path.extend(path[idx:] + [n])
            return True
        if color.get(n, WHITE) == BLACK:
            return False
        color[n] = GRAY
        for nxt in edges.get(n, []):
            if visit(nxt, path + [n]):
                return True
        color[n] = BLACK
        return False

    for n in list(edges.keys()):
        if color[n] == WHITE:
            if visit(n, []):
                print("CYCLE:" + " -> ".join(cycle_path))
                sys.exit()
    print("OK")
except Exception:
    print("PARSE_FAIL")
' "$wf")

    case "$output" in
        PARSE_FAIL)
            parse_fail=$((parse_fail + 1))
            ;;
        CYCLE:*)
            echo "FAIL  $wf: needs cycle detected: ${output#CYCLE:}"
            cycles=$((cycles + 1))
            ok=0
            ;;
    esac
done < <(find . -path './.git' -prune \
    -o -path '*/grammars/sources/*' -prune \
    -o -path '*/build/_deps/*' -prune \
    -o -path '*/clap-libs/*' -prune \
    -o -path '*/clap-juce-extensions/*' -prune \
    -o -path '*/node_modules/*' -prune \
    -o -path '*/vendor/*' -prune \
    -o -path '*/target/*' -prune \
    -o -path '*/third_party/*' -prune \
    -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflows checked ($parse_fail delegated to iter-68), $cycles with cycles"

[[ $ok -eq 1 ]] && exit 0 || exit 1
