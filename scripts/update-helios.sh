#!/usr/bin/env bash
set -Eeuo pipefail

REPO_URL="https://github.com/SCIFENEFICS/project-helios.git"
PROJECT_DIR="$HOME/Projects/project-helios"

echo "========================================="
echo " Updating Project Helios"
echo "========================================="
echo

mkdir -p "$HOME/Projects"

if [[ -d "$PROJECT_DIR/.git" ]]; then
    echo "Downloading the latest Helios updates..."
    git -C "$PROJECT_DIR" pull --ff-only
else
    if [[ -e "$PROJECT_DIR" ]]; then
        echo "ERROR: $PROJECT_DIR exists but is not a Git repository."
        echo
        read -rp "Press Enter to close..."
        exit 1
    fi

    echo "Downloading Project Helios from GitHub..."
    git clone "$REPO_URL" "$PROJECT_DIR"
fi

echo
echo "Installing the latest Helios version..."
sudo "$PROJECT_DIR/install.sh"

echo
echo "Updating Helios Flatpak applications..."
sudo flatpak update --system --noninteractive

echo
echo "Restarting Flex Launcher..."
pkill -x flex-launcher || true
nohup flex-launcher >/dev/null 2>&1 &

echo
echo "========================================="
echo " Helios update complete"
echo "========================================="
echo
read -rp "Press Enter to close..."
