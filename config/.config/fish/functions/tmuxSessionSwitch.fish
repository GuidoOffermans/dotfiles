function tmuxSessionSwitch
    set session (tmux list-windows -a | fzf | sed 's/: .*//g')
    tmux switch-client -t "$session"
end
