if [[ -z "$ZSHENV_LOADED" ]]; then
    export ZSHENV_LOADED=1
    typeset -gUx path

    # path_helperはカス
    setopt no_global_rcs
    if [[ -x /usr/libexec/path_helper ]]; then
        eval "$(/usr/libexec/path_helper -s)"
    fi

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
    export NBRC_PATH="$XDG_CONFIG_HOME/nb/nbrc"

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
    export VITE_PLUS_HOME="$XDG_DATA_HOME/vite-plus"

    export COPILOT_HOME="$XDG_CONFIG_HOME/copilot"
    export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"

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

    path=(
        "$HOME/.local/bin"(N-/)
        "$GOPATH/bin"(N-/)
        "$CARGO_HOME/bin"(N-/)
        "$COURSIER_INSTALL_DIR"(N-/)
        "$DENO_INSTALL/bin"(N-/)
        "$ANDROID_HOME/cmdline-tools/latest/bin"(N-/)
        "$ANDROID_HOME/platform-tools"(N-/)
        "$ANDROID_HOME/emulator"(N-/)
        "$NPM_CONFIG_PREFIX/bin"(N-/)
        "$PNPM_HOME"(N-/)
        "/Library/TeX/texbin"(N-/) # MacTeX
        "$HOME/.dotnet/tools"(N-/)
        "$FVM_CACHE_PATH/bin"(N-/) # fvm
        "$FVM_CACHE_PATH/default/bin"(N-/) # global flutter installed by fvm
        "$XDG_DATA_HOME/ghcup/bin"(N-/)
        $path
    )

    # set by command
    if command -v ruby >/dev/null; then
        # user local gem path
        # https://wiki.archlinux.jp/index.php/Ruby#.E3.82.BB.E3.83.83.E3.83.88.E3.82.A2.E3.83.83.E3.83.97
        path=("$(ruby -e "print Gem.user_dir")/bin"(N-/) $path)
    fi

    # Conditional variables
    if command -v sccache >/dev/null ; then
        export RUSTC_WRAPPER=$(command -v sccache)
    fi

    if command -v podman >/dev/null; then
        export PODMAN_HOST
        case "$(uname)" in
            Darwin)
                PODMAN_HOST="unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')"
                ;;
            Linux)
                PODMAN_HOST="unix://$(podman info --format '{{.Host.RemoteSocket.Path}}')"
                ;;
        esac
    fi

    export ZSHENV_VARS=(XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME PATH
         GTK_USE_PORTAL GHCUP_USE_XDG_DIRS DFT_COLOR DFT_DISPLAY EDITOR
         BUNDLE_USER_CONFIG DOCKER_CONFIG NPM_CONFIG_USERCONFIG WGETRC RIPGREP_CONFIG_PATH NBRC_PATH
         BUNDLE_USER_CACHE GEM_SPEC_CACHE ANDROID_USER_HOME ANDROID_HOME ANDROID_EMULATOR_HOME ANDROID_AVD_HOME
         BUNDLE_USER_PLUGIN CARGO_HOME COURSIER_INSTALL_DIR DENO_INSTALL DENO_INSTALL_ROOT
         GEM_HOME GOPATH GRADLE_USER_HOME OPAMROOT NPM_CONFIG_PREFIX PNPM_HOME
         POETRY_HOME RUSTUP_HOME STACK_ROOT FVM_CACHE_PATH VITE_PLUS_HOME
         COPILOT_HOME CLAUDE_CONIFG_DIR FZF_DEFAULT_OPTS_FILE LESS LESSCHARSET
         MOZ_ENABLE_WAYLAND RUSTC_WRAPPER PODMAN_HOST
    )

    # Describe machine specific configurations in ~/.profile.local
    ## example:
    # export XMODIFIERS=@im=fcitx
    #
    # export LANG=ja_JP.UTF-8
    # export BROWSER=/usr/bin/vivaldi
    # export TERMINAL=/usr/bin/ghostty
    # export EDITOR=/usr/bin/nvim
    # export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    # export CONTAINERD_SNAPSHOTTER="stargz"
    if [ -e "$HOME/.zshenv.local" ]; then
        source "$HOME/.zshenv.local"
    fi

fi
