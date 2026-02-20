PR Descriptionを自動生成して更新する。

## 手順

1. PR番号を特定する
   - 引数 `$ARGUMENTS` が指定されていればそれをPR番号として使う
   - 指定がなければ `gh pr view --json number -q .number` で現在のブランチのPRを自動検出する

2. PRの情報を収集する
   - `gh pr view <PR番号> --json title,baseRefName,headRefName` でPRのタイトルとブランチ情報を取得
   - `git log <base>..HEAD --oneline` でコミット履歴を取得
   - `git diff <base>...HEAD` で全変更差分を取得
   - 変更ファイル一覧を `git diff <base>...HEAD --name-only` で取得

3. PRテンプレート `.github/pull_request_template.md` を読み込み、以下のセクションを差分・コミット履歴から日本語で埋める

   - **概要**: 変更の目的と内容を簡潔に記述（箇条書き）
   - **チケット**: コミットメッセージやブランチ名からチケットURLがあればそのまま記載。なければ空欄のままにする
   - **受け入れ要件**: 変更内容に基づくチェックリスト（`- [ ]` 形式）
   - **スコープ外**: 関連するが今回対応しないものがあれば記載。なければ「なし」
   - **動作確認**: テスト実行コマンドや確認手順を記載

4. 生成したDescriptionを `gh api repos/{owner}/{repo}/pulls/<PR番号> -X PATCH -f body='...'` で更新する

5. 更新したPRのURLを表示する

## 注意事項

- 日本語で記述すること
- 概要は簡潔に。不要な詳細は省く
- チケットURLが不明な場合は推測せず空欄にする
- 既存のPR bodyに記載済みのチケットURLがあれば引き継ぐ
