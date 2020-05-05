# typo
alias gti git
alias g git

# use C++17, C++20 with GCC(default is C++14 in gcc6.1+)
alias g++17 'g++ -std=c++17'
alias g++20 'g++ -std=c++2a'
# with gnu extensions
alias g++17gnu 'g++ -std=gnu++17'
alias g++20gnu 'g++ -std=gnu++2a'

# use C++11,C++14,C++17,C++20 with Clang
alias clang++11 'clang++ -std=c++11'
alias clang++14 'clang++ -std=c++14'
alias clang++17 'clang++ -std=c++17'
alias clang++20 'clang++ -std=c++2a'

# format style
alias clang-format "clang-format -style='{BasedOnStyle: LLVM, BreakBeforeBraces: Stroustrup,IndentWidth: 4}'"

# from https://github.com/arkark/dotfiles
if type -q exa
  alias ls 'exa --icons'
  alias ll 'exa -lh --git --icons'
  alias la 'exa -alh --git --icons'
  alias l 'exa --icons'
  alias lt 'exa --tree --icons --git-ignore'
  alias llt 'exa -lh --git --tree --icons --git-ignore'
  alias lat 'exa -alh --git --tree --icons --git-ignore'
else
  alias ll 'ls -alF'
  alias la 'ls -A'
  alias l 'ls -CF'
end
alias sl ls

if type -q bat
  alias less 'bat -p'
  alias cat 'bat -pp'
end

if type -q rg
  alias grep 'rg'
  alias fgrep 'rg -F'
else
  alias grep 'grep --color=auto'
  alias fgrep 'fgrep --color=auto'
  alias egrep 'egrep --color=auto'
end

alias cls clear

if type -q nvim
  alias vi nvim
  alias vim nvim
  alias emacs nvim
else
  alias vi vim
  alias emacs vim
end
alias :q exit

if type -q htop
  alias top htop
end

# in fish, ssh-agent must be used with -c
alias ssh-agent 'ssh-agent -c'
