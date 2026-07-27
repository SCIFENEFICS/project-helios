#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
LIVE_BUILD_DIR="$BUILD_DIR/live-build"
RUNTIME_DIR="$LIVE_BUILD_DIR/config/includes.chroot_after_packages/opt/helios"
RELEASES_DIR="$PROJECT_DIR/releases"
VERSION_FILE="$PROJECT_DIR/config/version"

VERSION="$(<"$VERSION_FILE")"
RELEASE_ISO="$RELEASES_DIR/Project-Helios-v${VERSION}.iso"

if [[ -d "$BUILD_DIR" ]]; then
    sudo rm -rf "$BUILD_DIR"
fi
install -d -m 0755 "$BUILD_DIR"

cp -a "$PROJECT_DIR/live-build" "$LIVE_BUILD_DIR"

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

install -d -m 0755 "$RELEASES_DIR"
cp "$BUILT_ISO" "$RELEASE_ISO"
sha256sum "$RELEASE_ISO" > "${RELEASE_ISO}.sha256"

echo
echo "Release created:"
echo "$RELEASE_ISO"
echo "${RELEASE_ISO}.sha256"
