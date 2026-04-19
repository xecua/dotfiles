if status is-interactive
    # tmux内でのみ--tmuxオプションを追加する
    if set -q TMUX
        set -gx FZF_DEFAULT_OPTS "--tmux 80%"
    end

    if test -n "$GHOSTTY_RESOURCES_DIR"
        # Ghostty supports Kitty graphics protocol
        set -x TIMG_PIXELATION kitty
    end
end
