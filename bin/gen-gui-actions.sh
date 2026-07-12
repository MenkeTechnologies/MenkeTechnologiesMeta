#!/usr/bin/env bash
# gen-gui-actions.sh — regenerate GUI_SCRIPT_ACTIONS.md: a global catalog of every
# scriptable GUI-Script action (automation-bus verb) exposed by every GUI app.
#
# Each app's scriptable surface is what `App::open("<app>")->verbs()` returns over the
# GUI Automation Bus (see GUI_AUTOMATION_BUS.md): the app-owned engine command list plus
# the shared appShell verbs every app inherits from zgui-core.
#
# The verb lists are the SOURCE OF TRUTH in each app's own repo — this script only reads
# them (at origin/main, the freshest published surface) and renders the catalog. Never
# hand-edit GUI_SCRIPT_ACTIONS.md; run this. From the meta repo root:
#   ./bin/gen-gui-actions.sh
set -euo pipefail
cd "$(dirname "$0")/.."
OUT=GUI_SCRIPT_ACTIONS.md

# app | submodule | verb-source file (read at origin/main) | one-line surface description
APPS=(
  "zcite|zcite|crates/zcite-core/src/commands.rs|Zotero-style reference manager — library, collections, citations, PDF, sync"
  "zreq|zreq-core|src/commands.rs|Postman-style API client — requests, collections, auth, codegen, gRPC/WebSocket"
  "zemail|zemail-core|src/commands.rs|Thunderbird-style mail client — accounts, folders, messages, PGP/S-MIME, search"
  "zftp|zftp-core|src/commands.rs|Cyberduck-style transfer client — FTP/SFTP/WebDAV/S3/cloud, transfers, sync"
  "zoffice|zoffice-core|src/commands.rs|LibreOffice-style office engine — writer/calc/impress over ODF/OOXML"
  "zpdf|zpdf-core|src/commands.rs|Acrobat/Preview-style PDF engine — render, edit, annotate, forms, OCR, redact"
  "zthrottle|zthrottle-core|src/commands.rs|System monitor / process & network throttling"
  "ztunnel|ztunnel-core|src/commands.rs|Tunnelblick-style VPN client — OpenVPN / WireGuard config + control"
  "zgo|zgo-core|src/syscommands.rs|Alfred-style launcher — script-filter workflows and system commands"
  "zphoto|zphoto-core|DISPATCH:src|Photoshop + Illustrator-style raster & vector editor — layers, filters, paths, actions, smart objects"
  "zcontainer|zcontainer-core|DISPATCH:src|Docker Desktop + Lens-style container / Kubernetes manager — containers, images, volumes, compose, analyze, kube"
  "zstation|zstation-core|DISPATCH:src|Station-style multi-app workspace — boards, tiles, panes"
  "zwire|zwire-host|src/zbus.rs|Chromium-superset browser — tabs, windows, tab-groups, downloads, reading list, power"
  "traderview|traderview|frontend/js/zg-automation.js|TradingView-style charting/trading terminal — the ⌘K palette catalog registered as bus verbs (view tiles + shortcut actions)"
)

esc() { printf '%s' "$1"; }

# Extract verb strings from a source file's content on stdin.
# For zbus.rs (zwire) we only want the SURFACE_VERBS array (skip JSON protocol keys).
extract_verbs() {
  local file="$1"
  if [[ "$file" == *zbus.rs ]]; then
    # zwire host: the SURFACE_VERBS array (browser.* + host fs/exec/clipboard verbs)
    awk '/SURFACE_VERBS/{f=1} f{print} /^\];/{if(f)exit}' \
      | grep -oE '"[a-z][a-zA-Z0-9_.]+"' | tr -d '"'
  elif [[ "$file" == *syscommands.rs ]]; then
    # zgo: SysCommand structs keyed by `id: "..."`
    grep -oE 'id:[[:space:]]*"[a-z][a-zA-Z0-9_.]*"' | grep -oE '"[^"]+"' | tr -d '"'
  else
    grep -oE '^[[:space:]]*"[a-z][a-zA-Z0-9_.]*",?$' | grep -oE '"[^"]+"' | tr -d '"'
  fi
}

# traderview has no `-core` engine; its bus surface is the webview command catalog
# (frontend/js/zg-automation.js), which registers the STABLE `view:` tiles + `action:`
# shortcuts (ephemeral recents/favs/bookmarks dropped — its buildVerbs filter). Rebuild
# exactly that set from source: launcher.js TILES (id = element 0) and _shortcuts.js ids.
tv_verbs() {
  local sub="$1"
  git -C "$sub" show origin/main:frontend/js/views/launcher.js 2>/dev/null \
    | awk '/export const TILES = \[/{f=1;next} f&&/^\];/{exit} f' \
    | grep -oE "^[[:space:]]*\[[[:space:]]*['\"][^'\"]+" | grep -oE "['\"][^'\"]+$" | tr -d "\"'" | sed 's/^/view:/'
  git -C "$sub" show origin/main:frontend/js/_shortcuts.js 2>/dev/null \
    | grep -oE "id:[[:space:]]*['\"][^'\"]+['\"]" | grep -oE "['\"][^'\"]+['\"]\$" | tr -d "\"'" | sed 's/^/action:/'
}

# --- shared appShell verbs (every app inherits these from zgui-core) ---
APPSHELL=$(git -C zgui-core show origin/main:webui/app-shell.js 2>/dev/null \
  | grep -oE 'id:[[:space:]]*"appshell\.[a-zA-Z0-9_.]+"' \
  | grep -oE '"[^"]+"' | tr -d '"' | sort -u || true)
APPSHELL_N=$(printf '%s\n' "$APPSHELL" | grep -c . || true)

# --- gather per-app verbs into temp files, compute totals ---
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
GRAND=0
declare -a ROWS
for entry in "${APPS[@]}"; do
  IFS='|' read -r app sub file desc <<<"$entry"
  if [[ "$app" == traderview ]]; then
    tv_verbs "$sub" | sort -u > "$tmp/$app" || true
  elif [[ "$file" == DISPATCH:* ]]; then
    # Cores whose bus verbs are a multi-file `"ns.verb" => handler` match dispatch (zphoto/zcontainer/
    # zstation), not a single `commands.rs` verb list. Read every .rs under the given dir at origin/main
    # and collect the distinct namespaced (dotted) dispatch keys — the engine's real command surface,
    # reachable over the bus via the app's `*_invoke` bridge.
    dir="${file#DISPATCH:}"
    git -C "$sub" ls-tree -r --name-only origin/main -- "$dir" 2>/dev/null | grep '\.rs$' | while IFS= read -r rf; do
      git -C "$sub" show "origin/main:$rf" 2>/dev/null
    done | grep -oE '"[a-z][a-z0-9_]*\.[a-z0-9_.]+"[[:space:]]*=>' | grep -oE '"[^"]+"' | tr -d '"' | sort -u > "$tmp/$app" || true
  else
    git -C "$sub" show "origin/main:$file" 2>/dev/null | extract_verbs "$file" | sort -u > "$tmp/$app" || true
  fi
  n=$(grep -c . "$tmp/$app" || true)
  GRAND=$((GRAND + n))
  ROWS+=("$app|$sub|$file|$desc|$n")
done
TOTAL=$((GRAND + APPSHELL_N))
NAPPS=${#APPS[@]}
DATE="${GUI_ACTIONS_DATE:-$(date -u +%Y-%m-%d 2>/dev/null || echo unknown)}"

# --- render ---
{
  echo "# GUI Script Actions — Global Catalog"
  echo
  echo "Every scriptable **GUI-Script action** (automation-bus verb) exposed by every MenkeTechnologies"
  echo "GUI app. This is the surface a stryke script drives over the [GUI Automation Bus](GUI_AUTOMATION_BUS.md):"
  echo "\`App::open(\"<app>\")->verbs()\` returns an app's engine verbs, and every app additionally inherits the"
  echo "shared **appShell** verbs from \`zgui-core\`."
  echo
  echo "**$TOTAL actions** across **$NAPPS apps** + $APPSHELL_N shared appShell verbs. Generated \`$DATE\` from each"
  echo "app's verb source at \`origin/main\` by \`bin/gen-gui-actions.sh\` — do not hand-edit."
  echo
  echo "| App | Engine verbs | Source of truth | Surface |"
  echo "| --- |:--:| --- | --- |"
  for row in "${ROWS[@]}"; do
    IFS='|' read -r app sub file desc n <<<"$row"
    echo "| [\`$app\`](#$app) | $n | \`$sub/${file#DISPATCH:}\` | $desc |"
  done
  echo "| **appShell** (shared) | $APPSHELL_N | \`zgui-core/webui/app-shell.js\` | Terminal, file browser, hooks, palette, theme / CRT / neon toggles — on every app |"
  echo
  echo "---"
  echo
  echo "## appShell — shared verbs (present on every app)"
  echo
  echo '```'
  printf '%s\n' "$APPSHELL"
  echo '```'
  echo

  for row in "${ROWS[@]}"; do
    IFS='|' read -r app sub file desc n <<<"$row"
    echo "---"
    echo
    echo "## $app"
    echo
    echo "$desc  "
    echo "**$n verbs** · source \`$sub/${file#DISPATCH:}\` · call as \`App::open(\"$app\")->call(\"<verb>\", %args)\`"
    echo
    # group by namespace prefix (text before first '.'); non-dotted verbs go under "(top-level)"
    prefixes=$(awk -F. '{print (NF>1?$1:"(top-level)")}' "$tmp/$app" | sort -u)
    while IFS= read -r pfx; do
      [ -z "$pfx" ] && continue
      if [ "$pfx" = "(top-level)" ]; then
        members=$(grep -vE '\.' "$tmp/$app" || true)
      else
        members=$(grep -E "^${pfx}\." "$tmp/$app" || true)
      fi
      cnt=$(printf '%s\n' "$members" | grep -c . || true)
      echo "**\`$pfx\`** ($cnt)"
      echo
      echo '```'
      printf '%s\n' "$members"
      echo '```'
      echo
    done <<<"$prefixes"
  done

  echo "---"
  echo
  echo "## Notes"
  echo
  echo "- **Dispatch-core apps** (\`zphoto\`, \`zcontainer\`, \`zstation\`) expose their engine verbs as a multi-file"
  echo "  \`\"ns.verb\" => handler\` match dispatch in their \`-core\` (not a single \`commands.rs\` list); the count is"
  echo "  the distinct namespaced dispatch keys, reachable over the bus via each app's \`*_invoke\` bridge."
  echo "- **Forward-only apps** (\`ztranslator\`, \`Audio-Haxor\`) have no namespaced verb dispatch — their core is a"
  echo "  typed-function library and the bus forwards to the webview's \`ZGui.automation\` surface; only the appShell"
  echo "  verbs are enumerated here."
  echo "- Each app's \`bus.rs\` is a **hybrid** handler: engine verbs route straight to the \`-core\` engine;"
  echo "  \`appshell.*\` and any \`ZGui.automation\`-registered verb forward to the webview. \`call\` accepts any"
  echo "  registered verb even if discovery does not list it (e.g. zwire's \`browser.*\` executor)."
  echo "- Counts are derived at generation time from the verb source; they move as the apps evolve."
} > "$OUT"

echo "wrote $OUT — $TOTAL actions ($NAPPS apps + $APPSHELL_N appShell)"
