source ~/.config/fish/conf.d/alias.fish

set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache
set -x PYENV_ROOT $HOME/.pyenv
set -x PATH $PYENV_ROOT/bin $PATH
set -x GOPATH $HOME/.golang
set -x PATH $PATH $GOPATH/bin
# X Window
set -x DISPLAY localhost:0.0

# like pbcopy(macOS)
alias pbcopy 'xsel --clipboard --input'

# typo
alias gti git
# very frequently use alias
alias gs 'git status -sb'
alias commit 'git commit -am'

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

# some useful aliases
alias ls 'ls --color=auto'
alias ll 'ls -alF'
alias la 'ls -A'
alias l 'ls -CF'
alias grep 'grep --color=auto'
alias fgrep 'fgrep --color=auto'
alias egrep 'egrep --color=auto'

# it's dull to type 'n'
alias vim nvim
alias emacs nvim
alias :q exit
