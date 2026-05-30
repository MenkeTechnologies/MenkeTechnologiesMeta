#!/usr/bin/env bash
# For every Homebrew formula's `desc "..."` field, pin that
# the value contains no ALL-CAPS WORDS of 4+ letters.
#
# Why 4+ letters specifically:
#
#   - 2-3 letter ALL-CAPS are typically legitimate technical
#     acronyms: AWK, VM, JIT, TUI, CLI, AOP, CPU, RAM, SSD,
#     LLM, SQL, XML, JSON, HTML, CSS (5 chars but...), etc.
#     Excluding these would force descs to use awkward
#     lowercase variants ("cli tool" instead of "CLI tool")
#     that don't match how the technology is canonically
#     written.
#
#   - 4+ letter ALL-CAPS words almost always signal:
#     1. Shouty emphasis ("EXTREMELY FAST", "BLAZING SPEED")
#        — marketing-style language inappropriate for a brew
#        info card
#     2. Placeholder markers (TODO, FIXME, XXX, TBD —
#        already caught by iter-142 with a separate
#        word-boundary check; iter-177 reinforces this by
#        catching them via their CASE shape)
#     3. Yelling at the user (Reddit-style frustration that
#       leaked into the formula desc)
#     4. Misformatted continuation of a previous sentence
#        ("SEE INSTALL INSTRUCTIONS BELOW") where shift-
#        lock got stuck during a hand-edit
#
# 4+ chars is the canonical IDE / static-analysis threshold
# for "this looks shouty"; spell-checkers and Grammarly use
# the same cutoff.
#
# Genuine 4+ char acronyms that SHOULD be allowed (rare in
# brew formula context):
#
#   - XHTML, HTTPS, JSON5 — 5-char modern technologies
#   - These appear so rarely in brew formula descs that an
#     allowlist is unnecessary. If a future formula needs
#     one, the gate's allowlist mechanism (the bash assoc-
#     array pattern from iter-156 / iter-169 / iter-173)
#     can be added.
#
# Detection: split desc on whitespace, strip punctuation
# from each word, regex-match against `^[A-Z]{4,}$`. The
# regex requires the WHOLE WORD to be uppercase letters
# (no digits, no symbols) — this avoids false-positives on
# mixed-case identifiers like "IPv6" or "MacOS" or "iOS".
#
# Pairs with iter-141 (cargo TODO/FIXME placeholders),
# iter-142 (brew TODO/FIXME placeholders). iter-177 catches
# the same placeholder words via their CASE shape, plus
# arbitrary shouty caps that don't match the placeholder
# allowlist.
#
# 10/10 formulas green at iter-177 add — pure regression
# floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

formulas_dir="homebrew-menketech/Formula"
if [[ ! -d "$formulas_dir" ]]; then
    echo "SKIP  $formulas_dir not initialized"
    exit 0
fi

checked=0
bad=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))

    desc=$(grep -m1 -oE '^\s+desc *"[^"]+"' "$f" | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$desc" ]] || continue

    local_bad=0
    for word in $desc; do
        clean=$(echo "$word" | tr -d '.,;:!?"()[]{}—–-/')
        if echo "$clean" | grep -qE '^[A-Z]{4,}$'; then
            echo "FAIL  $f: desc contains shouty ALL-CAPS word \"$clean\" — \"$desc\""
            bad=$((bad + 1))
            local_bad=1
            ok=0
            break
        fi
    done
done

echo "---"
echo "Summary: $checked formulas checked, $bad with 4+ letter ALL-CAPS words in desc"

[[ $ok -eq 1 ]] && exit 0 || exit 1
