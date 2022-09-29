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

  # ./build.sh --compress (sys-apps/bat-extras) seems to have bug (#82)
  # if type -q batpipe
  #   eval (batpipe)
  # end
end
