# ルーティング表(SSOT)

モデル名・実行先は**このファイルにだけ**書く。新しいモデルへの乗り換え・分担変更は、この表の編集だけで完結させる(SKILL.md は触らない)。

## 役割 → 実行先

| 役割 | 実行先 | 呼び方 |
|------|--------|--------|
| 統括・設計判断・委譲文面の作成・検収・最終レビュー | メインセッション(現在: Fable) | 自分で実施 |
| コード探索・調査・現状把握 | sonnet | Agent(subagent_type: "Explore", model: "sonnet")。書き込みが要る定型作業は general-purpose + sonnet |
| 実装計画・デバッグ分析・難所の設計レビュー | opus | Agent(subagent_type: "Plan" または "general-purpose", model: "opus") |
| コード実装(diff を書く作業全般。骨組み・バグ修正含む) | Codex | Agent(subagent_type: "codex:codex-rescue")。モデル・effort は Codex 側デフォルトに任せる。状況確認は /codex:status、結果回収は /codex:result |
| 観点別コードレビュー(品質/パフォーマンス/セキュリティ) | プロジェクトのレビュアーエージェント | code-quality-reviewer / performance-reviewer / security-reviewer(insight-sky-frontend に定義あり。無いプロジェクトでは opus の general-purpose で代替) |

## 調整パラメータ

- **小修正閾値**: 2 ファイル以下かつ合計 ±20 行以下の機械的変更は、メインセッションが直接編集してよい
- **Codex background 切替目安**: 3 ステップ以上、または 10 分超が見込まれる実装は background で起動する

## 更新履歴

- 2026-07-19: 初版(Fable / sonnet / opus / Codex)
