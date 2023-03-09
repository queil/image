#!/usr/bin/env bash

# ALIASES

alias gr='cd $(git rev-parse --show-toplevel)'
alias cat=bat

eval "$(starship init bash)"

export CONTAINER_NAME=$(docker ps -f ID=$(hostname) --format "{{.Names}}")
export PATH=$HOME/.local/bin:$PATH
