{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
      wsl = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.nixos-wsl.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          ({ lib, pkgs, ... } :
          let
            stateVersion = "24.05";
          in {
            system.stateVersion = stateVersion;
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
            environment.systemPackages = with pkgs; [
              gcc git llvm
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
                  stateVersion = stateVersion;
                  packages = with pkgs; [
                    inputs.neovim-nightly-overlay.packages.${system}.default
                    fish deno rustup nodejs go
                    tmux unzip direnv difftastic
                    eza fd ripgrep fzf lazygit tig lnav fastfetch jnv jaq
                    unar hexyl bat starship
                  ];
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
        moduels = [
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
