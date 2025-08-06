if [[ $- != *i* ]]; then
    return
fi

if [[ -n "$CURSOR_AGENT" ]]; then
    return
fi

command -v fish >/dev/null && SHELL=$(command -v fish) exec fish
