{
  defaultUser,
  ...
}:
with (import ../utils.nix);
{
  imports = [ ./common.nix ];
  home.homeDirectory = "/home/${defaultUser}";
  xdg = {
    configFile =
      make-maps [
        "waybar"
        "dunst"
        "xremap"
        "kanshi"
        "fontconfig/fonts.conf"
      ]
      // {
        "libskk/rules" = make-item "skk/libskk/rules";
        "libcskk/rules" = make-item "skk/libcskk/rules";
        hypr = make-recursive-item "hypr";
        systemd = make-recursive-item "systemd/user";
      };
  };
}
