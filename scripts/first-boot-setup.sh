#!/usr/bin/env bash
set -Eeuo pipefail

STAMP="/var/lib/helios/first-boot-complete"
LOG="/var/log/helios-first-boot.log"

mkdir -p /var/lib/helios

if [[ -f "$STAMP" ]]; then
    exit 0
fi

exec > >(tee -a "$LOG") 2>&1

APP_LIST="/opt/helios/packages/flatpak.txt"
FAILED=0

run_message() {
    echo "$1"
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

BRAVE_FAILED=0

if ! command -v brave-browser >/dev/null 2>&1; then
    install -d -m 0755 /usr/share/keyrings

    if ! curl -fsSLo \
        /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg; then
        run_message "Failed to download the Brave signing key."
        BRAVE_FAILED=1
    fi

    if ! curl -fsSLo \
        /etc/apt/sources.list.d/brave-browser-release.sources \
        https://brave-browser-apt-release.s3.brave.com/brave-browser.sources; then
        run_message "Failed to download the Brave repository configuration."
        BRAVE_FAILED=1
    fi

    if [[ "$BRAVE_FAILED" -eq 0 ]]; then
        if ! apt-get -o DPkg::Lock::Timeout=300 update; then
            run_message "APT update failed while preparing Brave."
            BRAVE_FAILED=1
        elif ! DEBIAN_FRONTEND=noninteractive apt-get -o DPkg::Lock::Timeout=300 install -y brave-browser; then
            run_message "Brave Browser installation failed."
            BRAVE_FAILED=1
        fi
    fi
fi

if [[ "$BRAVE_FAILED" -ne 0 ]]; then
    run_message "Brave was not installed, but Flatpak application setup will continue."
    FAILED=1
fi

if ! flatpak remote-add \
    --system \
    --if-not-exists \
    flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo; then
    run_message "Failed to configure Flathub."
    FAILED=1
fi

while IFS='|' read -r APP_ID DISPLAY_NAME; do
    APP_ID="$(echo "$APP_ID" | xargs)"
    DISPLAY_NAME="$(echo "$DISPLAY_NAME" | xargs)"

    [[ -z "$APP_ID" ]] && continue
    [[ "$APP_ID" == \#* ]] && continue

    run_message "Installing $DISPLAY_NAME..."

    if flatpak install \
        --system \
        --noninteractive \
        --or-update \
        flathub \
        "$APP_ID" \
        && flatpak info --system "$APP_ID" >/dev/null 2>&1
    then
        run_message "$DISPLAY_NAME installed successfully."
    else
        run_message "$DISPLAY_NAME installation failed."
        FAILED=1
    fi

done < "$APP_LIST"

if ! flatpak update --system --noninteractive; then
    run_message "One or more Flatpak updates failed."
    FAILED=1
fi

if [[ "$FAILED" -ne 0 ]]; then
    run_message "Setup is incomplete. Please restart Helios to retry."
    exit 1
fi

run_message "Helios first boot setup complete."
sleep 3

touch "$STAMP"
