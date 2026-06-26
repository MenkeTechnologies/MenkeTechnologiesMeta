#!/usr/bin/env bash
set -euo pipefail

# Regenerate every MenkeTechnologies GUI app icon from the one shared brand
# template (bin/gen-app-icon.sh), so all apps share zterm's icon geometry and
# differ only by accent hue + glyph + wordmark.
#
#   bin/gen-all-icons.sh [app ...]   # all apps, or a subset by name
#
# zterm itself is the reference and is left untouched (it has its own
# icons/gen_icons.sh). Tauri apps get their full icon set via `cargo tauri
# icon` (only the files each app already ships are copied back, preserving
# inventory); JUCE apps get resources/AppIcon.icns built with iconutil.

ROOT=$(cd "$(dirname "$0")/.." && pwd)
GEN=$ROOT/bin/gen-app-icon.sh
TMP=$(mktemp -d -t mtech_icons.XXXXXX)
trap 'command rm -rf "$TMP"' EXIT

command -v cargo-tauri >/dev/null || command -v tauri >/dev/null || {
  echo "tauri CLI not found (cargo install tauri-cli)" >&2; exit 1; }
tauri_icon() { if command -v cargo-tauri >/dev/null; then cargo tauri icon "$@"; else tauri icon "$@"; fi; }

# app | kind | accent | glyph | wordmark | path
#   kind: tauri  -> path is the icons dir
#         juce   -> path is the resources dir (AppIcon.icns)
#         daw    -> zpwr-daw special layout
MANIFEST=(
  "Audio-Haxor|tauri|#00e5ff|AH|AUDIO HAXOR|Audio-Haxor/src-tauri/icons"
  "traderview|tauri|#19ff8c|TV|TRADERVIEW|traderview/src-tauri/icons"
  "zoffice|tauri|#05d9e8|ZO|ZOFFICE|zoffice/src-tauri/icons"
  "zpdf|tauri|#ff073a|PDF|ZPDF|zpdf/src-tauri/icons"
  "zcite|tauri|#ffb000|CITE|ZCITE|zcite/app/src-tauri/icons"
  "zcontainer|tauri|#2979ff|ZC|ZCONTAINER|zcontainer/app/src-tauri/icons"
  "zemail|tauri|#ff6f00|EM|ZEMAIL|zemail/app/src-tauri/icons"
  "zftp|tauri|#39ff14|FTP|ZFTP|zftp/app/src-tauri/icons"
  "zgo|tauri|#d300c5|GO|ZGO|zgo/app/src-tauri/icons"
  "zreq|tauri|#ffea00|REQ|ZREQ|zreq/app/src-tauri/icons"
  "ztranslator|tauri|#1de9b6|TR|ZTRANSLATOR|ztranslator/app/src-tauri/icons"
  "ztunnel|tauri|#7c4dff|TUN|ZTUNNEL|ztunnel/app/src-tauri/icons"
  "zpwr-synth|juce|#ff56e2|SYN|ZPWR-SYNTH|zpwr-synth/resources"
  "zpwr-fx|juce|#0bc6db|FX|ZPWR-FX|zpwr-fx/resources"
  "zpwr-midi-fx|juce|#b388ff|MFX|ZPWR-MIDI-FX|zpwr-midi-fx/resources"
  "zpwr-daw|daw|#ff2a6d|DAW|ZPWR-DAW|zpwr-daw"
)

# Build an .icns from a 1024 master PNG (same iconset recipe as zterm).
build_icns() {
  local master=$1 out=$2 iconset s d
  iconset=$(mktemp -d -t mtech_iconset.XXXXXX)/icon.iconset
  mkdir -p "$iconset"
  for s in 16 32 64 128 256 512; do
    sips -z "$s" "$s" "$master" --out "$iconset/icon_${s}x${s}.png" >/dev/null
    d=$((s * 2))
    sips -z "$d" "$d" "$master" --out "$iconset/icon_${s}x${s}@2x.png" >/dev/null
  done
  iconutil -c icns "$iconset" -o "$out"
  command rm -rf "$(dirname "$iconset")"
}

gen_one() {
  IFS='|' read -r app kind accent glyph word path <<<"$1"
  local dir=$ROOT/$path
  [[ -d $dir ]] || { echo "skip $app: missing $dir" >&2; return; }
  local master=$TMP/$app-1024.png svg=$TMP/$app.svg
  "$GEN" "$accent" "$glyph" "$word" "$master" "$svg"

  case $kind in
  tauri)
    local set=$TMP/$app-set
    rm -rf "$set"; mkdir -p "$set"
    tauri_icon "$master" -o "$set" >/dev/null 2>&1
    # Copy back only the files this app already ships (preserve inventory).
    local f rel
    while IFS= read -r f; do
      rel=${f#"$dir"/}
      [[ $rel == icon.svg ]] && continue
      if [[ -f $set/$rel ]]; then
        cp "$set/$rel" "$f"
      elif [[ $rel == *-1024.png || $rel == icon-1024.png ]]; then
        cp "$master" "$f"
      fi
    done < <(find "$dir" -type f \( -name '*.png' -o -name '*.icns' -o -name '*.ico' \))
    cp "$svg" "$dir/icon.svg"   # source-of-truth svg in every app
    ;;
  juce)
    build_icns "$master" "$dir/AppIcon.icns"
    ;;
  daw)
    build_icns "$master" "$dir/app/resources/AppIcon.icns"
    cp "$master" "$dir/icon-1024.png"
    sips -z 256 256 "$master" --out "$dir/icon-256.png" >/dev/null
    [[ -d $dir/webui/icons ]] && cp "$svg" "$dir/webui/icons/icon.svg"
    cp "$svg" "$dir/icon.svg"
    ;;
  esac
  echo "  ok  $app ($kind, $accent, $glyph)"
}

want=("$@")
for entry in "${MANIFEST[@]}"; do
  app=${entry%%|*}
  if [[ ${#want[@]} -gt 0 ]]; then
    found=0; for w in "${want[@]}"; do [[ $w == "$app" ]] && found=1; done
    [[ $found -eq 1 ]] || continue
  fi
  gen_one "$entry"
done
echo "done."
