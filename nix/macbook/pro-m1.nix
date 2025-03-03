{ defaultUser, ... }:
{
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
  home-manager = {
    users.${defaultUser} =
      { lib, ... }:
      {
        home = {
          homeDirectory = lib.mkForce "/Users/${defaultUser}";
        };
      };
  };
}
