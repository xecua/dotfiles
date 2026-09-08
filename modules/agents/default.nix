# AI コーディングエージェント (Claude Code / Codex CLI / GitHub Copilot CLI) 向けの
# skill / plugin / MCP を宣言的に管理するための共通モジュール。
#
#   agents.skills.<name>  = <SKILL.md を含むディレクトリ>;               # 全ホストの skill 置き場にエントリ単位でリンク
#                                                                        # (~/.agents/skills/<name> はここで張る。Codex / Copilot 共通)
#   agents.plugins.<name> = { description; mcpServers; skills; hooks; }; # plugin ディレクトリを derivation として構築
#   agents.marketplace    = { name; owner; };                            # 上記 plugin 群をまとめた marketplace derivation
#   agents.toolSkills.<t> = { package; installCommand; };                # サブコマンドで skill を置く CLI のブリッジ (tool-skills.nix)
#
# ホストごとの繋ぎ込みは同ディレクトリの claude-code.nix / codex.nix / copilot.nix が行う。
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.agents;
  jsonFormat = pkgs.formats.json { };

  pluginModule =
    { name, ... }:
    {
      options = {
        description = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "plugin.json / marketplace.json に書く説明";
        };
        version = lib.mkOption {
          type = lib.types.str;
          default = "0.1.0";
          description = "plugin のバージョン (形式的なもの)";
        };
        mcpServers = lib.mkOption {
          type = lib.types.attrsOf jsonFormat.type;
          default = { };
          description = ''
            plugin 内の `.mcp.json` に書く MCP サーバー定義 (Claude Code / Codex / Copilot 共通の `command` / `args` / `env` / `url` 形式)。
            `''${VAR}` のようなテンプレート変数は使わず、store パスなど静的な値を書くこと。
          '';
        };
        skills = lib.mkOption {
          type = lib.types.attrsOf lib.types.path;
          default = { };
          description = "名前 -> SKILL.md を含むディレクトリ";
        };
        hooks = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "hooks.jsonへのパス";
        };
        hosts = lib.mkOption {
          type = lib.types.listOf (
            lib.types.enum [
              "claude-code"
              "codex"
              "copilot"
            ]
          );
          default = [
            "claude-code"
            "codex"
            "copilot"
          ];
          description = ''
            この plugin を有効にするホスト。marketplace には常に含まれるが、列挙されていないホストではリンク / install / enable をしない
          '';
        };
        package = lib.mkOption {
          type = lib.types.package;
          readOnly = true;
          description = "構築された plugin ディレクトリ (store パス)";
        };
      };
      config.package = mkPlugin name cfg.plugins.${name};
    };

  mkPlugin =
    name: p:
    let
      manifest = jsonFormat.generate "${name}-plugin.json" (
        {
          inherit name;
          inherit (p) version;
          author = cfg.marketplace.owner;
        }
        // lib.optionalAttrs (p.description != "") { inherit (p) description; }
      );
    in
    pkgs.runCommand "agents-plugin-${name}" { } (
      ''
        mkdir -p $out/.claude-plugin $out/.codex-plugin
        cp ${manifest} $out/.claude-plugin/plugin.json
        cp ${manifest} $out/.codex-plugin/plugin.json
      ''
      + lib.optionalString (p.mcpServers != { }) ''
        cp ${jsonFormat.generate "${name}-mcp.json" { inherit (p) mcpServers; }} $out/.mcp.json
      ''
      + lib.optionalString (p.hooks != null) ''
        mkdir -p $out/hooks
        cp ${p.hooks} $out/hooks/hooks.json
      ''
      + lib.concatStrings (
        lib.mapAttrsToList (sname: spath: ''
          mkdir -p $out/skills
          cp -r ${spath} $out/skills/${sname}
        '') p.skills
      )
    );

  marketplaceManifest = jsonFormat.generate "${cfg.marketplace.name}-marketplace.json" {
    inherit (cfg.marketplace) name owner;
    plugins = lib.mapAttrsToList (
      name: p:
      {
        inherit name;
        inherit (p) version;
        source = "./plugins/${name}";
      }
      // lib.optionalAttrs (p.description != "") { inherit (p) description; }
    ) cfg.plugins;
  };

  marketplacePackage = pkgs.runCommand "agents-marketplace-${cfg.marketplace.name}" { } (
    ''
      mkdir -p $out/.claude-plugin $out/.agents/plugins $out/plugins
      cp ${marketplaceManifest} $out/.claude-plugin/marketplace.json
      cp ${marketplaceManifest} $out/.agents/plugins/marketplace.json
    ''
    + lib.concatStrings (
      lib.mapAttrsToList (name: p: ''
        cp -r ${p.package} $out/plugins/${name}
        chmod -R u+w $out/plugins/${name}
      '') cfg.plugins
    )
  );
in
{
  imports = [
    ../merged-files.nix
    ./claude-code.nix
    ./codex.nix
    ./copilot.nix
    ./tool-skills.nix
  ];

  options.agents = {
    enable = lib.mkEnableOption "declarative skill/plugin/MCP management for AI coding agents";

    skills = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      description = ''
        ホスト非依存の skill。名前 -> SKILL.md を含むディレクトリ (リポジトリ内でも flake input でもよい)。
        各ホストの skill 置き場に `<置き場>/<name>` としてエントリ単位でシンボリックリンクされる
        (親ディレクトリは排他管理しないので、他ツールが置いた skill と共存できる)。
      '';
      example = lib.literalExpression ''
        {
          my-skill = ./skills/my-skill;
          file-search = "''${inputs.file-search-skill}/skills/file-search";
        }
      '';
    };

    plugins = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule pluginModule);
      default = { };
      description = "marketplace に載せる plugin 群";
    };

    marketplace = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "local";
        description = "marketplace 名 (plugin の識別子 `<plugin>@<marketplace>` の右側)";
      };
      owner = lib.mkOption {
        type = jsonFormat.type;
        default = { };
        example = {
          name = "me";
          email = "me@example.com";
        };
        description = "marketplace.json / plugin.json の owner/author";
      };
      package = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        description = "構築された marketplace ディレクトリ (.claude-plugin/ と .agents/plugins/ に marketplace.json、plugins/*)";
      };
      path = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        description = ''
          marketplace への安定したパス ($XDG_DATA_HOME/agents/marketplaces/<name>)。
          home.file で package へリンクされる。各ツールの設定にはこのパスを書く
          (store パスを直接書くと内容が変わるたびに設定ファイルが書き換わる)。
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    agents.marketplace.package = marketplacePackage;
    agents.marketplace.path = "${config.xdg.dataHome}/agents/marketplaces/${cfg.marketplace.name}";

    home.file = lib.mkMerge [
      { ${cfg.marketplace.path}.source = marketplacePackage; }

      # Codex / Copilot はどちらも ~/.agents/skills をネイティブに走査する。
      # どちらか一方だけが有効なホスト (macOS は Copilot のみ) でも skill が置かれるよう、
      # ホスト別モジュールではなくここでリンクする
      (lib.mkIf (cfg.codex.enable || cfg.copilot.enable) (
        lib.mapAttrs' (
          name: path: lib.nameValuePair ".agents/skills/${name}" { source = path; }
        ) cfg.skills
      ))
    ];

    assertions = [
      {
        assertion = lib.intersectLists (lib.attrNames cfg.skills) (lib.attrNames cfg.plugins) == [ ];
        message = "agents.skills and agents.plugins must not share a name (both are linked into the same skills directory)";
      }
    ];
  };
}
