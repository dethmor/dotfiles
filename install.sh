#!/bin/bash


if [[ ! "$0" =~ install.sh$ ]]; then
    if [[ -d "$HOME/dotfiles" ]]; then
        mv -v "$HOME/dotfiles" "$HOME/dotfiles~"
    fi
    git clone https://github.com/dethmor/dotfiles.git "$HOME/dotfiles"
fi


bash "$HOME/dotfiles/sync.sh"
