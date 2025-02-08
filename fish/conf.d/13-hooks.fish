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

  if type -q fzf
    fzf --fish | source
    alias fcd fzf-cd-widget
  end
end
