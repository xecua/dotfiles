if [[ $- != *i* ]]; then
    return
fi

command -pv fish >/dev/null && SHELL=$(command -pv fish) exec fish
