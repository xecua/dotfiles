if [[ -r /etc/zshrc ]]; then
    source /etc/zshrc
fi

if [[ "$(basename "$(ps -o comm= -p $PPID)")" = "zed" ]]; then
    return
fi

command -v fish >/dev/null && SHELL=$(command -v fish) exec fish
