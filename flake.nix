{
  description = "dotfiles";

  inputs = {
    # NixOSじゃなくてもLinuxはnixos-でいいらしい
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      # url = "github:nix-community/nixGL";
      # https://github.com/nix-community/nixGL/pull/223
      url = "github:TheTeXnician/nixGL/update-for-latest-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quien = {
      url = "github:retlehs/quien";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      home-manager,
      nixgl,
      mcp-servers-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { inputs', ... }:
        let
          pkgs = inputs'.nixpkgs-unstable.legacyPackages;
        in
        {
          formatter = pkgs.nixfmt-tree;

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              fish-lsp
              lua-language-server
              (luajit.withPackages (
                ls: with ls; [
                  luacheck
                ]
              ))
              taplo
              (stylua.override {
                features = [
                  "lua54"
                  "luajit"
                  "luau"
                  "lsp"
                ];
              })
              (python3.withPackages (
                ps: with ps; [
                  debugpy
                  pyyaml
                ]
              ))
            ];
          };
        };

      flake =
        let
          nixpkgsFor = {
            x86_64-linux = inputs.nixpkgs;
            aarch64-darwin = inputs.nixpkgs-darwin;
          };
          mkHomeManagerConfiguration =
            {
              system,
              homeModule,
              gpuWrapper ? null,
              nvidiaVersion ? null,
              nvidiaHash ? null,
            }:
            let
              pkgs = import nixpkgsFor.${system} { inherit system; };
              nixglPackages =
                if nvidiaVersion == null then
                  nixgl.packages.${system}
                else
                  nixgl.packages.${system}
                  // (pkgs.callPackage "${nixgl}/nixGL.nix" {
                    inherit nvidiaVersion nvidiaHash;
                  });
            in
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                mcp-servers-nix.homeManagerModules.default
                homeModule
              ];
              extraSpecialArgs = {
                inherit inputs;
              }
              // nixpkgs.lib.optionalAttrs (gpuWrapper != null) {
                inherit gpuWrapper nixglPackages;
              };
            };
        in
        {
          homeConfigurations = {
            "xecua@melting-face" = mkHomeManagerConfiguration {
              system = "x86_64-linux";
              gpuWrapper = "mesa";
              homeModule = ./gentoo-home.nix;
            };
            "xecua@smiling-face-with-halo" = mkHomeManagerConfiguration {
              system = "x86_64-linux";
              gpuWrapper = "nvidia";
              nvidiaVersion = "595.84"; # オープンソース版をclangでビルドするとバージョンが取れないっぽい
              # .runファイルのhash(pureにするために必要)。バージョン上げたときは一旦そのままswitchしてみて、正しい値に置換するとよい
              nvidiaHash = "sha256-mcQE5SExvye8ptoCaNzOPr7cenOrF0BxqZXPGmxeugY=";
              homeModule = ./gentoo-home.nix;
            };
            "xecua@apple" = mkHomeManagerConfiguration {
              system = "aarch64-darwin";
              homeModule = ./macos-home.nix;
            };
          };
        };
    };
}
