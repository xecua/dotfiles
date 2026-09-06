# Codex CLI
#
# A (静的、home.file で store へリンク):
#   - agents.skills.<name>      -> ~/.agents/skills/<name>   (Codex がネイティブに走査する場所。symlink 可)
#   - agents.marketplace        -> $XDG_DATA_HOME/agents/marketplaces/<name> (default.nix。安定したパス)
# B (部分マージ、mergedFiles 経由で $CODEX_HOME/config.toml):
#   - [marketplaces.<name>]  source_type = "local", source = <上の安定パス>
#   - [plugins."<plugin>@<name>"] enabled = true
#   - [mcp_servers.*]        programs.mcp.servers を home-manager の codex モジュールと同じ変換で載せる
# activation (mergedFiles の後):
#   - `codex plugin add <plugin>@<marketplace>` を毎回実行する。Codex は plugin を
#     $CODEX_HOME/plugins/cache/<marketplace>/<plugin>/<version>/ にコピーして読むため、
#     store の中身が変わったら再コピーが必要。add は冪等で、既にあれば同じ場所へ上書きコピーする
#     (codex-cli 0.151.0)。
#
# programs.codex.settings / enableMcpIntegration は config.toml 全体を store へのリンクとして
# 生成し、Codex が書き戻す trust_level 等と衝突するので使わない (assertion)。
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.agents;
  xcfg = config.agents.codex;
  pcfg = config.programs.codex;

  # home-manager の programs/codex.nix と同じ計算 (preferXdgDirectories なら ~/.config/codex)
  codexHome =
    if config.home.preferXdgDirectories then
      "${config.xdg.configHome}/codex"
    else
      "${config.home.homeDirectory}/.codex";

  # programs/codex.nix の transformedMcpServers と同じ変換
  sharedMcpServers = lib.optionalAttrs (xcfg.includeSharedMcpServers && config.programs.mcp.enable) (
    lib.mapAttrs (
      name: server:
      lib.hm.mcp.transformMcpServer {
        inherit server;
        exclude = [
          "headers"
          "type"
        ];
        extraTransforms = [
          (s: s // lib.optionalAttrs (s.headers or { } != { }) { http_headers = s.headers; })
          lib.hm.mcp.addType
          (lib.hm.mcp.wrapEnvFilesCommand { inherit pkgs name; })
        ];
      }
    ) config.programs.mcp.servers
  );

  pluginIds = map (p: "${p}@${cfg.marketplace.name}") (
    lib.attrNames (lib.filterAttrs (_: p: lib.elem "codex" p.hosts) cfg.plugins)
  );
in
{
  options.agents.codex = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = pcfg.enable;
      defaultText = lib.literalExpression "config.programs.codex.enable";
      description = "Codex CLI に agents.* を反映する";
    };

    includeSharedMcpServers = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        programs.mcp.servers を config.toml の mcp_servers に部分マージで載せる
        (programs.codex.enableMcpIntegration の代替。あちらはファイル全体を生成してしまう)。
      '';
    };

    settings = lib.mkOption {
      type = (pkgs.formats.toml { }).type;
      default = { };
      description = ''
        config.toml に部分マージする追加の断片 (model など)。
        宣言したキーは上書きされ、宣言していないキー (projects.*.trust_level など Codex 自身が書くもの) は保持される。
      '';
    };
  };

  config = lib.mkIf (cfg.enable && xcfg.enable) {
    assertions = [
      {
        assertion = pcfg.settings == { } && !pcfg.enableMcpIntegration;
        message = "agents.codex: programs.codex.settings / enableMcpIntegration は config.toml 全体を生成するため併用できません。agents.codex.settings / includeSharedMcpServers を使ってください";
      }
    ];

    home.file = lib.mapAttrs' (
      name: path: lib.nameValuePair ".agents/skills/${name}" { source = path; }
    ) cfg.skills;

    mergedFiles.codex-config = {
      target = "${codexHome}/config.toml";
      format = "toml";
      fragment = lib.recursiveUpdate (
        {
          marketplaces.${cfg.marketplace.name} = {
            source_type = "local";
            source = cfg.marketplace.path;
          };
          plugins = lib.genAttrs pluginIds (_: {
            enabled = true;
          });
        }
        // lib.optionalAttrs (sharedMcpServers != { }) { mcp_servers = sharedMcpServers; }
      ) xcfg.settings;
    };

    # activation 環境には CODEX_HOME (home.sessionVariables) が入っていないので明示する
    home.activation.agentsCodexPlugins = lib.hm.dag.entryAfter [ "mergedFiles" ] (
      lib.concatMapStrings (id: ''
        CODEX_HOME=${lib.escapeShellArg codexHome} run ${pkgs.coreutils}/bin/timeout 120 \
          ${lib.getExe pcfg.package} plugin add ${lib.escapeShellArg id}
      '') pluginIds
    );
  };
}
