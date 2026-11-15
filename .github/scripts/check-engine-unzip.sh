#!/usr/bin/env bash
# Without 'unzip' the installer must keep the drive's Windows engine (x64, arm64, vulkan-x64),
# not wipe its folders: runs the real engine section of get-offline-library.sh with local
# fixtures and HAVE_UNZIP=0, offline. The macOS/Linux engines (tar.gz) must still update.
set -u
cd "$(dirname "$0")/../.."
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
fail=0
bad(){ echo "FAIL $*"; fail=1; }
TAG=b9999
sed -n '/^# =* 1\. AI engine/,/^# =* 2\. AI models/p' get-offline-library.sh > "$T/engine.sh"
grep -q 'LLAMA_ASSETS=' "$T/engine.sh" && grep -q 'BUILD.txt' "$T/engine.sh" || { echo "FAIL: engine section not found in get-offline-library.sh"; exit 1; }

# Local release: every asset name the installer wants, tar.gz ones holding a llama-cli.
mkdir -p "$T/src/pkg"; : > "$T/src/pkg/llama-cli"; : > "$T/src/pkg/libx.so"
tar -czf "$T/src/tgz" -C "$T/src/pkg" .
ASSETS="win-cpu-x64.zip win-cpu-arm64.zip win-vulkan-x64.zip macos-arm64.tar.gz macos-x64.tar.gz ubuntu-x64.tar.gz ubuntu-arm64.tar.gz ubuntu-vulkan-x64.tar.gz"
JSON="[{\"tag_name\":\"$TAG\",\"assets\":["
for a in $ASSETS; do
  JSON="$JSON{\"browser_download_url\":\"https://example.invalid/download/$TAG/llama-$TAG-bin-$a\"},"
  case "$a" in *.zip) echo "zip $a" > "$T/src/llama-$TAG-bin-$a" ;; *) cp "$T/src/tgz" "$T/src/llama-$TAG-bin-$a" ;; esac
done
JSON="${JSON%,}]}]"

log(){ echo "  $*"; }
curl(){ printf '%s' "$JSON"; }
fetch(){ echo "$1" >> "$T/fetched"; cp "$T/src/${1##*/}" "$2"; }

run(){ # root label: engine section, no unzip
  : > "$T/fetched"; ROOT="$1"; mkdir -p "$ROOT/AI-Offline/engine"
  ( HAVE_TAR=1; HAVE_UNZIP=0; ONLY=""; . "$T/engine.sh" ) > "$T/out" 2>&1 || { cat "$T/out"; bad "$2: engine section stopped with an error"; }
}

# A: drive with a working older Windows engine and an older BUILD.txt.
R="$T/a"; E="$R/AI-Offline/engine"
for d in x64 arm64 vulkan-x64; do mkdir -p "$E/$d"; echo old > "$E/$d/llama-cli.exe"; done
echo b1000 > "$E/BUILD.txt"
run "$R" A
for d in x64 arm64 vulkan-x64; do
  [ "$(cat "$E/$d/llama-cli.exe" 2>/dev/null)" = old ] || bad "A: engine/$d was wiped or changed without unzip"
done
ls "$E"/*.zip >/dev/null 2>&1 && bad "A: a Windows zip was downloaded although it cannot be unpacked"
grep -q '\.zip' "$T/fetched" && bad "A: fetch was called for a .zip"
[ -f "$E/macos-arm64/llama-cli" ] && [ -f "$E/linux-x64/llama-cli" ] || bad "A: the tar.gz engines were not unpacked"
[ "$(head -n1 "$E/BUILD.txt")" = "$TAG" ] || bad "A: BUILD.txt line 1 is not the build just unpacked: $(cat "$E/BUILD.txt")"
grep -q 'Windows engine not updated' "$E/BUILD.txt" || bad "A: BUILD.txt does not say the Windows engine was not updated"
grep -q "left as it is" "$T/out" || bad "A: no 'left as it is' line"
[ "$fail" = 0 ] && echo "  OK   existing Windows engine kept, no zip fetched, BUILD.txt notes it"

# B: new drive: no Windows folders created, BUILD.txt names the build and says Windows is missing.
R="$T/b"; E="$R/AI-Offline/engine"
run "$R" B
[ -z "$(ls -d "$E/x64" "$E/arm64" "$E/vulkan-x64" 2>/dev/null)" ] || bad "B: empty Windows folders were created"
[ "$(head -n1 "$E/BUILD.txt" 2>/dev/null)" = "$TAG" ] || bad "B: BUILD.txt first line is not the build tag"
grep -qi 'windows' "$E/BUILD.txt" 2>/dev/null || bad "B: BUILD.txt does not say the Windows engine is missing"
[ -f "$E/linux-x64/llama-cli" ] || bad "B: the tar.gz engines were not unpacked"
[ "$fail" = 0 ] && echo "  OK   new drive: BUILD.txt notes the missing Windows engine"
exit "$fail"
