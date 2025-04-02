{
  pkgs,
  defaultUser,
  ...
}:
{
  imports = [ ./files.nix ];
  programs.home-manager.enable = true;
  home = {
    username = defaultUser;
    stateVersion = "25.05";
    packages = with pkgs; [
      uv
      deno # w/ denols
      rustup # w/ rust-analyzer
      typescript # w/ tsserver
      # haskellPackages.ghcup # broken

      # LSP Servers
      astro-language-server
      pyright
      yapf
      clang-tools # includes clangd
      nodePackages_latest.prettier
      vim-language-server
      vscode-langservers-extracted # html, css, eslint
      efm-langserver
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
