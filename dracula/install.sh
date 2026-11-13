#!/usr/bin/env bash
# Sort a Dracula Pro download into the app configs in this repo.
#
# Drop the zip from draculatheme.com into this folder and run:
#   ./dracula/install.sh            # uses the newest dracula-pro*.zip here
#   ./dracula/install.sh some.zip   # or a specific one
#
# Dracula Pro is a paid theme: the zip and every file this copies are
# gitignored, so none of it ends up in the public repo.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
repo="$(dirname "$here")"

zip="${1:-$(ls -t "$here"/dracula-pro*.zip 2>/dev/null | head -1 || true)}"
if [[ -z "$zip" || ! -f "$zip" ]]; then
  echo "No dracula-pro*.zip found in $here" >&2
  exit 1
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
unzip -q "$zip" 'themes/*' -d "$tmp"
t="$tmp/themes"
echo "Installing from $(basename "$zip")"

# Ghostty: zip has bare variant names (pro, buffy, ...); config wants dracula-pro[-variant]
mkdir -p "$repo/ghostty/themes"
for f in "$t"/ghostty/*; do
  name="$(basename "$f")"
  [[ "$name" == *.md ]] && continue
  [[ "$name" == pro ]] && dest=dracula-pro || dest="dracula-pro-$name"
  cp "$f" "$repo/ghostty/themes/$dest"
done
echo "  ghostty/themes"

# Alacritty
mkdir -p "$repo/alacritty/themes"
cp "$t"/alacritty/themes/*.toml "$repo/alacritty/themes/"
echo "  alacritty/themes"

# Neovim: vim colorschemes plus their autoload helpers (lightline, airline)
mkdir -p "$repo/nvim/colors" "$repo/nvim/autoload"
cp "$t"/vim/colors/*.vim "$repo/nvim/colors/"
cp -R "$t"/vim/autoload/. "$repo/nvim/autoload/"
echo "  nvim/colors, nvim/autoload"

# Doom Emacs
mkdir -p "$repo/doom/themes"
cp "$t"/emacs/*-theme.el "$repo/doom/themes/"
echo "  doom/themes"

# Zed
mkdir -p "$repo/zed/themes"
cp "$t"/zed/dracula-pro.json "$repo/zed/themes/"
echo "  zed/themes"

echo "Done. Restart the apps (or reload their config) to pick up changes."
