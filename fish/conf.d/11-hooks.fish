if status --is-interactive
    if type -q mise
        mise activate fish | source
    end

    if type -q direnv
        eval (direnv hook fish)
    end

    if type -q thefuck
        thefuck --alias | source
    end

    if type -q starship
        starship init fish | source
    end

    if type -q batpipe
        eval (batpipe)
    end

    if type -q fzf
        fzf --fish | source
        alias fcd fzf-cd-widget
    end

    if type -q zoxide
        zoxide init --cmd=cd fish | source
    end

    if type -q elio
        elio shell init fish | source
    end

    if test -e "$VP_HOME/env.fish"
        source "$VP_HOME/env.fish"
    end

end
