{
  pkgs,
  defaultUser,
  mcp-hub,
  ...
}:
{
  imports = [ ./files.nix ];
  programs = {
    home-manager.enable = true;
    neovide = {
      enable = true;
      package = null;
      settings = {
        fork = true;
        title-hidden = true;
        font.normal = "UDEV Gothic 35NFLG";
      };
    };
  };
  home = {
    username = defaultUser;
    stateVersion = "25.05";
    packages = with pkgs; [
      # nix util
      nix-tree
      nvd

      mcp-hub.packages.${system}.mcp-hub

      uv
      deno # w/ denols
      typescript # w/ tsserver
      # haskellPackages.ghcup # broken

      # LSP Servers
      astro-language-server
      pyright
      yapf
      clang-tools # includes clangd
      copilot-language-server # replaces copilot.vim/copilot.lua
      prettier
      rust-analyzer
      vim-language-server
      vscode-langservers-extracted # html, css, eslint
      efm-langserver
      fish-lsp
      gopls
      nil # Nix
      kotlin-language-server
      intelephense
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
      fsautocomplete
      fantomas
      php84Packages.php-codesniffer
      jbang
      fvm # Flutter w/ Dart, including dart-analyzer

      # Debug Servers
      netcoredbg
      delve
      # codelldb, debugpy: phpと同じように?
      (writeShellScriptBin "php-debug-adapter" ''
        exec ${lib.getBin nodejs}/bin/node ${lib.getLib vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js "$@"
      '')

    ];
  };
}
