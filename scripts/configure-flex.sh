#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$PROJECT_DIR/config/helios.conf"
LOG_DIR="$PROJECT_DIR/output/logs"
LOG_FILE="$LOG_DIR/configure-flex.log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo " Project Helios: Flex Launcher Setup"
echo "=========================================="
echo

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Run this script with sudo:"
    echo "sudo \"$PROJECT_DIR/scripts/configure-flex.sh\""
    exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: Configuration file not found:"
    echo "$CONFIG_FILE"
    exit 1
fi

# shellcheck source=/dev/null
source "$CONFIG_FILE"

if [[ -z "${HELIOS_USER:-}" ]]; then
    echo "ERROR: HELIOS_USER is not defined."
    exit 1
fi

if ! id "$HELIOS_USER" >/dev/null 2>&1; then
    echo "ERROR: User '$HELIOS_USER' does not exist."
    echo "Run configure-system.sh first."
    exit 1
fi

HELIOS_HOME="$(getent passwd "$HELIOS_USER" | cut -d: -f6)"

if [[ -z "$HELIOS_HOME" || ! -d "$HELIOS_HOME" ]]; then
    echo "ERROR: Could not determine the Helios home directory."
    exit 1
fi

SOURCE_CONFIG="$PROJECT_DIR/flex-launcher/config.ini"
SOURCE_DESKTOP_DIR="$PROJECT_DIR/desktop-files"
SOURCE_ICON_DIR="$PROJECT_DIR/assets/icons"

TARGET_CONFIG_DIR="$HELIOS_HOME/.config/flex-launcher"
TARGET_DESKTOP_DIR="$HELIOS_HOME/.local/share/applications"
TARGET_ICON_DIR="$HELIOS_HOME/.local/share/helios/icons"

if [[ ! -s "$SOURCE_CONFIG" ]]; then
    echo "ERROR: Flex Launcher configuration is missing or empty:"
    echo "$SOURCE_CONFIG"
    exit 1
fi

if ! compgen -G "$SOURCE_DESKTOP_DIR/*.desktop" >/dev/null; then
    echo "ERROR: No desktop files were found in:"
    echo "$SOURCE_DESKTOP_DIR"
    exit 1
fi

echo "Creating target directories..."

install -d -o "$HELIOS_USER" -g "$HELIOS_USER" \
    "$TARGET_CONFIG_DIR" \
    "$TARGET_DESKTOP_DIR" \
    "$TARGET_ICON_DIR"

echo
echo "Installing Flex Launcher configuration..."

install -o "$HELIOS_USER" -g "$HELIOS_USER" -m 0644 \
    "$SOURCE_CONFIG" \
    "$TARGET_CONFIG_DIR/config.ini"

echo
echo "Installing application desktop files..."

for DESKTOP_FILE in "$SOURCE_DESKTOP_DIR"/*.desktop; do
    install -o "$HELIOS_USER" -g "$HELIOS_USER" -m 0644 \
        "$DESKTOP_FILE" \
        "$TARGET_DESKTOP_DIR/$(basename "$DESKTOP_FILE")"

    echo "Installed: $(basename "$DESKTOP_FILE")"
done

echo
echo "Copying launcher icons when available..."

if [[ -d "$SOURCE_ICON_DIR" ]] &&
   compgen -G "$SOURCE_ICON_DIR/*" >/dev/null; then
    cp -a "$SOURCE_ICON_DIR/." "$TARGET_ICON_DIR/"
    chown -R "$HELIOS_USER:$HELIOS_USER" "$TARGET_ICON_DIR"
    echo "Icons copied."
else
    echo "No custom icons are currently present."
fi

echo
echo "Validating installed files..."

if [[ ! -s "$TARGET_CONFIG_DIR/config.ini" ]]; then
    echo "ERROR: Installed Flex Launcher configuration is missing."
    exit 1
fi

FAILED=0

for DESKTOP_FILE in "$SOURCE_DESKTOP_DIR"/*.desktop; do
    BASENAME="$(basename "$DESKTOP_FILE")"

    if [[ -s "$TARGET_DESKTOP_DIR/$BASENAME" ]]; then
        echo "Present: $BASENAME"
    else
        echo "MISSING: $BASENAME"
        FAILED=1
    fi
done

if [[ $FAILED -ne 0 ]]; then
    echo
    echo "ERROR: One or more desktop files were not installed."
    exit 1
fi

echo
echo "=========================================="
echo " Flex Launcher setup completed"
echo "=========================================="
echo
echo "Configuration:"
echo "$TARGET_CONFIG_DIR/config.ini"
echo
echo "Desktop files:"
echo "$TARGET_DESKTOP_DIR"
echo
echo "Log saved to:"
echo "$LOG_FILE"
