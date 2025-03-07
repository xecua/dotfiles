{ pkgs, defaultUser, ... }:
{
  system = {
    # ?
    activationScripts.extraActivate.text = ''
      ln -sf ${pkgs.temurin-bin-17} /Library/Java/JavaVirtualMachines/temurin-17.jdk
      ln -sf ${pkgs.temurin-bin} /Library/Java/JavaVirtualMachines/temurin.jdk
    '';
    stateVersion = 6;
  };
  nixpkgs.hostPlatform = "aarch64-darwin";
  environment.systemPackages = with pkgs; [
    colima
    karabiner-elements
    temurin-bin-17
  ];
  home-manager = {
    users.${defaultUser} =
      { lib, ... }:
      {
        home = {
          homeDirectory = lib.mkForce "/Users/${defaultUser}";
          packages = with pkgs; [
            firefox
            flutter
            google-chrome
            # ghostty # corrupted?
            neovide
            ngrok
            obsidian
            postman
            raycast
            skimpdf
            slack
            vscode
            wireshark
            zoom-us
            docker-client
            docker-compose
            mutagen
            mutagen-compose
          ];
        };
      };
  };
  homebrew = {
    enable = true;
    taps = [
      "laishulu/homebrew" # macism
    ];
    brews = [
      "macism"
    ];
    casks = [
      "amethyst"
      "google-drive"
      "ghostty"
      "jetbrains-toolbox"
      "vivaldi"
    ];
  };
}
