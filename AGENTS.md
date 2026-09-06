# dotfiles

home-manager (flake) で管理する個人用 dotfiles。Gentoo (`gentoo-home.nix`) と macOS (`macos-home.nix`) の 2 系統。
シンボリックリンクだけの設定は `links.yaml` + `setup.py`、Nix で扱うものは `*.nix` に書く。

## AI エージェント (Claude Code / Codex CLI / Copilot CLI) 設定

skill・plugin・MCP の宣言は `agents.nix`、機構は `modules/` にある。

```text
agents.nix                    # 中身: agents.skills / plugins / toolSkills / claude-code.settings / codex.settings
claude/settings.json          # Claude Code settings.json に部分マージする断片 (JSON のまま置く)
claude/hooks/                 # programs.claude-code.hooksDir
skills/<name>/SKILL.md        # 自作 skill
pkgs/playwright-cli.nix       # @playwright/cli (nixpkgs に無い)
modules/merged-files.nix      # mergedFiles.<name> = { target; fragment; format = "json"|"toml"; }
modules/agents/default.nix    # agents.* オプション、plugin / marketplace derivation
modules/agents/{claude-code,codex,copilot,tool-skills}.nix   # 各ホストへの繋ぎ込み
```

### ファイルは A / B に分ける

- **A. 静的** (plugin ディレクトリ、skill、hook、marketplace): `home.file` で store へリンク。
  **エントリ単位**でリンクし、`skills/` のような親ディレクトリは排他管理しない。
- **B. ツール自身が実行時に書く** (`$CLAUDE_CONFIG_DIR/settings.json`、`$CODEX_HOME/config.toml`、
  `$COPILOT_HOME/{settings,mcp-config}.json`): `mergedFiles` で部分マージ。
  `programs.claude-code.settings` / `programs.codex.settings` / `programs.*.enableMcpIntegration` /
  `programs.github-copilot-cli.settings` のような「ファイル全体を生成する」オプションは使わない (assertion で禁止済み)。

### 置き場所

| 要素                   | Claude Code                                                                         | Codex                                                  | Copilot                                                        |
| ---------------------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------ | -------------------------------------------------------------- |
| `agents.skills`        | `$CLAUDE_CONFIG_DIR/skills/<name>` → store                                          | `~/.agents/skills/<name>` → store                      | `~/.agents/skills` を直接見る                                  |
| `agents.toolSkills`    | 同上 → `~/.agents/skills/<name>` (store 外リンク)                                   | CLI が `~/.agents/skills/<name>` に書く                | 同左                                                           |
| `agents.plugins`       | `$CLAUDE_CONFIG_DIR/skills/<name>` → store (skills-dir plugin、`<name>@skills-dir`) | marketplace を config.toml に登録 + `codex plugin add` | marketplace を settings.json に登録 + `copilot plugin install` |
| marketplace            | 使わない                                                                            | `$XDG_DATA_HOME/agents/marketplaces/<name>` (安定パス) | 同左                                                           |
| `programs.mcp.servers` | `enableMcpIntegration` (`--plugin-dir`)                                             | config.toml `mcp_servers` に部分マージ                 | mcp-config.json に部分マージ                                   |

- Codex / Copilot は plugin を cache にコピーして読むので、activation で毎回 `plugin add` / `plugin install` を実行する (冪等)。
- plugin の `.mcp.json` は `{"mcpServers": {...}}`。`${VAR}` は使わず store パスなど静的な値を書く。
- Copilot の `copilot mcp list` は plugin 由来のサーバーを表示しない (セッション内 `/mcp` で確認する)。
- plugin の `hosts = [ "claude-code" ... ]` で配布先を絞れる (例: `github` は Copilot に組み込みがあるので Claude のみ)。

### 追加のしかた

- 自作 skill: `skills/<name>/SKILL.md` + `agents.skills.<name> = ./skills/<name>;`
- GitHub 公開 skill: `flake.nix` の inputs に `flake = false` で追加し `agents.skills.<name> = "${inputs.x}/path";`。submodule は使わない
- plugin / MCP: `agents.plugins.<name> = { description; mcpServers; skills; hooks; hosts; }`
- CLI が置く skill: `agents.toolSkills.<tool> = { package; installCommand; skills; }` (installCommand は絶対パスで、冪等なもの)
- B ファイル: `mergedFiles.<name> = { target = "/abs/path"; fragment = {...}; format = "json"|"toml"; }`
- 名前の重複 (skills / plugins / toolSkills) は assertion で落ちる

### マージの挙動 (hm-merge-json / hm-merge-toml)

- 宣言したキーは上書き。テーブル / オブジェクトは再帰マージ、**配列はまるごと置換**
  (例: `permissions.allow` を宣言していると、ツール側で user scope に足した allow ルールは次の switch で消える)
- 宣言していないキー (`pluginConfigs`、`projects.*.trust_level`、OAuth 情報など) は保持
- 断片からキーを消してもライブファイルからは消えない。MCP サーバーを外したら `codex mcp remove` 等で手で消す
- 意味的に同一なら書かない。ただしシンボリックリンクなら実ファイルに置き換える
- 書き換え前に `$XDG_STATE_HOME/home-manager/merged-files/<name>/` にバックアップ (10 世代)
- 壊れた json / toml、JSONC のコメント入りは触らずに失敗する

### シークレット

- PAT / API キーは Nix、リポジトリ、断片、各ツールの設定ファイルに一切書かない (store は world-readable)
- activation スクリプトは資格情報を読まない・書かない
- GitHub MCP: リモート MCP は OAuth の DCR 非対応で Claude Code / Codex の OAuth は失敗する。
  `github-mcp-headers` (agents.nix) が接続のたびに `gh auth token` からヘッダを作る。前提は `gh auth login`。
  Claude Code はヘルパに `HOME` / `PATH` 以外の環境変数を渡さないので `GH_TOKEN` では動かない。
  未ログイン時は "does not support dynamic client registration" と出る
- Copilot は組み込みの GitHub MCP を使う (`copilot login`)

### 検証

```sh
nix build '.#homeConfigurations."xecua@melting-face".activationPackage' --no-link   # ビルドのみ
claude plugin validate "$(nix build '.#homeConfigurations."xecua@melting-face".config.agents.marketplace.package' --no-link --print-out-paths)"
home-manager switch --flake '.#xecua@melting-face' -n   # dry-run。旧リンクとの衝突はここで出る
home-manager switch --flake '.#xecua@melting-face'      # 2 回続けて実行しても "already up to date" で何も起きないこと
claude plugin list; codex plugin list; codex mcp list; copilot plugin list
```

- 新規ファイルは `git add -N` しないと flake から見えない
