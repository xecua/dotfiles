#
#   mergedFiles.<name> = {
#     target   = "/abs/path/to/live/file.json";    # 書き込み先
#     fragment = { key = "value"; };               # attrset か、json/toml ファイルへのパス
#     format   = "json";                           # "json" (jq) か "toml" (python + tomlkit)
#   };
#
# 挙動 (activation 時、linkGeneration の後に実行):
#   1. target が無ければ fragment の内容で作る (mode 600)
#   2. あれば fragment を再帰マージする
#        - fragment で宣言したキーはその値で上書き (配列も丸ごと置換)
#        - fragment に無いキー (OAuth トークン、他ツールが書いた項目など) には触れない
#        - toml はコメントや並び順も保つ (tomlkit)
#   3. 意味的に同一なら何もしない (mtime も変えない)
#      ただし target がシンボリックリンクなら実ファイルに置き換える (ツールが書き戻せるようにする)
#   4. 書き換える場合は $XDG_STATE_HOME/home-manager/merged-files/<name>/ に
#      タイムスタンプ付きバックアップを残してから、同一ディレクトリ内の一時ファイル + rename で置き換える
#   5. target が壊れていれば何もせず失敗する
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mergedFiles;
  jsonFormat = pkgs.formats.json { };
  tomlFormat = pkgs.formats.toml { };

  backupRoot = "${config.xdg.stateHome}/home-manager/merged-files";

  # 共通: バックアップ + 世代整理。$1=target $2=backup_dir $3=keep
  backupSnippet = ''
    hm_merge_backup() {
      local target=$1 backup_dir=$2 keep=$3 base stamp
      base=$(basename "$target")
      mkdir -p "$backup_dir"
      stamp=$(date +%Y%m%dT%H%M%S)
      cp -pL "$target" "$backup_dir/$base.$stamp"
      # ファイル名末尾がタイムスタンプなので名前順 = 時刻順
      find "$backup_dir" -maxdepth 1 -type f -name "$base.*" | sort -r | tail -n +"$((keep + 1))" \
        | while read -r old; do rm -f -- "$old"; done
      echo "$backup_dir/$base.$stamp"
    }
    # $1=target $2=content  同一ディレクトリの一時ファイル経由で置き換える (target がリンクでも実ファイルになる)
    hm_merge_write() {
      local target=$1 content=$2 dir tmp
      dir=$(dirname "$target")
      tmp=$(mktemp "$dir/.$(basename "$target").hm-merge.XXXXXX")
      printf '%s\n' "$content" >"$tmp"
      if [ -e "$target" ]; then chmod --reference="$target" "$tmp"; else chmod 600 "$tmp"; fi
      # target が store へのリンクだった場合は 444 を引き継いでしまうので、ツールが書き戻せるよう必ず書き込み可にする
      chmod u+w "$tmp"
      mv -f "$tmp" "$target"
    }
  '';

  mergeJson = pkgs.writeShellApplication {
    name = "hm-merge-json";
    runtimeInputs = with pkgs; [
      jq
      coreutils
      findutils
      diffutils
    ];
    text = ''
      # usage: hm-merge-json <name> <target> <fragment> <backup-dir> [keep]
      name=$1 target=$2 fragment=$3 backup_dir=$4 keep=''${5:-10}
      ${backupSnippet}
      mkdir -p "$(dirname "$target")"

      if [ -e "$target" ]; then
        if ! jq -e . "$target" >/dev/null 2>&1; then
          echo "hm-merge-json[$name]: $target is not valid JSON; refusing to touch it" >&2
          exit 1
        fi
        merged=$(jq --indent 2 -s '.[0] * .[1]' "$target" "$fragment")
        if diff -q <(jq -S . "$target") <(printf '%s\n' "$merged" | jq -S .) >/dev/null; then
          if [ -L "$target" ]; then
            echo "hm-merge-json[$name]: $target is a symlink; materializing as a regular file"
            merged=$(cat "$target")
          else
            echo "hm-merge-json[$name]: $target already up to date"
            exit 0
          fi
        else
          echo "hm-merge-json[$name]: merging into $target (backup: $(hm_merge_backup "$target" "$backup_dir" "$keep"))"
        fi
      else
        merged=$(jq --indent 2 . "$fragment")
        echo "hm-merge-json[$name]: creating $target"
      fi
      hm_merge_write "$target" "$merged"
    '';
  };

  tomlMergePy =
    pkgs.writers.writePython3 "hm-merge-toml.py"
      {
        libraries = [ pkgs.python3Packages.tomlkit ];
        flakeIgnore = [ "E501" ];
      }
      ''
        # usage: hm-merge-toml.py <target> <fragment>
        # 標準出力にマージ結果を出す。"UNCHANGED" を最初の行に出したら意味的に同一。
        # 終了コード 1: target が壊れている
        import sys
        from collections.abc import MutableMapping

        import tomlkit

        target, fragment = sys.argv[1], sys.argv[2]

        with open(fragment) as f:
            frag = tomlkit.parse(f.read())

        try:
            with open(target) as f:
                text = f.read()
        except FileNotFoundError:
            print("CREATE")
            print(tomlkit.dumps(frag), end="")
            sys.exit(0)

        try:
            doc = tomlkit.parse(text)
        except Exception as e:  # noqa: BLE001
            print(f"invalid TOML: {e}", file=sys.stderr)
            sys.exit(1)
        before = tomlkit.parse(text).unwrap()


        def merge(base, over):
            for key, value in over.items():
                if key in base and isinstance(base[key], MutableMapping) and isinstance(value, MutableMapping):
                    merge(base[key], value)
                else:
                    # 別ドキュメント由来の item をそのまま挿すと書式情報を引き連れるので素の値に戻す
                    base[key] = value.unwrap() if hasattr(value, "unwrap") else value


        merge(doc, frag)

        print("UNCHANGED" if doc.unwrap() == before else "CHANGED")
        print(tomlkit.dumps(doc), end="")
      '';

  mergeToml = pkgs.writeShellApplication {
    name = "hm-merge-toml";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
    ];
    text = ''
      # usage: hm-merge-toml <name> <target> <fragment> <backup-dir> [keep]
      name=$1 target=$2 fragment=$3 backup_dir=$4 keep=''${5:-10}
      ${backupSnippet}
      mkdir -p "$(dirname "$target")"

      if ! out=$(${tomlMergePy} "$target" "$fragment"); then
        echo "hm-merge-toml[$name]: $target could not be merged; refusing to touch it" >&2
        exit 1
      fi
      status=$(printf '%s\n' "$out" | head -n1)
      merged=$(printf '%s\n' "$out" | tail -n +2)

      case "$status" in
        CREATE)
          echo "hm-merge-toml[$name]: creating $target" ;;
        UNCHANGED)
          if [ -L "$target" ]; then
            echo "hm-merge-toml[$name]: $target is a symlink; materializing as a regular file"
            merged=$(cat "$target")
          else
            echo "hm-merge-toml[$name]: $target already up to date"
            exit 0
          fi ;;
        CHANGED)
          echo "hm-merge-toml[$name]: merging into $target (backup: $(hm_merge_backup "$target" "$backup_dir" "$keep"))" ;;
        *)
          echo "hm-merge-toml[$name]: unexpected merge status '$status'" >&2; exit 1 ;;
      esac
      hm_merge_write "$target" "$merged"
    '';
  };

  mergers = {
    json = mergeJson;
    toml = mergeToml;
  };

  # fragment は attrset でもファイルでもよいが、どちらも一度パーサを通して「妥当な形式であること」をビルド時に保証する
  normalizeFragment =
    name: format: fragment:
    let
      generate = if format == "json" then jsonFormat.generate else tomlFormat.generate;
      src = if lib.isAttrs fragment then generate "${name}-fragment-src.${format}" fragment else fragment;
    in
    if format == "json" then
      pkgs.runCommand "${name}-fragment.json" { nativeBuildInputs = [ pkgs.jq ]; } ''
        jq --indent 2 . ${src} > $out
      ''
    else
      pkgs.runCommand "${name}-fragment.toml" { nativeBuildInputs = [ pkgs.python3 ]; } ''
        python3 -c 'import sys, tomllib; tomllib.load(open(sys.argv[1], "rb"))' ${src}
        cp ${src} $out
      '';

  fileModule =
    { name, config, ... }:
    {
      options = {
        target = lib.mkOption {
          type = lib.types.str;
          description = "マージ先の実ファイル (絶対パス)";
          example = "/home/me/.config/claude/settings.json";
        };
        fragment = lib.mkOption {
          type = lib.types.either lib.types.path (lib.types.either jsonFormat.type tomlFormat.type);
          description = "宣言する設定。attrset か json/toml ファイルへのパス";
        };
        format = lib.mkOption {
          type = lib.types.enum [
            "json"
            "toml"
          ];
          default = "json";
          description = "対象ファイルの形式";
        };
        keepBackups = lib.mkOption {
          type = lib.types.ints.positive;
          default = 10;
          description = "残しておくバックアップの世代数";
        };
        fragmentFile = lib.mkOption {
          type = lib.types.package;
          readOnly = true;
          internal = true;
          description = "正規化済みの断片 (store 内)";
        };
      };
      config.fragmentFile = normalizeFragment name config.format config.fragment;
    };
in
{
  options.mergedFiles = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule fileModule);
    default = { };
    description = "設定ファイルにNixで書いた設定をマージする";
  };

  config = lib.mkIf (cfg != { }) {
    assertions = lib.mapAttrsToList (name: f: {
      assertion = lib.hasPrefix "/" f.target;
      message = "mergedFiles.${name}.target must be an absolute path (got ${f.target})";
    }) cfg;

    # linkGeneration の後: 前世代が同じパスを home.file で管理していた場合、
    # 古い store へのリンクが片付いた後でないと読み取り専用の先へ書きに行ってしまう
    home.activation.mergedFiles = lib.hm.dag.entryAfter [ "linkGeneration" ] (
      lib.concatStrings (
        lib.mapAttrsToList (name: f: ''
          run ${lib.getExe mergers.${f.format}} ${lib.escapeShellArg name} ${lib.escapeShellArg f.target} \
            ${f.fragmentFile} ${lib.escapeShellArg "${backupRoot}/${name}"} ${toString f.keepBackups}
        '') cfg
      )
    );
  };
}
