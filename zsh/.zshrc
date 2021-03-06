ttyctl -f


autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic


autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars " _-./;@?"
zstyle ':zle:*' word-style unspecified


bindkey -e
bindkey '' history-beginning-search-backward
bindkey '' history-beginning-search-forward
#bindkey 'B' vi-backward-blank-word
#bindkey 'F' vi-forward-blank-word
#bindkey 'U' backward-delete-word
#bindkey 'K' delete-word


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

        # Arch Linux: pacman -Syu pkgfile
        # macOS: brew tap homebrew/command-not-found
        ohmyzsh/ohmyzsh plugins/command-not-found/command-not-found.plugin.zsh
EOBUNDLES

    antigen apply

    # zsh-users/zaw
    zstyle ':filter-select:highlight' selected fg=black,bg=white,standout
    zstyle ':filter-select' max-lines -10
    zstyle ':filter-select' rotate-list yes
    zstyle ':filter-select' case-incensitive yes
    zstyle ':filter-select' hist-find-no-dups yes

    #bindkey '^R' zaw-history
    bindkey '' zaw-process
    bindkey ' ' zaw-ssh-hosts

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
    HISTSIZE=1000
    SAVEHIST=$((365 * $HISTSIZE))
    alias history='fc -lDi'
    zshaddhistory() { whence ${${(z)1}[1]} &> /dev/null || return 1 }

    # zsh-autoenv
    AUTOENV_FILE_ENTER=.env
    AUTOENV_FILE_LEAVE=.env.leave
}


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


export GPG_TTY=$(tty)


if (( $+commands[emacsclient] )); then
    alias emacs='emacsclient -t'
fi


export LESS='iMRS'

if (( $+commands[highlight] )); then
    export LESSOPEN='| highlight -O xterm256 -s base16/dracula --force -l -m 1 %s'
fi


() {
    if (( $+commands[nnn] )); then
        export NNN_OPTS='ado'

        if [[ ! -d "$HOME/.config/nnn/plugins" ]]; then
            curl -Ss https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
        fi

        local x
        for x in xdg-open open $HOME/.config/nnn/plugins/nuke; do
            if [[ -x ${NNN_OPENER:=$(command -v "$x")} ]]; then
                break
            fi
        done
        export NNN_OPENER


        if (( $+DISPLAY )) || [[ $OSTYPE =~ darwin* ]]; then
            export GUI=1
        fi

        typeset -TUg NNN_BMS nnn_bms ';'
        nnn_bms=(
            c:$HOME/.config/nnn/mounts
        )
        export NNN_BMS

        typeset -TUg NNN_PLUG nnn_plug ';'
        nnn_plug=(
            f:finder
            p:preview-tui
        )
        export NNN_PLUG

        export NNN_SSHFS='sshfs -o reconnect,idmap=user,cache_timeout=3600'

        if (( $+commands[trash] )); then
            export NNN_TRASH=1
            if (( ! $+commands[trash-put] )); then
                alias trash-put='trash'
            fi
        elif (( $+commands[gio] )); then
            export NNN_TRASH=2
        fi

        alias nnn='nnn -Tv'

        nnn_ps1() {
            if [[ -n "$NNNLVL" ]]; then
                echo "[nnn:$NNNLVL]"
            fi
        }
        RPROMPT="$RPROMPT "'$(nnn_ps1)'
    fi
}


if (( $+commands[aws] )); then
    aws_ps1() {
        if [[ -n "$AWS_PROFILE" ]]; then
            echo "[aws:%F{yellow}$AWS_PROFILE%f]"
        fi
    }
    RPROMPT="$RPROMPT "'$(aws_ps1)'
    awson() {
        local x=$(aws configure list-profiles | fzf)
        if [[ -n "$x" ]]; then
            export AWS_PROFILE="$x"
        fi
    }
    awsoff() {
        unset AWS_PROFILE
    }
    zaw-src-aws-profiles() {
        candidates=($(aws configure list-profiles))
        actions=(zaw-src-aws-profiles-set)
        act_descriptions=('set AWS_PROFILE')
    }
    zaw-src-aws-profiles-set() {
        export AWS_PROFILE="$1"
        zle accept-line
    }
    zaw-register-src -n aws-profiles zaw-src-aws-profiles
    bindkey '' zaw-aws-profiles
fi


if (( $+commands[kubectl] )); then
    source <(kubectl completion zsh)
    kube_ps1() {
        if [[ -n "$KUBECONFIG" ]]; then
            local cluster=$(kubectl config view -o jsonpath='{.clusters[].name}' | grep -oE '[^/]+$')
            local project="${KUBECONFIG#*/config_}"
            echo "[kube:%F{blue}$cluster%f@${project%%_*}]"
        fi
    }
    RPROMPT="$RPROMPT "'$(kube_ps1)'
    kubeon() {
        local prefix=~/.kube/config_
        local x=$(ls "$prefix"* | sed 's/^.*config_//' | fzf)
        if [[ -n "$x" ]]; then
            export KUBECONFIG="$prefix$x"
        fi
    }
    kubeoff() {
        unset KUBECONFIG
    }
    zaw-src-kube-contexts() {
        local config=(~/.kube/config_*)
        candidates=(${config[@]#*config_})
        actions=(zaw-src-kube-contexts-set)
        act_descriptions=('set KUBECONFIG')
    }
    zaw-src-kube-contexts-set() {
        export KUBECONFIG="$HOME/.kube/config_$1"
        zle accept-line
    }
    zaw-register-src -n kube-contexts zaw-src-kube-contexts
    bindkey '' zaw-kube-contexts
fi


if (( $+commands[gh] )); then
    source <(gh completion -s zsh)
fi


if (( $+commands[ykman] )); then
    source <(_YKMAN_COMPLETE=zsh_source ykman)
fi


if [[ ! "$TERM" =~ xterm* ]]; then
    alias ssh='TERM=xterm-256color ssh'
fi


if (( $+commands[brew] )); then
    path=(/usr/local/opt/*/libexec/*bin $path)
fi


if (( $+commands[VBoxManage] )); then
    alias vbox=VBoxManage
    compdef vbox=VBoxManage
fi


if [[ -x '/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport' ]]; then
    alias airport=/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport
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
