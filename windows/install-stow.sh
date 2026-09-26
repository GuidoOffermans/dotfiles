#!/usr/bin/env bash
# Install GNU Stow into ~/bin for Git Bash. Stow isn't on winget, but it's pure
# Perl and Git Bash ships Perl, so we just fill in the build templates by hand.
set -euo pipefail

# --version fails on a half-finished install (e.g. missing lib), so that gets redone
if stow --version >/dev/null 2>&1; then
    echo "stow already installed: $(stow --version)"
    exit 0
fi

LIB="$HOME/.local/share/stow/lib"
SRC="$(mktemp -d)"
trap 'rm -rf "$SRC"' EXIT

curl -fsSL https://ftp.gnu.org/gnu/stow/stow-latest.tar.gz | tar xz -C "$SRC"
cd "$SRC"/stow-*/
VERSION="$(basename "$PWD" | cut -d- -f2)"

mkdir -p "$LIB/Stow" "$HOME/bin"
sub() {
    sed -e 's|@PERL@|/usr/bin/perl|' \
        -e "s|@VERSION@|$VERSION|" \
        -e "s|@USE_LIB_PMDIR@|use lib \"$LIB\";|" "$1" > "$2"
}
sub bin/stow.in "$HOME/bin/stow"
sub bin/chkstow.in "$HOME/bin/chkstow"
sub lib/Stow.pm.in "$LIB/Stow.pm"
sub lib/Stow/Util.pm.in "$LIB/Stow/Util.pm"
chmod +x "$HOME/bin/stow" "$HOME/bin/chkstow"

echo "installed $("$HOME/bin/stow" --version)"
