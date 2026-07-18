#!/usr/bin/env bash
set -euo pipefail

# collect-pdfs.sh — centralize every authored PDF across the whole MenkeTechnologies
# monorepo into ONE folder with a manifest + a sortable HTML catalog, so the full set is
# trackable in one place.
#
# Outputs, in MenkeTechnologiesPublications/all-pdfs/ :
#   MANIFEST.md   — page counts + category + source + built/code dates + staleness (tracked)
#   index.html    — the catalog page, mirroring the app-store template: it LINKS the
#                   canonical app-store HUD assets (../../app-store/hud-static.css ·
#                   tutorial.css · store.css · hud-theme.js — the 8-color-scheme theme) and
#                   renders the table with the zgui-core ZGui.dataTable component
#                   (../../zgui-core/webui/*): sortable columns, a per-row Open button, and a
#                   staleness ranking (PDF build date vs. last source-code change).
#                   Open it from inside the meta checkout so the relative links resolve.
#                   Only zgui-core UI is used — no hand-rolled widgets.
#   *.pdf         — the copies themselves (gitignored local browse-folder)
#
# Families gathered:
#   1. Publications books + reference manuals — MenkeTechnologiesPublications/<product>/docs/{book,reference}.pdf
#   2. Audio-plugin + UI manuals — app-store/docs/*.pdf (the published store mirror).
#
# Staleness = (last commit in the live source repo) − (last commit touching the PDF). If the
# code moved after the deliverable was built, the doc is behind by that many days.
#   built date : git last-commit of the PDF in its home repo (Publications or app-store).
#   code date  : git HEAD date of the live source repo ROOT/<product> (INVENTIONS.md for
#                the ledger; the book.md itself for the novels / desktop-in-rust).
#
# Deliberately EXCLUDED as third-party / vendored duplicates:
#   */build/*  */_deps/*  */node_modules/*  */vendor/*  */libs/*   (JUCE, CLAP, VST3 SDK,
#   the nested patch-core/clip-engine/ztranslator copies), and the app-store zmax-reference
#   mirror (identical to Publications/zmax — counted once, under Publications).
#
# Re-run any time (idempotent). Requires: bash, git, mdls + date (macOS).

ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUT="$ROOT/MenkeTechnologiesPublications/all-pdfs"
MANIFEST="$OUT/MANIFEST.md"

pages() { # deterministic via pdfinfo (poppler); mdls is a Spotlight-timing-dependent fallback
  local n=""
  if command -v pdfinfo >/dev/null 2>&1; then
    n=$(pdfinfo "$1" 2>/dev/null | awk '/^Pages:/{print $2; exit}')
  fi
  if [[ -z $n ]]; then
    n=$(mdls -name kMDItemNumberOfPages -raw "$1" 2>/dev/null | grep -Eo '^[0-9]+' || true)
    if [[ -z $n ]]; then mdimport "$1" 2>/dev/null || true
      n=$(mdls -name kMDItemNumberOfPages -raw "$1" 2>/dev/null | grep -Eo '^[0-9]+' || true); fi
  fi
  echo "${n:-0}"
}

category_for() {
  case "$1" in
    strykelang|zshrs|elisprs|awkrs|vimlrs|zmax) echo "Language reference" ;;
    fusevm|zterminal|powerliners|desktop-in-rust|inventions|ztmux|zwire|gui-automation-bus) echo "Companion" ;;
    zpwr) echo "Encyclopedia" ;;
    fantasy|scifi|scifi2|scifi3) echo "Novel" ;;
    zpwr-synth|zpwr-fx|zpwr-midi-fx|zpwr-daw|zpwr-patch-core|zpwr-clip-engine) echo "Audio / DSP" ;;
    zgui-core) echo "UI catalog" ;;
    *) echo "Other" ;;
  esac
}

# echo "<built_epoch>\t<code_epoch>" for a PDF given its ROOT-relative source path + product
dates_for() {
  local src=$1 prod=$2 brepo bfile built code md
  case "$src" in
    MenkeTechnologiesPublications/*) brepo="$ROOT/MenkeTechnologiesPublications"; bfile="${src#MenkeTechnologiesPublications/}";;
    app-store/*)                     brepo="$ROOT/app-store";                     bfile="${src#app-store/}";;
    *)                               brepo="$ROOT";                               bfile="$src";;
  esac
  built=$(git -C "$brepo" log -1 --format=%ct -- "$bfile" 2>/dev/null || true)
  built=${built:-0}
  # a freshly-regenerated but uncommitted PDF: trust its mtime if newer than the last commit,
  # so "Updated" reflects when the deliverable was actually produced.
  local mtime; mtime=$(stat -f %m "$ROOT/$src" 2>/dev/null || echo 0)
  (( mtime > built )) && built=$mtime

  code=""
  if [[ $prod == inventions ]]; then
    code=$(git -C "$ROOT" log -1 --format=%ct -- INVENTIONS.md 2>/dev/null || true)
  elif [[ -e "$ROOT/$prod/.git" ]]; then
    code=$(git -C "$ROOT/$prod" log -1 --format=%ct 2>/dev/null || true)
  fi
  if [[ -z $code ]]; then            # novels / desktop-in-rust: the book.md is the source
    md="${bfile%.pdf}.md"
    code=$(git -C "$brepo" log -1 --format=%ct -- "$md" 2>/dev/null || true)
  fi
  [[ -z $code ]] && code=$built
  echo "$built	$code"
}

rm -rf "$OUT"; mkdir -p "$OUT"
cat > "$OUT/.gitignore" <<'GI'
# regenerable copies — rebuild with scripts/collect-pdfs.sh
*.pdf
GI

# rows: pages<TAB>category<TAB>destname<TAB>source-relpath<TAB>built_epoch<TAB>code_epoch
rows=()
declare -A have_dest   # destname -> 1, so mirror copies are counted once (see app-store loop)
copy() { # src  destname  product
  local src=$1 dest=$2 prod=$3 d
  [[ -f $src ]] || { echo "  ! missing: $src" >&2; return 0; }
  cp -f "$src" "$OUT/$dest"
  d=$(dates_for "${src#$ROOT/}" "$prod")
  rows+=("$(pages "$src")	$(category_for "$prod")	$dest	${src#$ROOT/}	$d")
  have_dest[$dest]=1
}

echo "collecting Publications books + references…"
for dir in "$ROOT"/MenkeTechnologiesPublications/*/; do
  prod=$(basename "$dir")
  [[ $prod == all-pdfs || $prod == docs || $prod == src || $prod == tests ]] && continue
  dir=${dir%/}
  [[ -f "$dir/docs/book.pdf"      ]] && copy "$dir/docs/book.pdf"      "$prod-book.pdf"      "$prod"
  [[ -f "$dir/docs/reference.pdf" ]] && copy "$dir/docs/reference.pdf" "$prod-reference.pdf" "$prod"
done

echo "collecting audio-plugin + UI manuals (app-store mirror)…"
for f in "$ROOT"/app-store/docs/*.pdf; do
  [[ -f $f ]] || continue
  base=$(basename "$f")
  # app-store/docs mirrors every Publications book/reference (elisprs-book, zshrs-book,
  # zmax-reference, …). Those were already collected above from Publications, which is the
  # canonical home; skip the mirror so each authored PDF is counted exactly once. Only the
  # app-store-ONLY deliverables (the audio-plugin manuals + zgui-core) survive this filter.
  [[ -n ${have_dest[$base]:-} ]] && continue
  prod=${base%-reference.pdf}; prod=${prod%-block-catalog.pdf}; prod=${prod%-component-catalog.pdf}
  copy "$f" "$base" "$prod"
done

# ---- derive display rows: stale_days<TAB>pages<TAB>cat<TAB>dest<TAB>src<TAB>updated<TAB>codedate ----
total_pages=0; count=0; stale_count=0
drows=()
for r in "${rows[@]}"; do
  IFS=$'\t' read -r pg cat dest src built code <<< "$r"
  total_pages=$(( total_pages + pg )); count=$(( count + 1 ))
  st=$(( (code - built) / 86400 )); (( st < 0 )) && st=0
  (( st > 0 )) && stale_count=$(( stale_count + 1 ))
  if (( built > 0 )); then ui=$(date -r "$built" +%Y-%m-%d); else ui="—"; fi
  if (( code  > 0 )); then ci=$(date -r "$code"  +%Y-%m-%d); else ci="—"; fi
  drows+=("$st	$pg	$cat	$dest	$src	$ui	$ci")
done
catcount=$(printf '%s\n' "${rows[@]}" | cut -f2 | sort -u | wc -l | tr -d ' ')

# ---- write MANIFEST.md (ranked by staleness) ----
{
  echo "# MenkeTechnologies — Central PDF Catalog"
  echo
  echo "Every authored PDF across the stack, gathered here by \`scripts/collect-pdfs.sh\`."
  echo "Browse it visually in \`index.html\` (app-store HUD + a sortable zgui-core table)."
  echo "Ranked by **staleness** = days the built PDF is behind the last source-code change."
  echo
  echo "**$count PDFs · $total_pages pages · $catcount categories · $stale_count stale.**"
  echo
  echo "| Stale (d) | Document | Category | Pages | Updated | Code changed | Source |"
  echo "|----------:|----------|----------|------:|---------|--------------|--------|"
  printf '%s\n' "${drows[@]}" | sort -t$'\t' -k1,1 -rn | while IFS=$'\t' read -r st pg cat dest src ui ci; do
    echo "| $st | \`$dest\` | $cat | $pg | $ui | $ci | \`$src\` |"
  done
  echo
  echo "_Generated by \`scripts/collect-pdfs.sh\`; do not edit by hand._"
} > "$MANIFEST"

# ---- write index.html (app-store HUD template + zgui-core ZGui.dataTable) ----
HTML="$OUT/index.html"
{
  cat <<HTML_HEAD
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="dark light">
  <title>MenkeTechnologies — PDF Catalog</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;600;700;900&amp;family=Share+Tech+Mono&amp;display=swap" rel="stylesheet">
  <link rel="stylesheet" href="../../app-store/hud-static.css">
  <link rel="stylesheet" href="../../app-store/tutorial.css">
  <link rel="stylesheet" href="../../app-store/store.css">
  <link rel="stylesheet" href="../../zgui-core/webui/data-table.css">
  <style>
    .tutorial-main { max-width: 84rem; }
    .hub-scheme-strip { border-bottom:1px dashed var(--border); background:color-mix(in srgb, var(--bg-secondary) 85%, transparent); padding:0.55rem 1.5rem 0.65rem; position:relative; }
    .hub-scheme-strip-inner { max-width:84rem; margin:0 auto; display:flex; align-items:center; gap:0.85rem; }
    .hub-scheme-strip .hud-scheme-label { flex:0 0 auto; font-family:'Orbitron',sans-serif; font-size:9px; font-weight:700; letter-spacing:2px; text-transform:uppercase; color:var(--accent); text-align:left; }
    .hub-scheme-strip .scheme-grid { flex:1 1 auto; display:grid; grid-template-columns:repeat(8,minmax(0,1fr)); gap:6px; }
    @media (max-width:720px){ .hub-scheme-strip-inner{flex-direction:column;align-items:stretch;} .hub-scheme-strip .scheme-grid{grid-template-columns:repeat(2,minmax(0,1fr));} }
    .cat-wrap { overflow-x:auto; border:1px solid var(--border); border-radius:2px; background:var(--bg-card); margin-top:1rem; }
    #tableHost .zg-datatable { min-width:860px; }
    .pg-cell { display:flex; align-items:center; gap:9px; justify-content:flex-end; }
    .pg-bar { height:7px; background:var(--cyan); border-radius:2px; box-shadow:0 0 6px var(--cyan-glow); min-width:2px; }
    .pg-n { min-width:44px; text-align:right; font-family:'Share Tech Mono',monospace; color:var(--text); }
    td .btn-open { display:inline-block; font-family:'Orbitron',sans-serif; font-size:9.5px; font-weight:700; letter-spacing:1px; text-transform:uppercase; text-decoration:none; color:var(--bg-primary); background:var(--cyan); padding:3px 11px; border-radius:2px; white-space:nowrap; }
    td .btn-open:hover { background:var(--magenta); color:#fff; }
    .zg-datatable td .doc-t { color:var(--text); }
    .zg-datatable td .cat-t { color:var(--magenta); font-size:11px; font-family:'Share Tech Mono',monospace; }
    .zg-datatable td .src-t { color:var(--text-muted); font-size:11px; font-family:'Share Tech Mono',monospace; }
    .zg-datatable td .date-t { font-family:'Share Tech Mono',monospace; font-size:11px; color:var(--text-dim); }
    .stale-badge { font-family:'Share Tech Mono',monospace; font-size:10.5px; padding:2px 9px; border-radius:11px; white-space:nowrap; }
    .stale-badge.ok   { color:var(--green); border:1px solid color-mix(in srgb, var(--green) 40%, transparent); }
    .stale-badge.warn { color:#ffcf3f;      border:1px solid rgba(255,207,63,0.45); }
    .stale-badge.bad  { color:var(--red);   border:1px solid color-mix(in srgb, var(--red) 50%, transparent); }
  </style>
</head>
<body>
  <div class="app tutorial-app" id="docsApp">
    <div class="crt-scanline" id="crtH" aria-hidden="true"></div>
    <div class="crt-scanline-v" id="crtV" aria-hidden="true"></div>

    <header class="tutorial-header">
      <div class="tutorial-header-inner">
        <div>
          <h1 class="tutorial-brand">// MENKETECHNOLOGIES — PDF CATALOG 📚</h1>
          <nav class="tutorial-crumbs" aria-label="Breadcrumb">
            <a href="../../app-store/index.html">Store</a>
            <span class="sep">/</span>
            <a href="../docs/index.html">Publications</a>
            <span class="sep">/</span>
            <span class="current">PDF Catalog</span>
            <span class="sep">/</span>
            <a href="https://github.com/MenkeTechnologies" target="_blank" rel="noopener noreferrer">GitHub</a>
          </nav>
          <p class="docs-build-line">Every authored PDF · ranked by staleness (build date vs. last code change) · generated by scripts/collect-pdfs.sh</p>
        </div>
        <div class="tutorial-toolbar">
          <button type="button" class="btn btn-secondary" id="btnTheme" title="Toggle light/dark">Theme</button>
          <button type="button" class="btn btn-secondary active" id="btnCrt" title="CRT scanline overlay">CRT</button>
          <button type="button" class="btn btn-secondary active" id="btnNeon" title="Neon border pulse">Neon</button>
          <a class="btn btn-secondary" href="../../app-store/index.html">Store</a>
        </div>
      </div>
    </header>

    <div class="hub-scheme-strip">
      <div class="hub-scheme-strip-inner">
        <span class="hud-scheme-label">// Color scheme</span>
        <div class="scheme-grid" id="hudSchemeGrid"></div>
      </div>
    </div>

    <main class="tutorial-main">
      <section class="store-hero">
        <h2><span class="hash">&gt;_</span>The Paper Trail for the Stack</h2>
        <p>Every authored PDF in one sortable table — companion books, language reference manuals, the zpwr encyclopedia, four novels, and the audio-plugin / UI manuals. Ranked by <strong>staleness</strong>: how many days the built PDF trails the last change in its source repo. Click a header to sort; hit <strong>Open</strong> to read.</p>
        <div class="hero-stats">
          <div class="hero-stat"><span class="num">$count</span><span class="lbl">PDFs</span></div>
          <div class="hero-stat"><span class="num">$total_pages</span><span class="lbl">Pages</span></div>
          <div class="hero-stat"><span class="num">$catcount</span><span class="lbl">Categories</span></div>
          <div class="hero-stat"><span class="num">$stale_count</span><span class="lbl">Stale</span></div>
        </div>
      </section>

      <div class="cat-wrap"><div id="tableHost"></div></div>
    </main>

    <footer class="tutorial-main doc-footer" style="padding-top:0;">
      MenkeTechnologies · All software © MenkeTechnologies · Built with the stryke HUD design system
    </footer>
  </div>

  <script src="../../zgui-core/webui/sort-state.js"></script>
  <script src="../../zgui-core/webui/table.js"></script>
  <script src="../../zgui-core/webui/data-table.js"></script>
  <script src="../../app-store/hud-theme.js"></script>
  <script>
const DATA=[
HTML_HEAD
  printf '%s\n' "${drows[@]}" | while IFS=$'\t' read -r st pg cat dest src ui ci; do
    printf '{"pages":%s,"doc":"%s","cat":"%s","src":"%s","updated":"%s","code":"%s","stale":%s},\n' \
      "$pg" "$dest" "$cat" "$src" "$ui" "$ci" "$st"
  done
  cat <<'HTML_TAIL'
];
const MAXP = Math.max.apply(null, DATA.map(function(d){ return d.pages; }));
function staleCell(d){
  var cls = d <= 0 ? "ok" : (d <= 30 ? "warn" : "bad");
  var txt = d <= 0 ? "✓ current" : (d + "d behind");
  return '<span class="stale-badge '+cls+'">'+txt+'</span>';
}
const cols = [
  { key:"doc",     label:"Document",     render:function(r){ return '<span class="doc-t">'+r.doc+'</span>'; } },
  { key:"cat",     label:"Category",     render:function(r){ return '<span class="cat-t">'+r.cat+'</span>'; } },
  { key:"pages",   label:"Pages",        render:function(r){
      var w = Math.max(2, Math.round(r.pages / MAXP * 130));
      return '<span class="pg-cell"><span class="pg-bar" style="width:'+w+'px"></span><span class="pg-n">'+r.pages+'</span></span>'; } },
  { key:"updated", label:"Updated",      render:function(r){ return '<span class="date-t">'+r.updated+'</span>'; } },
  { key:"code",    label:"Code changed", render:function(r){ return '<span class="date-t">'+r.code+'</span>'; } },
  { key:"stale",   label:"Staleness",    render:function(r){ return staleCell(r.stale); } },
  { key:"src",     label:"Source",       render:function(r){ return '<span class="src-t">'+r.src+'</span>'; } },
  { key:"open",    label:"",             sortable:false, render:function(r){
      return '<a class="btn-open" href="'+r.doc+'" target="_blank" rel="noopener">Open &#8599;</a>'; } }
];
var api = window.ZGui.dataTable("#tableHost", {
  id:"pdfCatalog", columns:cols, rows:DATA, sortScope:"pdf-catalog", resizable:true
});
// default view: most-stale first (the ranking)
if (!api.getSort().key) { api.sort("stale"); api.sort("stale"); }
  </script>
</body>
</html>
HTML_TAIL
} > "$HTML"

echo
echo "wrote $count PDFs ($total_pages pages, $catcount categories, $stale_count stale) → ${OUT#$ROOT/}/"
echo "manifest → ${MANIFEST#$ROOT/}"
echo "html     → ${HTML#$ROOT/}"
