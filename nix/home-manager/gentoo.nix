{
  pkgs,
  nixgl,
  config,
  ...
}:
{
  imports = [ ./linux.nix ];
  nixpkgs.config.allowUnfree = true;
  nixGL.packages = nixgl.packages;
  home.packages = with pkgs; [
    buildkit
    jnv
    redocly
    unar # 依存が……
    (config.lib.nixGL.wrap neovide)
    # walker # guruにあるけどメンテナがいないみたい
    # localstack # 依存が……
    cook-cli
  ];
  dconf = {
    # NixOSだとprograms.dconfでもうちょっとリッチなことできそう?
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        gtk-im-module = "fcitx"; # gtk 3,
        color-scheme = "prefer-dark"; # gtk 4.20
        # TODO: qt?
      };
    };
  };
}
