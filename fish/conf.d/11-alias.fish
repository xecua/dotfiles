# idiomatic, non-modification-prone commands
if status is-interactive
  alias gitop='cd (git rev-parse --show-toplevel)'

  alias :q=exit
  alias nvimdiff='nvim -d'

  alias brf="echo (br --conf ~/.config/broot/fzf.hjson)"

  if [ (uname) = 'Darwin' ]
    alias sudoedit='sudo -e'
  end

  if type -q exa
    set -l exa_command 'exa --header --git --time-style=iso --modified --created'
    alias l="$exa_command"
    alias ls="$exa_command --icons"
    alias ll="$exa_command --icons --long"
    alias la="$exa_command --icons --long --all"
    alias lt="$exa_command --icons --tree --git-ignore"
    alias llt="$exa_command --icons --tree --long"
    alias lat="$exa_command --icons --tree --long --all"
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

  if type -q htop
    alias top=htop
  end

  if type -q batman
    alias man=batman
  end

  if type -q gsed
    alias sed=gsed
  end

  if type -q gawk
    alias awk=gawk
  end

  if type -q pbcopy
    alias cbcopy='pbcopy'
    alias cbpaste='pbpaste'
  else if type -q xsel
    alias cbcopy='xsel -ib'
    alias cbpaste='xsel -ob'
  else if type -q win32yank.exe
    alias cbcopy='win32yank.exe -i'
    alias cbpaste='win32yank.exe -o'
  end
end
