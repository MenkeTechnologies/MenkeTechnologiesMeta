#!/usr/bin/env bash
# For every docs/*.html across the umbrella, pin that every
# `<img>` tag declares an `alt` attribute (value may be empty
# for decorative images per HTML5 / WCAG 2.1 1.1.1).
#
# Missing `alt` is a WCAG Level A failure — screen readers
# either announce the image filename verbatim ("port_report
# dot png") or skip silently depending on the reader; either
# way the user gets no signal about what the image conveys.
# Lighthouse accessibility audits give the page a hard FAIL.
#
# Why alt="" is OK and intentional:
#   - HTML5 spec says `alt=""` marks an image as DECORATIVE
#     (no semantic content; screen reader skips it without
#     announcing). 98/119 imgs in docs/ use this — typically
#     SVG icons paired with adjacent text labels.
#   - WCAG 2.1 1.1.1 explicitly accepts `alt=""` for decorative
#     images.
#   - Lighthouse only flags MISSING alt, not empty alt.
#
# Gate enforces: every `<img>` tag must have an `alt` attribute
# present. Value may be anything (empty OK, descriptive
# preferred). The check uses `alt=` substring presence which
# matches both `alt=""` and `alt="..."`.
#
# 119/119 imgs across 894 docs files have alt at iter-95 add —
# pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked_files=0
total_imgs=0
missing=0

while IFS= read -r f; do
    [[ -f "$f" ]] || continue
    checked_files=$((checked_files + 1))
    while IFS= read -r img; do
        [[ -z "$img" ]] && continue
        total_imgs=$((total_imgs + 1))
        if ! echo "$img" | grep -qE 'alt='; then
            echo "FAIL  $f: <img> tag missing alt attribute: $img"
            missing=$((missing + 1))
            ok=0
        fi
    done < <(grep -oE '<img[^>]*>' "$f" 2>/dev/null || true)
done < <(find . -path './.git' -prune -o -path './MenkeTechnologiesPublications' -prune -o -type f -path '*/docs/*.html' -print 2>/dev/null)

echo "---"
echo "Summary: $checked_files docs/*.html files, $total_imgs <img> tags checked, $missing without alt attribute"

[[ $ok -eq 1 ]] && exit 0 || exit 1
