#!/usr/bin/env bash

LOG="$HOME/brave-launch.log"

{
    echo
    echo "========================================"
    date
    echo "Starting Brave..."
    echo "DISPLAY=${DISPLAY:-unset}"
    echo "XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-unset}"
    echo

    exec /usr/bin/brave-browser-stable \
        --password-store=basic \
        --disable-gpu \
        --disable-gpu-compositing
} >>"$LOG" 2>&1
