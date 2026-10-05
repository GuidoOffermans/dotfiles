#!/usr/bin/env bash
# Symlink Windows dotfiles with GNU Stow. Run from Git Bash:
#   ~/dotfiles/windows/install.sh            # link (restow)
#   ~/dotfiles/windows/install.sh --delete   # unlink
#
# Requires Windows Developer Mode (for unprivileged symlinks) and stow on PATH.
set -euo pipefail

# Make MSYS/perl create real Windows symlinks instead of silently copying
export MSYS=winsymlinks:nativestrict

WINDOWS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$WINDOWS_DIR")"
WT_DIR="$(cygpath -u "$LOCALAPPDATA")/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState"

MODE="--restow"
[[ "${1:-}" == "--delete" ]] && MODE="--delete"

# timestamped so a re-run never overwrites an earlier backup
BACKUP_SUFFIX=".pre-stow.$(date +%Y%m%d-%H%M%S)"

if [[ "$MODE" != "--delete" ]]; then
    # only created on Terminal's first launch
    mkdir -p "$WT_DIR"

    # Git Bash may have generated its own copies on a fresh machine
    for f in .bashrc .bash_profile; do
        if [[ -f "$HOME/$f" && ! -L "$HOME/$f" ]]; then
            mv "$HOME/$f" "$HOME/$f$BACKUP_SUFFIX"
            echo "moved existing ~/$f to ~/$f$BACKUP_SUFFIX"
        fi
    done
fi

# A running Windows Terminal instantly regenerates settings.json when it's
# missing, so stow can't just move it aside. Instead back it up and atomically
# rename the exact link stow would create over it; stow then sees it as its own.
# (A real file here is the user's settings, so it's backed up, never discarded.)
rel="$(realpath --relative-to="$WT_DIR" "$WINDOWS_DIR/windows-terminal/settings.json")"
if [[ "$MODE" != "--delete" && -e "$WT_DIR/settings.json" && "$(readlink "$WT_DIR/settings.json")" != "$rel" ]]; then
    if [[ ! -L "$WT_DIR/settings.json" ]]; then
        cp "$WT_DIR/settings.json" "$WT_DIR/settings.json$BACKUP_SUFFIX"
        echo "backed up existing Windows Terminal settings to settings.json$BACKUP_SUFFIX"
    fi
    # use perl (like stow does): MSYS ln/mv rewrite the link as absolute,
    # which stow then refuses to own
    (cd "$WT_DIR" && perl -e 'symlink($ARGV[0], "settings.json.tmp-link") or die "symlink: $!\n";
        rename("settings.json.tmp-link", "settings.json") or die "rename: $!\n"' "$rel")
fi

# --no-folding: link files, never whole directories. Otherwise a missing
# ~/.config would become a link into the repo and every tool writing there
# would dump its files into the dotfiles.
STOW=(stow --verbose --no-folding "$MODE")

# Shared packages from the main dotfiles repo
"${STOW[@]}" --dir="$DOTFILES_DIR" --target="$HOME" ohmyposh
# only nvim from config/.config: the rest there is macOS-only.
# XDG_CONFIG_HOME=~/.config (bootstrap.ps1) makes nvim look here
mkdir -p "$HOME/.config/nvim"
"${STOW[@]}" --dir="$DOTFILES_DIR/config/.config" --target="$HOME/.config/nvim" nvim

# Windows-only packages
"${STOW[@]}" --dir="$WINDOWS_DIR" --target="$HOME" bash git
"${STOW[@]}" --dir="$WINDOWS_DIR" --target="$WT_DIR" windows-terminal

# Windows Terminal only watches its own folder, so edits to the linked file in
# the repo go unnoticed. Touching the link itself makes it reload settings.
if [[ "$MODE" != "--delete" ]]; then
    touch -h "$WT_DIR/settings.json"
fi
