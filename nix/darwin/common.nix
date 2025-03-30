{ pkgs, defaultUser, ... }:
{
  imports = [ ../common/system.nix ];
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
  home-manager.users.${defaultUser} = {
    imports = [ ../home-manager/darwin.nix ];
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
