#!/usr/bin/env bash
set -u

ACTIVE_WINDOW="$(xdotool getactivewindow 2>/dev/null)" || exit 0
WINDOW_CLASS="$(xprop -id "$ACTIVE_WINDOW" WM_CLASS 2>/dev/null || true)"
WINDOW_PID="$(xdotool getwindowpid "$ACTIVE_WINDOW" 2>/dev/null || true)"

# Never close Flex Launcher itself.
if [[ "$WINDOW_CLASS" == *'"flex-launcher", "flex-launcher"'* ]]; then
    exit 0
fi

case "$WINDOW_CLASS" in
    *PlexHTPC*|*plex*)
        flatpak kill tv.plex.PlexHTPC 2>/dev/null || true
        ;;

    *Spotify*|*spotify*)
        flatpak kill com.spotify.Client 2>/dev/null || true
        ;;

    *Moonlight*|*moonlight*)
        flatpak kill com.moonlight_stream.Moonlight 2>/dev/null || true
        ;;

    *VacuumTube*|*vacuumtube*)
        flatpak kill rocks.shy.VacuumTube 2>/dev/null || true
        ;;

    *Brave-browser*|*brave-browser*|*Brave*)
        pkill -TERM -u "$USER" -f '/opt/brave.com/brave/brave' 2>/dev/null || true
        ;;

    *mpv*|*Mpv*)
        pkill -TERM -u "$USER" -x mpv 2>/dev/null || true
        ;;

    *Pcmanfm*|*pcmanfm*)
        pkill -TERM -u "$USER" -x pcmanfm 2>/dev/null || true
        ;;

    *XTerm*|*xterm*)
        if [[ -n "$WINDOW_PID" ]]; then
            kill -TERM "$WINDOW_PID" 2>/dev/null || true
        else
            xdotool windowclose "$ACTIVE_WINDOW"
        fi
        ;;

    *)
        # Unknown applications receive a normal close request first.
        xdotool windowclose "$ACTIVE_WINDOW"

        # If the window remains after two seconds, terminate its process.
        sleep 2

        if xdotool getwindowname "$ACTIVE_WINDOW" >/dev/null 2>&1 &&
           [[ -n "$WINDOW_PID" ]]; then
            kill -TERM "$WINDOW_PID" 2>/dev/null || true
        fi
        ;;
esac
