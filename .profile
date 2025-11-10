export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export GTK_USE_PORTAL=1 # Use xdg-desktop-portal instead of default handler
export GHCUP_USE_XDG_DIRS=1
export DFT_COLOR=always
export DFT_DISPLAY=side-by-side-show-both
export EDITOR=nvim

# Language related variables, using XDG Base Directories
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME/bundle"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/ripgreprc"

export BUNDLE_USER_CACHE="$XDG_CACHE_HOME/bundle"
export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"

export ANDROID_USER_HOME="$XDG_DATA_HOME/android"
export ANDROID_HOME="$ANDROID_USER_HOME/sdk" # Android Studio default
export ANDROID_EMULATOR_HOME="$ANDROID_USER_HOME" # Should be default, but not considered in some tools
export ANDROID_AVD_HOME="$ANDROID_EMULATOR_HOME/avd" # Should be default, but not considered in some tools
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME/bundle"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export COURSIER_INSTALL_DIR="$XDG_DATA_HOME/coursier/bin"
export DENO_INSTALL="$XDG_DATA_HOME/deno"
export DENO_INSTALL_ROOT="$HOME/.local" # `deno install`-ed scripts installed into $DENO_INSTALL_ROOT/bin
export GEM_HOME="$XDG_DATA_HOME/gem"
export GOPATH="$XDG_DATA_HOME/go"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export OPAMROOT="$XDG_DATA_HOME/opam"
export NPM_CONFIG_PREFIX="$XDG_DATA_HOME/npm"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export POETRY_HOME="$XDG_DATA_HOME/poetry"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export STACK_ROOT="$XDG_DATA_HOME/stack"
export FVM_CACHE_PATH="$XDG_DATA_HOME/fvm" # Flutter (FVM)

export FZF_DEFAULT_OPTS_FILE="$XDG_CONFIG_HOME/fzfrc"
export LESS="-FRXMS -j5 --shift 5"
export LESSCHARSET="utf-8"

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    export MOZ_ENABLE_WAYLAND=1
fi

# Update PATH
# Homebrewってどっちかというとシステムのものっぽさ
if [ -r /opt/homebrew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

PATH="$HOME/.local/bin:$PATH"
PATH="$GOPATH/bin:$PATH"
PATH="$CARGO_HOME/bin:$PATH"
PATH="$COURSIER_INSTALL_DIR:$PATH"
PATH="$POETRY_HOME/bin:$PATH"
PATH="$DENO_INSTALL/bin:$PATH"
PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
PATH="$ANDROID_HOME/platform-tools:$PATH"
PATH="$ANDROID_HOME/emulator:$PATH"
PATH="$NPM_CONFIG_PREFIX/bin:$PATH"
PATH="$PNPM_HOME:$PATH"
PATH="/Library/TeX/texbin:$PATH" # MacTeX
PATH="$HOME/.dotnet/tools:$PATH"
PATH="$FVM_CACHE_PATH/default/bin:$PATH"

# set by command
if command -v ruby >/dev/null; then
    # user local gem path
    # https://wiki.archlinux.jp/index.php/Ruby#.E3.82.BB.E3.83.83.E3.83.88.E3.82.A2.E3.83.83.E3.83.97
    PATH="$(ruby -e "print Gem.user_dir")/bin:$PATH"
fi

export PATH

# Conditional variables
if command -v sccache >/dev/null ; then
    export RUSTC_WRAPPER=$(command -v sccache)
fi

# opam configuration
if [ -r "$OPAMROOT/opam-init/init.sh" ]; then
  source "$OPAMROOT/opam-init/init.sh" >/dev/null 2>&1
fi

# SDKMAN
if [ -r "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# stargz(containerd snapshotter; fallback to overlayfs)
if command -v stargz-store >/dev/null; then
    export CONTAINERD_SNAPSHOTTER="stargz"
fi

# Describe machine specific configurations in ~/.profile.local
## example:
# export XMODIFIERS=@im=fcitx
# export QT_IM_MODULE=fcitx
# export QT_IM_MODULES="wayland;fcitx;ibus"
# note: for gtk, copy content of gtk-{3,4}.0/settings.ini to each file and not use GTK_IM_MODULE
#
# export LANG=ja_JP.UTF-8
# export BROWSER=/usr/bin/vivaldi
# export TERMINAL=/usr/bin/ghostty
# export EDITOR=/usr/bin/nvim
# export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
if [ -e "$HOME/.profile.local" ]; then
    source "$HOME/.profile.local"
fi
