if status --is-interactive
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

  if type -q gibo
    gibo completion fish | source
  end

  if type -q colima
    colima completion fish | source
  end

  if type -q xremap
    xremap --completions fish | source
  end

  if type -q fzf
    fzf --fish | source
    alias fcd fzf-cd-widget
  end

  if type -q brew
    if test -d (brew --prefix)"/share/fish/completions"
      set -p fish_complete_path (brew --prefix)/share/fish/completions
    end

    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
      set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end
  end
end
