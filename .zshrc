if [[ -r /etc/zshrc ]]; then
    source /etc/zshrc
fi

command -v fish >/dev/null && SHELL=$(command -v fish) exec fish
