{
  pkgs,
  defaultUser,
  mcp-hub,
  ...
}:
{
  imports = [ ../system.nix ];
  system = {
    activationScripts.extraActivation.text = ''
      ln -sfn {${pkgs.temurin-bin-17},}/Library/Java/JavaVirtualMachines/temurin-17.jdk
      ln -sfn {${pkgs.temurin-bin-21},}/Library/Java/JavaVirtualMachines/temurin-21.jdk
    '';
  };
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };
  environment.systemPackages = with pkgs; [
    lima
    colima
    karabiner-elements
    cocoapods
    (writeShellScriptBin "gtar" ''exec ${lib.getExe gnutar} "$@"'')
    (writeShellScriptBin "gsed" ''exec ${lib.getExe gnused} "$@"'')
    (writeShellScriptBin "gawk" ''exec ${lib.getExe gawk} "$@"'')
    postman
    raycast
    skimpdf
    slack
  ];
  users.users.${defaultUser} = {
    name = defaultUser;
  };
  home-manager = {
    extraSpecialArgs = { inherit mcp-hub defaultUser; };
    users.${defaultUser} = {
      imports = [ ../home-manager/darwin.nix ];
      programs.neovide.settings.frame = "buttonless";
    };
  };
  homebrew = {
    enable = true;
    user = defaultUser;
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
      "zoom"
      "wireshark-app"
    ];
  };
}
