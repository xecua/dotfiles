---
name: ask-copilot
description: |
  Copilot CLIを使用してコードや文言について相談・レビューを行う。
  トリガー: "copilot", "copilotと相談", "copilotに聞いて", "コードレビュー", "レビューして"
  使用場面: (1) 文言・メッセージの検討、(2) コードレビュー、(3) 設計の相談、(4) バグ調査、(5) 解消困難な問題の調査
---

# Copilot

GitHub Copilot CLIを使用してコードレビュー・分析を実行するスキル。

## 実行コマンド

copilot --no-ask-user --allow-all-tools --deny-tool write --model gpt-5.6-sol -s --output-format json --add-dir <project_directory> -p "<request>"

requestが長い場合は一時ファイルに書き出しても構いません。

## プロンプトのルール

**重要**: copilot cliに渡すリクエストには、以下の指示を必ず含めること：

> 「具体的な提案・修正案・コード例まで自主的に出力してください。」

## パラメータ

| パラメータ             | 説明                                               |
| ---------------------- | -------------------------------------------------- |
| `--no-ask-user`        | 確認項目を抑制                                     |
| `--allow-all-tools`    | すべてのツールの実行を自動的に許可                 |
| `--deny-tool write`    | ファイルへの書き込みのみ禁止                       |
| `--model <model>`      | 使用するモデル。基本的に`gpt-5.6-sol`を推奨        |
| `-s`                   | 出力内容を抑制                                     |
| `--output-format json` | jsonで出力                                         |
| `--add-dir <dir>`      | 対象プロジェクトのディレクトリの読み取り権限を付与 |
| `"<request>"`          | 依頼内容（日本語可）                               |

## 使用例

**注意**: 各例では末尾に「確認不要、具体的な提案まで出力」の指示を含めている。

### コードレビュー

copilot -p --no-ask-user --allow-all-tools --deny-tool write --model gpt-5.6-sol -s --output-format json --add-dir /path/to/project "このプロジェクトのコードをレビューして、改善点を指摘してください。具体的な修正案とコード例まで自主的に出力してください。"

### バグ調査

copilot -p --no-ask-user --allow-all-tools --deny-tool write --model gpt-5.6-sol -s --output-format json --add-dir /path/to/project "認証処理でエラーが発生する原因を調査してください。原因の特定と具体的な修正案まで自主的に出力してください。"

### アーキテクチャ分析

copilot -p --no-ask-user --allow-all-tools --deny-tool write --model gpt-5.6-sol -s --output-format json --add-dir /path/to/project "このプロジェクトのアーキテクチャを分析して説明してください。改善提案まで自主的に出力してください。"

### リファクタリング提案

copilot -p --no-ask-user --allow-all-tools --deny-tool write --model gpt-5.6-sol -s --output-format json --add-dir /path/to/project "技術的負債を特定し、リファクタリング計画を提案してください。具体的なコード例まで自主的に出力してください。"

### デザイン相談（UI/UX）

copilot -p --no-ask-user --allow-all-tools --deny-tool write --model gpt-5.6-sol -s --output-format json --add-dir /path/to/project "あなたは世界トップクラスのUIデザイナーです。以下の観点からこのプロジェクトのUIを評価してください: (1) 視覚的階層構造とタイポグラフィ、(2) 余白・スペーシングのリズム、(3) カラーパレットのコントラストとアクセシビリティ、(4) インタラクションパターンの一貫性、(5) ユーザーの認知負荷の軽減。具体的な改善案をコード例付きで提示してください。"

copilot -p --no-ask-user --allow-all-tools --deny-tool write --model gpt-5.6-sol -s --output-format json --add-dir /path/to/project "UXリサーチャー兼デザイナーとして、このフォームのユーザビリティを分析してください。Nielsen の10ヒューリスティクスに基づき、(1) エラー防止の仕組み、(2) ユーザーの制御と自由度、(3) 一貫性と標準、(4) 認識vs記憶の負荷、(5) 柔軟性と効率性を評価してください。改善したTailwind CSSコードまで自主的に提示してください。"

## 実行手順

1. ユーザーから依頼内容を受け取る
2. 対象プロジェクトのディレクトリを特定する（現在のワーキングディレクトリまたはユーザー指定）
3. **プロンプトを作成する際、末尾に「具体的な提案まで自主的に出力してください。」を必ず追加する**
4. 上記コマンド形式でcopilotを実行
5. 結果をユーザーに報告
