{ defaultUser, ... }:
with (import ../utils.nix);
{
  imports = [ ./common.nix ];
  nixpkgs.config.allowUnfree = true;
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
      ]
      // {
        "libskk/rules" = make-item "skk/libskk/rules";
        "libcskk/rules" = make-item "skk/libcskk/rules";
        systemd = make-recursive-item "systemd/user";
      };
  };
}
