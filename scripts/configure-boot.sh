#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_SOURCE="$PROJECT_DIR/plymouth/helios"
THEME_DEST="/usr/share/plymouth/themes/helios"

echo "=========================================="
echo " Project Helios: Boot Configuration"
echo "=========================================="
echo

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must run as root."
    exit 1
fi

if [[ ! -d "$THEME_SOURCE" ]]; then
    echo "ERROR: Plymouth theme not found:"
    echo "$THEME_SOURCE"
    exit 1
fi

echo "Installing Helios Plymouth theme..."

install -d -m 0755 "$THEME_DEST"
install -m 0644 "$THEME_SOURCE/helios.plymouth" "$THEME_DEST/helios.plymouth"
install -m 0644 "$THEME_SOURCE/helios.script" "$THEME_DEST/helios.script"
install -m 0644 "$THEME_SOURCE/helios.png" "$THEME_DEST/helios.png"
install -m 0644 "$THEME_SOURCE/helios.svg" "$THEME_DEST/helios.svg"

echo "Setting Helios as the default Plymouth theme..."

plymouth-set-default-theme helios

echo "Rebuilding initramfs..."

update-initramfs -u -k all

echo
echo "=========================================="
echo " Boot configuration completed"
echo "=========================================="
