{ pkgs, config, ... }:
with (import ../utils.nix);
{
  home = {
    # activation = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #   # cdとかする必要ある?
    #   run npm set prefix ${config.xdg.dataHome}/npm
    #   run npm set cache  ${config.xdg.cacheHome}/npm
    #   run npm set init-module ${config.xdg.configHome}/npm/config/npm-init.js
    # '';
    file =
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
  };
  xdg = {
    configFile =
      make-maps [
        "fzfrc"
        "ideavim"
        "git"
        "lazygit/config.yml"
        "fd"
        "ripgrep"
        "starship.toml"
        "ghostty/config"
        "lesskey"
        "latexmk/latexmkrc"
        "tmux/tmux.conf"
        "zathura"
        "walker/config.toml" # themesは起動時に権限変更とかしようとするのでstoreにあるとまずい。カスタムテーマやるならそいつも個別に。
        "gtk-3.0/settings.ini"
        "gtk-4.0/settings.ini"
      ]
      // {
        "wgetrc".text = "${config.xdg.cacheHome}/wget-hsts";
        # indentconfig?
        nvim = make-recursive-item "nvim";
        fish = make-recursive-item "fish";
      };
    dataFile = {
      "fish/vendor_completions.d/nix.fish".source =
        "${pkgs.nix}/share/fish/vendor_completions.d/nix.fish";
    };
  };
}
