{
  pkgs,
  pkgsUnstable,
  gpuWrapper,
  nixglPackages,
  config,
  inputs,
  lib,
  ...
}:
let
  installScripts =
    if gpuWrapper == "mesa" then
      [ "mesa" ]
    else if gpuWrapper == "nvidia" then
      [
        "mesa"
        "nvidia"
      ]
    else
      [ ];
  chrome-executable =
    if pkgs.stdenv.isDarwin then
      "/Applications/Vivaldi.app/Contents/MacOS/Vivaldi"
    else
      "/usr/bin/vivaldi";
in
{
  _module.args = {
    pkgsUnstable = import inputs.nixpkgs-unstable {
      inherit (pkgs.stdenv.hostPlatform) system;
      inherit (config.nixpkgs) config;
    };
  };

  targets.genericLinux.nixGL = {
    packages = nixglPackages;
    defaultWrapper = gpuWrapper;
    installScripts = installScripts;
  };

  nixpkgs.config.allowUnfreePackages = [
    "claude-code"
    "claude-agent-acp"
    "github-copilot-cli"
    "copilot-language-server"
    "intelephense"
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = "xecua";
    homeDirectory = "/home/xecua";
    shell.enableShellIntegration = false;
    preferXdgDirectories = true;

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "26.05"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages =
      (with pkgs; [
        nil
        nixfmt
        tinymist
        serve
        unar
        sqls
        lazydocker
        termshot
        browsr
        gogup # いるかなあ
        captive-browser

        intelephense
        oxfmt
        oxlint
        efm-langserver
        vim-language-server
        yaml-language-server
        lemminx
        typos-lsp

        usql
        hayagriva
        # xwayland-satellite # これもnixGLいりそう
        usage
        jnv
        tdf
        # (config.lib.nixGL.wrap neovide) # 動かねえ……
        typescript-go

        idris2Packages.pack

        (writeShellScriptBin "stylelint-language-server" ''
          exec ${pkgs.nodejs}/bin/node ${pkgs.vscode-extensions.stylelint.vscode-stylelint}/share/vscode/extensions/stylelint.vscode-stylelint/dist/index.js "$@"
        '')

        (python3.withPackages (
          ps: with ps; [
            debugpy
          ]
        ))
      ])
      ++ (with pkgsUnstable; [
        claude-agent-acp
        copilot-language-server
        bitwarden-cli

        # v0.* (assuming frequently updated)
        ty
        tombi
        rumdl
        mcat
        eza
        zmx
        hunk
        tuicr

        (writeShellScriptBin "kitesurf-mcp" ''
          set -euo pipefail
          account_id=$(${lib.getExe' bitwarden-cli "bw"} get username kitesurf)
          api_token=$(${lib.getExe' bitwarden-cli "bw"} get password kitesurf)
          ws_headers=$(${lib.getExe jq} -nc --arg token "$api_token" '{Authorization: ("Bearer " + $token)}')
          exec ${
            lib.getExe inputs.mcp-servers-nix.packages.${stdenv.hostPlatform.system}.chrome-devtools-mcp
          } \
            "--wsEndpoint=wss://api.cloudflare.com/client/v4/accounts/''${account_id}/browser-rendering/devtools/browser?browser=kitesurf&keep_alive=600000" \
            "--wsHeaders=''${ws_headers}"
        '')

      ])
      ++ [
        # note: nix flake showでいい感じにoutputが見れる
        inputs.quien.packages.${pkgs.stdenv.hostPlatform.system}.quien
      ];
  };

  mcp-servers.programs = {
    # mcp-servers-nix part
    chrome-devtools = {
      enable = true;
      executable = chrome-executable;
    };
    nixos.enable = true;
    playwright = {
      enable = true;
      executable = chrome-executable;
    };
  };

  programs = {
    home-manager.enable = true;
    nh = {
      enable = true;
      homeFlake = "${config.home.homeDirectory}/Documents/repos/github.com/xecua/dotfiles";
    };

    mcp = {
      # home-manager part
      enable = true;
      servers = {
        kitesurf.command = "kitesurf-mcp";
      };
    };

    github-copilot-cli = {
      enable = true;
      package = pkgsUnstable.github-copilot-cli;
      enableMcpIntegration = true;
    };
    claude-code = {
      enable = true;
      package = pkgsUnstable.claude-code;
      enableMcpIntegration = true;
      configDir = "${config.xdg.configHome}/claude";
      hooks = {
        block-find-exec = ''
          #!/usr/bin/env fish
          set -l command (cat | jaq -r '.tool_input.command // empty')
          # findのexecとかを位置問わず拒否
          if string match -r '\bfind\b+.*\s-exec(dir)?\b' -- $command
              echo "Blocked: execを伴うfindはファイルシステムを破壊する可能性があるため許可されていません"
              exit 2
          else if string match -r '\fd\b+.*\s(--exec(-batch)?|-x|-X)\b' -- $command
              echo "Blocked: execを伴うfdはファイルシステムを破壊する可能性があるため許可されていません"
              exit 2
          end
        '';
      };
      settings = {
        model = "sonnet";
        advisorModel = "opus";
        tui = "fullscreen";
        editorMode = "vim";

        permissions = {
          defaultMode = "auto";
          allow = [
            "Read"
            "Bash(cd)"
            "Bash(ls)"
            "Bash(git status)"
            "Bash(git show)"
            "Bash(git log)"
            "Bash(git diff)"
            "Bash(git blame)"
            "Bash(git commit)"
            "Bash(npm run build)"
            "Bash(tsc --noEmit)"
            "Bash(jq)"
            "Bash(jaq)"
            "Artifact"
            "Edit"
            "EnterWorktree"
            "NotebookEdit"
            "Skill"
            "WebFetch"
            "Workflow"
          ];
          deny = [
            "Bash(sudo)"
            "Bash(rm)"
            "Bash(git reset *)"
            "Bash(git restore *)"
            "Bash(git switch *)"
            "Bash(git checkout *)"
            "Bash(git rebase *)"
            "Bash(git push --force *)"
            "Bash(telnet)"
            "Bash(nc)"
            "Bash(curl)"
            "Bash(wget)"
            "Bash(ssh)"
            "Bash(scp)"
            "Bash(sftp)"
            "Read(.env*)"
            "Edit(.env*)"
          ];
          "ask" = [ "Bash(git push)" ];
        };
        hooks = {
          PreToolUse = [
            {
              matcher = "Bash";
              hooks = [
                {
                  type = "command";
                  command = "\${CLAUDE_CONFIG_DIR:-\$HOME/.claude}/hooks/block-find-exec";
                }
              ];
            }
          ];
        };
        enabledPlugins = {
          "gopls-lsp@claude-plugins-official" = true;
          "lua-lsp@claude-plugins-official" = true;
          "pyright-lsp@claude-plugins-official" = true;
          "typescript-lsp@claude-plugins-official" = true;
        };
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      package = pkgs.direnv.overrideAttrs (oldAttrs: {
        installPhase = ''
          runHook preInstall
        ''
        + (oldAttrs.installPhase or "")
        + ''
          runHook postInstall
        '';
      });
    };

  };
}
