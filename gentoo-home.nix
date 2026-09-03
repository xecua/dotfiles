{
  pkgs,
  pkgsUnstable,
  # gpuWrapper,
  # nixglPackages,
  config,
  inputs,
  lib,
  ...
}:
let
  # installScripts =
  #   if gpuWrapper == "mesa" then
  #     [ "mesa" ]
  #   else if gpuWrapper == "nvidia" then
  #     [
  #       "mesa"
  #       "nvidia"
  #     ]
  #   else
  #     [ ];
  chrome-executable = "/usr/bin/vivaldi";
  yamlFormatter = pkgs.formats.yaml { };

  # codexは信用設定(projects.<path>.trust_level)やモデル選択を$CODEX_HOME/config.tomlに
  # 書き戻すが、home-managerが張るのはstoreへのシンボリックリンクなので書き込めない。
  # Unixでは管理者用の読み取り専用レイヤが/etc/codex配下固定なので逃がす先もない。
  # そこでリンクはやめ、生成物を実ファイルへマージする。
  codexHome = "${config.xdg.configHome}/codex";
  # programs/codex.nixのconfigDirと同じ計算 ("/.config/codex/config.toml")
  codexConfigAttr = "${lib.removePrefix config.home.homeDirectory config.xdg.configHome}/codex/config.toml";

  codexConfigMerge = pkgs.writers.writePython3Bin "codex-config-merge" {
    libraries = [ pkgs.python3Packages.tomlkit ];
    flakeIgnore = [ "E501" ];
  } ''
    import os
    import sys

    import tomlkit


    def merge(base, over):
        for key, value in over.items():
            if key in base and isinstance(base[key], dict) and isinstance(value, dict):
                merge(base[key], value)
            else:
                base[key] = value


    src, dst = sys.argv[1], sys.argv[2]

    with open(src) as f:
        overlay = tomlkit.parse(f.read())

    try:
        with open(dst) as f:
            doc = tomlkit.parse(f.read())
    except FileNotFoundError:
        doc = tomlkit.document()

    # mcp_serversはNix側を正とするので丸ごと差し替える。
    # (深いマージだとNixから消したサーバが実ファイルに残り続ける)
    doc.pop("mcp_servers", None)

    merge(doc, overlay)

    # tmp+renameにすることで、dstが前世代のstoreへのシンボリックリンクのまま
    # 残っていても(読み取り専用のリンク先ではなく)実ファイルで置き換えられる
    tmp = dst + ".hm-new"
    with open(tmp, "w") as f:
        f.write(tomlkit.dumps(doc))
    os.replace(tmp, dst)
  '';
in
{
  _module.args = {
    pkgsUnstable = import inputs.nixpkgs-unstable {
      inherit (pkgs.stdenv.hostPlatform) system;
      inherit (config.nixpkgs) config;
    };
  };

  # targets.genericLinux.nixGL = {
  #   packages = nixglPackages;
  #   defaultWrapper = gpuWrapper;
  #   installScripts = installScripts;
  # };

  nixpkgs.config.allowUnfreePackages = [
    "claude-code"
    "claude-agent-acp"
    "codex"
    "codex-acp"
    "github-copilot-cli"
    "copilot-language-server"
    "intelephense"
  ];

  xdg = {
    configFile = {
      wgetrc = {
        target = "wgetrc";
        text = "hsts-file = ${config.xdg.cacheHome}/wget-hsts";
      };
    };
    dataFile = {
      #   java-debug = {
      #     target = "java-debug";
      #     source = "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug";
      #   };
      #   java-test = {
      #     target = "java-test";
      #     source = "${pkgs.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test";
      #   };
    };
  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = "xecua";
    homeDirectory = "/home/${config.home.username}";
    shell.enableShellIntegration = false;
    preferXdgDirectories = true;

    file = {
      indentconfig = {
        target = ".indentconfig.yaml";
        source = yamlFormatter.generate ".indentconfig.yaml" {
          paths = [ "${./latexindent/setting.yaml}" ];
        };
      };

      # 実体はhome.activation.codexConfigが書く。sourceは評価されたまま残るので参照できる
      ${codexConfigAttr}.enable = lib.mkForce false;
    };

    # linkGenerationの後でなければならない。writeBoundaryの時点では前世代の
    # シンボリックリンクがまだ残っており、storeへ書きに行って失敗する
    activation.codexConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run mkdir -p ${lib.escapeShellArg codexHome}
      run ${codexConfigMerge}/bin/codex-config-merge \
        ${config.home.file.${codexConfigAttr}.source} \
        ${lib.escapeShellArg "${codexHome}/config.toml"}
    '';

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

        # intelephense
        tinymist
        serve
        unar
        sqls
        lazydocker
        termshot
        # browsr
        # gogup # いるかなあ
        captive-browser
        google-clasp

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

        (writeShellScriptBin "stylelint-language-server" ''
          exec ${nodejs}/bin/node ${vscode-extensions.stylelint.vscode-stylelint}/share/vscode/extensions/stylelint.vscode-stylelint/dist/index.js "$@"
        '')

        # (writeShellScriptBin "php-debug-adapter" ''
        #   exec ${nodejs}/bin/node ${vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js "$@"
        # '')

        # (writeShellScriptBin "vscode-lldb" ''
        #   exec ${vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb "$@"
        # '')

        (python314.withPackages (
          ps: with ps; [
            debugpy
          ]
        ))
      ])
      ++ (with pkgsUnstable; [
        claude-agent-acp
        codex-acp
        copilot-language-server
        bitwarden-cli
        android-cli

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
  };

  programs = {
    home-manager.enable = true;
    nh = {
      enable = true;
      homeFlake = "${config.xdg.userDirs.projects}/github.com/xecua/dotfiles";
    };

    mcp = {
      # home-manager part
      enable = true;
      servers = {
        kitesurf.command = "kitesurf-mcp";
        postgres.command = "npx @microsoft/postgres-mcp";
        mysql.command = "uvx mysql-mcp-server";
        chrome-devtools.command = "chrome-devtools-mcp --auto-connect";
      };
    };

    github-copilot-cli = {
      enable = true;
      package = pkgsUnstable.github-copilot-cli;
      enableMcpIntegration = true;
    };

    codex = {
      enable = true;
      package = pkgsUnstable.codex;
      enableMcpIntegration = true;
    };

    claude-code = {
      enable = true;
      package = pkgsUnstable.claude-code;
      enableMcpIntegration = true;
      configDir = "${config.xdg.configHome}/claude";
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
