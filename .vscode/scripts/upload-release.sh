#!/usr/bin/env bash
# upload-release.sh — Lädt YouTubeExtended.ipa als GitHub Release hoch
# Repository: Trojan-V/YouTubeExtendedReleases
# Benötigt: gh CLI (sudo apt install gh && gh auth login)

set -euo pipefail

REPO="Trojan-V/YouTubeExtendedReleases"
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
IPA_PATH="${1:-$PROJECT_ROOT/YouTubeExtended.ipa}"

# ── Validierung ───────────────────────────────────────────────
if [[ ! -f "$IPA_PATH" ]]; then
    echo "❌ Datei nicht gefunden: $IPA_PATH" >&2; exit 1
fi

command -v gh &>/dev/null || {
    echo "❌ GitHub CLI nicht installiert. Führe aus:" >&2
    echo "   sudo apt install gh && gh auth login" >&2
    exit 1
}

gh auth status &>/dev/null || {
    echo "❌ Nicht bei GitHub angemeldet. Führe aus: gh auth login" >&2
    exit 1
}

# ── Version ermitteln ─────────────────────────────────────────
# Priorität: $RELEASE_VERSION → aus IPA-Dateiname → Datum
if [[ -n "${RELEASE_VERSION:-}" ]]; then
    VERSION="$RELEASE_VERSION"
elif [[ "$IPA_PATH" =~ _([0-9]+\.[0-9]+\.[0-9]+-[0-9]+) ]]; then
    VERSION="${BASH_REMATCH[1]}"
else
    VERSION="$(date +%Y.%m.%d-%H%M)"
fi

TAG="v${VERSION}"
FILE_SIZE_MB=$(du -m "$IPA_PATH" | cut -f1)

echo "📦 Datei:      $(basename "$IPA_PATH") (${FILE_SIZE_MB} MB)"
echo "🏷️  Tag:        $TAG"
echo "📁 Repository: $REPO"
echo ""

# ── Release erstellen oder vorhandenen nutzen ─────────────────
if gh release view "$TAG" --repo "$REPO" &>/dev/null; then
    echo "ℹ️  Release $TAG existiert bereits – füge Asset hinzu..."
else
    echo "📝 Erstelle Release $TAG..."
    gh release create "$TAG" \
        --repo "$REPO" \
        --title "YouTubeExtended $TAG" \
        --notes "$(cat <<NOTES
## YouTubeExtended $TAG

Automatisch gebaut am $(date '+%d.%m.%Y um %H:%M Uhr')

### Installation
1. IPA herunterladen
2. Mit [SideStore](https://sidestore.io) installieren

### Enthaltene Tweaks
- YouTube-X
- YouPiP
- YouQuality
- YTABConfig
- YouGroupSettings
- YTVideoOverlay
- Return YouTube Dislikes
- YTSideload
NOTES
)" \
        --latest
fi

# ── IPA hochladen ─────────────────────────────────────────────
echo "⬆️  Lade hoch..."
gh release upload "$TAG" "$IPA_PATH" \
    --repo "$REPO" \
    --clobber

# ── Download-URL ausgeben ─────────────────────────────────────
# ── Download-URL ausgeben ─────────────────────────────────────
echo "⏳ Warte auf Asset-Verfügbarkeit..."
URL=""
for i in {1..10}; do
    URL=$(gh release view "$TAG" \
        --repo "$REPO" \
        --json assets \
        --jq '.assets[0].browserDownloadUrl // empty' \
        2>/dev/null | head -1)
    [[ -n "$URL" ]] && break
    sleep 2
done

if [[ -z "$URL" ]]; then
    # Fallback: URL manuell zusammenbauen
    IPA_FILENAME=$(basename "$IPA_PATH")
    IPA_FILENAME_ENCODED="${IPA_FILENAME// /%20}"
    URL="https://github.com/$REPO/releases/download/$TAG/$IPA_FILENAME_ENCODED"
    echo "ℹ️  URL aus Dateiname konstruiert"
fi

echo ""
echo "✅ Upload erfolgreich!"
echo "🔗 $URL"

echo "$URL" > "$PROJECT_ROOT/.last-upload-url"
echo "💾 URL gespeichert in: $PROJECT_ROOT/.last-upload-url"
