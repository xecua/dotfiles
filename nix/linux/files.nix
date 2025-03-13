{ pkgs, defaultUser, ... }:
let
  make-item = path: { source = ../../${path}; };
  make-attr = path: { ${path} = make-item path; };
  make-maps = builtins.foldl' (acc: item: acc // make-attr item) { };
in
{
  home-manager = {
    users.${defaultUser} =
      { config, ... }:
      {
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
