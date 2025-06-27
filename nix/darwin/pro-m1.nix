{ pkgs, defaultUser, ... }:
{
  imports = [ ./common.nix ];
  system.stateVersion = 6;
  environment.systemPackages = with pkgs; [
    flutter
    code-cursor
  ];
  nixpkgs.hostPlatform = "aarch64-darwin"; # Intel Mac買うことたぶんないけど……
  home-manager.users.${defaultUser} = {
    home.packages = with pkgs; [
      mutagen
      mutagen-compose
      ngrok
    ];
    programs.neovide.settings.font.size = 14;
  };
}
