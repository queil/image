# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# ALIASES

alias gr='cd $(git rev-parse --show-toplevel)'
alias ga='git add'
alias st='git-status.sh'
alias di='git diff'
alias co='git checkout'
alias cb='git checkout -b'
alias cm='git commit -m'
alias inf='git add . && git commit -a --amend --no-edit'
alias pu='git push -u origin "$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)"'
alias pl='git pull'
alias wipe='git reset --hard && git clean -xfd'
alias uuid=uuidgen
alias nano=micro

eval "$(starship init bash)"
eval "$(fzf --bash)"

# ENV VARS

# uncomment for a local daemon
# export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

export CONTAINER_NAME=$(cat /etc/hostname)
export PATH=$HOME/.local/bin:$PATH
export COLORTERM=truecolor
export MICRO_TRUECOLOR=1
export EDITOR=micro

# SET WINDOW TITLE

function set_win_title(){

    echo -ne "\033]0; $CONTAINER_NAME \007"
}
starship_precmd_user_func="set_win_title"

. ~/.image.bashrc

source /home/queil/.config/broot/launcher/bash/br
