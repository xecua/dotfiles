#!/usr/bin/env zsh

for v in ${=EXPOSED_VARS}; do
    launchctl setenv "$v" "${(P)v}"
done
