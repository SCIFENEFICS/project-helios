#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
LIVE_BUILD_DIR="$BUILD_DIR/live-build"
RUNTIME_DIR="$LIVE_BUILD_DIR/config/includes.chroot_after_packages/opt/helios"
RELEASES_DIR="$PROJECT_DIR/releases"
VERSION_FILE="$PROJECT_DIR/config/version"

VERSION="$(<"$VERSION_FILE")"
DEBIAN_VERSION="$(cat /etc/debian_version)"
BUILD_DATE=$(date +%Y%m%d-%H%M%S)
RELEASE_ISO="$RELEASES_DIR/Project-Helios-v${VERSION}-${BUILD_DATE}.iso"

if [[ -d "$BUILD_DIR" ]]; then
    sudo rm -rf "$BUILD_DIR"
fi
install -d -m 0755 "$BUILD_DIR"

cp -a "$PROJECT_DIR/live-build" "$LIVE_BUILD_DIR"

SPLASH_FILE="$LIVE_BUILD_DIR/config/bootloaders/grub-pc/splash.svg"
if [[ -f "$SPLASH_FILE" ]]; then
    sed -i         -e "s|@HELIOS_VERSION@|$VERSION|g"         -e "s|@DEBIAN_VERSION@|$DEBIAN_VERSION|g"         "$SPLASH_FILE"
fi

"$PROJECT_DIR/scripts/build-runtime.sh" "$RUNTIME_DIR"

echo "Build tree prepared at:"
echo "$LIVE_BUILD_DIR"

echo
echo "Starting live-build..."

cd "$LIVE_BUILD_DIR"

sudo lb config
sudo lb build

BUILT_ISO="$LIVE_BUILD_DIR/live-image-amd64.hybrid.iso"

if [[ ! -f "$BUILT_ISO" ]]; then
    echo "Error: expected ISO was not created: $BUILT_ISO" >&2
    exit 1
fi

"$PROJECT_DIR/scripts/validate-iso.sh" "$BUILT_ISO"

install -d -m 0755 "$RELEASES_DIR"
cp "$BUILT_ISO" "$RELEASE_ISO"
sha256sum "$RELEASE_ISO" > "${RELEASE_ISO}.sha256"

HOST_USER="pyrus"
HOST_IP="192.168.10.216"
HOST_RELEASES_DIR="/home/pyrus/vault/projects/Project Helios/releases"

echo
echo "Copying release to Pop!_OS host..."
scp "$RELEASE_ISO" "${RELEASE_ISO}.sha256"     "$HOST_USER@$HOST_IP:$HOST_RELEASES_DIR/"

echo
echo "Release created:"
echo "$RELEASE_ISO"
echo "${RELEASE_ISO}.sha256"
echo
echo "Copied to Pop!_OS host:"
echo "$HOST_RELEASES_DIR/"
