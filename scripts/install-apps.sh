#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLATPAK_FILE="$PROJECT_DIR/packages/flatpak.txt"
LOG_DIR="$PROJECT_DIR/output/logs"
LOG_FILE="$LOG_DIR/install-apps.log"

mkdir -p "$LOG_DIR"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo " Project Helios: Application Installer"
echo "=========================================="
echo

if [[ $EUID -eq 0 ]]; then
    echo "ERROR: Do not run this script with sudo."
    echo
    echo "Run it as the normal Helios user:"
    echo "\"$PROJECT_DIR/scripts/install-apps.sh\""
    exit 1
fi

if ! command -v flatpak >/dev/null 2>&1; then
    echo "ERROR: Flatpak is not installed."
    echo "Run the base package installer first."
    exit 1
fi

if [[ ! -f "$FLATPAK_FILE" ]]; then
    echo "ERROR: Flatpak package list not found:"
    echo "$FLATPAK_FILE"
    exit 1
fi

echo "Checking Flathub configuration..."

if ! flatpak remotes --user --columns=name | grep -qx "flathub"; then
    echo "Adding Flathub for the current user..."

    flatpak remote-add \
        --user \
        --if-not-exists \
        flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo
else
    echo "Flathub is already configured."
fi

echo
echo "Reading application list..."

APP_COUNT=0

while IFS='|' read -r APP_ID DISPLAY_NAME; do
    APP_ID="$(echo "$APP_ID" | xargs)"
    DISPLAY_NAME="$(echo "$DISPLAY_NAME" | xargs)"

    [[ -z "$APP_ID" ]] && continue
    [[ "$APP_ID" == \#* ]] && continue

    APP_COUNT=$((APP_COUNT + 1))

    echo
    echo "Installing $DISPLAY_NAME"
    echo "Flatpak ID: $APP_ID"

    flatpak install \
        --user \
        --noninteractive \
        flathub \
        "$APP_ID"
done < "$FLATPAK_FILE"

if [[ $APP_COUNT -eq 0 ]]; then
    echo "ERROR: No Flatpak applications were found in:"
    echo "$FLATPAK_FILE"
    exit 1
fi

echo
echo "=========================================="
echo " Flatpak application installation complete"
echo "=========================================="
echo
echo "Applications processed: $APP_COUNT"
echo "Log saved to:"
echo "$LOG_FILE"
