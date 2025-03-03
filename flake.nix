{
  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
      nixosConfigurations = {
        upside-down-face = inputs.nixos.lib.nixosSystem {
          modules = [
            inputs.nixos-wsl.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            (import ./nix/common.nix)
            (import ./nix/desktop/wsl.nix)
          ];
          specialArgs = {
            defaultUser = "xecua";
            inherit (inputs) neovim-nightly-overlay;
          };
        };
      };
      darwinConfigurations = {
        default = inputs.nix-darwin.lib.darwinSystem {
          modules = [
            inputs.home-manager.darwinModules.home-manager
            (import ./nix/common.nix)
            (import ./nix/macbook/pro-m1.nix)
          ];
          specialArgs = {
            defaultUser = "shiba";
            inherit (inputs) neovim-nightly-overlay;
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
# containerd slirp4netns cni-plugins nerdctl rootlesskit
# fcitx fcitx-configtool fcitx-gtk fcitx-qt fcitx-skk chafa
# discord httpie blueman wf-recorder wl-clipboard xremap xdg-desktop-portal-hyprland protonmail-desktop adwaita-qt
# udev-gothic udev-gothic-nf noto-fonts-cjk-sans noto-fonts-cjk-serif noto-fonts-color-emoji corefonts nerd-fonts.symbols-only dunst ghostty font-awesome
# alsa-utils bluez-alsa pavucontrol playerctl pipewire obs-studio
# grim hypridle hyprlock hyprpaper kanshi qt6ct greetd.greetd greetd.tuigreet waybar
# libfido2 yubikey-manager
#
# Kernel/File System
# refind btrfs-progs parted efibootmgr
# v4l2loopback: https://nixos.wiki/wiki/OBS_Studio
# nVidia driver: https://nixos.wiki/wiki/Nvidia
