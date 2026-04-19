#!/usr/bin/env zsh

for v in ${=ZSHENV_VARS}; do
    launchctl setenv "$v" "${(P)v}"
done
