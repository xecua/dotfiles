{ pkgs, defaultUser, ... }:
{
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
  environment.systemPackages = with pkgs; [
    colima
    firefox
    flutter
    google-chrome
    # ghostty # corrupted?
    karabiner-elements
    neovide
    ngrok
    obsidian
    postman
    raycast
    skimpdf
    slack
    temurin-bin
    temurin-bin-17
    vscode
    wireshark
    zoom-us
  ];
  home-manager = {
    users.${defaultUser} =
      { lib, ... }:
      {
        home = {
          homeDirectory = lib.mkForce "/Users/${defaultUser}";
        };
      };
  };
  homebrew = {
    enable = true;
    casks = [
      "amethyst"
      "google-drive"
      "ghostty"
      "jetbrains-toolbox"
      "vivaldi"
    ];
  };
}
