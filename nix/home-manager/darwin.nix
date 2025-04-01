{
  defaultUser,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./common.nix ];
  home = {
    homeDirectory = lib.mkForce "/Users/${defaultUser}";
    packages = with pkgs; [
      docker-client
      docker-compose
      docker-credential-helpers
      iproute2mac
      # ghostty # broken
    ];
  };
}
