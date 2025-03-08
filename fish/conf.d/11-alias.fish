# idiomatic, non-modification-prone commands
if status is-interactive
  alias gitop='cd (git rev-parse --show-toplevel)'

  alias :q=exit
  alias nvimdiff='nvim -d'

  if [ (uname) = 'Darwin' ]
    alias sudoedit='sudo -e'
  end

  if type -q eza # actively maintained fork
    set -l eza_command 'eza --header --git --time-style=iso --modified --created'
    alias l="$eza_command"
    alias ls="$eza_command --icons"
    alias ll="$eza_command --icons --long"
    alias la="$eza_command --icons --long --all"
    alias lt="$eza_command --icons --tree --git-ignore"
    alias llt="$eza_command --icons --tree --long"
    alias lat="$eza_command --icons --tree --long --all"
  else
    alias l='ls -C'
    alias ll='ls -alF'
    alias la='ls -A'

    if type -q tree
      # treeコマンドを入れてみて似たような感じにする
      alias lt="tree"
      alias llt="tree"
      alias lat="tree -a"
    end
  end

  if type -q btm
    alias top="btm -b"
  else if type -q htop
    alias top=htop
  end

  if type -q batman
    alias man=batman
  end

  if type -q gsed
    alias sed=gsed
  end

  if type -q gtar
    alias sed=gtar
  end

  if type -q gawk
    alias awk=gawk
  end

  if type -q lazygit
    alias lg=lazygit
  end

  if type -q pbcopy
    alias cbpaste=pbpaste
  else if type -q xsel
    alias cbpaste='xsel -ob'
  else if type -q wl-copy
    alias cbpaste=wl-paste
  else if type -q win32yank.exe
    alias cbpaste='win32yank.exe -o'
  end
end
