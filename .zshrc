if [[ $- != *i* ]]; then
    return
fi

which fish >/dev/null && SHELL=$(which fish) exec fish
