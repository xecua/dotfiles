{
  description = "xecua's dotfiles (portageでカバーできない分のシステム情報を含む)";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    # NixOSじゃなくてもLinuxはnixos-でいいらしい(darwinはもちろんnixpkgs-26.05-darwin)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
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

      # 設定ファイルを書くとき用の開発環境。
      # 更新の速いツールばかりなのでunstableを見る
      perSystem =
        { system, ... }:
        let
          pkgsUnstable = import inputs.nixpkgs-unstable { inherit system; };
        in
        {
          devShells.default = pkgsUnstable.mkShell {
            packages = with pkgsUnstable; [
              fish-lsp
              lua-language-server
              (stylua.override {
                features = [
                  "lua54"
                  "luajit"
                  "luau"
                  "lsp"
                ];
              })
            ];
          };
        };

      # home-managerの設定はsystem非依存 (x86_64-linux決め打ち) なのでtop-levelに置く
      flake =
        let
          system = "x86_64-linux";
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePackages = [
              "nvidia"
              "nvidia-x11"
            ];
          };
          mkHomeManagerConfiguration =
            {
              nvidiaVersion ? null,
              nvidiaHash ? null,
              gpuWrapper,
            }:
            let
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
                ./home.nix
              ];
              extraSpecialArgs = {
                inherit
                  inputs
                  nixglPackages
                  gpuWrapper
                  ;
              };
            };
        in
        {
          homeConfigurations = {
            "xecua@melting-face" = mkHomeManagerConfiguration { gpuWrapper = "mesa"; };
            "xecua@smiling-face-with-halo" = mkHomeManagerConfiguration {
              gpuWrapper = "nvidia";
              nvidiaVersion = "595.84"; # オープンソース版をclangでビルドするとバージョンが取れないっぽい
              # .runファイルのhash(pureにするために必要)。バージョン上げたときは一旦そのままswitchしてみて、正しい値に置換するとよい
              nvidiaHash = "sha256-mcQE5SExvye8ptoCaNzOPr7cenOrF0BxqZXPGmxeugY=";
            };
          };
        };
    };
}
