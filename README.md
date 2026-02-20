# claude-code-settings

Ruby/Rails 開発に特化した [Claude Code](https://docs.anthropic.com/en/docs/claude-code) の設定テンプレート集

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

## 概要

Claude Code で Ruby/Rails プロジェクトを効率的に開発するための設定・コマンド・スキル・ルールをまとめたテンプレートリポジトリです。

- **スラッシュコマンド** - コミット、PRレビュー、RSpecテスト生成などの定型作業を自動化
- **スキル** - コマンドから呼び出される再利用可能なロジック
- **ルール** - コーディング規約、Git運用、テスト要件などの開発ルール
- **MCP サーバー** - GitHub、Playwright、Sentry 等の外部ツール統合

## ディレクトリ構成

```
claude/
├── CLAUDE.md                              # プロジェクト設定ガイド
├── settings.json                          # Claude Code プロジェクト設定
├── commands/                              # スラッシュコマンド
│   ├── commit.md                          #   /commit
│   ├── review-pr.md                       #   /review-pr
│   ├── review-local.md                    #   /review-local
│   ├── generate-rspec.md                  #   /generate-rspec
│   ├── pr-description.md                  #   /pr-description
│   └── update-readme.md                   #   /update-readme
└── skills/                                # スキル
    ├── rspec-generator/                   #   RSpecテスト生成
    ├── github-pr-review-operation/        #   GitHub PR操作
    ├── update-claude-md/                  #   CLAUDE.md管理
    └── update-rules/                      #   ルールファイル管理

.claude/rules/                             # 開発ルール
├── coding-style.md                        #   コーディング規約
├── git-workflow.md                        #   Git運用フロー
├── testing.md                             #   テスト要件
├── performance.md                         #   パフォーマンス最適化
├── patterns.md                            #   共通パターン
├── hooks.md                               #   Hooks設定
├── agents.md                              #   エージェント運用
└── security.md                            #   セキュリティ

.claude.json                               # MCP サーバー設定
```

## セットアップ

### 前提条件

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) がインストール済み
- [GitHub CLI (`gh`)](https://cli.github.com/) がインストール・認証済み
- Node.js（MCP サーバー実行用）

### 導入手順

1. このリポジトリの `claude/` ディレクトリをプロジェクトのルートにコピー

```bash
# リポジトリをクローン
git clone https://github.com/hatsu38/claude-code-settings.git

# 対象プロジェクトに claude/ をコピー
cp -r claude-code-settings/claude/ /path/to/your-project/claude/
```

2. 必要に応じて `.claude.json` をプロジェクトルートにコピー（MCP サーバーを使う場合）

```bash
cp claude-code-settings/.claude.json /path/to/your-project/.claude.json
```

3. `.claude.json` 内の環境変数（`GITHUB_PERSONAL_ACCESS_TOKEN` 等）を自分の値に設定

4. ルールを使う場合は `.claude/rules/` もコピー

```bash
cp -r claude-code-settings/.claude/rules/ /path/to/your-project/.claude/rules/
```

## コマンド一覧

Claude Code 内で `/コマンド名` で実行できるスラッシュコマンドです。

| コマンド | 説明 | 使い方 |
|---|---|---|
| `/commit` | 変更内容を分析し、日本語で詳細なコミットメッセージを生成してコミット | `/commit` |
| `/review-pr` | GitHub上のPRをマルチエージェントでコードレビュー（バグ検出・品質・セキュリティ） | `/review-pr` or `/review-pr 123` |
| `/review-local` | PRオープン前にローカル変更をセルフレビュー（バグ・CLAUDE.md準拠・セキュリティ） | `/review-local` |
| `/generate-rspec` | git diff の差分から変更されたRubyファイルのRSpecテストを自動生成 | `/generate-rspec` or `/generate-rspec main` |
| `/pr-description` | PRテンプレートに基づきPR Descriptionを自動生成・更新 | `/pr-description` or `/pr-description 123` |
| `/update-readme` | README.md をリポジトリの実態（コマンド・スキル・ルール・MCP）と同期 | `/update-readme` |

## スキル一覧

コマンドから内部的に参照される再利用可能なスキルです。

| スキル | 説明 |
|---|---|
| **rspec-generator** | RSpecテスト生成のコアロジック。18種類のファイルタイプ分類、specパス解決、テストパターン適用 |
| **github-pr-review-operation** | `gh` CLI を使ったPR操作（情報取得、差分確認、インラインコメント投稿） |
| **update-claude-md** | CLAUDE.md のレビュー・スリム化・同期を行う最適化スキル |
| **update-rules** | コードベースを分析して `.claude/rules/` のルールファイルを作成・更新 |

## ルール一覧

`.claude/rules/` に格納された開発ルールです。Claude Code がコード生成・レビュー時に自動参照します。

| ルール | 内容 |
|---|---|
| **coding-style.md** | 不変性（Immutability）、ファイル構成、エラーハンドリング、入力バリデーション |
| **git-workflow.md** | Conventional Commits、PR作成フロー、TDDを含む機能実装ワークフロー |
| **testing.md** | 80%カバレッジ必須、TDD（RED→GREEN→IMPROVE）、ユニット/統合/E2Eテスト |
| **performance.md** | モデル選択戦略（Haiku/Sonnet/Opus）、コンテキストウィンドウ管理 |
| **patterns.md** | APIレスポンス形式、Custom Hooks、Repository パターン |
| **hooks.md** | PreToolUse/PostToolUse/Stop のHook定義、自動フォーマット |
| **agents.md** | 利用可能エージェント一覧、並列実行、マルチパースペクティブ分析 |
| **security.md** | シークレット管理、入力バリデーション、セキュリティチェックリスト |

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

`claude/CLAUDE.md` をプロジェクトに合わせて編集してください。基本方針（言語、フレームワーク、テスト方針等）を記述します。

### ルールの追加・変更

`.claude/rules/` にMarkdownファイルを追加・編集することで、Claude Code の振る舞いをカスタマイズできます。`paths:` フロントマターで対象ファイルパスを限定できます。

```yaml
---
paths:
  - "app/models/**/*.rb"
---

# モデル固有のルール
- バリデーションは必ず追加する
- ...
```

### MCP サーバーの追加・削除

`.claude.json` の `mcpServers` セクションを編集してください。

## ライセンス

[Apache License 2.0](LICENSE)
