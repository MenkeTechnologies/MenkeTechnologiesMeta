#!/usr/bin/env bash
# Pin that every GENERATED page under docs/ is current with the source it
# is derived from. Each generator in bin/ owns a page; nothing was
# checking that the committed page still matches what the generator would
# emit today, so a page could sit stale indefinitely and publish to
# GitHub Pages under the author's name.
#
# Three derived artifacts, each with its own source of truth:
#
#   docs/inventions.html  <- docs/INVENTIONS.md   (sync-inventions-html.mjs)
#   docs/<repo>/*.html    <- each submodule docs/ (sync-doc-mirrors)
#   docs/inventory.html   <- the docs/ tree       (gen-doc-inventory.mjs)
#
# Drift is introduced the same way every time: someone edits the SOURCE
# (adds a ledger entry, lands a page in a submodule, adds a docs/ page)
# and never re-runs the generator. The page and its source diverge
# silently — both files are valid, neither is obviously wrong, and the
# published site quietly reports last month's numbers. The inventions
# ledger and its page once drifted 108 entries apart exactly this way.
#
# This gate is CHECK-ONLY: it never leaves a modified file behind.
# sync-inventions-html.mjs and sync-doc-mirrors have real --check /
# --dry-run modes. gen-doc-inventory.mjs has none and always rewrites its
# page, so the page is saved first and restored afterwards (including on
# failure, via trap) and only the comparison result is reported.
#
# Pairs with docs-index-html-present.sh (every Pages dir HAS a homepage)
# and docs-static-deps-exist.sh (the chrome a page references resolves):
# those check a page's SHAPE, this one checks its CONTENT is not stale.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
stale=0

# gen-doc-inventory.mjs rewrites docs/inventory.html in place; restore the
# committed copy no matter how the gate exits so a local run stays clean.
saved=""
restore() { [[ -n "$saved" && -f "$saved" ]] && cp "$saved" docs/inventory.html; rm -f "$saved"; }
trap restore EXIT

if ! command -v node >/dev/null 2>&1; then
    echo "SKIP  node not installed (all three generators are node or shell+node)"
    exit 0
fi

# ---------------------------------------------------------------- 1/3
# docs/inventions.html vs the docs/INVENTIONS.md ledger.
if [[ -f bin/sync-inventions-html.mjs && -f docs/INVENTIONS.md && -f docs/inventions.html ]]; then
    checked=$((checked + 1))
    out=$(node bin/sync-inventions-html.mjs --check 2>&1)
    if [[ $? -eq 0 ]]; then
        echo "PASS  docs/inventions.html: ${out}"
    else
        echo "FAIL  docs/inventions.html: stale vs docs/INVENTIONS.md — run: node bin/sync-inventions-html.mjs"
        echo "      $out"
        stale=$((stale + 1))
        ok=0
    fi
else
    echo "SKIP  docs/inventions.html: generator or ledger absent"
fi

# ---------------------------------------------------------------- 2/3
# docs/<repo>/ mirrors vs each submodule's own docs/. Only meaningful
# when submodules are checked out — on a bare clone there is nothing to
# mirror FROM, and the dry run correctly reports every page unchecked.
if [[ -x bin/sync-doc-mirrors ]]; then
    init_count=0
    while IFS= read -r p; do
        [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] && init_count=$((init_count + 1))
    done < <(git config -f .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null | awk '{print $2}')

    if [[ $init_count -eq 0 ]]; then
        echo "SKIP  docs/<repo>/ mirrors: no submodules initialized"
    else
        checked=$((checked + 1))
        summary=$(./bin/sync-doc-mirrors --dry-run 2>&1 | tail -1)
        # Summary shape: "sync-doc-mirrors: N mirrored pages checked, K stale"
        n_stale=$(printf '%s' "$summary" | grep -oE '[0-9]+ stale' | grep -oE '[0-9]+')
        if [[ -z "$n_stale" ]]; then
            echo "FAIL  docs/<repo>/ mirrors: could not parse dry-run summary: $summary"
            stale=$((stale + 1))
            ok=0
        elif [[ "$n_stale" -eq 0 ]]; then
            echo "PASS  docs/<repo>/ mirrors: $summary"
        else
            echo "FAIL  docs/<repo>/ mirrors: $n_stale behind their submodule — run: ./bin/sync-doc-mirrors"
            stale=$((stale + 1))
            ok=0
        fi
    fi
else
    echo "SKIP  docs/<repo>/ mirrors: bin/sync-doc-mirrors absent"
fi

# ---------------------------------------------------------------- 3/3
# docs/inventory.html vs the actual docs/ tree. No --check mode exists,
# so regenerate over a saved copy and diff, then restore.
if [[ -f bin/gen-doc-inventory.mjs && -f docs/inventory.html ]]; then
    checked=$((checked + 1))
    saved=$(mktemp "${TMPDIR:-/tmp}/inventory.XXXXXX") || saved=""
    if [[ -z "$saved" ]]; then
        echo "FAIL  docs/inventory.html: could not create a temp file to stage the comparison"
        stale=$((stale + 1))
        ok=0
    else
        cp docs/inventory.html "$saved"
        gen_out=$(node bin/gen-doc-inventory.mjs 2>&1)
        if [[ $? -ne 0 ]]; then
            echo "FAIL  docs/inventory.html: generator errored: $gen_out"
            stale=$((stale + 1))
            ok=0
        elif cmp -s "$saved" docs/inventory.html; then
            echo "PASS  docs/inventory.html: ${gen_out}"
        else
            echo "FAIL  docs/inventory.html: stale vs the docs/ tree — run: node bin/gen-doc-inventory.mjs"
            stale=$((stale + 1))
            ok=0
        fi
    fi
else
    echo "SKIP  docs/inventory.html: generator or page absent"
fi

echo "---"
echo "Summary: $checked generated docs pages checked, $stale stale vs their source"

[[ $ok -eq 1 ]] && exit 0 || exit 1
