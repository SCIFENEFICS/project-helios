#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$PROJECT_DIR/config/helios.conf"
LOG_DIR="$PROJECT_DIR/output/logs"
LOG_FILE="$LOG_DIR/configure-system.log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo " Project Helios: System Configuration"
echo "=========================================="
echo

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Run this script with sudo:"
    echo "sudo \"$PROJECT_DIR/scripts/configure-system.sh\""
    exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: Configuration file not found:"
    echo "$CONFIG_FILE"
    exit 1
fi

# shellcheck source=/dev/null
source "$CONFIG_FILE"

if [[ -z "${HELIOS_USER:-}" ]]; then
    echo "ERROR: HELIOS_USER is not defined."
    exit 1
fi

if id "$HELIOS_USER" >/dev/null 2>&1; then
    echo "User '$HELIOS_USER' already exists."
else
    echo "Creating user '$HELIOS_USER'..."

    useradd \
        --create-home \
        --shell /bin/bash \
        "$HELIOS_USER"

    echo
    echo "Set a password for the Helios user:"
    passwd "$HELIOS_USER"
fi

HELIOS_HOME="$(getent passwd "$HELIOS_USER" | cut -d: -f6)"

if [[ -z "$HELIOS_HOME" || ! -d "$HELIOS_HOME" ]]; then
    echo "ERROR: Could not determine the Helios home directory."
    exit 1
fi

echo
echo "Helios home directory:"
echo "$HELIOS_HOME"

echo
echo "Adding the Helios user to required hardware groups..."

for GROUP in audio video render input netdev; do
    if getent group "$GROUP" >/dev/null 2>&1; then
        usermod -aG "$GROUP" "$HELIOS_USER"
        echo "Added to group: $GROUP"
    else
        echo "Group not present, skipped: $GROUP"
    fi
done

echo
echo "Creating Helios directories..."

install -d -o "$HELIOS_USER" -g "$HELIOS_USER" \
    "$HELIOS_HOME/.config" \
    "$HELIOS_HOME/.config/openbox" \
    "$HELIOS_HOME/.config/helios" \
    "$HELIOS_HOME/.config/flex-launcher" \
    "$HELIOS_HOME/.local" \
    "$HELIOS_HOME/.local/share" \
    "$HELIOS_HOME/.local/share/helios" \
    "$HELIOS_HOME/.local/share/helios/backgrounds" \
    "$HELIOS_HOME/.local/share/helios/icons" \
    "$HELIOS_HOME/Videos"

echo
echo "Installing Helios maintenance tools..."
install -m 0755 "$PROJECT_DIR/scripts/escape-close.sh" /usr/local/bin/helios-escape-close

install -d -o "$HELIOS_USER" -g "$HELIOS_USER"     "$HELIOS_HOME/.local/bin"

install -o "$HELIOS_USER" -g "$HELIOS_USER" -m 0755     "$PROJECT_DIR/scripts/app-selector.sh"     "$HELIOS_HOME/.local/bin/helios-maintenance"

echo
echo "Installing Openbox configuration..."

install -m 0755 \
    "$PROJECT_DIR/openbox/autostart" \
    "$HELIOS_HOME/.config/openbox/autostart"

install -m 0644 \
    "$PROJECT_DIR/openbox/environment" \
    "$HELIOS_HOME/.config/openbox/environment"

if [[ -s "$PROJECT_DIR/openbox/rc.xml" ]]; then
    install -m 0644 \
        "$PROJECT_DIR/openbox/rc.xml" \
        "$HELIOS_HOME/.config/openbox/rc.xml"
else
    echo "Openbox rc.xml is currently empty and was not copied."
fi

echo
echo "Installing LightDM autologin configuration..."

install -d -m 0755 /etc/lightdm/lightdm.conf.d
install -m 0644     "$PROJECT_DIR/lightdm/helios-autologin.conf"     /etc/lightdm/lightdm.conf.d/50-helios-autologin.conf

echo
echo "Installing the Project Helios session..."

install -d -m 0755 /usr/share/xsessions
install -m 0644     "$PROJECT_DIR/sessions/helios.desktop"     /usr/share/xsessions/helios.desktop

echo
echo "Enabling graphical startup and LightDM..."

systemctl set-default graphical.target
systemctl enable lightdm.service

echo
echo "Installing Helios configuration..."

install -m 0644 \
    "$PROJECT_DIR/config/helios.conf" \
    "$HELIOS_HOME/.config/helios/helios.conf"

if [[ -s "$PROJECT_DIR/flex-launcher/config.ini" ]]; then
    install -m 0644 \
        "$PROJECT_DIR/flex-launcher/config.ini" \
        "$HELIOS_HOME/.config/flex-launcher/config.ini"
else
    echo "Flex Launcher config.ini is currently empty and was not copied."
fi

echo
echo "Copying available assets..."

if compgen -G "$PROJECT_DIR/assets/backgrounds/*" >/dev/null; then
    cp -a \
        "$PROJECT_DIR/assets/backgrounds/." \
        "$HELIOS_HOME/.local/share/helios/backgrounds/"
fi

if compgen -G "$PROJECT_DIR/assets/icons/*" >/dev/null; then
    cp -a \
        "$PROJECT_DIR/assets/icons/." \
        "$HELIOS_HOME/.local/share/helios/icons/"
fi

chown -R "$HELIOS_USER:$HELIOS_USER" \
    "$HELIOS_HOME/.config" \
    "$HELIOS_HOME/.local" \
    "$HELIOS_HOME/Videos"

echo
echo "=========================================="
echo " System configuration completed"
echo "=========================================="
echo
echo "Configured user: $HELIOS_USER"
echo "Home directory: $HELIOS_HOME"
echo "Log saved to: $LOG_FILE"
