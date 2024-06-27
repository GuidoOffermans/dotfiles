fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin

starship init fish | source
zoxide init fish | source

alias ts="tmuxSessionSwitch"
alias lg='lazygit'
alias sf='source ~/.config/fish/config.fish'
alias trash='trash-put'
# alias rm='echo "Use trash instead of rm"'

alias gco='git checkout'
alias gst='git status'
alias gcm='git checkout main'

alias fnm='find . -name "node_modules" -type d -prune -print | xargs du -chs'
alias tnm='find . -name 'node_modules' -type d -prune -print -exec trash-put '{}' \;'

alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH
set -gx EDITOR nvim
set -gx PATH "$HOME/.cargo/bin" $PATH;
set -x PATH $HOME/.emacs.d/bin $PATH

fish_add_path /Users/guidooffermans/bin
fish_add_path /usr/local/sbin
fish_add_path /usr/local/bin
#fish_add_path /usr/local/bin/docker
#fish_add_path /Applications/Docker.app/Contents/Resources/bin/
fish_add_path ~/.composer/vendor/bin

set -gx FZF_DEFAULT_COMMAND "find . -type f -not -path '*/\.git/*'"

thefuck --alias | source
