{
  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixos";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mcp-hub = {
      url = "github:ravitemer/mcp-hub";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      systems = [
        "x86_64-linux"
      ];
      eachSystem =
        callback: nixpkgs.lib.genAttrs systems (system: callback nixpkgs.legacyPackages.${system});
      overlays = [
        inputs.neovim-nightly-overlay.overlays.default # これコメントアウトすれば安定板に戻せる気がする
      ];
    in
    {
      formatter = eachSystem (
        pkgs:
        inputs.treefmt.lib.mkWrapper pkgs {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
        }
      );
      nixosConfigurations = {
        upside-down-face = inputs.nixos.lib.nixosSystem {
          modules = [
            { nixpkgs.overlays = overlays; }
            inputs.nixos-wsl.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            (import ./nix/nixos/desktop-wsl.nix)
          ];
          specialArgs = {
            defaultUser = "xecua";
            inherit (inputs) mcp-hub;
          };
        };
      };
    };
}

# ↓ネイティブで入れる機会あったら書くやつ
# Desktop App
# bitwarden-desktop obsidian vivaldi vivaldi-ffmpeg-codecs firefox-devedition
#
# Native
# containerd slirp4netns cni-plugins nerdctl rootlesskit buildkit
# fcitx fcitx-configtool fcitx-gtk fcitx-qt fcitx-skk chafa walker corefonts
# discord blueman wf-recorder wl-clipboard xremap xdg-desktop-portal-hyprland protonmail-desktop adwaita-qt dunst ghostty
# alsa-utils bluez-alsa pavucontrol playerctl pipewire obs-studio
# grim hypridle hyprlock hyprpaper kanshi qt6ct greetd.greetd greetd.tuigreet waybar
# libfido2 yubikey-manager
#
# Kernel/File System
# refind btrfs-progs parted efibootmgr
# v4l2loopback: https://nixos.wiki/wiki/OBS_Studio
# nVidia driver: https://nixos.wiki/wiki/Nvidia
