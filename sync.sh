#!/bin/bash


IFS=$'\n'


DOTFILES_ROOT=$(realpath "${0%/*}")


set -- $(find "$DOTFILES_ROOT" -mindepth 1 -maxdepth 1 -path "$DOTFILES_ROOT/.git" -prune -o -type d -printf '%f\n')


apps=()

if [[ "$OSTYPE" =~ darwin* ]] && type brew &>/dev/null; then
    apps=($(brew list -1))
fi


has() {
    if type "$1" &>/dev/null; then
        return 0
    fi
    if printf '%s\n' "${apps[@]}" | grep -qx "^$1$"; then
        return 0
    fi
    return 1
}

while [[ $# -gt 0 ]]; do
    cmd="${1##*/}"
    if has "$cmd"; then
        find "$DOTFILES_ROOT/$cmd" -type f -printf '%P\n' | while read -r x; do
            mode=$(stat -c %a "$DOTFILES_ROOT/$cmd/$x")
            install -C -D -m "$mode" -v "$DOTFILES_ROOT/$cmd/$x" "$HOME/$x"
        done
    fi
    shift
done
