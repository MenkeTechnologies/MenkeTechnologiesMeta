#!/usr/bin/env bash
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
ok=1

check_exec() {
    if [[ -x "$1" ]]; then echo "PASS  $1 is executable"
    else echo "FAIL  $1 lacks +x bit"; ok=0; fi
}

check_parses() {
    if sh -n "$1" 2>/dev/null; then echo "PASS  $1 parses under sh -n"
    else echo "FAIL  $1 has syntax error"; ok=0; fi
}

for s in bin/foreach bin/status-all bin/pull-all bin/sync-pointers; do
    [[ -f "$s" ]] || continue
    check_exec "$s"
    check_parses "$s"
done

out=$(./bin/foreach 2>&1 || true)
if [[ "$out" == *"usage"* ]]; then
    echo "PASS  bin/foreach prints usage when called without args"
else
    echo "FAIL  bin/foreach no-args output missing 'usage'; got: $out"
    ok=0
fi

[[ $ok -eq 1 ]] && exit 0 || exit 1
