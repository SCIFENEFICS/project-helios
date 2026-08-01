#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILED=0

pass() {
    echo "PASS: $*"
}

fail() {
    echo "FAIL: $*"
    FAILED=1
}

echo "=========================================="
echo " Project Helios: Project Validation"
echo "=========================================="
echo

REQUIRED_FILES=(
    "README.md"
    "install.sh"
    "config/helios.conf"
    "packages/base.txt"
    "packages/flatpak.txt"
    "packages/external.txt"
    "flex-launcher/config.ini"
    "openbox/autostart"
    "openbox/environment"
    "openbox/rc.xml"
    "lightdm/helios-autologin.conf"
    "sessions/helios.desktop"
)

echo "--- Required files ---"

for FILE in "${REQUIRED_FILES[@]}"; do
    if [[ -s "$PROJECT_DIR/$FILE" ]]; then
        pass "$FILE"
    else
        fail "$FILE is missing or empty"
    fi
done

echo
echo "--- Shell syntax ---"

while IFS= read -r -d '' SCRIPT; do
    RELATIVE="${SCRIPT#"$PROJECT_DIR/"}"

    if bash -n "$SCRIPT"; then
        pass "$RELATIVE"
    else
        fail "$RELATIVE"
    fi
done < <(
    find "$PROJECT_DIR" \
        -type f \
        \( -name '*.sh' -o -name 'install.sh' -o -name 'autostart' -o -name 'environment' \) \
        -print0
)

echo
echo "--- Executable scripts ---"

while IFS= read -r -d '' SCRIPT; do
    RELATIVE="${SCRIPT#"$PROJECT_DIR/"}"

    if [[ -x "$SCRIPT" ]]; then
        pass "$RELATIVE"
    else
        fail "$RELATIVE is not executable"
    fi
done < <(
    find "$PROJECT_DIR/scripts" -maxdepth 1 -type f -name '*.sh' -print0
)

if [[ -x "$PROJECT_DIR/install.sh" ]]; then
    pass "install.sh"
else
    fail "install.sh is not executable"
fi

echo
echo "--- Openbox XML ---"

if python3 - "$PROJECT_DIR/openbox/rc.xml" <<'PY'
import sys
import xml.etree.ElementTree as ET

ET.parse(sys.argv[1])
PY
then
    pass "openbox/rc.xml"
else
    fail "openbox/rc.xml"
fi

echo
echo "--- Desktop files ---"

for FILE in "$PROJECT_DIR"/desktop-files/*.desktop; do
    NAME="$(basename "$FILE")"

    if grep -q '^\[Desktop Entry\]$' "$FILE" &&
       grep -q '^Type=Application$' "$FILE" &&
       grep -q '^Name=' "$FILE" &&
       grep -q '^Exec=' "$FILE"; then
        pass "$NAME"
    else
        fail "$NAME"
    fi
done

echo
echo "--- Package list duplicates ---"

for FILE in \
    "$PROJECT_DIR/packages/base.txt" \
    "$PROJECT_DIR/packages/flatpak.txt" \
    "$PROJECT_DIR/packages/external.txt" \
    "$PROJECT_DIR/packages/optional.txt"
do
    NAME="${FILE#"$PROJECT_DIR/"}"

    DUPLICATES="$(
        grep -Ev '^[[:space:]]*(#|$)' "$FILE" |
        sort |
        uniq -d
    )"

    if [[ -z "$DUPLICATES" ]]; then
        pass "$NAME"
    else
        fail "$NAME contains duplicate entries: $DUPLICATES"
    fi
done

echo
echo "--- Flex Launcher configuration ---"

FLEX_CONFIG="$PROJECT_DIR/flex-launcher/config.ini"

for SECTION in Home; do
    if grep -q "^\[$SECTION\]$" "$FLEX_CONFIG"; then
        pass "Flex section: $SECTION"
    else
        fail "Flex section missing: $SECTION"
    fi
done

while IFS= read -r DESKTOP_PATH; do
    BASENAME="$(basename "$DESKTOP_PATH")"
    SOURCE_FILE="$PROJECT_DIR/desktop-files/$BASENAME"

    if [[ -s "$SOURCE_FILE" ]]; then
        pass "Flex desktop target: $BASENAME"
    else
        fail "Flex desktop target missing: $BASENAME"
    fi
done < <(
    grep -o '/home/helios/[^;[:space:]]*\.desktop' "$FLEX_CONFIG" |
    sort -u
)

echo
echo "=========================================="

if [[ $FAILED -eq 0 ]]; then
    echo " Project validation passed"
    RESULT=0
else
    echo " Project validation failed"
    RESULT=1
fi

echo "=========================================="

exit "$RESULT"
