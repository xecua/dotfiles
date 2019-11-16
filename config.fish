set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache
set -x XDG_RUNTIME_DIR $HOME/.tmp

source $XDG_CONFIG_HOME/fish/conf.d/alias.fish

set -x LANG "ja_JP.UTF-8"
set -x LC_ALL "$LANG"

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
alias ll 'ls -alF'
alias la 'ls -A'
alias l 'ls -CF'
alias grep 'grep --color=auto'
alias fgrep 'fgrep --color=auto'
alias egrep 'egrep --color=auto'
switch (uname)
    case Linux
        alias ls 'ls --color=auto'
        alias sl 'ls --color=auto'
    case Darwin
        alias ls 'ls -G'
        alias sl 'ls -G'
end

alias cls clear

alias vi nvim
alias vim nvim
alias emacs nvim
alias :q exit
alias top htop

# in fish, ssh-agent must be used with -c
alias ssh-agent 'ssh-agent -c'

# oh-my-fish/theme-bobthefish
set -g theme_display_date no
set -g theme_display_cmd_duration no

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /Users/xecua/.anyenv/envs/pyenv/versions/anaconda3-2019.10/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

