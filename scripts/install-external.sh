#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_DIR/output/logs"
LOG_FILE="$LOG_DIR/install-external.log"

mkdir -p "$LOG_DIR"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo " Project Helios: External App Installer"
echo "=========================================="
echo

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Run this script with sudo:"
    echo "sudo \"$PROJECT_DIR/scripts/install-external.sh\""
    exit 1
fi

REAL_USER="${SUDO_USER:-$(awk -F: '$3 >= 1000 && $3 < 65534 {print $1; exit}' /etc/passwd)}"
REAL_HOME=""

if [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]]; then
    REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
fi

echo "Installing Brave Browser..."

install -d -m 0755 /usr/share/keyrings

curl -fsSLo \
    /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

curl -fsSLo \
    /etc/apt/sources.list.d/brave-browser-release.sources \
    https://brave-browser-apt-release.s3.brave.com/brave-browser.sources

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y brave-browser

echo
echo "Flex Launcher is supplied through live-build/config/packages.chroot."
echo "Skipping external Flex Launcher download."

echo "=========================================="
echo " External application installation complete"
echo "=========================================="
echo
echo "Log saved to:"
echo "$LOG_FILE"
