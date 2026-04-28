#!/usr/bin/env bash
# update-source.sh — Aktualisiert die downloadURL + Metadaten in apps.json
# Liest die neue URL aus .last-upload-url und die Größe direkt von der IPA

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
IPA_PATH="$PROJECT_ROOT/YouTubeExtended.ipa"
SOURCE_FILE="$PROJECT_ROOT/repo/apps.json"
URL_FILE="$PROJECT_ROOT/.last-upload-url"

# ── Validierung ───────────────────────────────────────────────
for f in "$IPA_PATH" "$SOURCE_FILE" "$URL_FILE"; do
    [[ -f "$f" ]] || { echo "❌ Nicht gefunden: $f" >&2; exit 1; }
done

command -v jq &>/dev/null || { echo "❌ jq nicht installiert: sudo apt install jq" >&2; exit 1; }

# ── Werte ermitteln ───────────────────────────────────────────
DOWNLOAD_URL=$(cat "$URL_FILE" | tr -d '[:space:]')
FILE_SIZE=$(stat -c%s "$IPA_PATH")
DATE=$(date +%Y-%m-%d)

# Version aus RELEASE_VERSION oder aus letztem gh-Release-Tag
if [[ -n "${RELEASE_VERSION:-}" ]]; then
    VERSION="$RELEASE_VERSION"
else
    VERSION=$(gh release view --repo Trojan-V/YouTubeExtendedReleases \
        --json tagName --jq '.tagName' 2>/dev/null | sed 's/^v//' || echo "")
    [[ -z "$VERSION" ]] && VERSION=$(date +%Y.%m.%d)
fi

echo "📋 Aktualisiere apps.json:"
echo "   Version:  $VERSION"
echo "   Datum:    $DATE"
echo "   Größe:    $FILE_SIZE Bytes"
echo "   URL:      $DOWNLOAD_URL"
echo ""

# ── JSON aktualisieren ────────────────────────────────────────
UPDATED=$(jq \
    --arg url "$DOWNLOAD_URL" \
    --arg version "$VERSION" \
    --arg date "$DATE" \
    --argjson size "$FILE_SIZE" \
    '
    .apps[0].versions = [{
        version:              $version,
        date:                 $date,
        localizedDescription: ("YouTube \($version) mit Tweaks"),
        downloadURL:          $url,
        size:                 $size,
        minOSVersion:         "14.0"
    }] + .apps[0].versions
    | .apps[0].versions |= unique_by(.version)
    ' \
    "$SOURCE_FILE")

echo "$UPDATED" > "$SOURCE_FILE"
echo "✅ apps.json aktualisiert"

# ── Änderungen committen und pushen ──────────────────────────
SOURCE_REPO_PATH="${SOURCE_REPO_PATH:-$PROJECT_ROOT/repo}"

cd "$SOURCE_REPO_PATH"
git add apps.json
git diff --cached --quiet && { echo "ℹ️  Keine Änderungen – apps.json ist bereits aktuell"; exit 0; }
git commit -m "release: YouTubeExtended $VERSION"
git push
echo "🚀 apps.json gepusht"
