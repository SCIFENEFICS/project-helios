#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="${1:?Usage: $0 <runtime-destination>}"

rm -rf "$RUNTIME_DIR"
install -d -m 0755 "$RUNTIME_DIR"

copy_dir() {
    local source="$1"

    if [[ ! -d "$PROJECT_DIR/$source" ]]; then
        echo "ERROR: Missing runtime source directory: $source" >&2
        exit 1
    fi

    cp -a "$PROJECT_DIR/$source" "$RUNTIME_DIR/"
}

copy_dir assets
copy_dir config
copy_dir desktop-files
copy_dir flex-launcher
copy_dir lightdm
copy_dir openbox
copy_dir plymouth
copy_dir sessions

install -d -m 0755 "$RUNTIME_DIR/scripts"

for script in \
    app-selector.sh \
    configure-boot.sh \
    configure-flex.sh \
    configure-system.sh \
    escape-close.sh \
    install-external.sh
do
    install -m 0755 \
        "$PROJECT_DIR/scripts/$script" \
        "$RUNTIME_DIR/scripts/$script"
done

echo "Runtime assembled at:"
echo "$RUNTIME_DIR"
