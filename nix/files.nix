{ pkgs, defaultUser, ... }:
let
  make-item = path: { source = ../${path}; };
  make-attr = path: { ${path} = make-item path; };
  make-maps = builtins.foldl' (acc: item: acc // make-attr item) { };
in
{
  home-manager = {
    users.${defaultUser} = {
      home.file =
        make-maps [
          ".profile"
          ".bash_profile"
          ".bashrc"
          ".zprofile"
          ".zshrc"
          ".myclirc"
          ".mutagen.yml"
          ".clang-format"
        ]
        // {
          ".local/bin/fzf-preview.sh" = make-item "fzf-preview.sh";
          ".satysfi/local/packages" = make-item "satysfi/packages";
        };
      xdg = {
        configFile =
          make-maps [
            "fish/conf.d"
            "fish/completions"
            "fzfrc"
            "nvim"
            "ideavim"
            "git"
            "lazygit/config.yml"
            "fd"
            "ripgrep"
            "waybar"
            "dunst"
            "hypr"
            "starship.toml"
            "ghostty"
            "lesskey"
            "latexmk/latexmkrc"
            "tmux/tmux.conf"
            "xremap"
            "kanshi"
            "fontconfig/fonts.conf"
            "zathura"
          ]
          // {
            "libskk/rules" = make-item "skk/libskk/rules";
            "libcskk/rules" = make-item "skk/libcskk/rules";
            # "wgetrc" = {
            #   text = ''
            #     $XDG_CACHE_HOME/wget-hsts
            #   '';
            # };
            # indentconfig?
            systemd = {
              source = ../systemd/user;
              target = "systemd/user";
              recursive = true;
            };
          };
        dataFile = {
          "fish/vendor_completions.d/nix.fish".source =
            "${pkgs.nix}/share/fish/vendor_completions.d/nix.fish";
        };
      };
    };
  };
  # TODO: npm prefix
  # TODO: rofi
}
