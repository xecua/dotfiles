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

end

if type -q gpgconf
  gpgconf --launch gpg-agent
  set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
end

if type -q opam
  source $HOME/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
end
