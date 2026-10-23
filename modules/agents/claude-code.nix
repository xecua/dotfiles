# Claude Code
#
# A (静的、home.file で store へリンク):
#   - agents.skills.<name>  -> $CLAUDE_CONFIG_DIR/skills/<name>
#       agents.claude-code.syncedSkills に挙げたものは除く (claude.ai の同期で配る)
#   - agents.plugins.<name> -> $CLAUDE_CONFIG_DIR/skills/<name>
#       Claude Code 2.1.x は skills/ 配下に `.claude-plugin/plugin.json` を持つディレクトリを
#       `<name>@skills-dir` として自動で plugin 扱いする (marketplace 登録も install も不要、
#       cache へのコピーも無いので store パスが変われば次セッションから反映される)。
#       そのため Claude Code に対しては marketplace を登録しない。
# B (部分マージ):
#   - agents.claude-code.settings -> $CLAUDE_CONFIG_DIR/settings.json (mergedFiles 経由)
#
# 静的な部分 (package, hooksDir, context 等) は従来通り programs.claude-code に任せる。
# ただし programs.claude-code.settings / marketplaces は settings.json 全体を生成してしまうので使わない。
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.agents;
  agents-config = config.agents.claude-code;
  programs-config = config.programs.claude-code;
  jsonFormat = pkgs.formats.json { };
  skillsDir = "${programs-config.configDir}/skills";
in
{
  options.agents.claude-code = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = programs-config.enable;
      defaultText = lib.literalExpression "config.programs.claude-code.enable";
      description = "Claude Code に agents.* を反映する";
    };

    settings = lib.mkOption {
      type = jsonFormat.type;
      default = { };
      description = ''
        settings.json に部分マージする断片。ここで宣言したキーは上書きされ、
        宣言していないキー (Claude Code 自身が書く pluginConfigs など) は保持される。
      '';
    };

    syncedSkills = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        claude.ai に登録して同期で配る agents.skills の名前。Claude Code にはリンクしない (他のホストには従来通りリンクする)。
        同期された skill は `anthropic-skills:<name>` として読み込まれ、ローカルの同名 skill を置き換えずに並ぶので、
        両方あると重複する。
      '';
    };
  };

  config = lib.mkIf (cfg.enable && agents-config.enable) {
    assertions = [
      {
        assertion = programs-config.settings == { } && programs-config.marketplaces == { };
        message = "agents.claude-code: programs.claude-code.settings / marketplaces は settings.json 全体を生成するため併用できません。agents.claude-code.settings を使ってください";
      }
      {
        assertion = lib.subtractLists (lib.attrNames cfg.skills) agents-config.syncedSkills == [ ];
        message = "agents.claude-code.syncedSkills に agents.skills に無い名前があります: ${
          lib.concatStringsSep ", " (lib.subtractLists (lib.attrNames cfg.skills) agents-config.syncedSkills)
        }";
      }
    ];

    home.file =
      lib.mapAttrs' (name: path: lib.nameValuePair "${skillsDir}/${name}" { source = path; }) (
        removeAttrs cfg.skills agents-config.syncedSkills
      )
      // lib.mapAttrs' (name: p: lib.nameValuePair "${skillsDir}/${name}" { source = p.package; }) (
        lib.filterAttrs (_: p: lib.elem "claude-code" p.hosts) cfg.plugins
      );

    mergedFiles.claude-code-settings = lib.mkIf (agents-config.settings != { }) {
      target = "${programs-config.configDir}/settings.json";
      fragment = agents-config.settings;
      format = "json";
    };
  };
}
