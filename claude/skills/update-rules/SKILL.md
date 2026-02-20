---
name: update-rules
description: コードベースを分析して .claude/rules/ のpath-specificルールファイルを作成・更新する。ルール追加、ルール更新、プロジェクトルール作成が必要な時に使用。
disable-model-invocation: true
argument-hint: "[scope: all|rails|frontend|graphql|rspec|<path>]"
---

# Update Rules

コードベースの実装パターンを分析し、`.claude/rules/` にpath-specificルールファイルを作成・更新する。

**すべての出力は日本語で記述すること。**

## 引数

- `$ARGUMENTS`: 分析スコープ（デフォルト: `all`）
  - `all`: 全レイヤーを対象
  - `rails`: Rails バックエンド（models, services, interactions, decorators, jobs, service_wrappers）
  - `frontend`: frontend-next/ と admin/
  - `graphql`: GraphQL スキーマ・リゾルバ・ミューテーション
  - `rspec`: テスト関連
  - `<path>`: 特定のディレクトリやファイルパス

## ステップ1: 現状把握

以下を並列で実行する：

1. 既存のルールファイル一覧を取得
   - `.claude/rules/` 配下の全 `.md` ファイルを読み込む
   - 各ファイルの `paths:` フロントマターとコンテンツを把握する

2. CLAUDE.md を読み込む
   - ルールファイルと重複している内容がないか確認する

3. `@knowledge/` ディレクトリの構成を確認する
   - ルールと知識ファイルの役割分担を理解する

## ステップ2: コードベース分析

スコープに応じて **2-3個のExplore agentを並列起動** し、実際のコードパターンを調査する。

### 調査観点

各agentは以下の観点で分析する：

- **アーキテクチャパターン**: レイヤー構成、依存関係、命名規約
- **実装規約**: 基底クラス、共通パターン、ヘルパーの使い方
- **技術スタック**: 使用しているgem/パッケージ、バージョン、設定
- **エラーハンドリング**: エラークラス階層、例外処理パターン
- **テストパターン**: テストヘルパー、共通セットアップ、モックパターン

### スコープ別の調査対象

#### `rails` スコープ
- Agent 1: `app/models/`, `app/services/`, `app/interactions/` のパターン
- Agent 2: `app/decorators/`, `app/jobs/`, `app/service_wrappers/` のパターン
- Agent 3: `config/`, `Gemfile`, `lib/` の設定・規約

#### `frontend` スコープ
- Agent 1: `frontend-next/` のコンポーネント・hooks・状態管理パターン
- Agent 2: `admin/` のパターン、共通デザインシステムの使い方

#### `graphql` スコープ
- Agent 1: `app/graphql/` のtypes, mutations, resolvers, sourcesパターン
- Agent 2: フロントエンド側のGraphQL利用パターン（クエリ、コード生成）

#### `rspec` スコープ
- Agent 1: `spec/` のテスト構造、ファクトリ、ヘルパー
- Agent 2: `spec/support/`, `spec/shared_examples/` のパターン

#### `all` スコープ
- 上記すべてを対象に、変更が多いレイヤーを優先して調査する

## ステップ3: ルール生成

分析結果をもとに、ルールファイルを生成する。

### ルールファイルの構造

```yaml
---
paths:
  - "app/models/**"
  - "app/models/**/*.rb"
---

# ルールタイトル

## セクション1
- 具体的なパターンや規約
- コード例を含める

## セクション2
...
```

### 生成ルール

1. **path-specific**: 各ルールファイルは `paths:` フロントマターで対象パスを限定する
2. **具体的**: 実際のコードベースから抽出したパターンを記述する（一般論ではなく）
3. **コード例を含む**: 正しいパターンと避けるべきパターンを示す
4. **簡潔**: 1ファイル200行以内を目安にする
5. **既存ルールとの整合性**: 既存のルールと矛盾しないようにする

### ファイル命名規約

- `{layer}.md`: 単一レイヤー（例: `models.md`, `frontend-next.md`）
- `{domain}/{layer}.md`: サブディレクトリ整理（例: `rails/models.md`, `rails/services.md`）

## ステップ4: 差分の提示と確認

ルールファイルを書き込む前に、以下を提示する：

### 新規作成ファイル
各ファイルについて：
- ファイルパス
- 対象パス（paths フロントマター）
- コンテンツの要約（主要なルール3-5個）

### 更新ファイル
各ファイルについて：
- ファイルパス
- 変更内容の要約（追加・変更・削除されるルール）
- 変更理由

### 削除候補ファイル
- 不要になったルールファイル（統合された等）

ユーザーに「この内容でルールファイルを作成/更新しますか？」と確認する。

## ステップ5: ファイルの書き込み

確認後、ルールファイルを作成・更新する。

### 完了サマリー

```
## ルール更新サマリー

### 新規作成
- .claude/rules/xxx.md（主要ルール: A, B, C）

### 更新
- .claude/rules/yyy.md（追加: D, 変更: E）

### 次のステップ
- `git diff .claude/rules/` で変更内容を確認
- `/commit` でコミット
```

## 制約事項

- CLAUDE.md は直接編集しない（`/update-claude-md` を使用すること）
- `@knowledge/` ファイルは編集しない（読み取り専用で参照のみ）
- 一般論ではなく、このプロジェクト固有のパターンを記述する
- 存在しないパターンを推測で記述しない（実際のコードから抽出する）
- 既存のルールを破壊的に変更しない（追記・修正を優先する）
