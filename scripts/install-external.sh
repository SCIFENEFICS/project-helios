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

REAL_USER="${SUDO_USER:-}"

if [[ -z "$REAL_USER" || "$REAL_USER" == "root" ]]; then
    echo "ERROR: This script must be run with sudo from a normal user account."
    exit 1
fi

REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"

if [[ -z "$REAL_HOME" || ! -d "$REAL_HOME" ]]; then
    echo "ERROR: Could not determine the home directory for $REAL_USER."
    exit 1
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
echo "Installing Flex Launcher..."

ARCH="$(dpkg --print-architecture)"

case "$ARCH" in
    amd64)
        FLEX_ARCH_PATTERN='amd64'
        ;;
    arm64)
        FLEX_ARCH_PATTERN='arm64'
        ;;
    *)
        echo "ERROR: Unsupported architecture for automatic Flex Launcher installation: $ARCH"
        exit 1
        ;;
esac

RELEASE_JSON="$(curl -fsSL \
    https://api.github.com/repos/complexlogic/flex-launcher/releases/latest)"

FLEX_URL="$(printf '%s' "$RELEASE_JSON" |
    grep -oE '"browser_download_url":[[:space:]]*"[^"]+"' |
    cut -d'"' -f4 |
    grep -Ei "${FLEX_ARCH_PATTERN}.*\.deb$|\.deb$" |
    head -n 1)"

if [[ -z "$FLEX_URL" ]]; then
    echo "ERROR: Could not find a Flex Launcher Debian package."
    exit 1
fi

TEMP_DEB="$(mktemp --suffix=.deb)"

cleanup() {
    rm -f "$TEMP_DEB"
}

trap cleanup EXIT

echo "Downloading:"
echo "$FLEX_URL"

curl -fL "$FLEX_URL" -o "$TEMP_DEB"

apt-get install -y "$TEMP_DEB"

echo
echo "Preparing the user Flex Launcher configuration..."

install -d -o "$REAL_USER" -g "$REAL_USER" \
    "$REAL_HOME/.config"

if [[ -d /usr/share/flex-launcher ]]; then
    rm -rf "$REAL_HOME/.config/flex-launcher"

    cp -a \
        /usr/share/flex-launcher \
        "$REAL_HOME/.config/flex-launcher"

    chown -R "$REAL_USER:$REAL_USER" \
        "$REAL_HOME/.config/flex-launcher"

    if [[ -f "$REAL_HOME/.config/flex-launcher/config.ini" ]]; then
        sed -i \
            "s|/usr/share/flex-launcher|$REAL_HOME/.config/flex-launcher|g" \
            "$REAL_HOME/.config/flex-launcher/config.ini"
    fi
else
    echo "WARNING: /usr/share/flex-launcher was not found."
    echo "The launcher installed, but its default assets were not copied."
fi

echo
echo "=========================================="
echo " External application installation complete"
echo "=========================================="
echo
echo "Log saved to:"
echo "$LOG_FILE"
