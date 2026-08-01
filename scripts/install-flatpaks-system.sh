#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLATPAK_FILE="$PROJECT_DIR/packages/flatpak.txt"

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must run as root."
    exit 1
fi

if [[ ! -f "$FLATPAK_FILE" ]]; then
    echo "ERROR: Flatpak package list not found: $FLATPAK_FILE"
    exit 1
fi

flatpak remote-add \
    --system \
    --if-not-exists \
    flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

while IFS='|' read -r APP_ID DISPLAY_NAME; do
    APP_ID="$(echo "$APP_ID" | xargs)"
    DISPLAY_NAME="$(echo "$DISPLAY_NAME" | xargs)"

    [[ -z "$APP_ID" ]] && continue
    [[ "$APP_ID" == \#* ]] && continue

    if [[ "$APP_ID" == "com.spotify.Client" ]]; then
        echo "Skipping Spotify during ISO build because its extra-data installer cannot run inside the live-build chroot."
        continue
    fi

    echo "Installing $DISPLAY_NAME ($APP_ID)..."

    flatpak install \
        --system \
        --noninteractive \
        --or-update \
        flathub \
        "$APP_ID"
done < "$FLATPAK_FILE"
