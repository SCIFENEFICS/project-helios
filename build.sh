#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
LIVE_BUILD_DIR="$BUILD_DIR/live-build"
RUNTIME_DIR="$LIVE_BUILD_DIR/config/includes.chroot_after_packages/opt/helios"

rm -rf "$BUILD_DIR"
install -d -m 0755 "$BUILD_DIR"

cp -a "$PROJECT_DIR/live-build" "$LIVE_BUILD_DIR"

"$PROJECT_DIR/scripts/build-runtime.sh" "$RUNTIME_DIR"

echo "Build tree prepared at:"
echo "$LIVE_BUILD_DIR"
