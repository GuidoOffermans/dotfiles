# .dotfiles

Symlinked into place with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

| Dir | Target |
|---|---|
| `bash`, `bin`, `ohmyposh`, `zsh` | `~` |
| every other top-level dir (`nvim`, `tmux`, `ghostty`, `aerospace`, ...) | `~/.config/<dir>` |
| `windows` | Windows setup from Git Bash, see [windows/README.md](windows/README.md) |

Adding an app config is just a new top-level dir named after its `~/.config` folder; `make` picks it up.

## macOS

```sh
git clone https://github.com/GuidoOffermans/dotfiles.git ~/dotfiles
cd ~/dotfiles
brew bundle   # install everything in the Brewfile
make          # link everything (restow)
```

- `make delete`: unlink everything
- `make adopt`: move existing files in `~` into the repo and link them in their place
