if status is-interactive
    # tmux内でのみ--tmuxオプションを追加する
    if set -q TMUX
        set -gx FZF_DEFAULT_OPTS "--tmux 80%"
    end

    if test -n "$GHOSTTY_RESOURCES_DIR"
        # Ghostty supports Kitty graphics protocol
        set -x TIMG_PIXELATION kitty
    end

    if type -q brew; and brew ls --versions llvm 2>&1 >/dev/null
        fish_add_path (brew --prefix llvm)/bin
    end

    set -x FORCE_COLOR 1
end
