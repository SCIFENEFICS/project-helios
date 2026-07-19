#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$PROJECT_DIR/output/logs"
LOG_FILE="$LOG_DIR/install.log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo " Project Helios: Master Installer"
echo "=========================================="
echo

if [[ $EUID -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
        echo "ERROR: Administrator access is required."
        echo
        echo "Run:"
        echo
        echo "  sudo \"$PROJECT_DIR/install.sh\""
    else
        echo "ERROR: Administrator access is required, but sudo is not installed."
        echo
        echo "Log in as root and run:"
        echo
        echo "  \"$PROJECT_DIR/install.sh\""
    fi

    exit 1
fi

if [[ ! -r /etc/os-release ]]; then
    echo "ERROR: Cannot identify the operating system."
    exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release

if [[ "${ID:-}" != "debian" ]]; then
    echo "ERROR: Project Helios currently supports Debian only."
    echo "Detected operating system: ${PRETTY_NAME:-unknown}"
    exit 1
fi

if [[ "${VERSION_ID:-}" != "13" ]]; then
    echo "WARNING: Project Helios was designed for Debian 13."
    echo "Detected operating system: ${PRETTY_NAME:-unknown}"
    echo
fi

if ! command -v apt-get >/dev/null 2>&1; then
    echo "ERROR: apt-get was not found."
    exit 1
fi

if ! getent passwd helios >/dev/null 2>&1; then
    echo "ERROR: The required user account 'helios' does not exist."
    echo
    echo "Create the helios user before running this installer."
    exit 1
fi

run_step() {
    local STEP_NAME="$1"
    local SCRIPT_PATH="$2"

    echo
    echo "------------------------------------------"
    echo "$STEP_NAME"
    echo "------------------------------------------"

    if [[ ! -f "$SCRIPT_PATH" ]]; then
        echo "ERROR: Required script is missing:"
        echo "$SCRIPT_PATH"
        exit 1
    fi

    if [[ ! -x "$SCRIPT_PATH" ]]; then
        echo "ERROR: Required script is not executable:"
        echo "$SCRIPT_PATH"
        exit 1
    fi

    "$SCRIPT_PATH"

    echo
    echo "Completed: $STEP_NAME"
}

run_step \
    "Step 1 of 4: Install base Debian packages" \
    "$PROJECT_DIR/scripts/install-base.sh"

run_step \
    "Step 2 of 4: Install external applications" \
    "$PROJECT_DIR/scripts/install-external.sh"

run_step \
    "Step 3 of 4: Configure the Helios system" \
    "$PROJECT_DIR/scripts/configure-system.sh"

run_step \
    "Step 4 of 4: Configure Flex Launcher" \
    "$PROJECT_DIR/scripts/configure-flex.sh"

echo
echo "=========================================="
echo " Core Project Helios installation complete"
echo "=========================================="
echo
echo "Flatpak applications must now be installed"
echo "from the normal helios user account."
echo
echo "Log in as helios and run:"
echo
echo "  \"$PROJECT_DIR/scripts/install-apps.sh\""
echo
echo "Afterwards, verify video acceleration with:"
echo
echo "  \"$PROJECT_DIR/scripts/verify-vaapi.sh\""
echo
echo "Master log saved to:"
echo "$LOG_FILE"
