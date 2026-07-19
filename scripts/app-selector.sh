#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_DIR/output/logs"
LOG_FILE="$LOG_DIR/app-selector.log"

mkdir -p "$LOG_DIR"

log_message() {
    printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}

if ! command -v zenity >/dev/null 2>&1; then
    echo "ERROR: Zenity is not installed."
    echo "Install the zenity package to use the maintenance menu."
    exit 1
fi

CHOICE="$(
    zenity --list \
        --title="Project Helios Maintenance" \
        --width=520 \
        --height=420 \
        --column="Maintenance Tool" \
        "Network Settings" \
        "Audio Settings" \
        "File Manager" \
        "Terminal" \
        "VA-API Diagnostics" \
        "Restart Flex Launcher" \
        "Log Out" \
        2>/dev/null
)" || exit 0

log_message "Selected: $CHOICE"

case "$CHOICE" in
    "Network Settings")
        nm-connection-editor >/dev/null 2>&1 &
        ;;

    "Audio Settings")
        pavucontrol >/dev/null 2>&1 &
        ;;

    "File Manager")
        pcmanfm "$HOME" >/dev/null 2>&1 &
        ;;

    "Terminal")
        lxterminal >/dev/null 2>&1 &
        ;;

    "VA-API Diagnostics")
        lxterminal \
            -e bash -lc \
            "\"$PROJECT_DIR/scripts/verify-vaapi.sh\"; echo; read -rp 'Press Enter to close...'" \
            >/dev/null 2>&1 &
        ;;

    "Restart Flex Launcher")
        pkill -x flex-launcher 2>/dev/null || true
        ;;

    "Log Out")
        openbox --exit
        ;;

    *)
        log_message "Unknown selection: $CHOICE"
        exit 1
        ;;
esac
