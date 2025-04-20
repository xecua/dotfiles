{
  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixos";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, treefmt, ... }@inputs:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      eachSystem =
        callback: nixpkgs.lib.genAttrs systems (system: callback nixpkgs.legacyPackages.${system});
    in
    {
      formatter = eachSystem (
        pkgs:
        treefmt.lib.mkWrapper pkgs {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
        }
      );
      nixosConfigurations = {
        upside-down-face = inputs.nixos.lib.nixosSystem {
          modules = [
            inputs.nixos-wsl.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            (import ./nix/nixos/desktop-wsl.nix)
          ];
          specialArgs = {
            defaultUser = "xecua";
            # inherit (inputs) neovim-nightly-overlay;
          };
        };
      };
      darwinConfigurations = {
        default = inputs.nix-darwin.lib.darwinSystem {
          modules = [
            inputs.home-manager.darwinModules.home-manager
            (import ./nix/darwin/pro-m1.nix)
          ];
          specialArgs = {
            defaultUser = "shiba";
            # inherit (inputs) neovim-nightly-overlay;
          };
        };
      };
      homeConfigurations = {
        gentoo = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ (import ./nix/home-manager/gentoo.nix) ];
          extraSpecialArgs = {
            defaultUser = "xecua";
            inherit (inputs) nixgl; # neovim-nightly-overlay
          };
        };
      };
    };
}

# ↓ネイティブで入れる機会あったら書くやつ
# Desktop App
# bitwarden-desktop obsidian vivaldi vivaldi-ffmpeg-codecs firefox-devedition-bin
#
# Native
# containerd slirp4netns cni-plugins nerdctl rootlesskit buildkit
# fcitx fcitx-configtool fcitx-gtk fcitx-qt fcitx-skk chafa walker
# discord blueman wf-recorder wl-clipboard xremap xdg-desktop-portal-hyprland protonmail-desktop adwaita-qt dunst ghostty
# alsa-utils bluez-alsa pavucontrol playerctl pipewire obs-studio
# grim hypridle hyprlock hyprpaper kanshi qt6ct greetd.greetd greetd.tuigreet waybar
# libfido2 yubikey-manager
#
# Kernel/File System
# refind btrfs-progs parted efibootmgr
# v4l2loopback: https://nixos.wiki/wiki/OBS_Studio
# nVidia driver: https://nixos.wiki/wiki/Nvidia
