# Windows

Stow packages for Windows, used from Git Bash. Also links the shared `ohmyposh` package from the repo root.

| Package | Target |
|---|---|
| `bash` | `~` (Git Bash `.bashrc` / `.bash_profile`) |
| `git` | `~/.config/git/config`: Windows-only git settings (LF line endings, real symlinks, long paths) |
| `windows-terminal` | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState` |

## POSIX-like behaviour

- `ln -s` makes real symlinks (`MSYS=winsymlinks:nativestrict` in `.bashrc`), never silent copies
- Git keeps LF line endings, checks out symlinks as symlinks, and handles paths over 260 chars, overriding Git for Windows' defaults
- `XDG_CONFIG_HOME=~/.config`, so XDG-aware tools (nvim, gh, lazygit, ...) read config from the same place as on Mac/Linux
- fzf key bindings: `Ctrl+R` history, `Ctrl+T` files, `Alt+C` cd

## New machine

```powershell
winget install --id Git.Git -e
git clone https://github.com/GuidoOffermans/dotfiles.git $HOME\dotfiles
powershell -ExecutionPolicy Bypass -File $HOME\dotfiles\windows\bootstrap.ps1
```

`bootstrap.ps1` is **idempotent**: run it as often as you like, on a fresh or an already set-up machine. Every step checks first and only acts on what's missing, so a re-run changes nothing and doesn't upgrade anything. It still fails loudly if an install actually fails. It:

1. Enables Developer Mode (symlinks without admin) and long paths, with one UAC prompt only if either is off
2. Installs WSL2 (platform only, no distro) for Docker Desktop; **needs a reboot** the first time
3. Sets `XDG_CONFIG_HOME` to `~/.config`
4. Installs anything missing from `packages.json` (the Brewfile equivalent)
5. Installs VS Build Tools with the C++ workload (Rust's linker)
6. Sets the Rust stable toolchain
7. Installs the JetBrains Mono Nerd Font
8. Installs GNU Stow into `~/bin` (`install-stow.sh`; not on winget, but it's pure Perl and Git Bash ships Perl)
9. Links everything (`install.sh`)

## Day to day

- Relink: `~/dotfiles/windows/install.sh` (`--delete` to unlink). Also idempotent: existing real files in the way are moved to timestamped `*.pre-stow.<date>` backups, never overwritten.
- Add a tool: add its winget ID to `packages.json`
- Edited `windows-terminal/settings.json`? Run `install.sh` to make Terminal reload it; it doesn't notice changes made through the link on its own
