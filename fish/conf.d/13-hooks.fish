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

  # enable vi mode
  fish_vi_key_bindings
end
