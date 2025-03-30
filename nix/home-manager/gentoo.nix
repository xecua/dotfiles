{ pkgs, ... }:
{
  imports = [ ./linux.nix ];
  home.packages = with pkgs; [
    buildkit
    neovide
    jnv
  ];
}
