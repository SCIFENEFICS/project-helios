#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_FILE="$PROJECT_DIR/packages/base.txt"
LOG_DIR="$PROJECT_DIR/output/logs"
LOG_FILE="$LOG_DIR/install-base.log"

mkdir -p "$LOG_DIR"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "========================================"
echo " Project Helios: Base Package Installer"
echo "========================================"
echo

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Run this script with sudo:"
    echo "sudo \"$PROJECT_DIR/scripts/install-base.sh\""
    exit 1
fi

if [[ ! -f "$PACKAGE_FILE" ]]; then
    echo "ERROR: Package file not found:"
    echo "$PACKAGE_FILE"
    exit 1
fi

mapfile -t PACKAGES < <(
    sed \
        -e 's/[[:space:]]*#.*$//' \
        -e '/^[[:space:]]*$/d' \
        "$PACKAGE_FILE"
)

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
    echo "ERROR: No packages were found in:"
    echo "$PACKAGE_FILE"
    exit 1
fi

echo "Packages selected for installation:"
printf '  - %s\n' "${PACKAGES[@]}"
echo

echo "Updating Debian package information..."
apt-get update

echo
echo "Installing Project Helios base packages..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    --no-install-recommends \
    "${PACKAGES[@]}"

echo
echo "Base package installation completed successfully."
echo "Log saved to:"
echo "$LOG_FILE"
