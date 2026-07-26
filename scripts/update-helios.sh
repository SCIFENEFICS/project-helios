 #!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$HOME/Projects/project-helios"

cd "$PROJECT_DIR"

echo "========================================="
echo " Updating Project Helios"
echo "========================================="
echo

git pull --ff-only

echo
echo "Running Project Helios installer..."
sudo ./install.sh

echo
echo "Updating Flatpak applications..."
./scripts/install-apps.sh

echo
echo "Restarting Flex Launcher..."
pkill flex-launcher || true
nohup flex-launcher >/dev/null 2>&1 &

echo
echo "Update complete."#!/usr/bin/env bash
set -e

PROJECT_DIR="$HOME/Projects/project-helios"

cd "$PROJECT_DIR"

echo "Updating Project Helios..."
git pull --ff-only

echo
echo "Reinstalling launcher..."
sudo ./scripts/configure-flex.sh

echo
echo "Update complete."
echo "Restarting Flex Launcher..."
pkill flex-launcher || true
nohup flex-launcher >/dev/null 2>&1 &
