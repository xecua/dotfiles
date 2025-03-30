{ defaultUser, lib, ... }:
with (import ../utils.nix);
{
  imports = [ ./common.nix ];
  nixpkgs.config.allowUnfree = true;
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
