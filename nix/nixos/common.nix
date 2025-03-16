{ pkgs, defaultUser, ... }:
let
  make-item = path: { source = ../../${path}; };
  make-attr = path: { ${path} = make-item path; };
  make-maps = builtins.foldl' (acc: item: acc // make-attr item) { };
in
{
  imports = [
    ../common
    ../common/extra-pkgs.nix
  ];
  i18n = {
    supportedLocales = [ "en_US.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8" ];
    defaultLocale = "en_US.UTF-8";
  };
  home-manager = {
    users.${defaultUser} =
      { config, ... }:
      {
        home.homeDirectory = "/home/${defaultUser}";
        xdg = {
          configFile =
            make-maps [
              "waybar"
              "dunst"
              "hypr"
              "xremap"
              "kanshi"
              "fontconfig/fonts.conf"
              "zathura"
            ]
            // {
              "libskk/rules" = make-item "skk/libskk/rules";
              "libcskk/rules" = make-item "skk/libcskk/rules";
              systemd = {
                source = ../../systemd/user;
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
}
