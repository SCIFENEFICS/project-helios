#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$PROJECT_DIR/config/helios.conf"
LOG_DIR="$PROJECT_DIR/output/logs"
LOG_FILE="$LOG_DIR/configure-flex.log"

SOURCE_CONFIG="$PROJECT_DIR/flex-launcher/config.ini"
SOURCE_MENU="$PROJECT_DIR/flex-launcher/menu.ini"
SOURCE_DESKTOP_DIR="$PROJECT_DIR/desktop-files"
SOURCE_ICON_DIR="$PROJECT_DIR/assets/icons"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo " Project Helios: Flex Launcher Setup"
echo "=========================================="
echo

fail() {
    echo "ERROR: $1"
    exit 1
}

read_desktop_value() {
    local file="$1"
    local key="$2"

    sed -n "s/^${key}=//p" "$file" | head -n 1
}

generate_menu_sections() {
    local output_file="$1"
    local section=""
    local entry_number=0
    local line=""
    local type=""
    local value=""
    local desktop_file=""
    local desktop_path=""
    local name=""
    local icon=""
    local target_path=""
    local label=""
    local command=""

    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%$'\r'}"

        if [[ -z "$line" || "$line" == \#* || "$line" == \;* ]]; then
            continue
        fi

        if [[ "$line" =~ ^\[([^]]+)\]$ ]]; then
            section="${BASH_REMATCH[1]}"
            entry_number=0

            echo >> "$output_file"
            echo "[$section]" >> "$output_file"
            continue
        fi

        if [[ -z "$section" ]]; then
            fail "Menu entry appears before a section in $SOURCE_MENU: $line"
        fi

        if [[ "$line" != *=* ]]; then
            fail "Invalid menu definition in $SOURCE_MENU: $line"
        fi

        type="${line%%=*}"
        value="${line#*=}"
        entry_number=$((entry_number + 1))

        case "$type" in
            app)
                desktop_file="$value"
                desktop_path="$SOURCE_DESKTOP_DIR/$desktop_file"

                if [[ ! -s "$desktop_path" ]]; then
                    fail "Desktop file referenced by menu.ini was not found: $desktop_file"
                fi

                name="$(read_desktop_value "$desktop_path" "Name")"
                icon="$(read_desktop_value "$desktop_path" "Icon")"

                if [[ -z "$name" ]]; then
                    fail "Desktop file has no Name= entry: $desktop_path"
                fi

                if [[ -z "$icon" ]]; then
                    fail "Desktop file has no Icon= entry: $desktop_path"
                fi

                target_path="$TARGET_DESKTOP_DIR/$desktop_file"

                printf 'Entry%d=%s;%s;%s\n' \
                    "$entry_number" \
                    "$name" \
                    "$icon" \
                    "$target_path" >> "$output_file"
                ;;

            submenu)
                if [[ "$value" != *"|"* ]]; then
                    fail "Invalid submenu definition in $SOURCE_MENU: $line"
                fi

                label="${value%%|*}"
                icon="${value#*|}"

                if [[ -z "$label" || -z "$icon" ]]; then
                    fail "Incomplete submenu definition in $SOURCE_MENU: $line"
                fi

                printf 'Entry%d=%s;%s;:submenu %s\n' \
                    "$entry_number" \
                    "$label" \
                    "$icon" \
                    "$label" >> "$output_file"
                ;;

            action)
                IFS='|' read -r label icon command <<< "$value"

                if [[ -z "$label" || -z "$icon" || -z "$command" ]]; then
                    fail "Invalid action definition in $SOURCE_MENU: $line"
                fi

                printf 'Entry%d=%s;%s;%s\n' \
                    "$entry_number" \
                    "$label" \
                    "$icon" \
                    "$command" >> "$output_file"
                ;;

            *)
                fail "Unknown menu entry type '$type' in $SOURCE_MENU"
                ;;
        esac
    done < "$SOURCE_MENU"

    if [[ -z "$section" ]]; then
        fail "No menu sections were found in $SOURCE_MENU"
    fi
}

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Run this script with sudo:"
    echo "sudo \"$PROJECT_DIR/scripts/configure-flex.sh\""
    exit 1
fi

[[ -s "$CONFIG_FILE" ]] || fail "Configuration file not found or empty: $CONFIG_FILE"

# shellcheck source=/dev/null
source "$CONFIG_FILE"

[[ -n "${HELIOS_USER:-}" ]] || fail "HELIOS_USER is not defined in $CONFIG_FILE"

if ! id "$HELIOS_USER" >/dev/null 2>&1; then
    fail "User '$HELIOS_USER' does not exist. Run configure-system.sh first."
fi

HELIOS_HOME="$(getent passwd "$HELIOS_USER" | cut -d: -f6)"

[[ -n "$HELIOS_HOME" ]] || fail "Could not determine the Helios home directory"
[[ -d "$HELIOS_HOME" ]] || fail "Helios home directory does not exist: $HELIOS_HOME"

TARGET_CONFIG_DIR="$HELIOS_HOME/.config/flex-launcher"
TARGET_DESKTOP_DIR="$HELIOS_HOME/.local/share/applications"
TARGET_ICON_DIR="/usr/share/flex-launcher/assets/icons"

[[ -s "$SOURCE_CONFIG" ]] || fail "Flex Launcher configuration is missing or empty: $SOURCE_CONFIG"
[[ -s "$SOURCE_MENU" ]] || fail "Menu definition is missing or empty: $SOURCE_MENU"

if ! compgen -G "$SOURCE_DESKTOP_DIR/*.desktop" >/dev/null; then
    fail "No desktop files were found in: $SOURCE_DESKTOP_DIR"
fi

echo "Validating source desktop files..."

for desktop_file in "$SOURCE_DESKTOP_DIR"/*.desktop; do
    name="$(read_desktop_value "$desktop_file" "Name")"
    icon="$(read_desktop_value "$desktop_file" "Icon")"

    [[ -n "$name" ]] || fail "Desktop file has no Name= entry: $desktop_file"
    [[ -n "$icon" ]] || fail "Desktop file has no Icon= entry: $desktop_file"

    echo "Valid: $(basename "$desktop_file")"
done

echo
echo "Creating target directories..."

install -d -o "$HELIOS_USER" -g "$HELIOS_USER" "$TARGET_CONFIG_DIR" "$TARGET_DESKTOP_DIR"
install -d -o root -g root "$TARGET_ICON_DIR"

echo
echo "Installing application desktop files..."

for desktop_file in "$SOURCE_DESKTOP_DIR"/*.desktop; do
    install -o "$HELIOS_USER" -g "$HELIOS_USER" -m 0644 \
        "$desktop_file" \
        "$TARGET_DESKTOP_DIR/$(basename "$desktop_file")"

    echo "Installed: $(basename "$desktop_file")"
done

echo
echo "Copying launcher icons when available..."

if [[ -d "$SOURCE_ICON_DIR" ]] &&
   compgen -G "$SOURCE_ICON_DIR/*" >/dev/null; then
    cp -a "$SOURCE_ICON_DIR/." "$TARGET_ICON_DIR/"
    echo "Icons copied."
else
    echo "No custom icons are currently present."
fi

echo
echo "Generating Flex Launcher configuration..."

TEMP_CONFIG="$(mktemp)"
trap 'rm -f "$TEMP_CONFIG"' EXIT

awk '
    /^\[Home\]$/ {
        exit
    }

    {
        print
    }
' "$SOURCE_CONFIG" > "$TEMP_CONFIG"

generate_menu_sections "$TEMP_CONFIG"

install -o "$HELIOS_USER" -g "$HELIOS_USER" -m 0644 \
    "$TEMP_CONFIG" \
    "$TARGET_CONFIG_DIR/config.ini"

echo "Generated: $TARGET_CONFIG_DIR/config.ini"

echo
echo "Validating installed files..."

[[ -s "$TARGET_CONFIG_DIR/config.ini" ]] ||
    fail "Installed Flex Launcher configuration is missing"

failed=0

for desktop_file in "$SOURCE_DESKTOP_DIR"/*.desktop; do
    basename="$(basename "$desktop_file")"

    if [[ -s "$TARGET_DESKTOP_DIR/$basename" ]]; then
        echo "Present: $basename"
    else
        echo "MISSING: $basename"
        failed=1
    fi
done

if [[ $failed -ne 0 ]]; then
    fail "One or more desktop files were not installed"
fi

for section in Home; do
    if grep -Fxq "[$section]" "$TARGET_CONFIG_DIR/config.ini"; then
        echo "Present: [$section]"
    else
        fail "Generated configuration is missing the [$section] section"
    fi
done

echo
echo "=========================================="
echo " Flex Launcher setup completed"
echo "=========================================="
echo
echo "Configuration:"
echo "$TARGET_CONFIG_DIR/config.ini"
echo
echo "Menu definition:"
echo "$SOURCE_MENU"
echo
echo "Desktop files:"
echo "$TARGET_DESKTOP_DIR"
echo
echo "Log saved to:"
echo "$LOG_FILE"