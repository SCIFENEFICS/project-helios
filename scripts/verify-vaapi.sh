#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_DIR/output/logs"
LOG_FILE="$LOG_DIR/verify-vaapi.log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo " Project Helios: VA-API Verification"
echo "=========================================="
echo

FAILED=0

echo "--- Graphics hardware ---"

if command -v lspci >/dev/null 2>&1; then
    lspci | grep -Ei 'vga|3d|display' || true
else
    echo "lspci is not installed."
    FAILED=1
fi

echo
echo "--- Kernel graphics driver ---"

if command -v lspci >/dev/null 2>&1; then
    lspci -k | grep -EA3 'VGA|3D|Display' || true
fi

echo
echo "--- VA-API information ---"

if command -v vainfo >/dev/null 2>&1; then
    if vainfo; then
        echo
        echo "vainfo completed successfully."
    else
        echo
        echo "WARNING: vainfo returned an error."
        FAILED=1
    fi
else
    echo "vainfo is not installed."
    FAILED=1
fi

echo
echo "--- OpenGL renderer ---"

if command -v glxinfo >/dev/null 2>&1; then
    glxinfo -B || {
        echo "WARNING: glxinfo could not query the active display."
        FAILED=1
    }
else
    echo "glxinfo is not installed."
    FAILED=1
fi

echo
echo "--- User groups ---"

CURRENT_USER="${SUDO_USER:-$USER}"

echo "User: $CURRENT_USER"
id "$CURRENT_USER"

for GROUP in video render; do
    if id -nG "$CURRENT_USER" | tr ' ' '\n' | grep -qx "$GROUP"; then
        echo "Present in group: $GROUP"
    else
        echo "Missing from group: $GROUP"
        FAILED=1
    fi
done

echo
echo "--- Device permissions ---"

if compgen -G '/dev/dri/*' >/dev/null; then
    ls -l /dev/dri/
else
    echo "No /dev/dri devices were found."
    FAILED=1
fi

echo
echo "=========================================="

if [[ $FAILED -eq 0 ]]; then
    echo " Hardware acceleration checks passed"
    RESULT=0
else
    echo " One or more checks require attention"
    RESULT=1
fi

echo "=========================================="
echo
echo "Log saved to:"
echo "$LOG_FILE"

exit "$RESULT"
