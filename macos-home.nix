{
  config,
  inputs,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  yamlFormatter = pkgs.formats.yaml { };
in
{
  imports = [ ./agents.nix ];

  agents.plugins.ask-copilot = {
    description = "Copilot CLIを使用してコードや文言について相談・レビューを行う";
    hosts = [ "claude-code" ];
    skills.ask-copilot = ./skills/ask-copilot;
  };

  _module.args.pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };

  nixpkgs.config.allowUnfreePackages = [
    "claude-code"
    "claude-agent-acp"
    "github-copilot-cli"
    "intelephense"
    "android-cli"
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
    username = "shiba";
    homeDirectory = "/Users/${config.home.username}";
    shell.enableShellIntegration = false;
    preferXdgDirectories = true;

    file = {
      indentconfig = {
        target = ".indentconfig.yaml";
        source = yamlFormatter.generate ".indentconfig.yaml" {
          paths = [ "${./latexindent/setting.yaml}" ];
        };
      };
    };

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
        vim-language-server
        mermaid-cli
        vim-language-server
        sqls
        # browsr
        serve
        lemminx
        usql
        rstcheck
        google-clasp

        (python314.withPackages (
          ps: with ps; [
            debugpy
          ]
        ))

        (writeShellScriptBin "stylelint-language-server" ''
          exec ${nodejs}/bin/node ${vscode-extensions.stylelint.vscode-stylelint}/share/vscode/extensions/stylelint.vscode-stylelint/dist/index.js "$@"
        '')

        (writeShellScriptBin "php-debug-adapter" ''
          exec ${nodejs}/bin/node ${vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js "$@"
        '')
      ])
      ++ (with pkgsUnstable; [
        claude-agent-acp
      ]);
  };

  mcp-servers.programs = {
    # mcp-servers-nix part
    nixos.enable = true;
  };

  # Let Home Manager install and manage itself.
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
        postgres = {
          command = "npx";
          args = [ "@microsoft/postgres-mcp" ];
        };
        mysql = {
          command = "uvx";
          args = [ "mysql-mcp-server" ];
        };
      };
    };

    # agents. enableMcpIntegration=trueにするとstoreへのsymlinkになるのでfalseにして、activate時に設定から部分マージする
    github-copilot-cli = {
      enable = true;
      package = pkgsUnstable.github-copilot-cli;
      enableMcpIntegration = false;
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
