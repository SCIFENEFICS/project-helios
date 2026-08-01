#!/usr/bin/env bash
set -Eeuo pipefail

ISO="${1:?Usage: validate-iso.sh /path/to/image.iso}"
WORK="$(mktemp -d "$PWD/.validate-iso.XXXXXX")"
trap 'sudo mountpoint -q "$WORK/root" && sudo umount "$WORK/root"; sudo rm -rf "$WORK"' EXIT

command -v xorriso >/dev/null || {
    echo "FAIL: xorriso is not installed"
    exit 1
}

command -v unsquashfs >/dev/null || {
    echo "FAIL: unsquashfs is not installed"
    exit 1
}

mkdir -p "$WORK/root"

echo "Mounting finished ISO filesystem..."

xorriso -osirrox on \
    -indev "$ISO" \
    -extract /live/filesystem.squashfs "$WORK/filesystem.squashfs" \
    >/dev/null 2>&1

sudo mount -o loop,ro "$WORK/filesystem.squashfs" "$WORK/root"

ROOT="$WORK/root"
FAILED=0

check_file() {
    if sudo test -e "$ROOT$1"; then
        echo "PASS: $1"
    else
        echo "FAIL: missing $1"
        FAILED=1
    fi
}

check_package() {
    if sudo chroot "$ROOT" dpkg-query -W -f='${Status}' "$1" 2>/dev/null |
        grep -q 'install ok installed'; then
        echo "PASS: package $1"
    else
        echo "FAIL: package $1"
        FAILED=1
    fi
}

check_enabled() {
    if sudo chroot "$ROOT" systemctl is-enabled "$1" >/dev/null 2>&1; then
        echo "PASS: enabled $1"
    else
        echo "FAIL: not enabled $1"
        FAILED=1
    fi
}

check_package openssh-server
check_package lightdm
check_package openbox
check_package network-manager

check_file /usr/local/bin/flex-launcher
check_file /home/helios/.config/openbox/autostart
check_file /home/helios/.config/flex-launcher/config.ini
check_file /etc/lightdm/lightdm.conf.d/50-helios-autologin.conf

check_enabled ssh.service
check_enabled lightdm.service
check_enabled NetworkManager.service

if sudo grep -RqsF '[[' \
    "$ROOT/home/helios/.config/openbox" \
    "$ROOT/etc/xdg/openbox" 2>/dev/null; then
    echo "FAIL: Bash-only [[ found in Openbox files"
    FAILED=1
else
    echo "PASS: Openbox scripts use compatible shell syntax"
fi

if (( FAILED != 0 )); then
    echo
    echo "ISO VALIDATION FAILED - RELEASE REJECTED"
    exit 1
fi

echo
echo "ISO VALIDATION PASSED"
