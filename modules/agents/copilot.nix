# GitHub Copilot CLI
#
# A (静的):
#   - skill: Copilot は ~/.agents/skills をネイティブに走査する (公式ドキュメント) ので、
#     codex.nix が張る ~/.agents/skills/<name> と tool-skills.nix の生成物がそのまま見える。追加のリンクは不要
#   - marketplace: default.nix が $XDG_DATA_HOME/agents/marketplaces/<name> に置くものを使う
# B (部分マージ、mergedFiles 経由):
#   - $COPILOT_HOME/settings.json   extraKnownMarketplaces.<name> (source = directory) と enabledPlugins."<p>@<name>" = true
#                                   (`copilot plugin marketplace add` / `plugin install` が書くのと同じ形。1.0.61)
#   - $COPILOT_HOME/mcp-config.json mcpServers に programs.mcp.servers を home-manager モジュールと同じ変換で載せる
# activation (mergedFiles の後):
#   - `copilot plugin install <p>@<name>` を毎回実行する。Copilot は plugin を
#     $COPILOT_HOME/installed-plugins/<marketplace>/<plugin>/ にコピーして読む (config.json の installedPlugins に記録)。
#     install は冪等で、既にあれば上書きコピーし直す (1.0.61)。
#     settings.json の enabledPlugins だけでは (少なくとも CLI の plugin list 上は) インストールされない。
#
# plugin 同梱 .mcp.json は {"mcpServers": {...}} でも直接のマップでも読まれる (バンドル内の
# ローダーが両方を正規化し、tools が無ければ ["*"] を補う)。ただし `copilot mcp list` は plugin 由来の
# サーバーを表示しない (セッション内の /mcp で確認する)。
#
# programs.github-copilot-cli.settings (config.json を丸ごと生成。しかも 1.0.61 では config.json は
# Copilot が自動管理する状態ファイルで、ユーザー設定は settings.json) と
# enableMcpIntegration / mcpServers (mcp-config.json を丸ごと生成) は使わない (assertion)。
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.agents;
  ccfg = config.agents.copilot;
  pcfg = config.programs.github-copilot-cli;
  jsonFormat = pkgs.formats.json { };

  # programs/github-copilot-cli.nix と同じ変換
  forCopilotFormat =
    server:
    let
      isLocal = server.type == "stdio";
    in
    server
    // {
      type = if server.type == "stdio" then "local" else server.type or "local";
    }
    // lib.optionalAttrs isLocal { args = server.args or [ ]; }
    // lib.optionalAttrs (!(server ? tools)) { tools = [ "*" ]; };

  enabledServers = lib.filterAttrs (
    _: server: !(server.disabled or false) && (server ? url || server ? command)
  ) config.programs.mcp.servers;

  sharedMcpServers = lib.optionalAttrs (ccfg.includeSharedMcpServers && config.programs.mcp.enable) (
    lib.mapAttrs (
      name: server:
      lib.hm.mcp.transformMcpServer {
        inherit server;
        extraTransforms = [
          lib.hm.mcp.addType
          (lib.hm.mcp.wrapEnvFilesCommand { inherit pkgs name; })
          forCopilotFormat
        ];
      }
    ) enabledServers
  );

  pluginIds = map (p: "${p}@${cfg.marketplace.name}") (
    lib.attrNames (lib.filterAttrs (_: p: lib.elem "copilot" p.hosts) cfg.plugins)
  );
in
{
  options.agents.copilot = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = pcfg.enable;
      defaultText = lib.literalExpression "config.programs.github-copilot-cli.enable";
      description = "GitHub Copilot CLI に agents.* を反映する";
    };

    includeSharedMcpServers = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        programs.mcp.servers を mcp-config.json の mcpServers に部分マージで載せる
        (programs.github-copilot-cli.enableMcpIntegration の代替。あちらはファイル全体を生成してしまう)。
      '';
    };

    settings = lib.mkOption {
      type = jsonFormat.type;
      default = { };
      description = ''
        settings.json に部分マージする追加の断片 (model, allowedUrls など)。
        宣言したキーは上書きされ、宣言していないキー (Copilot 自身や /mcp add が書くもの) は保持される。
        注意: settings.json は JSONC も許されるが、マージは jq で行うのでコメントが入っていると失敗する (壊さずに止まる)。
      '';
    };
  };

  config = lib.mkIf (cfg.enable && ccfg.enable) {
    assertions = [
      {
        assertion = pcfg.settings == { } && pcfg.mcpServers == { } && !pcfg.enableMcpIntegration;
        message = "agents.copilot: programs.github-copilot-cli.settings / mcpServers / enableMcpIntegration はファイル全体を生成するため併用できません。agents.copilot.settings / includeSharedMcpServers を使ってください";
      }
    ];

    mergedFiles = {
      copilot-settings = {
        target = "${pcfg.configDir}/settings.json";
        format = "json";
        fragment = lib.recursiveUpdate {
          extraKnownMarketplaces.${cfg.marketplace.name}.source = {
            source = "directory";
            path = cfg.marketplace.path;
          };
          enabledPlugins = lib.genAttrs pluginIds (_: true);
        } ccfg.settings;
      };

      copilot-mcp-config = lib.mkIf (sharedMcpServers != { }) {
        target = "${pcfg.configDir}/mcp-config.json";
        format = "json";
        fragment = {
          mcpServers = sharedMcpServers;
        };
      };
    };

    # activation 環境には COPILOT_HOME (home.sessionVariables) が入っていないので明示する
    home.activation.agentsCopilotPlugins = lib.hm.dag.entryAfter [ "mergedFiles" ] (
      lib.concatMapStrings (id: ''
        COPILOT_HOME=${lib.escapeShellArg pcfg.configDir} run ${pkgs.coreutils}/bin/timeout 120 \
          ${lib.getExe pcfg.package} plugin install ${lib.escapeShellArg id}
      '') pluginIds
    );
  };
}
