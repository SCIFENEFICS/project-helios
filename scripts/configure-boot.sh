#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_SOURCE="$PROJECT_DIR/plymouth/helios"
THEME_DEST="/usr/share/plymouth/themes/helios"

echo "=========================================="
echo " Project Helios: Boot Configuration"
echo "=========================================="
echo

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must run as root."
    exit 1
fi

if [[ ! -d "$THEME_SOURCE" ]]; then
    echo "ERROR: Plymouth theme not found:"
    echo "$THEME_SOURCE"
    exit 1
fi

echo "Installing Helios Plymouth theme..."

install -d -m 0755 "$THEME_DEST"
install -m 0644 "$THEME_SOURCE/helios.plymouth" "$THEME_DEST/helios.plymouth"
install -m 0644 "$THEME_SOURCE/helios.script" "$THEME_DEST/helios.script"
install -m 0644 "$THEME_SOURCE/helios.png" "$THEME_DEST/helios.png"
install -m 0644 "$THEME_SOURCE/helios.svg" "$THEME_DEST/helios.svg"

echo "Setting Helios as the default Plymouth theme..."

plymouth-set-default-theme helios

echo "Rebuilding initramfs..."

update-initramfs -u -k all

echo "Hiding the GRUB menu and boot messages..."

if [[ -f /etc/grub.d/10_linux ]]; then
    sed -i 's/^quiet_boot="0"$/quiet_boot="1"/' /etc/grub.d/10_linux
fi

install -d -m 0755 /etc/default/grub.d

cat > /etc/default/grub.d/99-helios.cfg <<'EOF'
GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=hidden
GRUB_TIMEOUT=0
GRUB_RECORDFAIL_TIMEOUT=0
GRUB_DISABLE_OS_PROBER=true
GRUB_DISABLE_RECOVERY=true
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=0 systemd.show_status=false rd.systemd.show_status=false rd.udev.log_level=0 udev.log_level=0 vt.global_cursor_default=0 console=tty3"
EOF

update-grub

echo
echo "=========================================="
echo " Boot configuration completed"
echo "=========================================="
