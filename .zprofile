typeset -U path
path=(~/bin(N-/) ~/.local/bin(N-/) /usr/local/bin(N-/) $path)

typeset -U fpath
fpath=(/usr/local/share/zsh/site-functions(N-/) $fpath)


() {
    if (( $+commands[tmux] )); then
        if (( $+SSH_CONNECTION && ! $+TMUX )); then
            local sessions=($(tmux list-sessions -F \#S 2>/dev/null))
            if (( $+sessions[1] )); then
                exec tmux attach -dt $sessions[1]
            fi
            exec tmux new
        fi
    fi
}
