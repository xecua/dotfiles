{
  pkgs,
  nixgl,
  config,
  ...
}:
{
  imports = [ ./linux.nix ];
  nixGL.packages = nixgl.packages;
  home.packages = with pkgs; [
    buildkit
    jnv
    (config.lib.nixGL.wrap neovide)
  ];
}
