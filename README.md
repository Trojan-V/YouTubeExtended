
# YouTubeExtended

![YouTubeExtended – Logo](assets/logo.jpg)

Dieses Repository baut einen YouTube-Tweak (`YouTubeExtended`) und erzeugt daraus per GitHub Actions eine finale `.ipa`, in die die gewünschten Tweaks injiziert werden.

## Automatische GitHub Releases

Sobald ein Pull Request in `main` gemerged wurde, startet der Workflow `(INTERNAL) Create Release` (`.github/workflows/release.yml`).
Dabei wird auf Basis der Versionsnummer aus der Datei `control` ein Git-Tag und ein GitHub Release mit dem gebauten `.deb` erstellt.

## Finale IPA bauen

Für den IPA-Build ist der manuelle Workflow `(USER) Create YouTubeExtended App` (`.github/workflows/create_app.yml`) zuständig.

1. Repository forken
2. In GitHub den Tab **Actions** öffnen
3. Workflow **(USER) Create YouTubeExtended App** starten
4. `ipa_url` (decrypted YouTube IPA als Direktlink) ausfüllen
5. Optional: App-Name, Bundle-ID und externe Tweaks auswählen

Ergebnis: Die gebaute Datei wird als **Draft Release** im GitHub-Reiter **Releases** hochgeladen.

## In die finale IPA injizierbare Tweaks

Die IPA-Injektion erfolgt im Workflow über `cyan` mit allen gefundenen `*.deb` und `*.appex` Dateien.

### Immer enthalten

- **YouTubeExtended**
	Source: https://github.com/Trojan-V/YouTubeExtended

### Optional aktivierbar (Workflow-Inputs)

- **YouPiP** (`enable_youpip`)
	Source: https://github.com/PoomSmart/YouPiP

- **YouTubeUHD / YTUHD** (`enable_ytuhd`)
	Source: https://github.com/Tonwalter888/YTUHD

- **YouQuality** (`enable_yq`)
	Source: https://github.com/PoomSmart/YouQuality

- **Return-YouTube-Dislikes** (`enable_ryd`)
	Source: https://github.com/PoomSmart/Return-YouTube-Dislikes

- **YouTubeABConfig / YTABConfig** (`enable_ytabc`)
	Source: https://github.com/PoomSmart/YTABConfig

- **DontEatMyContent** (`enable_demc`)
	Source: https://github.com/therealFoxster/DontEatMyContent

### Abhängigkeiten / zusätzliche Komponenten (werden je nach Auswahl ebenfalls injiziert)

- **YTVideoOverlay** (Dependency für mehrere externe Tweaks)
	Source: https://github.com/PoomSmart/YTVideoOverlay

- **YouGroupSettings** (wird im External-Build mitgebaut)
	Source: https://github.com/PoomSmart/YouGroupSettings

- **Open in YouTube (Safari Extension)** (`.appex`)
	Source: https://github.com/BillyCurtis/OpenYouTubeSafariExtension

## Versionshinweise

- Vor jedem Release die neue Version in `control` erhöhen.
- Falls ein auswählbarer Build über `tweak_version` genutzt wird, muss die Version in `.github/workflows/create_app.yml` bei den `options` ergänzt werden.
