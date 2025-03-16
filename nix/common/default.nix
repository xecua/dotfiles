{
  pkgs,
  defaultUser,
  ...
}:
{
  imports = [
    ./files.nix
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${defaultUser} = {
      programs.home-manager.enable = true;
      home = {
        username = defaultUser;
        stateVersion = "24.05";
        packages = with pkgs; [
          # LSP Servers
          astro-language-server
          pyright
          yapf
          clang-tools # includes clangd
          typescript-language-server
          nodePackages_latest.prettier
          vim-language-server
          vscode-langservers-extracted # html, css, eslint
          efm-langserver
          gopls
          nil # Nix
          kotlin-language-server
          jdt-language-server
          texlab
          stylelint-lsp
          lua-language-server
          stylua
          sqls
          sql-formatter
          lemminx # XML
          yaml-language-server
          taplo # TOML
          typos-lsp

          (writeShellScriptBin "php-debug-adapter" ''
            exec ${lib.getBin nodejs}/bin/node ${lib.getLib vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js "$@"
          '')

          (intelephense.overrideAttrs (oldAttrs: rec {
            version = "1.12.6";
            src = fetchurl {
              url = "https://registry.npmjs.org/intelephense/-/intelephense-${version}.tgz";
              hash = "sha256-p2x5Ayipoxk77x0v+zRhg86dbRHuBBk1Iegk/FaZrU4=";
            };
          }))
        ];
      };
    };
  };
}
