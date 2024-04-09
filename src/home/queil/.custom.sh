#!/usr/bin/env bash

# ALIASES

alias gr='cd $(git rev-parse --show-toplevel)'
alias ga='git add'
alias st='git status'
alias di='git diff'
alias co='git checkout'
alias cb='git checkout -b'
alias cm='git commit -m'
alias pu='git push -u origin "$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)"'
alias pl='git pull'
alias uuid='cat /proc/sys/kernel/random/uuid'
alias nano=micro

eval "$(starship init bash)"

# ENV VARS

export CONTAINER_NAME=$(cat /etc/hostname)
export PATH=$HOME/.local/bin:$PATH
export COLORTERM=truecolor
export MICRO_TRUECOLOR=1

# SET WINDOW TITLE

function set_win_title(){

    echo -ne "\033]0; $CONTAINER_NAME \007"
}
starship_precmd_user_func="set_win_title"
