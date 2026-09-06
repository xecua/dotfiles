# 「自分のサブコマンドで ~/.agents/skills/<name> に skill を配置する CLI」のブリッジ。
# 例: playwright-cli (`install --skills agents --global`)、android-cli (`android init`)。
#
#   agents.toolSkills.<tool> = {
#     package        = <CLI の derivation>;          # home.packages に加える (null 可)
#     installCommand = "<絶対パス> install ...";    # activation で毎回実行する。冪等であること
#     skills         = [ "<name>" ];                 # ~/.agents/skills 配下に生成されるディレクトリ名 (既定: <tool>)
#   };
#
# activation (linkGeneration の後):
#   1. ~/.agents/skills を作る (android-cli はこれが無いと別の場所に書く)
#   2. 生成先がシンボリックリンクなら消す (setup.py や home.file で張っていたリンク。
#      リンク先は触らない)。実ディレクトリなら chmod -R u+w する
#      (playwright-cli は store のファイルモードをそのままコピーするので、次回の上書きに失敗する)
#   3. installCommand を実行する
#
# 各ホストからの見え方:
#   - Codex / Copilot: ~/.agents/skills をネイティブに走査するのでブリッジ不要
#   - Claude Code: $CLAUDE_CONFIG_DIR/skills/<name> -> ~/.agents/skills/<name> の
#     (store 外への) シンボリックリンクを張る。CLI 側の `--skills claude` は
#     CLAUDE_CONFIG_DIR を見ず ~/.claude/skills に書くので使わない
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.agents;
  tcfg = config.agents.toolSkills;
  agentsSkillsDir = "${config.home.homeDirectory}/.agents/skills";
  claudeSkillsDir = "${config.programs.claude-code.configDir}/skills";

  toolModule =
    { name, ... }:
    {
      options = {
        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = null;
          description = "CLI 本体。home.packages に加える";
        };
        installCommand = lib.mkOption {
          type = lib.types.str;
          description = "skill を配置する冪等なコマンド (コマンドは絶対パスで書く。activation の PATH は貧弱)";
          example = "\${lib.getExe playwright-cli} install --skills agents --global";
        };
        skills = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ name ];
          defaultText = lib.literalExpression "[ <tool> ]";
          description = "installCommand が ~/.agents/skills 配下に生成する skill ディレクトリ名";
        };
      };
    };

  allToolSkills = lib.concatMap (t: t.skills) (lib.attrValues tcfg);
in
{
  options.agents.toolSkills = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule toolModule);
    default = { };
    description = "サブコマンドで ~/.agents/skills に skill を配置する CLI 群";
  };

  config = lib.mkIf (cfg.enable && tcfg != { }) {
    assertions = [
      {
        assertion = lib.length allToolSkills == lib.length (lib.unique allToolSkills);
        message = "agents.toolSkills: skill 名が重複しています (${lib.concatStringsSep ", " allToolSkills})";
      }
      {
        assertion =
          lib.intersectLists allToolSkills (lib.attrNames cfg.skills ++ lib.attrNames cfg.plugins) == [ ];
        message = "agents.toolSkills の skill 名は agents.skills / agents.plugins と重複できません";
      }
    ];

    home.packages = lib.filter (p: p != null) (map (t: t.package) (lib.attrValues tcfg));

    home.activation.agentsToolSkills = lib.hm.dag.entryAfter [ "linkGeneration" ] (
      ''
        run mkdir -p ${lib.escapeShellArg agentsSkillsDir}
      ''
      + lib.concatStrings (
        lib.mapAttrsToList (
          tool: t:
          lib.concatMapStrings (skill: ''
            if [ -L ${lib.escapeShellArg "${agentsSkillsDir}/${skill}"} ]; then
              verboseEcho "agents.toolSkills[${tool}]: removing stale symlink ${agentsSkillsDir}/${skill}"
              run rm -f ${lib.escapeShellArg "${agentsSkillsDir}/${skill}"}
            elif [ -d ${lib.escapeShellArg "${agentsSkillsDir}/${skill}"} ]; then
              run chmod -R u+w ${lib.escapeShellArg "${agentsSkillsDir}/${skill}"}
            fi
          '') t.skills
          + ''
            run ${pkgs.coreutils}/bin/timeout 300 ${t.installCommand}
          ''
        ) tcfg
      )
    );

    # Claude Code へのブリッジ (store 外へのリンク)
    home.file = lib.optionalAttrs cfg.claude-code.enable (
      lib.listToAttrs (
        map (
          skill:
          lib.nameValuePair "${claudeSkillsDir}/${skill}" {
            source = config.lib.file.mkOutOfStoreSymlink "${agentsSkillsDir}/${skill}";
          }
        ) allToolSkills
      )
    );
  };
}
