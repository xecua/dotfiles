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
    let
      scripts =
        let
          pkgs = (import <nixpkgs> { });
        in
        {
          format = {
            # requires --impure?
            type = "app";
            program = toString (pkgs.writeShellScript "nix-format" "nix fmt flake.nix nix/**/*.nix");
          };
        };
    in
    {
      # flake-partsとか使えそう?
      formatter = {
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
        aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
      };
      apps = {
        x86_64-linux = scripts;
        aarch64-darwin = scripts;
      };
      nixosConfigurations = {
        upside-down-face = inputs.nixos.lib.nixosSystem {
          modules = [
            inputs.nixos-wsl.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            (import ./nix/nixos/desktop-wsl.nix)
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
            (import ./nix/darwin/pro-m1.nix)
          ];
          specialArgs = {
            defaultUser = "shiba";
            inherit (inputs) neovim-nightly-overlay;
          };
        };
      };
      # 直home-managerはLinuxでファイルの配置をするときくらいな気がする
      homeConfigurations = {
        gentoo = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [ (import ./nix/home-manager/gentoo.nix) ];
          extraSpecialArgs = {
            defaultUser = "xecua";
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
# containerd slirp4netns cni-plugins nerdctl rootlesskit buildkit
# fcitx fcitx-configtool fcitx-gtk fcitx-qt fcitx-skk chafa
# discord blueman wf-recorder wl-clipboard xremap xdg-desktop-portal-hyprland protonmail-desktop adwaita-qt dunst ghostty
# alsa-utils bluez-alsa pavucontrol playerctl pipewire obs-studio
# grim hypridle hyprlock hyprpaper kanshi qt6ct greetd.greetd greetd.tuigreet waybar
# libfido2 yubikey-manager
#
# Kernel/File System
# refind btrfs-progs parted efibootmgr
# v4l2loopback: https://nixos.wiki/wiki/OBS_Studio
# nVidia driver: https://nixos.wiki/wiki/Nvidia
