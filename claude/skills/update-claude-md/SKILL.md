---
name: update-claude-md
description: CLAUDE.md をレビューし、ルールへの分離・陳腐化した情報の更新・最適化を行う。CLAUDE.md更新、プロジェクト設定見直しが必要な時に使用。
disable-model-invocation: true
argument-hint: "[focus: review|slim|sync]"
---

# Update CLAUDE.md

CLAUDE.md の内容をレビューし、最適化する。

**すべての出力は日本語で記述すること。**

## 引数

- `$ARGUMENTS`: 操作モード（デフォルト: `review`）
  - `review`: CLAUDE.md 全体をレビューし、改善提案を出す
  - `slim`: ルールファイルに抽出すべき詳細をCLAUDE.mdから分離する
  - `sync`: コードベースの現状とCLAUDE.mdの記述を同期する

## CLAUDE.md の役割（設計原則）

CLAUDE.md は **プロジェクトの概要と入り口** であり、以下を含むべき：

- アーキテクチャの全体像（簡潔に）
- 開発環境のセットアップコマンド
- よく使うコマンド一覧
- 必要な環境変数
- `@knowledge/` や `.claude/rules/` への参照

CLAUDE.md に含めるべき **でない** もの：

- 詳細な実装パターン → `.claude/rules/` に移動
- ドメイン知識・業務ロジック → `@knowledge/` に移動
- 特定レイヤーの技術的詳細 → path-specificルールに移動

## モード: review

### ステップ1: 情報収集

以下を並列で実行する：

1. `CLAUDE.md` を読み込む
2. `.claude/rules/` の全ファイルを一覧・読み込む
3. `@knowledge/` のファイル一覧を取得する
4. プロジェクトの主要な設定ファイルを確認する
   - `package.json`, `Gemfile`, `docker-compose.yml` 等のバージョン情報

### ステップ2: 分析

以下の観点で CLAUDE.md を分析する：

- **重複**: `.claude/rules/` や `@knowledge/` と内容が重複している箇所
- **陳腐化**: バージョン番号、コマンド、パス等が現状と異なる箇所
- **肥大化**: ルールファイルに分離すべき詳細な記述
- **欠落**: あるべきだが記載されていない重要な情報
- **構成**: セクション構成が適切か

### ステップ3: レポート出力

```
## CLAUDE.md レビュー結果

### 現在の状態
- 行数: N行
- セクション数: N
- ルールファイルとの重複: N箇所

### 改善提案

#### 重複の解消
- [ ] 「XXX」セクションの詳細を `.claude/rules/yyy.md` に移動
  理由: path-specificルールで対象ファイル編集時のみ読み込めば十分

#### 陳腐化の修正
- [ ] Ruby バージョン: 3.3.x → 3.4.2
  確認元: .ruby-version

#### 構成の改善
- [ ] 「XXX」セクションを追加
  理由: ...

### 推奨アクション
1. ...
2. ...
```

ユーザーに各提案の実行可否を確認する。

## モード: slim

### ステップ1: CLAUDE.md の読み込み

CLAUDE.md の全内容を読み込み、各セクションの役割を分析する。

### ステップ2: 分離候補の特定

以下の基準で、ルールファイルに移動すべきコンテンツを特定する：

- **特定レイヤーに限定される記述**: 例）「Railsのサービスクラスは〜」→ `rails/services.md`
- **200文字を超える技術的詳細**: 概要はCLAUDE.mdに残し、詳細をルールに移動
- **コード例を含むセクション**: ルールファイルの方が適切

### ステップ3: 分離計画の提示

各分離候補について：
- CLAUDE.md から削除する内容
- 移動先のルールファイルパス
- ルールファイルに追記する内容

ユーザーに確認後、CLAUDE.md を更新し、必要に応じてルールファイルも作成・更新する。

## モード: sync

### ステップ1: 現状の情報収集

以下を並列で確認する：

- `Gemfile` / `Gemfile.lock` → Ruby バージョン、主要gem
- `frontend-next/package.json` → Node/Next.js バージョン、主要パッケージ
- `admin/package.json` → admin側のバージョン
- `docker-compose.yml` → サービス構成、ポート番号
- `.ruby-version`, `.node-version`, `.tool-versions` → ランタイムバージョン
- `config/database.yml` → DB構成
- `Makefile`, `dx/` → 開発コマンド

### ステップ2: 差分の検出

CLAUDE.md の記述と実際の設定を比較し、不一致を検出する：

- バージョン番号の不一致
- 存在しないコマンドやパスの参照
- 削除・追加されたサービスやツール
- ポート番号の変更

### ステップ3: 更新の提案

不一致箇所をリストアップし、修正案を提示する。
ユーザーに確認後、CLAUDE.md を更新する。

## 制約事項

- `.claude/rules/` のルールファイルを直接編集する場合は最小限に留める（`/update-rules` の使用を推奨）
- `@knowledge/` ファイルは編集しない
- CLAUDE.md の全体構成を大幅に変更する場合はユーザーに事前確認する
- 200行以内を目安にCLAUDE.mdを維持する
