#!/usr/bin/env zsh

unset ZSHENV_LOADED
source "$HOME/.zshenv"

for v in ${=ZSHENV_VARS}; do
    launchctl setenv "$v" "${(P)v}"
done
