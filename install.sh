#!/bin/bash

if [[ ! "$0" =~ install.sh$ ]]; then
    if [[ -d "$HOME/dotfiles" ]]; then
        mv -v "$HOME/dotfiles" "$HOME/dotfiles~"
    fi
    git clone https://github.com/dethmor/dotfiles.git "$HOME/dotfiles"
    exec bash "$HOME/dotfiles/install.sh"
fi

DOTFILES_ROOT=$(realpath "${0%/*}")
SRC_DIR="$DOTFILES_ROOT" DEST_DIR="$HOME"
if [[ "$1" == '-u' ]]; then
    SRC_DIR="$HOME" DEST_DIR="$DOTFILES_ROOT"
fi

IFS=$'\n'
set -- $(git -C "$DOTFILES_ROOT" ls-files | grep -vE "^(.gitignore|${0##*/})$")

while [[ $# -gt 0 ]]; do
    mode=$(stat -c %a "$DOTFILES_ROOT/$1")
    install -C -D -m "$mode" -v "$SRC_DIR/$1" "$DEST_DIR/$1"
    shift
done
