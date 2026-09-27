# ble.sh: syntax highlighting + autosuggestions (https://github.com/akinomyoga/ble.sh)
# must be sourced first and attached last (see bottom of file)
[[ $- == *i* && -f ~/.local/share/blesh/ble.sh ]] &&
    source ~/.local/share/blesh/ble.sh --noattach

# make `ln -s` create real Windows symlinks instead of silently copying
# (needs Developer Mode; fails loudly rather than falling back to a copy)
export MSYS=winsymlinks:nativestrict

# aliases (same as zsh/.zshrc)
alias gst='git status'
alias gcm='git checkout main'
alias lg='lazygit'

# oh-my-posh prompt (themes: https://ohmyposh.dev/docs/themes)
if command -v oh-my-posh >/dev/null 2>&1; then
    eval "$(oh-my-posh init bash --config ~/.mytheme.omp.toml)"
fi

# fzf: Ctrl+R history, Ctrl+T files, Alt+C cd into dir
if command -v fzf >/dev/null 2>&1; then
    if [[ ${BLE_VERSION-} ]]; then
        # fzf's own bindings use `bind -x`, which ble.sh doesn't handle well
        ble-import -d integration/fzf-completion
        ble-import -d integration/fzf-key-bindings
    else
        eval "$(fzf --bash)"
    fi
fi

# zoxide: smart cd (use `z <dir>`, `zi` for interactive pick)
# keep this last so its prompt hook isn't overwritten
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
    # zoxide 0.10.0's Windows template quotes the command instead of running it
    # (cygpath -w "\builtin pwd -L"), so the directory never changes and nothing
    # is ever recorded. Redefine it correctly.
    __zoxide_pwd() { \command cygpath -w "$(\builtin pwd -L)"; }
fi

# ble.sh: attach after everything else has set up prompts and key bindings
[[ ! ${BLE_VERSION-} ]] || ble-attach
