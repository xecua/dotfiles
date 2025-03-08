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
    (writeShellScriptBin "gtar" ''exec ${lib.getExe gnutar} "$@"'')
    (writeShellScriptBin "gsed" ''exec ${lib.getExe gnused} "$@"'')
  ];
  home-manager = {
    users.${defaultUser} =
      { lib, ... }:
      {
        home = {
          homeDirectory = lib.mkForce "/Users/${defaultUser}";
          packages = with pkgs; [
            darwin.iproute2mac
            docker-client
            docker-compose
            docker-credential-helpers
            firefox
            flutter
            # ghostty # corrupted?
            google-chrome
            mutagen
            mutagen-compose
            neovide
            ngrok
            postman
            raycast
            skimpdf
            slack
            vscode
            wireshark
            zoom-us
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
      "ghostty"
      "google-drive"
      "jetbrains-toolbox"
      "obsidian"
      "vivaldi"
    ];
  };
}
