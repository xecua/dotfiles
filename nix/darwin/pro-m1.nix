{ pkgs, defaultUser, ... }:
{
  imports = [
    ./common.nix
  ];
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin"; # Intel Mac買うことたぶんないけど……
  home-manager.users.${defaultUser} = {
    home.packages = with pkgs; [
      flutter
      mutagen
      mutagen-compose
      ngrok
      code-cursor
    ];
    programs.neovide.settings.font.size = 14;
  };
}
