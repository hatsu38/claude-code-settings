# claude-code-settings

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) の個人設定（`~/.claude/`）を複数マシンで共有するためのリポジトリ

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

## 概要

普段使いしている Claude Code のグローバル設定・スラッシュコマンド・スキルをこのリポジトリで管理し、シンボリックリンクで `~/.claude/` に配置します。`git pull` するだけでどのマシンでも同じ設定が使えます。

- **CLAUDE.md** - 全プロジェクト共通の個人設定（言語・Git 運用・モデルの使い分け等）
- **スキル** - コミット・PR 作成などの定型作業から、タスクルーティング・文章規範まで、再利用可能な手順書（`/名前` で明示起動、または内容に応じて自動起動）
- **MCP サーバー** - GitHub、Playwright、Sentry 等の外部ツール統合

## ディレクトリ構成

```
claude/
├── CLAUDE.md                              # 全プロジェクト共通の個人設定
├── settings.json                          # Claude Code 設定（参考用。手動マージ）
└── skills/                                # スキル
    ├── agmsg/                             #   エージェント間メッセージング
    ├── commit/                            #   日本語コミットメッセージ生成
    ├── empirical-prompt-tuning/           #   プロンプト・スキルの実証的チューニング
    ├── github-pr-review-operation/        #   GitHub PR操作
    ├── grill-me/                          #   計画・設計の深掘り質問
    ├── japanese-tech-writing/             #   日本語技術文書の文章規範
    ├── ship/                              #   commit→push→PR作成の一括実行
    ├── task-routing/                      #   モデル・ツールのルーティング
    └── web-perf/                          #   Webパフォーマンス分析

.claude.json                               # MCP サーバー設定（参考用。手動マージ）

scripts/
├── setup.sh                               # シンボリックリンク作成
└── uninstall.sh                           # シンボリックリンク削除
```

## セットアップ

### 前提条件

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) がインストール済み
- [GitHub CLI (`gh`)](https://cli.github.com/) がインストール・認証済み
- Node.js（MCP サーバー実行用）

### シンボリックリンク（推奨）

`~/.claude/` にシンボリックリンクを作成し、全プロジェクトで設定を共有します。`git pull` するだけで最新の設定が反映されます。

```bash
# リポジトリをクローン
git clone https://github.com/hatsu38/claude-code-settings.git
cd claude-code-settings

# セットアップスクリプトを実行（プレビュー）
./scripts/setup.sh --dry-run

# 問題なければ実行
./scripts/setup.sh
```

**リンクされるもの:**

| リポジトリ内 | リンク先 |
|---|---|
| `claude/skills/*/` | `~/.claude/skills/` |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |

既存ファイルがある場合は `.bak` にバックアップされます。`~/.claude/` 内の他のファイル（キャッシュ、プロジェクト別メモリ等）は影響を受けません。

**アンインストール:**

```bash
./scripts/uninstall.sh
```

このリポジトリへのシンボリックリンクのみを削除し、バックアップがあれば復元します。

### settings.json / .claude.json の設定

これらは個人環境に依存するため、手動で設定してください。

- **`~/.claude/settings.json`** - 本リポジトリの `claude/settings.json` を参考に、permissions や hooks をマージ
- **`~/.claude.json`** - 本リポジトリの `.claude.json` を参考に、MCP サーバーの設定とトークンを追加

## スキル一覧

`/スキル名` で明示起動、またはタスク内容に応じて自動起動される再利用可能なスキルです。

| スキル | 説明 |
|---|---|
| **agmsg** | エージェント間メッセージング（受信確認・送信・履歴表示） |
| **commit** | 変更内容を分析し、日本語で詳細なコミットメッセージを生成してコミット |
| **empirical-prompt-tuning** | agent 向けテキスト指示（skill / プロンプト / CLAUDE.md 節）を、バイアスを排した実行者に動かして両面評価し、反復改善する手法 |
| **github-pr-review-operation** | `gh` CLI を使った PR 操作（情報取得、差分確認、インラインコメント投稿） |
| **grill-me** | 計画やデザインについて徹底的に質問し、意思決定ツリーの各分岐を解決して共通理解に達する |
| **japanese-tech-writing** | 日本語の技術文書・書籍原稿の文章規範（整形、パラグラフライティング、論証の厳密さ、冗長の排除） |
| **ship** | commit → push → PR 作成 → PR 説明文の生成までを一括で実行 |
| **task-routing** | 実作業を伴うタスクの委譲先ルーティング。探索・計画・実装・レビューを役割ごとに最適なモデル/Codex へ委譲する規範。モデル名は `routing.md`（SSOT）でのみ管理し、新モデル登場時は表の編集だけで乗り換え可能 |
| **web-perf** | Chrome DevTools MCP による Web パフォーマンス分析（Core Web Vitals 計測、レンダリングブロック・キャッシュ問題の特定） |

## MCP サーバー設定

`.claude.json` で設定されている外部ツール統合です。

| サーバー | 用途 |
|---|---|
| **Playwright** | E2Eテスト・ブラウザ操作 |
| **Chrome DevTools** | Web開発・デバッグ支援 |
| **Context7** | ライブラリドキュメントの検索 |
| **GitHub** | GitHub API 統合 |
| **Sentry** | エラートラッキング |
| **Serena** | コードベース分析 |
| **DeepWiki** | OSS ドキュメント検索 |

## カスタマイズ

### CLAUDE.md の編集

`claude/CLAUDE.md` が全プロジェクト共通の個人設定です。言語・Git 運用・モデルの使い分けなどの方針を記述します。

### スキルの追加

`claude/skills/{name}/SKILL.md` を追加して `./scripts/setup.sh` を再実行すると、`~/.claude/skills/` にリンクされます。スラッシュコマンドは作らず、すべてスキルとして管理します。

### MCP サーバーの追加・削除

`.claude.json` の `mcpServers` セクションを編集してください。

## ライセンス

[Apache License 2.0](LICENSE)
