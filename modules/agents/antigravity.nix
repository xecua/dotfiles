# Antigravity CLI (agy)
#
# 本体のインストールと有効化はマシンごとに programs.antigravity-cli (home-manager) で行い、ここはそれに追従する
# (package は nixpkgs-unstable の antigravity-cli。mainProgram は agy。unfree)。
# 置き場所は AGY / AGY CLI / AGY IDE の 3 つが共通で読む ~/.gemini/config を使う。
# ~/.agents/skills は AGY CLI が読まない。~/.gemini/skills は android-cli などが実ディレクトリを書くので触らない。
#
# A (静的、home.file で store へリンク):
#   - agents.skills.<name>     -> ~/.gemini/config/skills/<name>
#   - agents.plugins.<name>    -> ~/.gemini/config/plugins/<name>
#       ディレクトリを走査して自動で読み込むので marketplace 登録も `agy plugin install` も不要
#       (install は ~/.gemini/antigravity-cli/plugins/ にコピーするだけ)。
#       構成は Claude Code / Codex 用と異なる (ルートに plugin.json と mcp_config.json) ので、
#       default.nix の package は使わずここで組み直す
#   - agents.toolSkills の skill は tool-skills.nix が ~/.gemini/config/skills/<name> にブリッジする
# B (部分マージ、mergedFiles 経由):
#   - ~/.gemini/config/mcp_config.json         mcpServers に programs.mcp.servers を載せる
#   - ~/.gemini/antigravity-cli/settings.json  agents.antigravity.settings
#
# programs.antigravity-cli.settings / permissions (settings.json を丸ごと生成) と
# mcpServers / enableMcpIntegration (mcp_config.json を丸ごと生成) は使わない (assertion)。
#
# MCP の形式: stdio は command / args / env / cwd、リモートは url ではなく serverUrl (+ 静的な headers)。
# headers を実行時に作るヘルパ (headersHelper) や環境変数展開は無いので、それが必要なサーバーは載せられない (assertion)。
# hooks.json の形式 ({"<hook 名>": {"PreToolUse": [...]}}) は Claude Code の hooks.json と異なるので plugin の hooks は載せない (assertion)。
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.agents;
  agents-config = config.agents.antigravity;
  programs-config = config.programs.antigravity-cli;
  jsonFormat = pkgs.formats.json { };

  # 共通形式 (command / args / env / url / headers / type) -> Antigravity 形式
  toAntigravityServer =
    server:
    removeAttrs server [
      "type"
      "url"
      "enabled"
    ]
    // lib.optionalAttrs (server ? url) { serverUrl = server.url; }
    // lib.optionalAttrs ((server.enabled or true) == false) { disabled = true; };

  sharedMcpServers =
    lib.optionalAttrs (agents-config.includeSharedMcpServers && config.programs.mcp.enable)
      (
        lib.mapAttrs (
          name: server:
          toAntigravityServer (
            lib.hm.mcp.transformMcpServer {
              inherit server;
              extraTransforms = [ (lib.hm.mcp.wrapEnvFilesCommand { inherit pkgs name; }) ];
            }
          )
        ) config.programs.mcp.servers
      );

  plugins = lib.filterAttrs (_: p: lib.elem "antigravity" p.hosts) cfg.plugins;

  mkPlugin =
    name: p:
    let
      manifest = jsonFormat.generate "${name}-antigravity-plugin.json" (
        {
          "$schema" = "https://antigravity.google/schemas/v1/plugin.json";
          inherit name;
        }
        // lib.optionalAttrs (p.description != "") { inherit (p) description; }
      );
      mcpConfig = jsonFormat.generate "${name}-antigravity-mcp_config.json" {
        mcpServers = lib.mapAttrs (_: toAntigravityServer) p.mcpServers;
      };
    in
    pkgs.runCommand "agents-antigravity-plugin-${name}" { } (
      ''
        mkdir -p $out
        cp ${manifest} $out/plugin.json
      ''
      + lib.optionalString (p.mcpServers != { }) ''
        cp ${mcpConfig} $out/mcp_config.json
      ''
      + lib.concatStrings (
        lib.mapAttrsToList (sname: spath: ''
          mkdir -p $out/skills
          cp -r ${spath} $out/skills/${sname}
        '') p.skills
      )
    );

  helperServers =
    lib.attrNames (lib.filterAttrs (_: s: s ? headersHelper) sharedMcpServers)
    ++ lib.concatLists (
      lib.mapAttrsToList (
        pname: p:
        map (s: "${pname}/${s}") (lib.attrNames (lib.filterAttrs (_: s: s ? headersHelper) p.mcpServers))
      ) plugins
    );
in
{
  options.agents.antigravity = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = programs-config.enable;
      defaultText = lib.literalExpression "config.programs.antigravity-cli.enable";
      description = "Antigravity CLI (agy) に agents.* を反映する";
    };

    configDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.gemini/config";
      defaultText = lib.literalExpression ''"''${config.home.homeDirectory}/.gemini/config"'';
      description = "AGY / AGY CLI / AGY IDE が共通で読む設定ディレクトリ (skills/, plugins/, mcp_config.json)";
    };

    cliDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.gemini/antigravity-cli";
      defaultText = lib.literalExpression ''"''${config.home.homeDirectory}/.gemini/antigravity-cli"'';
      description = "Antigravity CLI 固有の設定ディレクトリ (settings.json)";
    };

    includeSharedMcpServers = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        programs.mcp.servers を mcp_config.json の mcpServers に部分マージで載せる
        (programs.antigravity-cli.enableMcpIntegration の代替。あちらはファイル全体を生成してしまう)。
      '';
    };

    settings = lib.mkOption {
      type = jsonFormat.type;
      default = { };
      description = ''
        ~/.gemini/antigravity-cli/settings.json に部分マージする断片 (permissions, enableTerminalSandbox など)。
        宣言したキーは上書きされ、宣言していないキーは保持される。
      '';
    };
  };

  config = lib.mkIf (cfg.enable && agents-config.enable) {
    assertions = [
      {
        assertion =
          programs-config.settings == { }
          && programs-config.permissions == null
          && programs-config.mcpServers == { }
          && !programs-config.enableMcpIntegration;
        message = "agents.antigravity: programs.antigravity-cli.settings / permissions / mcpServers / enableMcpIntegration はファイル全体を生成するため併用できません。agents.antigravity.settings / includeSharedMcpServers を使ってください";
      }
      {
        assertion = helperServers == [ ];
        message = "agents.antigravity: Antigravity の mcp_config.json は headersHelper に対応していません (${lib.concatStringsSep ", " helperServers})。plugin の hosts から antigravity を外してください";
      }
      {
        assertion = lib.all (p: p.hooks == null) (lib.attrValues plugins);
        message = "agents.antigravity: plugin の hooks は Claude Code 形式なので Antigravity には載せられません。plugin の hosts から antigravity を外してください";
      }
    ];

    home.file =
      lib.mapAttrs' (
        name: path: lib.nameValuePair "${agents-config.configDir}/skills/${name}" { source = path; }
      ) cfg.skills
      // lib.mapAttrs' (
        name: p:
        lib.nameValuePair "${agents-config.configDir}/plugins/${name}" { source = mkPlugin name p; }
      ) plugins;

    mergedFiles = {
      antigravity-mcp-config = lib.mkIf (sharedMcpServers != { }) {
        target = "${agents-config.configDir}/mcp_config.json";
        format = "json";
        fragment = {
          mcpServers = sharedMcpServers;
        };
      };

      antigravity-settings = lib.mkIf (agents-config.settings != { }) {
        target = "${agents-config.cliDir}/settings.json";
        format = "json";
        fragment = agents-config.settings;
      };
    };
  };
}
