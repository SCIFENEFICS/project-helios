#!/usr/bin/env bash
set -Eeuo pipefail

STAMP="/var/lib/helios/first-boot-flatpaks-complete"
LOG="/var/log/helios-first-boot.log"

mkdir -p /var/lib/helios

if [[ -f "$STAMP" ]]; then
    exit 0
fi

exec >>"$LOG" 2>&1

echo "========================================="
echo " Helios first-boot application setup"
echo " $(date --iso-8601=seconds)"
echo "========================================="

for attempt in $(seq 1 30); do
    if curl -fsS --max-time 5 https://dl.flathub.org/ >/dev/null; then
        break
    fi

    echo "Waiting for internet connection ($attempt/30)..."
    sleep 5
done

if ! curl -fsS --max-time 5 https://dl.flathub.org/ >/dev/null; then
    echo "No internet connection. Setup will retry after the next boot."
    exit 1
fi

flatpak remote-add \
    --system \
    --if-not-exists \
    flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

echo "Installing Spotify..."
flatpak install \
    --system \
    --noninteractive \
    --or-update \
    flathub \
    com.spotify.Client

echo "Updating installed Flatpak applications..."
flatpak update --system --noninteractive

touch "$STAMP"
echo "First-boot application setup completed successfully."
