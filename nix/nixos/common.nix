{ defaultUser, mcp-hub, ... }:
{
  imports = [ ../common/system.nix ];
  i18n = {
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
    ];
    defaultLocale = "en_US.UTF-8";
  };
  home-manager = {
    extraSpecialArgs = { inherit mcp-hub defaultUser; };
    users.${defaultUser} = {
      imports = [ ../home-manager/linux.nix ];
    };
  };
}
