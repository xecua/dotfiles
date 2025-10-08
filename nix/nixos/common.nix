{
  pkgs,
  defaultUser,
  mcp-hub,
  ...
}:
{
  imports = [ ../system.nix ];
  i18n = {
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
    ];
    defaultLocale = "en_US.UTF-8";
  };
  environment.systemPackages = with pkgs; [
    file
    iaito # radare2 GUI
  ];
  home-manager = {
    extraSpecialArgs = { inherit mcp-hub defaultUser; };
    users.${defaultUser} = {
      imports = [ ../home-manager/linux.nix ];
    };
  };
}
