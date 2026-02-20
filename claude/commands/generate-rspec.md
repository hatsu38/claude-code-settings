---
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git status:*), Bash(git branch:*)
description: git diffの差分からRSpecテストを自動生成する
---

git diffの差分から変更されたRubyファイルを分析し、RSpecテストを自動生成する。

**すべての出力・コメント・descriptionは日本語で記述すること。**

## 引数

- `$ARGUMENTS`: diff対象ブランチ（デフォルト: `master`）

## ステップ1: コンテキスト収集

以下のコマンドを並列で実行する：

- `git branch --show-current` で現在のブランチを確認
- `git diff ${ARGUMENTS:-master}...HEAD --name-only --diff-filter=ACMR -- '*.rb'` で変更されたRubyファイル一覧を取得
- `git diff ${ARGUMENTS:-master}...HEAD -- '*.rb'` で差分内容を取得

変更されたRubyファイルがない場合は「変更されたRubyファイルはありません」と出力して終了する。

## ステップ2: ファイルの分類

`rspec-generator` スキルのSKILL.mdに従い、変更ファイルを分類する：

- **テスト対象**: `app/` 配下のソースファイル（models, services, interactions, controllers, graphql, jobs, workers, decorators, policies, queries, validators, service_wrappers, mailers, lib, subscribers, events）
- **対象外**: マイグレーション、設定ファイル、specファイル自体、Gemfile、Rakefile、initializer

各ファイルについて、スキルのマッピングテーブルに従いspecパスを解決する。

specが既に存在するか確認し、以下を判定する：
- **新規生成**: specファイルが存在しない → 完全なspecを新規作成
- **追加提案**: specファイルが存在する → 差分で追加されたメソッドのテストのみ提案

## ステップ3: 参照情報の収集（3 Agent並列）

**3つのagentを並列で起動する：**

### Agent 1: ファクトリ調査（haiku agent）

変更ファイルで使用されているモデルに対応するファクトリを調査する：
- `spec/factories/` から関連するファクトリファイルを検索して読み込む
- 利用可能なtrait一覧を収集する
- 結果をファクトリ名・trait名のリストとして返す

### Agent 2: 類似スペック分析（sonnet agent）

同じカテゴリの既存specから最新のものを2-3個選択して読み込む：
- describe/context/itの構造パターンを分析
- 使用されているヘルパー・マッチャ・セットアップパターンを収集
- `spec/support/` 内の関連ヘルパーを特定
- パターンのサマリーを返す

### Agent 3: ソースコード分析（sonnet agent）

変更された各ソースファイルを読み込み、テスト対象を特定する：
- パブリックメソッド一覧（クラスメソッド / インスタンスメソッド）
- 引数の型・バリデーション
- 分岐ロジック（成功パス / 失敗パス / エッジケース）
- 依存する外部サービスやモデル
- 基底クラス（ActiveInteraction, ApplicationJob, Sidekiq::Worker等）
- 例外処理パターン

## ステップ4: テスト生成

`rspec-generator` スキルの `references/rspec-patterns.md` を読み込み、カテゴリ別テンプレートに従ってRSpecコードを生成する。

Agent結果を統合し、以下を遵守する：
- Agent 1が収集したファクトリ・traitのみを使用する（存在しないものは使わない）
- Agent 2が分析したパターンと一貫性を保つ
- Agent 3が特定したメソッド・分岐に基づきテストケースを網羅する

## ステップ5: 出力

### 新規生成の場合
1. specファイルのフルパスを提示
2. 生成したRSpecコードを表示
3. ファイルを作成する

### 追加提案の場合
1. 既存specファイルのパスを提示
2. 追加すべきテストケースをコードブロックで表示
3. ユーザーに「このテストを既存ファイルに追加しますか？」と確認

### サマリー

```
## テスト生成サマリー

### 新規作成
- spec/xxx_spec.rb（テストケース数: N）

### 追加提案
- spec/yyy_spec.rb（追加テストケース数: N）

### スキップ
- db/migrate/xxx.rb（マイグレーションのため対象外）

### 次のステップ
生成されたテストを実行して確認してください：
bundle exec rspec <生成されたspecファイルパス>
```

## 制約事項

- 存在しないファクトリやtraitを使用しない
- specファイル自体の変更は対象外
- 外部サービス呼び出しは必ずスタブ化する
- `console.log` や `puts` のデバッグ出力を含めない
- 変更されたファイルが50個を超える場合は、新規ファイルを優先してバッチ処理する
