#!/usr/bin/env bash
# Install the Neovim nightly build into %LOCALAPPDATA%\Programs\nvim-nightly.
# winget's Neovim.Neovim.Nightly is unusable: the nightly asset is rebuilt every
# day, so its pinned installer hash never matches.
#   install-nvim.sh            # install if missing
#   install-nvim.sh --update   # replace with today's nightly
set -euo pipefail

DEST="$(cygpath -u "$LOCALAPPDATA")/Programs/nvim-nightly"

if [[ -x "$DEST/bin/nvim.exe" && "${1:-}" != "--update" ]]; then
    echo "neovim already installed: $("$DEST/bin/nvim.exe" --version | head -1)"
    exit 0
fi

SRC="$(mktemp -d)"
trap 'rm -rf "$SRC"' EXIT

curl -fsSL -o "$SRC/nvim.zip" https://github.com/neovim/neovim/releases/download/nightly/nvim-win64.zip
unzip -q "$SRC/nvim.zip" -d "$SRC"
rm -rf "$DEST"
mkdir -p "$(dirname "$DEST")"
mv "$SRC/nvim-win64" "$DEST"

echo "installed $("$DEST/bin/nvim.exe" --version | head -1) into $DEST"
