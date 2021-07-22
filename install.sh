#!/bin/bash


if [[ ! "$0" =~ install.sh$ ]]; then
    if [[ -d "$HOME/dotfiles" ]]; then
        mv -v "$HOME/dotfiles" "$HOME/dotfiles~"
    fi
    git clone https://github.com/dethmor/dotfiles.git "$HOME/dotfiles"
fi


if [[ "$OSTYPE" =~ darwin* ]]; then
    if type brew &>/dev/null; then
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
    fi
    brew bundle --file="$HOME/dofiles/Brewfile"
fi


bash "$HOME/dotfiles/sync.sh"
