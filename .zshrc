if ! [[ -o interactive ]]; then
    return
fi

command -v fish >/dev/null && SHELL=$(command -v fish) exec fish
