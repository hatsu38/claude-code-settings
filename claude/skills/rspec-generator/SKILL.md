---
name: rspec-generator
description: RSpecテストの自動生成をサポートするスキル。変更されたRubyファイルの分類、specパスの解決、テストパターンの適用を行う。RSpecテスト生成、テスト自動生成、spec作成が必要な時に使用。
---

# RSpec Generator

変更されたRubyファイルからRSpecテストを生成するためのコア指示。

## ファイル分類マッピング

ソースファイルのパスに基づき、対応するspecのパスとtypeを決定する。

| ソースパスパターン | specパス | type |
|---|---|---|
| `app/models/**/*.rb` | `spec/models/` | `:model` |
| `app/services/**/*.rb` | `spec/services/` | なし |
| `app/interactions/**/*.rb` | `spec/interactions/` | なし |
| `app/controllers/**/*.rb` | `spec/controllers/` | `:controller` |
| `app/graphql/mutations/**/*.rb` | `spec/graphql/mutations/` | なし |
| `app/graphql/resolvers/**/*.rb` | `spec/graphql/resolvers/` | なし |
| `app/graphql/types/**/*.rb` | `spec/graphql/types/` | なし |
| `app/graphql/sources/**/*.rb` | `spec/graphql/sources/` | なし |
| `app/graphql/directives/**/*.rb` | `spec/graphql/directives/` | なし |
| `app/jobs/**/*.rb` | `spec/jobs/` | なし |
| `app/workers/**/*.rb` | `spec/workers/` | なし |
| `app/decorators/**/*.rb` | `spec/decorators/` | なし |
| `app/policies/**/*.rb` | `spec/policies/` | なし |
| `app/queries/**/*.rb` | `spec/queries/` | なし |
| `app/validators/**/*.rb` | `spec/validators/` | なし |
| `app/service_wrappers/**/*.rb` | `spec/service_wrappers/` | なし |
| `app/mailers/**/*.rb` | `spec/mailers/` | `:mailer` |
| `app/lib/**/*.rb` | `spec/lib/` | なし |
| `app/subscribers/**/*.rb` | `spec/subscribers/` | なし |
| `app/events/**/*.rb` | `spec/events/` | なし |

## specパス解決ルール

ソースファイルパスからspecファイルパスを導出する：

1. `app/` プレフィックスを `spec/` に置換
2. ファイル名の `.rb` を `_spec.rb` に置換
3. ネームスペース（サブディレクトリ）はそのまま維持

例：
- `app/services/order_guard_service.rb` → `spec/services/order_guard_service_spec.rb`
- `app/graphql/mutations/agree_to_terms.rb` → `spec/graphql/mutations/agree_to_terms_spec.rb`
- `app/controllers/api/v3/coupons_controller.rb` → `spec/controllers/api/v3/coupons_controller_spec.rb`
- `app/models/user.rb` → `spec/models/user_spec.rb`

## 除外ルール

以下のファイルはテスト生成の対象外とする：

- `db/migrate/**/*.rb` - マイグレーション
- `config/**/*.rb` - 設定ファイル
- `spec/**/*.rb` - specファイル自体
- `Gemfile`, `Rakefile` - ビルド設定
- `app/graphql/she_webapp_schema.rb` - スキーマ定義
- `bin/**/*.rb` - 実行スクリプト
- `lib/tasks/**/*.rb` - Rakeタスク（`app/lib/`は対象）

## プロジェクト共通テスト規約

すべてのspecファイルで以下を遵守する：

```ruby
require "rails_helper"
```

### 基本ルール

- `described_class` でテスト対象クラスを参照する
- `subject(:name)` で名前付きsubjectを定義する
- `context` と `it` の説明は日本語で記述する
- 成功パスと失敗パスの両方をテストする
- テストデータは最小限に留める

### テストデータのセットアップ

- `let_it_be`: テスト全体で不変のデータ（ユーザー等の共通データ）
- `let!`: 事前に存在する必要があるデータ（DBレベルのアサーションに必要）
- `let`: 遅延評価で十分なデータ（デフォルトで使用）
- `before_all`: 高コストな共通セットアップ（Fixtures.setup_* 等）

### ファクトリの使用

- `create(:factory_name)` でDBに保存されたレコードを作成
- `create(:factory_name, :trait_name)` でtraitを適用
- `build(:factory_name)` でDBに保存せずインスタンスを作成
- 存在するファクトリ・traitのみを使用すること

### 外部サービスのスタブ化

- WebMock: HTTP呼び出しのスタブ化
- `allow(...).to receive(...)`: メソッドのスタブ化
- 外部API呼び出しは必ずスタブ化する

## カテゴリ別テストテンプレート

詳細なテストテンプレートは `references/rspec-patterns.md` を参照。カテゴリに応じた具体的なコード例が記載されている。
