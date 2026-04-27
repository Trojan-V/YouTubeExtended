#!/usr/bin/env bash
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD_DIR="$(mktemp -d)"
rm -rf "$PROJECT_ROOT/packages"
mkdir -p "$PROJECT_ROOT/packages"
cd "$BUILD_DIR"

# ── Setup YouTube Headers ─────────────────────────────────────
if [ -d "$THEOS/include/YouTubeHeader" ]; then
  git -C "$THEOS/include/YouTubeHeader" pull
else
  git clone --quiet --depth=1 https://github.com/PoomSmart/YouTubeHeader.git "$THEOS/include/YouTubeHeader"
fi

if [ -d "$THEOS/include/PSHeader" ]; then
  git -C "$THEOS/include/PSHeader" pull
else
  git clone --quiet --depth=1 https://github.com/PoomSmart/PSHeader.git "$THEOS/include/PSHeader"
fi

rm -rf "$THEOS/include/YTHeaders"
cp -r "$THEOS/include/YouTubeHeader" "$THEOS/include/YTHeaders"

# ── Build-Funktion (eigenes tmpdir) ───────────────────────────
build_repo() {
  local REPO="$1"
  local WORK_DIR="$2"   # optionales Verzeichnis – default: eigenes tmpdir
  local REPO_NAME
  REPO_NAME=$(basename "$REPO")
  local OWN_DIR=false

  if [ -z "$WORK_DIR" ]; then
    WORK_DIR=$(mktemp -d)
    OWN_DIR=true
  fi

  echo "→ Building $REPO_NAME..."
  git clone --quiet --depth=1 "https://github.com/$REPO.git" "$WORK_DIR/$REPO_NAME"
  cd "$WORK_DIR/$REPO_NAME"
  make package DEBUG=0 FINALPACKAGE=0
  mv packages/*.deb "$PROJECT_ROOT/packages/"
  cd "$BUILD_DIR"

  if $OWN_DIR; then
    rm -rf "$WORK_DIR"
  fi

  echo "✅ $REPO_NAME"
}

# ── Schritt 1: YTVideoOverlay + abhängige Repos im selben Verzeichnis
SHARED_DIR=$(mktemp -d)

build_repo PoomSmart/YTVideoOverlay "$SHARED_DIR"

# YouPiP, YTUHD, YouQuality brauchen ../YTVideoOverlay/ → selbes SHARED_DIR
build_repo PoomSmart/YouPiP          "$SHARED_DIR" &  PIDS+=($!)
# build_repo Tonwalter888/YTUHD        "$SHARED_DIR" &  PIDS+=($!)
build_repo PoomSmart/YouQuality      "$SHARED_DIR" &  PIDS+=($!)

# ── Schritt 2: Unabhängige Repos parallel ─────────────────────
PIDS=()
build_repo PoomSmart/Return-YouTube-Dislikes & PIDS+=($!)
build_repo PoomSmart/YTABConfig              & PIDS+=($!)
build_repo PoomSmart/YouGroupSettings        & PIDS+=($!)
build_repo PoomSmart/YouTube-X               & PIDS+=($!)
build_repo Balackburn/YTSideload             & PIDS+=($!)
# build_repo ZomkaDEV/DontEatMyContent &          PIDS+=($!)

# Safari Extension
(
  echo "→ Cloning OpenYouTubeSafariExtension..."
  git clone --quiet --depth=1 \
    https://github.com/BillyCurtis/OpenYouTubeSafariExtension \
    "$BUILD_DIR/safari"
  # Namen des .appex dynamisch ermitteln
  APPEX=$(find "$BUILD_DIR/safari" -maxdepth 1 -name "*.appex" | head -1)
  [ -n "$APPEX" ] || { echo "❌ Kein .appex gefunden!"; ls "$BUILD_DIR/safari"; exit 1; }
  mv "$APPEX" "$PROJECT_ROOT/packages/"
  echo "✅ $(basename "$APPEX")"
) &
PIDS+=($!)

FAILED=0
for PID in "${PIDS[@]}"; do
  wait "$PID" || FAILED=1
done

rm -rf "$SHARED_DIR"
[ $FAILED -eq 0 ] || { echo "❌ Ein oder mehrere Builds fehlgeschlagen"; exit 1; }

# ── Aufräumen ─────────────────────────────────────────────────
rm -rf "$BUILD_DIR"

echo ""
echo "🎉 All external tweaks built successfully."
