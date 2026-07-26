#!/usr/bin/env bash

ACTIVE_WINDOW="$(xdotool getactivewindow 2>/dev/null)" || exit 0
WINDOW_CLASS="$(xprop -id "$ACTIVE_WINDOW" WM_CLASS 2>/dev/null)"

if [[ "$WINDOW_CLASS" == *'"flex-launcher", "flex-launcher"'* ]]; then
    exit 0
fi

xdotool windowclose "$ACTIVE_WINDOW"
