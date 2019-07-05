source ~/.config/fish/conf.d/alias.fish

set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache
set -x XDG_RUNTIME_DIR /tmp/runtime

set -x ANYENV_ROOT $HOME/.anyenv
set -x PATH $HOME/.anyenv/bin $PATH
source (anyenv init -|psub)

set -x PYENV_ROOT $ANYENV_ROOT/envs/pyenv
set -x WORKON_HOME $HOME/.virtualenvs
set -x PATH $PYENV_ROOT/bin $PATH

set -x GOPATH $HOME/.golang
set -x PATH $GOPATH/bin $PATH

set -x SDKMAN_ROOT $HOME/.sdkman
set -x KOTLIN_ROOT $SDKMAN_ROOT/candidates/kotlin/current
set -x PATH $KOTLIN_ROOT/bin $PATH

set -x PATH $HOME/.cargo/bin $PATH

set -x PATH $HOME/.local/bin $PATH

set -x MATLAB_USE_USERWORK 1
set -x PATH /usr/local/MATLAB/R2019a/bin $PATH

# like pbcopy(macOS)
alias pbcopy 'xsel --clipboard --input'

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

# some useful aliases
alias ls 'ls --color=auto'
alias ll 'ls -alF'
alias la 'ls -A'
alias l 'ls -CF'
alias grep 'grep --color=auto'
alias fgrep 'fgrep --color=auto'
alias egrep 'egrep --color=auto'
alias cls clear
alias exp "explorer.exe ."

alias vi nvim
alias vim nvim
alias emacs nvim
alias :q exit

# in fish, we must use like csh
alias ssh-agent 'ssh-agent -c'

alias mozc_conf '/usr/lib/mozc/mozc_tool --mode=config_dialog'

# Rust REPL
alias rust evcxr

# oh-my-fish/theme-bobthefish
set -g theme_display_date no
set -g theme_display_cmd_duration no

alias latexmk-docker "docker run --rm -it -v (pwd):/workdir -u (id -u):(id -g) arkark/latexmk"

