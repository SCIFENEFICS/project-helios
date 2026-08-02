#!/usr/bin/env bash
set -Eeuo pipefail

LOG="/var/log/helios-update.log"

exec >>"$LOG" 2>&1

echo "========================================="
echo " Project Helios Update"
echo "$(date --iso-8601=seconds)"
echo "========================================="

echo "Checking for Helios updates..."

echo
echo "The runtime update mechanism is not yet implemented."
echo "This service will later download and apply official Helios runtime updates."

echo
echo "Flatpak updates are available separately."

flatpak update --system --noninteractive || true

echo
echo "Helios update service complete."
echo "========================================="
