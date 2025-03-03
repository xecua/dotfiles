{ defaultUser, ... }:
{
  system.stateVersion = "24.05";
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "upside-down-face";
  wsl = {
    enable = true;
    inherit defaultUser;
  };
  home-manager = {
    users.${defaultUser} = {
      home.homeDirectory = "/home/${defaultUser}";
    };
  };
}
