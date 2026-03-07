---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git log:*), Bash(git push:*), Bash(git branch:*), Bash(gh pr create:*), Bash(gh pr view:*), Bash(gh api:*)
description: commit → push → PR作成 → PR説明文の生成までを一括で実行する
---

変更内容のコミットからPR作成・説明文の記述まで、全フローを自動で実行する。

**すべての出力は日本語で記述すること。**

## フロー

### 1. /commit の実行

まず `/commit` コマンドと同じ手順でコミットを行う：

- `git status` / `git diff HEAD` / `git branch --show-current` / `git log --oneline -10` でコンテキスト収集
- 差分を論理単位にグループ分けし、グループごとに：
  - `git add -p` で該当変更のみをステージング（新規ファイルは `git add <file>`）
  - `.env`、認証情報、シークレットを含むファイルはステージングしない
  - Conventional Commits形式 + 変更理由付きのコミットメッセージを生成
  - 確認を求めず `git commit` を自動実行
- コミット一覧を表示

### 2. push

- `git push origin <現在のブランチ>` を実行する
- リモートにブランチがなければ `git push -u origin <現在のブランチ>` を使う

### 3. PR作成

- `gh pr view` で既存PRがあるか確認する
- PRがまだなければ `gh pr create` で作成する
  - タイトルはコミット内容から日本語で生成する
  - ベースブランチは `main` とする
  - `--fill` は使わず、タイトルと仮のbodyを明示的に指定する
- 既にPRがあればそのまま次のステップに進む

### 4. /pr-description の実行

PRの説明文を自動生成して更新する：

- `gh pr view --json number -q .number` でPR番号を取得
- `gh pr view <PR番号> --json title,baseRefName,headRefName` でPR情報を取得
- `git log <base>..HEAD --oneline` でコミット履歴を取得
- `git diff <base>...HEAD` で全変更差分を取得
- PRテンプレート `.github/pull_request_template.md` があれば読み込み、各セクションを埋める
- `gh api` でPRのbodyを更新する
- 更新したPRのURLを表示する

### 5. 完了報告

最終的に以下を表示する：
- 作成したコミットの一覧
- PRのURL

## 制約事項

- Co-Authored-By フッターを追加しない
- コミットメッセージ・PR説明文は日本語で記述する（タイプ接頭辞は英語）
- `--no-verify` フラグを使用しない
- pre-commit hookが失敗した場合は、問題を修正してから新しいコミットを作成する
- main ブランチにいる場合はエラーを出して中断する（直接pushを防ぐ）
