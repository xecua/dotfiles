if type -q google-drive-ocamlfuse
  set -l dir_items (ls ~/GoogleDrive)
  if [ -z "$dir_items" ] # directory is empty
    google-drive-ocamlfuse ~/GoogleDrive
  end
end

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
  # if WSL, this should not be executed
  if [ -z "$WSL_DISTRO_NAME" ]
    echo 'foo'
    gpgconf --launch gpg-agent
    set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
  end
end

if type -q opam
  source $HOME/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
end

if type -q batpipe
  eval (batpipe)
end
