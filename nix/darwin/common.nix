{ pkgs, defaultUser, ... }:
{
  imports = [ ../common/system.nix ];
  system = {
    activationScripts.extraActivation.text = ''
      ln -sfn {${pkgs.temurin-bin-17},}/Library/Java/JavaVirtualMachines/temurin-17.jdk
      ln -sfn {${pkgs.temurin-bin},}/Library/Java/JavaVirtualMachines/temurin.jdk
    '';
  };
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };
  environment.systemPackages = with pkgs; [
    colima
    karabiner-elements
    cocoapods
    temurin-bin-17
    (writeShellScriptBin "gtar" ''exec ${lib.getExe gnutar} "$@"'')
    (writeShellScriptBin "gsed" ''exec ${lib.getExe gnused} "$@"'')
    (writeShellScriptBin "gawk" ''exec ${lib.getExe gawk} "$@"'')
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
  users.users.${defaultUser} = {
    name = defaultUser;
  };
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
