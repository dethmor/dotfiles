() {
    ADOTDIR=$HOME/.antigen

    local rc=$ADOTDIR/antigen.zsh
    [[ -f $rc ]] \
        || curl -SsLo $rc --create-dirs git.io/antigen
    source $rc

    antigen bundles <<EOBUNDLES
        # zsh anything.el-like widget.
        zsh-users/zaw

        # Fish-like autosuggestions for zsh
        zsh-users/zsh-autosuggestions

        # Additional completion definitions for Zsh.
        zsh-users/zsh-completions

        # Fish shell like syntax highlighting for Zsh.
        zsh-users/zsh-syntax-highlighting

        # Because your terminal should be able to perform tasks asynchronously without external tools!
        mafredri/zsh-async

        # Pretty, minimal and fast ZSH prompt
        sindresorhus/pure@main

        # prezto modules
        sorin-ionescu/prezto modules/completion/init.zsh
        sorin-ionescu/prezto modules/history/init.zsh

        # a plugin for finding z abbreviations
        Mellbourn/zabb

        # Autoenv for zsh
        Tarrasch/zsh-autoenv

EOBUNDLES

    antigen apply

    # zsh-users/zaw
    zstyle ':filter-select:highlight' selected fg=black,bg=white,standout
    zstyle ':filter-select' max-lines -10
    zstyle ':filter-select' rotate-list yes
    zstyle ':filter-select' case-incensitive yes
    zstyle ':filter-select' hist-find-no-dups yes

    #bindkey '^R' zaw-history
    bindkey '^\^' zaw-process
    bindkey '^@' zaw-ssh-hosts

    # zsh-users/zsh-autosuggestions
    #ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=magenta,bold,underline'

    # sindresorhus/pure
    # PURE_PROMPT_SYMBOL="‹%(?..$?)›"
    PURE_PROMPT_SYMBOL="%(?..%?)›"

    zstyle ':prompt:pure:user' color blue
    zstyle ':prompt:pure:host' color white
    zstyle ':prompt:pure:git:branch' color magenta

    # sorin-ionescu/prezto/modules/completion/init.zsh
    zstyle ':prezto:module:completion:*:hosts' etc-host-ignores '0.0.0.0' '127.0.0.1' '::1'

    # sorin-ionescu/prezto/modules/history/init.zsh
    SAVEHIST=1000
    HISTSIZE=$((365 * $SAVEHIST))
    alias history='fc -lDi'
    zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }

    # zsh-autoenv
    AUTOENV_FILE_ENTER=.env
    AUTOENV_FILE_LEAVE=.env.leave
}


autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic

bindkey -e
bindkey '^[P' history-beginning-search-backward
bindkey '^[N' history-beginning-search-forward
bindkey '^[B' vi-backward-blank-word
bindkey '^[F' vi-forward-blank-word
bindkey '^[U' backward-delete-word
bindkey '^[K' delete-word


ttyctl -f


update_rprompt_hook() {
    local rprompt=()
    if [[ -n "$AWS_PROFILE" ]]; then
        rprompt+=("[aws:$AWS_PROFILE]")
    fi
    if [[ -n "$KUBECONFIG" ]]; then
        local x="${KUBECONFIG%/config}"
        rprompt+=("[kube:${x#*/.kube.}]")
    fi
    RPROMPT="$rprompt[@]"
}

precmd_functions+=(update_rprompt_hook)


urlencode() {
    local c
    echo "$1" | fold -b1 - | while read -r c; do
	case $c in
	    [a-zA-Z0-9.~_-]) printf '%c' "$c" ;;
	    ' ') printf + ;;
	    *) printf '%%%.2X' "'$c" ;;
	esac
    done
    echo
}


urldecode() {
   echo "$1" | sed 's/+/ /g; s/\%/\\x/g' | xargs -rd\\n printf '%b\n'
}


randstr() {
    local -A opt
    zparseopts -D -A opt -- a: b: n:
    < /dev/random tr -dc ${opt[-a]:-A-Za-z0-9} \
	| fold -b${opt[-b]:-10} | head -n${opt[-n]:-10}
}


mkcd() {
    install -Dd "$1" && cd "$1"
}


cdls() {
    ls -Xv --color=auto --group-directories-first
}

chpwd_functions+=(cdls)


alias relogin='exec $SHELL -l'


alias ls='ls -Xv --color=auto --group-directories-first'


mkcp() {
    install -Dd "$@[-1]" && cp "$@"
}

alias cp='cp -v'


mkmv() {
    install -Dd "$@[-1]" && mv "$@"
}

alias mv='mv -v'


alias rm='rm -v'

if (( $+commands[trash] )); then
    alias rm='trash -v'
fi


if (( $+commands[emacsclient] )); then
    alias emacs='emacsclient -t'
fi


export LESS='iMRS'

if (( $+commands[highlight] )); then
    export LESSOPEN='| highlight -O xterm256 -s base16/dracula --force -l -m 1 %s'
fi


() {
    if (( $+commands[nnn] )); then
        export NNN_OPTS='adfo'

        export NNN_OPENER="$HOME/.config/nnn/plugins/nuke"
        if [[ ! -x "$NNN_OPENER" ]]; then
            curl -Ss https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
        fi

        if (( $+DISPLAY )); then
            export GUI=1
        fi

        #typeset -TU NNN_BMS nnn_bms ';'
        NNN_BMS="c:$HOME/.config/nnn/mounts;M:/mnt"
        if [[ -d /media ]]; then
            NNN_BMS="m:/media;$NNN_BMS"
        fi
        export NNN_BMS

        export NNN_PLUG='f:finder;p:preview-tui'

        if (( $+commands[trash] )); then
            export NNN_TRASH=1
            if (( ! $+commands[trash-put] )); then
                alias trash-put='trash'
            fi
        fi
        if (( $+commands[gio] )); then
            export NNN_TRASH=2
        fi
    fi
}


if (( $+commands[kubectl] )); then
    source <(kubectl completion zsh)
fi


if (( $+commands[gh] )); then
    source <(gh completion -s zsh)
fi


if [[ ! "$TERM" =~ xterm* ]]; then
    alias ssh='TERM=xterm-256color ssh'
fi


() {
    while [[ $# -gt 0 ]]; do
        local src=$1 zwc=$1.zwc
        if [[ ! -f $zwc || $src -nt $zwc ]]; then
            zcompile $src
        fi
        if [[ $src != ${(%):-%x} ]]; then
            source $src
        fi
        shift
    done
} $HOME/.zshrc $HOME/.zshrc.*~*.zwc(N-)


# zshrc ends here.
