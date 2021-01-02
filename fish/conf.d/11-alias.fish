if status --is-interactive
  # typo
  alias gti git
  alias g git

  # format style
  alias clang-format "clang-format -style='{BasedOnStyle: LLVM, BreakBeforeBraces: Stroustrup,IndentWidth: 4}'"

  # from https://github.com/arkark/dotfiles
  if type -q exa
    alias ls 'exa --icons'
    alias ll 'exa -lh --git --icons'
    alias la 'exa -alh --git --icons'
    alias l 'exa'
    alias lt 'exa --tree --icons --git-ignore'
    alias llt 'exa -lh --git --tree --icons --git-ignore'
    alias lat 'exa -alh --git --tree --icons --git-ignore'
  else
    alias ll 'ls -alF'
    alias la 'ls -A'
    alias l 'ls -CF'
  end
  alias sl ls

  if type -q rg
    alias rg 'rg --smart-case'
  end

  if type -q bat
    alias less 'bat -p'
    alias cat 'bat -pp'
  end

  if type -q nvim
    alias vi nvim
    alias vim nvim
  else
    alias vi vim
  end
  alias :q exit

  if type -q htop
    alias top htop
  end

  if type -q batman
    alias man batman
  end

  # in fish, ssh-agent must be used with -c
  alias ssh-agent 'ssh-agent -c'

end
