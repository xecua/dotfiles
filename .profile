export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export GTK_USE_PORTAL=1 # Use xdg-desktop-portal instead of default handler
export GHCUP_USE_XDG_DIRS=1
export EDITOR=nvim

# export NEOVIDE_FRAME=buttonless # for macOS (.profile.local)
export NEOVIDE_TITLE_HIDDEN=1

# Language related variables, using XDG Base Directories
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME/bundle"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/ripgreprc"

export BUNDLE_USER_CACHE="$XDG_CACHE_HOME/bundle"
export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"

export ANDROID_HOME="$XDG_DATA_HOME/Android/Sdk" # Android Studio default
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME/bundle"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export COURSIER_INSTALL_DIR="$XDG_DATA_HOME/coursier/bin"
export DENO_INSTALL="$XDG_DATA_HOME/deno"
export GEM_HOME="$XDG_DATA_HOME/gem"
export GOPATH="$XDG_DATA_HOME/go"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export OPAMROOT="$XDG_DATA_HOME/opam"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export POETRY_HOME="$XDG_DATA_HOME/poetry"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export STACK_ROOT="$XDG_DATA_HOME/stack"
export BUN_INSTALL="$XDG_DATA_HOME/bun"

export FZF_DEFAULT_OPTS="--reverse"
export LESS="-FRXM --shift 5"

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    export MOZ_ENABLE_WAYLAND=1
fi
if [ "$XDG_SESSION_DESKTOP" = "sway" ]; then
    # https://github.com/swaywm/sway/issues/595
    export _JAVA_AWT_WM_NONREPARENTING=1
fi
if [ "$XDG_SESSION_DESKTOP" = "berry" ]; then
    sxhkd -c $HOME/.config/berry/sxhkdrc &
fi

# Update PATH
PATH="$HOME/.local/bin:$PATH"
PATH="$GOPATH/bin:$PATH"
PATH="$CARGO_HOME/bin:$PATH"
PATH="$COURSIER_INSTALL_DIR:$PATH"
PATH="$POETRY_HOME/bin:$PATH"
PATH="$DENO_INSTALL/bin:$PATH"
PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
PATH="$ANDROID_HOME/platform-tools:$PATH"
PATH="$XDG_DATA_HOME/npm/bin:$PATH" # npm global bin (assuming properly configured)
PATH="$XDG_DATA_HOME/yarn/bin:$PATH" # yarn global bin (assuming properly configured)
PATH="$PNPM_HOME:$PATH"
PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH" # GNU sed installed with Homebrew
PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH" # GNU tar installed with Homebrew
PATH="/Library/TeX/texbin:$PATH" # MacTeX
PATH="$XDG_CONFIG_HOME/rofi/bin:$PATH" # scripts from https://github.com/adi1090x/rofi (v1.7)
PATH="$XDG_CONFIG_HOME/rofi/scripts:$PATH" # scripts from https://github.com/adi1090x/rofi (master)
PATH="$BUN_INSTALL/bin:$PATH"

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
# export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
if [ -e "$HOME/.profile.local" ]; then
    source "$HOME/.profile.local"
fi
