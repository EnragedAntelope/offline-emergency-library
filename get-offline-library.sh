#!/usr/bin/env bash
# get-offline-library.sh — Mac/Linux one-shot downloader for the Offline Emergency Library.
# Mirrors Get-OfflineLibrary.ps1. Resumable: re-run to continue after an interruption.
#
# Usage:
#   ./get-offline-library.sh                 # asks where to save
#   ./get-offline-library.sh -d /mnt/usb     # non-interactive
#   flags: --skip-wikipedia  --skip-maps  --skip-models

REPO_RAW="https://raw.githubusercontent.com/elhajahmadj/offline-emergency-library/main"
DEST=""; SKIP_WIKI=0; SKIP_MAPS=0; SKIP_MODELS=0
while [ $# -gt 0 ]; do
  case "$1" in
    -d|--destination) DEST="$2"; shift 2;;
    --skip-wikipedia) SKIP_WIKI=1; shift;;
    --skip-maps)      SKIP_MAPS=1; shift;;
    --skip-models)    SKIP_MODELS=1; shift;;
    *) shift;;
  esac
done

command -v curl >/dev/null 2>&1 || { echo "ERROR: 'curl' is required."; exit 1; }
HAVE_UNZIP=1; command -v unzip >/dev/null 2>&1 || HAVE_UNZIP=0
HAVE_TAR=1;   command -v tar   >/dev/null 2>&1 || HAVE_TAR=0

if [ -z "$DEST" ]; then
  echo ""
  echo "  Offline Emergency Library installer"
  echo "  -----------------------------------"
  printf "Where would you like to save these files? "
  read -r DEST
fi
[ -z "$DEST" ] && { echo "No destination given. Exiting."; exit 1; }
ROOT="$DEST/OfflineLibrary"
mkdir -p "$ROOT" || { echo "Cannot create $ROOT"; exit 1; }
LOG="$ROOT/_download.log"
log(){ printf '%s  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG"; }
fetch(){ curl -L -C - --retry 10 --retry-delay 5 --retry-all-errors -s -o "$2" "$1"; }
UA="Mozilla/5.0"

# ---- platform detection ----
OSN="$(uname -s)"; ARCHN="$(uname -m)"
case "$ARCHN" in arm64|aarch64) CPU=arm64; JARCH=aarch64;; *) CPU=x64; JARCH=x64;; esac
case "$OSN" in Darwin) PLAT=mac;; Linux) PLAT=linux;; *) PLAT=linux;; esac
log "Platform: $PLAT/$CPU   Destination: $ROOT"
[ "$HAVE_UNZIP" = 0 ] && log "NOTE: 'unzip' not found — the desktop map viewer needs it (install it to enable maps-on-PC)."

# ---- folder tree ----
for d in AI-Offline AI-Offline/engine AI-Offline/models AI-Offline/DocReader-GPT4All \
         Manuals Manuals/ArmyFieldManuals Manuals/Repair-iFixit Manuals/DIY-Appropedia \
         Manuals/Survival-Water-Food Manuals/Radio-Communications \
         Medical Medical/WikiMed Medical/zimgit-medicine Medical/Manuals-PDF \
         Wikipedia OsmAnd Kiwix-Reader Phone-Apps; do
  mkdir -p "$ROOT/$d"
done

# ---- helpers ----
gh_asset(){ # repo regex  -> first matching asset url across recent releases
  curl -s -H "User-Agent: oel" "https://api.github.com/repos/$1/releases?per_page=20" \
   | grep -oE '"browser_download_url"[ ]*:[ ]*"[^"]+"' | sed -E 's/.*"(https[^"]+)"/\1/' \
   | grep -E "$2" | head -n1
}
gh_asset_latest(){ # repo regex -> asset url from the 'latest' release
  curl -s -H "User-Agent: oel" "https://api.github.com/repos/$1/releases/latest" \
   | grep -oE '"browser_download_url"[ ]*:[ ]*"[^"]+"' | sed -E 's/.*"(https[^"]+)"/\1/' \
   | grep -E "$2" | head -n1
}
latest_zim(){ curl -s -A "$UA" "$1" | grep -oE "$2[^\"<]*\.zim" | sort -u | tail -n1; }

# ================================================================ 1. AI engine
log "=== [1/8] Offline AI engine (llama.cpp) ==="
if [ "$HAVE_TAR" = 1 ]; then
  if [ "$PLAT" = mac ]; then
    u="$(gh_asset ggml-org/llama.cpp "bin-macos-${CPU}\\.tar\\.gz$")"
    [ -n "$u" ] && { log "engine: $(basename "$u")"; fetch "$u" "$ROOT/AI-Offline/engine/engine.tar.gz"; mkdir -p "$ROOT/AI-Offline/engine/metal"; tar -xf "$ROOT/AI-Offline/engine/engine.tar.gz" -C "$ROOT/AI-Offline/engine/metal"; }
  else
    u="$(gh_asset ggml-org/llama.cpp "bin-ubuntu-${CPU}\\.tar\\.gz$")"
    [ -n "$u" ] && { log "engine CPU: $(basename "$u")"; fetch "$u" "$ROOT/AI-Offline/engine/cpu.tar.gz"; mkdir -p "$ROOT/AI-Offline/engine/cpu"; tar -xf "$ROOT/AI-Offline/engine/cpu.tar.gz" -C "$ROOT/AI-Offline/engine/cpu"; }
    g="$(gh_asset ggml-org/llama.cpp "bin-ubuntu-vulkan-${CPU}\\.tar\\.gz$")"
    [ -n "$g" ] && { log "engine GPU(Vulkan): $(basename "$g")"; fetch "$g" "$ROOT/AI-Offline/engine/gpu.tar.gz"; mkdir -p "$ROOT/AI-Offline/engine/gpu"; tar -xf "$ROOT/AI-Offline/engine/gpu.tar.gz" -C "$ROOT/AI-Offline/engine/gpu"; }
  fi
else
  log "engine: skipped (no 'tar')"
fi

# ================================================================ 2. AI models
log "=== [2/8] AI chat models (GGUF) ==="
fetch "https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf" "$ROOT/AI-Offline/models/Llama-3.2-3B-Instruct-Q4_K_M.gguf"
log "model: Llama-3.2-3B done"
if [ "$SKIP_MODELS" = 0 ]; then
  fetch "https://huggingface.co/bartowski/Meta-Llama-3.1-8B-Instruct-GGUF/resolve/main/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf" "$ROOT/AI-Offline/models/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf"; log "model: Llama-3.1-8B done"
  fetch "https://huggingface.co/bartowski/Qwen2.5-7B-Instruct-GGUF/resolve/main/Qwen2.5-7B-Instruct-Q4_K_M.gguf" "$ROOT/AI-Offline/models/Qwen2.5-7B-Instruct-Q4_K_M.gguf"; log "model: Qwen2.5-7B done"
else
  log "models: large models skipped"
fi

# ================================================================ 3. GPT4All
log "=== [3/8] GPT4All (offline document Q&A) ==="
if [ "$PLAT" = mac ]; then
  u="$(gh_asset_latest nomic-ai/gpt4all 'installer-macos-v.*\.dmg$')"
  [ -n "$u" ] && { log "gpt4all: $(basename "$u")"; fetch "$u" "$ROOT/AI-Offline/DocReader-GPT4All/$(basename "$u")"; }
else
  u="$(gh_asset_latest nomic-ai/gpt4all 'installer-linux-v.*\.run$')"
  [ -n "$u" ] && { log "gpt4all: $(basename "$u")"; fetch "$u" "$ROOT/AI-Offline/DocReader-GPT4All/$(basename "$u")"; chmod +x "$ROOT/AI-Offline/DocReader-GPT4All/$(basename "$u")" 2>/dev/null; }
fi

# ================================================================ 4. Kiwix reader
log "=== [4/8] Kiwix reader ==="
if [ "$PLAT" = linux ] && [ "$CPU" = x64 ]; then
  ai="$(curl -s -A "$UA" https://download.kiwix.org/release/kiwix-desktop/ | grep -oE 'kiwix-desktop_x86_64_[0-9][^\"]*\.appimage' | sort -u | tail -n1)"
  if [ -n "$ai" ]; then log "kiwix: $ai"; fetch "https://download.kiwix.org/release/kiwix-desktop/$ai" "$ROOT/Kiwix-Reader/$ai"; chmod +x "$ROOT/Kiwix-Reader/$ai" 2>/dev/null; fi
else
  log "kiwix desktop: on macOS install 'Kiwix' from the Mac App Store or kiwix.org; on Linux-ARM use the Kiwix website. (ZIMs still work via the bundled Android app or any Kiwix build.)"
fi

# ================================================================ 5. ZIM archives
log "=== [5/8] Offline archives (Kiwix ZIM) ==="
add_zim(){ n="$(latest_zim "$1" "$2")"; [ -n "$n" ] && { log "zim: $n"; fetch "$1$n" "$3/$n"; } || log "zim: not found ($2)"; }
add_zim "https://download.kiwix.org/zim/ifixit/"    "ifixit_en_all_"            "$ROOT/Manuals/Repair-iFixit"
add_zim "https://download.kiwix.org/zim/other/"     "appropedia_en_all_maxi_"   "$ROOT/Manuals/DIY-Appropedia"
add_zim "https://download.kiwix.org/zim/other/"     "zimgit-post-disaster_en_"  "$ROOT/Manuals/Survival-Water-Food"
add_zim "https://download.kiwix.org/zim/other/"     "zimgit-water_en_"          "$ROOT/Manuals/Survival-Water-Food"
add_zim "https://download.kiwix.org/zim/other/"     "zimgit-food-preparation_en_" "$ROOT/Manuals/Survival-Water-Food"
add_zim "https://download.kiwix.org/zim/other/"     "zimgit-knots_en_"          "$ROOT/Manuals/Survival-Water-Food"
add_zim "https://download.kiwix.org/zim/wikipedia/" "wikipedia_en_medicine_maxi_" "$ROOT/Medical/WikiMed"
add_zim "https://download.kiwix.org/zim/other/"     "zimgit-medicine_en_"       "$ROOT/Medical/zimgit-medicine"

# ================================================================ 6. PDFs
log "=== [6/8] Public-domain manuals (PDF) ==="
ia_pdf(){ curl -s -A "$UA" "https://archive.org/metadata/$1" | grep -oE '"name":"[^"]+\.pdf"' | sed -E 's/"name":"([^"]+)"/\1/' | grep -vE '_text\.pdf$' | head -n1; }
get_pdf(){ # id  localname  destdir
  f="$(ia_pdf "$1")"
  if [ -n "$f" ]; then
    enc="$(printf '%s' "$f" | sed 's/ /%20/g')"
    log "pdf: $2"; fetch "https://archive.org/download/$1/$enc" "$3/$2"
  else log "pdf: none for $1"; fi
}
AFM="$ROOT/Manuals/ArmyFieldManuals"; MPDF="$ROOT/Medical/Manuals-PDF"
get_pdf "fm-21-76-us-army-survival-manual"                    "FM 21-76 Army Survival Manual.pdf" "$AFM"
get_pdf "fm-3-05.70-survival-2002"                            "FM 3-05.70 Survival (2002).pdf" "$AFM"
get_pdf "105-page-survival-field-manual"                      "105-Page Survival Field Manual.pdf" "$AFM"
get_pdf "UsArmyFirstAidManualFm4-25.11"                       "FM 4-25.11 First Aid.pdf" "$AFM"
get_pdf "Survival-FirstAidForSoldiers-AFieldManual"          "Survival and First Aid for Soldiers.pdf" "$AFM"
get_pdf "use-and-care-of-hand-tools-and-measuring-tools-1983" "TM 9-243 Use and Care of Hand Tools.pdf" "$AFM"
get_pdf "fm-5-426-carpentry-1995"                            "FM 5-426 Carpentry.pdf" "$AFM"
get_pdf "tm-9-8000-principles-of-automotive-vehicles-1985"   "TM 9-8000 Principles of Automotive Vehicles.pdf" "$AFM"
get_pdf "u-s-army-guide-to-rigging"                          "FM 5-125 Army Guide to Rigging.pdf" "$AFM"
get_pdf "fm-90-3-desert-operations-1993"                     "FM 90-3 Desert Operations.pdf" "$AFM"
get_pdf "tm-10-412-armed-forces-recipe-service-2003"         "TM 10-412 Armed Forces Recipe Service.pdf" "$AFM"
get_pdf "bwb_S0-EJI-512"                                     "Where There Is No Doctor.pdf" "$MPDF"
get_pdf "where-there-is-no-dentist-13th-printing-2010"       "Where There Is No Dentist.pdf" "$MPDF"
get_pdf "shipsmedicineche0000medi"                           "Ships Medicine Chest and First Aid at Sea.pdf" "$MPDF"

# ================================================================ 7. Wikipedia + Maps
if [ "$SKIP_WIKI" = 0 ]; then
  log "=== [7/8] Wikipedia (article text, ~24 GB) ==="
  fetch "https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-pages-articles.xml.bz2" "$ROOT/Wikipedia/enwiki-latest-pages-articles.xml.bz2"
else log "=== [7/8] Wikipedia SKIPPED ==="; fi

if [ "$SKIP_MAPS" = 0 ]; then
  log "=== [8/8] Offline US maps (OsmAnd, ~17 GB) ==="
  curl -s "https://download.osmand.net/get_indexes" -o "$ROOT/OsmAnd/_index.xml"
  grep -oE 'name="US_[^"]+\.obf\.zip"' "$ROOT/OsmAnd/_index.xml" | sed -E 's/name="([^"]+)"/\1/' | grep -viE 'wiki|srtm|depth' | sort -u > "$ROOT/OsmAnd/_filelist.txt"
  n=$(wc -l < "$ROOT/OsmAnd/_filelist.txt" | tr -d ' ')
  log "osmand: $n US map files"
  while IFS= read -r fn; do [ -n "$fn" ] && fetch "https://download.osmand.net/download.php?standard=yes&file=$fn" "$ROOT/OsmAnd/$fn"; done < "$ROOT/OsmAnd/_filelist.txt"

  # desktop map viewer (OsmAndMapCreator + portable Java) — use maps on a PC, no phone
  log "=== [8b] Desktop map viewer (OsmAndMapCreator + portable Java) ==="
  MVD="$ROOT/OsmAnd/MapViewer-Desktop"; mkdir -p "$MVD/app"
  if [ "$HAVE_UNZIP" = 1 ]; then
    fetch "https://download.osmand.net/latest-night-build/OsmAndMapCreator-main.zip" "$MVD/OsmAndMapCreator.zip"
    unzip -o -q "$MVD/OsmAndMapCreator.zip" -d "$MVD/app"
    jreurl="https://api.adoptium.net/v3/binary/latest/21/ga/${PLAT}/${JARCH}/jre/hotspot/normal/eclipse"
    [ "$PLAT" = mac ] && jreurl="https://api.adoptium.net/v3/binary/latest/21/ga/mac/${JARCH}/jre/hotspot/normal/eclipse"
    fetch "$jreurl" "$MVD/jre.tar.gz"
    mkdir -p "$MVD/_jre"; tar -xf "$MVD/jre.tar.gz" -C "$MVD/_jre" 2>/dev/null
    rm -rf "$MVD/jre"; mv "$MVD/_jre"/*/ "$MVD/jre" 2>/dev/null; rm -rf "$MVD/_jre"
    cat > "$MVD/VIEW-MAPS-ON-PC.sh" <<'EOS'
#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")" && pwd)"
# find bundled java
JAVA="$(find "$DIR/jre" -name java -type f 2>/dev/null | head -n1)"
[ -n "$JAVA" ] && export PATH="$(dirname "$JAVA"):$PATH"
MAPS="$(cd "$DIR/.." && pwd)"; OBF="$MAPS/obf"; mkdir -p "$OBF"
echo "Preparing maps for desktop viewing (first run can take several minutes)..."
for z in "$MAPS"/*.obf.zip; do
  [ -e "$z" ] || continue
  base="$(basename "$z" .zip)"
  [ -e "$OBF/$base" ] || unzip -o -q "$z" -d "$OBF"
done
echo "Maps ready in: $OBF"
sh "$DIR/app/OsmAndMapCreator.sh" 2>/dev/null || bash "$DIR/app/OsmAndMapCreator.sh"
EOS
    chmod +x "$MVD/VIEW-MAPS-ON-PC.sh" 2>/dev/null
    find "$MVD/app" -name "*.sh" -exec chmod +x {} \; 2>/dev/null
    find "$MVD/jre" -name java -exec chmod +x {} \; 2>/dev/null
  else
    log "desktop map viewer: skipped (install 'unzip' then re-run to enable)"
  fi
else log "=== [8/8] Maps SKIPPED ==="; fi

# ================================================================ phone apps
log "=== Phone apps (port the library to a phone) ==="
PA="$ROOT/Phone-Apps"
ku="$(gh_asset_latest kiwix/kiwix-android 'universal-standalone\.apk$')"
[ -z "$ku" ] && ku="$(gh_asset_latest kiwix/kiwix-android '\.apk$')"
[ -n "$ku" ] && { log "phone app: Kiwix $(basename "$ku")"; fetch "$ku" "$PA/$(basename "$ku")"; }
if [ "$SKIP_MAPS" = 0 ]; then
  vc="$(curl -s -A "$UA" https://f-droid.org/api/v1/packages/net.osmand.plus | grep -oE '"suggestedVersionCode":[0-9]+' | grep -oE '[0-9]+' | head -n1)"
  [ -n "$vc" ] && { log "phone app: OsmAnd~ $vc"; fetch "https://f-droid.org/repo/net.osmand.plus_$vc.apk" "$PA/OsmAnd-$vc.apk"; }
fi

# ================================================================ launchers (.sh)
log "=== Writing launchers ==="
AO="$ROOT/AI-Offline"
make_launcher(){ # file  model  extra-args
cat > "$AO/$1" <<EOS
#!/usr/bin/env bash
DIR="\$(cd "\$(dirname "\$0")" && pwd)"
CLI="\$(find "\$DIR/engine" -name llama-cli -type f 2>/dev/null | head -n1)"
SRV="\$(find "\$DIR/engine" -name llama-server -type f 2>/dev/null | head -n1)"
[ -z "\$CLI" ] && { echo "AI engine not found in \$DIR/engine"; exit 1; }
LIBDIR="\$(dirname "\$CLI")"
export LD_LIBRARY_PATH="\$LIBDIR:\${LD_LIBRARY_PATH:-}"
export DYLD_LIBRARY_PATH="\$LIBDIR:\${DYLD_LIBRARY_PATH:-}"
exec "\$CLI" -m "\$DIR/models/$2" -c 4096 $3 -cnv
EOS
chmod +x "$AO/$1" 2>/dev/null
}
make_launcher "chat-3B-light.sh" "Llama-3.2-3B-Instruct-Q4_K_M.gguf" ""
make_launcher "chat-8B-smart.sh" "Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf" ""
if [ "$PLAT" = linux ]; then
  # GPU launcher uses the Vulkan engine subdir
  cat > "$AO/chat-GPU-Qwen7B.sh" <<'EOS'
#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")" && pwd)"
CLI="$(find "$DIR/engine/gpu" -name llama-cli -type f 2>/dev/null | head -n1)"
[ -z "$CLI" ] && CLI="$(find "$DIR/engine" -name llama-cli -type f 2>/dev/null | head -n1)"
LIBDIR="$(dirname "$CLI")"; export LD_LIBRARY_PATH="$LIBDIR:${LD_LIBRARY_PATH:-}"
exec "$CLI" -m "$DIR/models/Qwen2.5-7B-Instruct-Q4_K_M.gguf" -c 4096 -ngl 99 -cnv
EOS
  chmod +x "$AO/chat-GPU-Qwen7B.sh" 2>/dev/null
fi
cat > "$AO/web-ui.sh" <<'EOS'
#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")" && pwd)"
SRV="$(find "$DIR/engine" -name llama-server -type f 2>/dev/null | head -n1)"
[ -z "$SRV" ] && { echo "server not found"; exit 1; }
LIBDIR="$(dirname "$SRV")"; export LD_LIBRARY_PATH="$LIBDIR:${LD_LIBRARY_PATH:-}"; export DYLD_LIBRARY_PATH="$LIBDIR:${DYLD_LIBRARY_PATH:-}"
echo "Open http://127.0.0.1:8080 when it says 'server listening'"
exec "$SRV" -m "$DIR/models/Llama-3.2-3B-Instruct-Q4_K_M.gguf" -c 4096 --host 127.0.0.1 --port 8080
EOS
chmod +x "$AO/web-ui.sh" 2>/dev/null

# ================================================================ documentation
log "=== Documentation (Markdown + HTML) ==="
SCRIPTDIR="$(cd "$(dirname "$0")" && pwd)"
place_doc(){ # base  destpath
  for ext in md html; do
    if [ -f "$SCRIPTDIR/docs/$1.$ext" ]; then cp "$SCRIPTDIR/docs/$1.$ext" "$2.$ext"
    else curl -s -A "$UA" "$REPO_RAW/docs/$1.$ext" -o "$2.$ext"; fi
  done
}
place_doc "START-HERE"            "$ROOT/START-HERE"
place_doc "HOW-TO-RUN-OFFLINE-AI" "$ROOT/AI-Offline/HOW-TO-RUN-OFFLINE-AI"
place_doc "HOW-TO-ASK-YOUR-DOCS"  "$ROOT/AI-Offline/DocReader-GPT4All/HOW-TO-ASK-YOUR-DOCS"
place_doc "HOW-TO-USE-KIWIX"      "$ROOT/Kiwix-Reader/HOW-TO-USE-KIWIX"
place_doc "Manuals-READ-ME-FIRST" "$ROOT/Manuals/READ-ME-FIRST"
place_doc "Medical-READ-ME-FIRST" "$ROOT/Medical/READ-ME-FIRST"
place_doc "RADIO-GUIDE"           "$ROOT/Manuals/Radio-Communications/RADIO-GUIDE"
place_doc "HOW-TO-VIEW-MAPS"      "$ROOT/OsmAnd/HOW-TO-VIEW-MAPS"
place_doc "USE-ON-PHONE"          "$ROOT/Phone-Apps/USE-ON-PHONE"

log "=== DONE. Open START-HERE.html in the destination folder. ==="
echo ""
echo "  Finished. Your offline library is in: $ROOT"
echo "  Start by opening START-HERE.html"
