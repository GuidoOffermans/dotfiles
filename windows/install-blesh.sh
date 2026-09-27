#!/usr/bin/env bash
# Install ble.sh (syntax highlighting + autosuggestions for bash) into
# ~/.local/share/blesh. Uses the prebuilt nightly, so no make/gawk needed.
# Update later from inside a shell with `ble-update`.
set -euo pipefail

DEST="$HOME/.local/share"

if [[ -f "$DEST/blesh/ble.sh" ]]; then
    echo "ble.sh already installed"
    exit 0
fi

SRC="$(mktemp -d)"
trap 'rm -rf "$SRC"' EXIT

curl -fsSL https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar xJ -C "$SRC"
bash "$SRC/ble-nightly/ble.sh" --install "$DEST"

echo "installed ble.sh into $DEST/blesh"
