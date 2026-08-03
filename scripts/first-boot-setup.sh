#!/usr/bin/env bash
set -Eeuo pipefail

STAMP="/var/lib/helios/first-boot-complete"
LOG="/var/log/helios-first-boot.log"

mkdir -p /var/lib/helios

if [[ -f "$STAMP" ]]; then
    exit 0
fi

exec >>"$LOG" 2>&1

APP_LIST="/opt/helios/packages/flatpak.txt"

run_message() {
    echo "$1" >> "$LOG"
}

run_message "========================================="
run_message " Project Helios First Boot Setup"
run_message "========================================="

run_message "Checking internet connection..."

for attempt in $(seq 1 30); do
    if curl -fsS --max-time 5 https://flathub.org >/dev/null; then
        break
    fi
    sleep 5
done

if ! curl -fsS --max-time 5 https://flathub.org >/dev/null; then
    run_message "No internet connection available."
    exit 1
fi

run_message "Installing Brave Browser..."

if ! command -v brave-browser >/dev/null 2>&1; then
    install -d -m 0755 /usr/share/keyrings

    curl -fsSLo \
        /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

    curl -fsSLo \
        /etc/apt/sources.list.d/brave-browser-release.sources \
        https://brave-browser-apt-release.s3.brave.com/brave-browser.sources

    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y brave-browser
fi

flatpak remote-add \
    --system \
    --if-not-exists \
    flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

while IFS='|' read -r APP_ID DISPLAY_NAME; do
    APP_ID="$(echo "$APP_ID" | xargs)"
    DISPLAY_NAME="$(echo "$DISPLAY_NAME" | xargs)"

    [[ -z "$APP_ID" ]] && continue
    [[ "$APP_ID" == \#* ]] && continue

    run_message "Installing $DISPLAY_NAME..."

    flatpak install \
        --system \
        --noninteractive \
        --or-update \
        flathub \
        "$APP_ID"

done < "$APP_LIST"

flatpak update --system --noninteractive

run_message "Helios first boot setup complete."
sleep 3

touch "$STAMP"
