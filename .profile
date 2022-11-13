export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export GTK_USE_PORTAL=1 # Use xdg-desktop-portal instead of default handler
export EDITOR=nvim

# Language related variables
export GOPATH="$HOME/.go"
export COURSIER_INSTALL_DIR="$XDG_DATA_HOME/coursier/bin"
export ANDROID_HOME="$HOME/Android/Sdk" # Android Studio default
export POETRY_HOME="$HOME/.poetry"
export DENO_INSTALL="$HOME/.deno"
export NPM_PREFIX="$XDG_DATA_HOME/npm" # npm config set prefix $NPM_PREFIX
export YARN_PREFIX="$XDG_DATA_HOME/yarn" # yarn config set prefix $YARN_PREFIX
export PNPM_HOME="$XDG_DATA_HOME/pnpm" # automatically used

export FZF_DEFAULT_OPTS="--reverse"

# Update PATH
PATH="$GOPATH/bin:$PATH"
PATH="$HOME/.cargo/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="$COURSIER_INSTALL_DIR:$PATH"
PATH="$POETRY_HOME/bin:$PATH"
PATH="$DENO_INSTALL/bin:$PATH"
PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
PATH="$ANDROID_HOME/platform-tools:$PATH"

# Conditional variables
if command -v sccache >/dev/null ; then
    export RUSTC_WRAPPER=$(command -v sccache)
fi

if command -v npm >/dev/null; then
    PATH="$(npm -g bin 2>/dev/null):$PATH" # become $NPM_PREFIX in win32 (otherwise $NPM_PREFIX/bin)
fi

if command -v yarn >/dev/null; then
    PATH="$YARN_PREFIX/bin:$PATH" # independent of platform
fi

if command -v pnpm >/dev/null; then
    PATH="$PNPM_HOME:$PATH"
fi

if [ -e /usr/local/opt/gnu-sed ]; then
    # GNU sed installed with Homebrew
    PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
fi

if [ -e /usr/local/opt/gnu-tar ]; then
    # GNU tar installed with Homebrew
    PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
fi

if command -v ruby >/dev/null; then
    # user local gem path
    # https://wiki.archlinux.jp/index.php/Ruby#.E3.82.BB.E3.83.83.E3.83.88.E3.82.A2.E3.83.83.E3.83.97
    PATH="$(ruby -e "print Gem.user_dir")/bin:$PATH"
fi

if [ -e /Library/TeX/texbin ]; then
  # MacTeX
  PATH="/Library/TeX/texbin:$PATH"
fi

if [ -e "$XDG_CONFIG_HOME/rofi/bin" ]; then
  # scripts from https://github.com/adi1090x/rofi (v1.7)
  PATH="$XDG_CONFIG_HOME/rofi/bin:$PATH"
fi

if [ -e "$XDG_CONFIG_HOME/rofi/scripts" ]; then
  # scripts from https://github.com/adi1090x/rofi (master)
  PATH="$XDG_CONFIG_HOME/rofi/scripts:$PATH"
fi

export PATH

### Extra files

# opam configuration
if [ -r "$HOME/.opam/opam-init/init.sh" ]; then
  source "$HOME/.opam/opam-init/init.sh" > /dev/null 2> /dev/null
fi

# SDKMAN
if [ -r "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi


# Describe machine specific configurations in ~/.profile.local
## example:
# export GTK_IM_MODULE=fcitx
# export QT_IM_MODULE=fcitx
# export XMODIFIERS=@im=fcitx
#
# export LANG=ja_JP.utf8
# export BROWSER=/usr/bin/vivaldi
# export TERMINAL=/usr/bin/alacritty
# export EDITOR=/usr/bin/nvim
#
## How gpg-agent should be started differs from each other (below: gentoo with systemd)
# gpgconf --launch gpg-agent
# export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
if [ -e "$HOME/.profile.local" ]; then
    source "$HOME/.profile.local"
fi
