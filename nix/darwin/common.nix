{ pkgs, defaultUser, ... }:
{
  imports = [
    ../common
    ../common/extra-pkgs.nix
  ];
  system = {
    activationScripts.extraActivation.text = ''
      ln -sf ${pkgs.temurin-bin-17} /Library/Java/JavaVirtualMachines/temurin-17.jdk
      ln -sf ${pkgs.temurin-bin} /Library/Java/JavaVirtualMachines/temurin.jdk
    '';
  };
  environment.systemPackages = with pkgs; [
    colima
    karabiner-elements
    temurin-bin-17
    (writeShellScriptBin "gtar" ''exec ${lib.getExe gnutar} "$@"'')
    (writeShellScriptBin "gsed" ''exec ${lib.getExe gnused} "$@"'')
    firefox
    google-chrome
    neovide
    postman
    raycast
    skimpdf
    slack
    vscode
    wireshark
    zoom-us
  ];
  home-manager.users.${defaultUser} =
    { lib, ... }:
    {
      home = {
        homeDirectory = lib.mkForce "/Users/${defaultUser}";
        packages = with pkgs; [
          docker-client
          docker-compose
          docker-credential-helpers
          iproute2mac
          # ghostty # corrupted?
        ];
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
      "macskk"
      "jetbrains-toolbox"
      "obsidian"
      "vivaldi"
    ];
  };
}
