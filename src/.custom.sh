#!/usr/bin/env bash

# ALIASES

alias gr='cd $(git rev-parse --show-toplevel)'
alias co='git checkout'
alias cb='git checkout -b'
alias pu='git push -u origin "$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)"'
alias nano=micro

eval "$(starship init bash)"

export CONTAINER_NAME=$(cat /etc/hostname)
export PATH=$HOME/.local/bin:$PATH

# SET WINDOW TITLE

function set_win_title(){

    echo -ne "\033]0; $CONTAINER_NAME \007"
}
starship_precmd_user_func="set_win_title"
