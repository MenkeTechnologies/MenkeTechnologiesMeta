#!/usr/bin/env bash
# bp.sh — MenkeTechnologiesPublications release (run from the meta checkout).
#
# Regenerates only the STALE book/reference PDFs (source committed after the PDF
# was built, per the manifest's staleness metric), publishes them to app-store/docs
# and to a GitHub release, bumps VERSION, and pushes across the affected repos.
#
#   1. collect-pdfs.sh            -> manifest with per-PDF staleness (git-based)
#   2. rebuild every stale PDF    (or all with --all); fail-fast, never tag a broken set
#   3. collect-pdfs.sh again      -> fresh manifest + uniquely-named all-pdfs/ copies
#   4. mirror rebuilt PDFs        -> app-store/docs/<product>-<kind>.pdf  (store display)
#   5. bump VERSION, commit+tag+push publications
#   6. commit+push the app-store mirror
#   7. gh release v<NEW>          on publications, PDFs attached (uniquely named)
#   8. bump meta submodule pointers (publications + app-store) forward-only
#
# Usage:  scripts/bp.sh [patch|minor|major|X.Y.Z] [--all]     (default: patch)
set -euo pipefail

META=$(cd "$(dirname "$0")/.." && pwd)
PUB="$META/MenkeTechnologiesPublications"
AS="$META/app-store"
REPO="MenkeTechnologies/MenkeTechnologiesPublications"
cd "$META"
die() { echo "bp: $*" >&2; exit 1; }

FORCE=0; LEVEL=patch
for a in "$@"; do
  case "$a" in
    --all) FORCE=1 ;;
    patch|minor|major|[0-9]*.[0-9]*.[0-9]*) LEVEL=$a ;;
    *) die "bad arg '$a' (want patch|minor|major|X.Y.Z [--all])" ;;
  esac
done

command -v gh >/dev/null || die "gh CLI not found"

# --- branch safety: every repo we touch must be on main at origin/main ---
for r in "$META" "$PUB" "$AS"; do
  git -C "$r" fetch origin --quiet
  [ "$(git -C "$r" rev-parse --abbrev-ref HEAD)" = main ] || die "$(basename "$r") not on main"
  [ "$(git -C "$r" rev-parse HEAD)" = "$(git -C "$r" rev-parse origin/main)" ] \
    || die "$(basename "$r") not at origin/main — reconcile first"
done

# --- 1. manifest + staleness ---
echo ">> collect-pdfs (staleness scan)"
bash "$META/scripts/collect-pdfs.sh" >/dev/null
MAN="$PUB/all-pdfs/MANIFEST.md"

# --- 2. select what to rebuild ---
builds=()
if (( FORCE )); then
  # --all: books from their book.md SOURCE (so newly-added books like znative are
  # built even before a PDF exists); references from existing reference.pdf (skips
  # aspirational stubs with no output, e.g. fusevm:reference — no gen-docs bin).
  for m in "$PUB"/*/docs/book.md;       do [ -f "$m" ] && builds+=("$(basename "$(dirname "$(dirname "$m")")"):book"); done
  for p in "$PUB"/*/docs/reference.pdf; do [ -f "$p" ] && builds+=("$(basename "$(dirname "$(dirname "$p")")"):reference"); done
else
  while IFS= read -r line; do
    [[ $line =~ ^\|[[:space:]]*([0-9]+)[[:space:]]*\|.*\`MenkeTechnologiesPublications/([^/]+)/docs/(book|reference)\.pdf\` ]] || continue
    (( ${BASH_REMATCH[1]} > 0 )) && builds+=("${BASH_REMATCH[2]}:${BASH_REMATCH[3]}")
  done < "$MAN"
fi

if (( ${#builds[@]} == 0 )); then
  echo "bp: no stale PDFs — nothing to release (use --all to force a full rebuild)"
  exit 0
fi
echo "bp: rebuilding ${#builds[@]} PDF(s): ${builds[*]}"

# --- 3. rebuild (fail-fast) ---
rebuilt=(); fails=()
for b in "${builds[@]}"; do
  prod=${b%%:*}; kind=${b##*:}
  s="$PUB/$prod/scripts/${kind}_pdf.sh"
  [ -f "$s" ] || { fails+=("$b (no build script)"); continue; }
  echo ">> build $prod/$kind"
  if bash "$s" >/dev/null 2>&1; then rebuilt+=("$b"); else fails+=("$b"); fi
done
if (( ${#fails[@]} )); then
  { printf 'bp: %d build(s) FAILED — aborting (no tag, no release):\n' "${#fails[@]}"
    printf '  %s\n' "${fails[@]}"; } >&2
  exit 1
fi

# --- 4. fresh manifest + uniquely-named all-pdfs/ copies ---
echo ">> collect-pdfs (rebuild manifest)"
bash "$META/scripts/collect-pdfs.sh" >/dev/null

# --- 5. mirror rebuilt PDFs into app-store/docs (store display copies) ---
for b in "${rebuilt[@]}"; do
  prod=${b%%:*}; kind=${b##*:}
  cp -f "$PUB/$prod/docs/${kind}.pdf" "$AS/docs/${prod}-${kind}.pdf"
done

# --- 6. version bump ---
CUR=$(cat "$PUB/VERSION")
IFS=. read -r MA MI PA <<<"$CUR"
case "$LEVEL" in
  major) MA=$((MA + 1)); MI=0; PA=0 ;;
  minor) MI=$((MI + 1)); PA=0 ;;
  patch) PA=$((PA + 1)) ;;
  *) MA=${LEVEL%%.*}; rest=${LEVEL#*.}; MI=${rest%%.*}; PA=${rest##*.} ;;
esac
NEW="$MA.$MI.$PA"
echo "$NEW" > "$PUB/VERSION"
echo "bp: v$CUR -> v$NEW"

# --- 7. commit + tag + push publications (explicit paths) ---
cd "$PUB"
git add VERSION all-pdfs/MANIFEST.md
for b in "${rebuilt[@]}"; do
  prod=${b%%:*}; kind=${b##*:}
  git add "$prod/docs/${kind}.pdf" 2>/dev/null || true
  [ -f "$prod/docs/${kind}.tex" ] && git add "$prod/docs/${kind}.tex"
done
git commit -m "release v$NEW: regen ${#rebuilt[@]} stale PDF(s)"
git tag -a "v$NEW" -m "MenkeTechnologiesPublications v$NEW"
git push origin main --follow-tags

# --- 8. commit + push app-store mirror ---
cd "$AS"
for b in "${rebuilt[@]}"; do prod=${b%%:*}; kind=${b##*:}; git add "docs/${prod}-${kind}.pdf" 2>/dev/null || true; done
if ! git diff --cached --quiet; then
  git commit -m "docs: publish Publications v$NEW PDFs (store mirror)"
  git push origin main
fi

# --- 9. GitHub release with uniquely-named assets (all-pdfs/ copies) ---
assets=()
for b in "${rebuilt[@]}"; do prod=${b%%:*}; kind=${b##*:}; assets+=("$PUB/all-pdfs/${prod}-${kind}.pdf"); done
if gh release view "v$NEW" --repo "$REPO" >/dev/null 2>&1; then
  gh release upload "v$NEW" "${assets[@]}" --repo "$REPO" --clobber
else
  gh release create "v$NEW" "${assets[@]}" --repo "$REPO" \
    --title "Publications v$NEW" --notes "Regenerated ${#rebuilt[@]} stale PDF(s)."
fi

# --- 10. bump meta submodule pointers forward-only ---
cd "$META"
git add MenkeTechnologiesPublications app-store
if ! git diff --cached --quiet; then
  git commit -m "publications: release v$NEW; app-store PDF mirror"
  git push origin main
fi

echo "bp: released v$NEW — ${#rebuilt[@]} PDF(s), app-store mirror, gh release."
