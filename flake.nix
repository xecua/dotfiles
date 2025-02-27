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

  outputs = { self, ... }@inputs: {
    nixosConfigurations = {
      # NixOS on WSL
      wsl = inputs.nixos.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.nixos-wsl.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          ({ lib, pkgs, ... } : {
            system = {
              configurationRevision = self.rev or self.dirtyRev or null;
              stateVersion = "24.05";
            };
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
            environment.systemPackages = with pkgs; [
              gcc git llvm gnupg mold
            ];
            wsl = {
              enable = true;
              defaultUser = "xecua";
            };
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.xecua = {
                home = {
                  stateVersion = "24.05";
                  packages = with pkgs; [
                    inputs.neovim-nightly-overlay.packages.${system}.default
                    fish deno rustup nodejs go
                    tmux unzip direnv difftastic
                    eza fd ripgrep fzf lazygit tig lnav fastfetch jnv jaq
                    unar hexyl bat starship skktools
                    bat-extras.prettybat bat-extras.batpipe bat-extras.batman
                    sccache radare2 typst bottom temurin-bin
                    # .NET: https://nixos.wiki/wiki/DotNET
                  ];
                  # file = {};
                  # xdg.configFile = {};
                };
                programs.home-manager.enable = true;
              };
              # dotfilesの各ファイルを配置するやつを書く
            };
          })
        ];
      };
    };
    darwinConfigurations = {
      default = inputs.nix-darwin.lib.darwinSystem {
        modules = [
          ({ pkgs, ...  }: {
            environment.systemPackages = with pkgs; [
              git
            ];
              nix.settings.experimental-features = [ "nix-command" "flakes" ];
          })
        ];
      };
    };
  };
}

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
# Driver: 一番めんどくさい。とりあえずネイティブで入れる予定ないし後で……
# v4l2loopback: https://nixos.wiki/wiki/OBS_Studio
# nVidia driver: https://nixos.wiki/wiki/Nvidia
