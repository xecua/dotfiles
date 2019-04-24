source ~/.config/fish/conf.d/alias.fish

# X Window
set -x DISPLAY localhost:0.0

set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache
set -x ANYENV_ROOT $HOME/.anyenv
set -x PATH $HOME/.anyenv/bin $PATH
source (anyenv init -|psub)
set -x PYENV_ROOT $ANYENV_ROOT/envs/pyenv
set -x WORKON_HOME $HOME/.virtualenvs
set -x PATH $PYENV_ROOT/bin $PATH
set -x GOPATH $HOME/.golang
set -x PATH $GOPATH/bin $PATH
set -x PATH $HOME/.cargo/bin $PATH
set -x PATH /home/xecua/.local/bin $PATH
set -x MATLAB_USE_USERWORK 1
set -x PATH /usr/local/MATLAB/R2019a/bin $PATH
set -x LANG "ja_JP.UTF-8"
set -x LC_ALL "$LANG"
set -x LIBGL_ALWAYS_INDIRECT 1
set -x XIM "fcitx"
set -x GTK_IM_MODULE "$XIM"
set -x QT_IM_MODULE "$XIM"
set -x XMODIFIERS "@im=$XIM"
set -x DefaultIMModule "$XIM"
set -x NO_AT_BRIDGE 1

if not pgrep mozc_server > /dev/null
    xset -r 49
    fcitx-autostart > /dev/null
end

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

# it's dull to type 'n'
alias vim nvim
alias emacs nvim
alias :q exit

# in fish, we must use like csh
alias ssh-agent 'ssh-agent -c'

alias mozc_conf '/usr/lib/mozc/mozc_tool --mode=config_dialog'

# make be able to execute ELF 32-bit Executable on 64bit machine using qemu
alias bin32 "sudo update-binfmts --install qemu-i386 /usr/bin/qemu-i386-static --magic '\x7f\x45\x4c\x46\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x03\x00' --mask '\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'"

# Rust REPL
alias rust evcxr

# oh-my-fish/theme-bobthefish
set -g theme_display_date no
set -g theme_display_cmd_duration no

# atcoder python version 3.4.3
alias atcoder 'source (pyenv init -|psub); and pyenv shell 3.4.3'

