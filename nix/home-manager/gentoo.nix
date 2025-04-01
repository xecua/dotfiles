{
  pkgs,
  nixgl,
  config,
  ...
}:
{
  imports = [ ./linux.nix ];
  nixpkgs.config.allowUnfree = true;
  nixGL.packages = nixgl.packages;
  home.packages = with pkgs; [
    buildkit
    jnv
    (config.lib.nixGL.wrap neovide)
  ];
}
