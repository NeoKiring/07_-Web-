# Issue Spec: I-008

- title: project-specific supplement document (CLAUDE.project.md)
- area: docs/project
- slug: docs-project-supplement
- batch id: BATCH-WAVE0
- derived from: 要件定義 v0.2 §15.6 (AI 主体開発時の注意点・CLAUDE.md 転記),
  Appendix A §A.2 (型規約), Appendix B §B.4.5 (カラートークン),
  §B.5.2 層 6 (プロンプトガードレール)
- harness: v4.1-p0-tool-ownership

## Background

要件定義 v0.2 §15.6 は「Appendix B §B.5.2 の 6 層防御を `CLAUDE.md` に転記し、
Claude Code への指示プロンプトから常時参照させる」と指示している。
一方、本プロジェクトはハーネス v4.1 bundle を採用しており、同梱の
`CLAUDE.md` / `AGENTS.md` / `CODEX.md` は **ハーネス設計アンカー**として
改変禁止（Forbidden files、Anchor 4 相当）である。

したがって、要件 v0.2 §15.6 の要請は「ハーネス CLAUDE.md を上書き」ではなく
「別ファイルでプロジェクト固有の supplement を置き、ハーネス CLAUDE.md から
参照される形にする」で満たす。

本タスクは **docs のみ**で閉じる。コードや設定には一切触れない。
ハーネス bundle と本プロジェクトの要件定義 / Appendix の**橋渡し**となる
supplement ドキュメント `docs/ai/project/CLAUDE.project.md` を作成する。

## Objective

プロジェクト固有の supplement `docs/ai/project/CLAUDE.project.md` を作成する。
内容は以下の橋渡し情報を含む:

1. 要件定義 v0.2 / Appendix A / Appendix B への索引
2. Appendix A §A.2 の型規約（Amount / YearMonth / CurrencyCode の扱い）
3. Appendix B §B.4.5 のカラートークン CSS 変数
4. Appendix B §B.4 の shadcn vs Tremor 使い分け原則
5. Appendix B §B.5.2 の 6 層防御への索引（本文を再掲せず、参照先を明示）
6. 要件 v0.2 NFR-003 / NFR-004 / NFR-005 / NFR-009 の要旨
7. 本プロジェクトで AI impl lane が踏んではいけない地雷
   （`localStorage`/`sessionStorage` 禁止、金額への `number` 使用禁止、
   CPI 未取得月の `null` 伝播、Decimal × number の四則演算禁止、等）
8. Wave 別タスクで「読むべき文書」の対応表

ハーネス既定の role 定義 / stop conditions / tool ownership は**重複させない**。
ハーネス CLAUDE.md からの参照経路を確立するのが目的。

## Scope

- `docs/ai/project/CLAUDE.project.md` (new)
- `docs/ai/project/README.md` (new, 1 段落程度のインデックス)

## Out of scope

- ハーネス同梱の `CLAUDE.md` / `AGENTS.md` / `CODEX.md` の改変（Forbidden）
- `docs/harness/**` の変更（Forbidden）
- 要件定義 v0.2 本体 / Appendix A / B の改訂（別の Wave、別タスク）
- 実装や設定ファイルの変更
- `README.md` (root, I-001 で作成) の大幅改訂（索引 1 行の追加は可、
  ただし本タスクでは触らない方針。I-008 完了後、別の軽い task で統合する）
- Wave 1 以降のタスク個別の CLAUDE supplement（本タスクは Wave 横断の唯一の 1 点）
- Codex / Copilot 向けの別 supplement ファイル（Phase A では不要）

## Done definition

- `docs/ai/project/CLAUDE.project.md` が存在し、以下を含む:
  - 冒頭: このファイルの位置付けと、ハーネス CLAUDE.md との関係
    （supplement である旨、ハーネス CLAUDE.md の上書きではない旨）
  - §1「プロジェクト要件の索引」: v0.2 本体 / Appendix A / B への相対パス
  - §2「型規約」: Appendix A §A.2 の `Amount` / `YearMonth` / `CurrencyCode` /
    Branded Type の扱いの要旨（本文は Appendix A 参照）
  - §3「UI コンポーネント採用ポリシー」: Appendix B §B.4 の要旨と参照先
  - §4「カラートークン」: Appendix B §B.4.5 の CSS 変数の要旨と参照先
  - §5「ガードレール（6 層防御）」: Appendix B §B.5.2 への索引（本文は転記しない）
  - §6「NFR 要旨」: NFR-003 (個人データ)、NFR-004 (依存禁止)、NFR-005 (AI 対応)、
    NFR-009 (API 制約) の 1 段落要約
  - §7「地雷マップ」: 箇条書き形式、以下を含む最小セット:
    - `localStorage` / `sessionStorage` を Artifact-like UI 実装で使わない
    - 金額に `number` を使わない（`Decimal` / `Amount` のみ）
    - CPI 未取得月は `null` を保つ（0 に fallback しない）
    - `Decimal × number` の四則演算を書かない
    - shadcn `<Card>` の中に Tremor `<Card>` を入れ子にしない（§B.4.1 原則）
    - カラー値をハードコードしない（CSS 変数経由のみ）
    - `packages/core` から `@repo/db` / `@repo/ui` / `@repo/ingestion` に依存しない
  - §8「Wave 別読書ガイド」: Wave 0 / 1 / 2 / 3 / 4 / 5 ごとに impl 着手前に
    目を通す文書の対応表
- `docs/ai/project/README.md` が 1 段落の説明と `CLAUDE.project.md` への link を含む
- ハーネス同梱ファイルに touch 無し
- `scripts/harness/validate-task-artifacts` が I-008 に対して PASS

## Risks

- **R-I008-01**: 要件 v0.2 / Appendix A/B の本文を大量に転記してしまい、
  変更追従が二重管理になる
  → 「参照先の相対パス + 1〜2 文要約」に留める制約を contract に明記
- **R-I008-02**: ハーネス CLAUDE.md と重複する内容を書いてしまう
  → role / stop conditions / tool ownership は書かない。書きかけた時点で stop
- **R-I008-03**: Wave 1 以降のタスクで「この supplement に追記する」需要が出て
  serial-only 扱いになる
  → 本ファイルは serial-only の cross-cutting logging / tracing 相当ではないが、
  cross-cutting な「読書ガイド」なので、Wave ごとの小 PR を前提として運用。
  serial-only 扱いには **しない** 方針を planning で確認
- **R-I008-04**: ハーネス bundle 側の `CLAUDE.md` からこの supplement を
  参照する経路が無い
  → `CLAUDE.md` はハーネス側なので改変禁止。代わりに、本タスクの handoff で
  「運用者が `CLAUDE.md` 冒頭に 1 行の参照を手動追加するか、あるいは
  プロジェクトルートの `README.md` で導線を作る」運用を明記。
  後者（README に導線）を推奨し、別タスクで実施する

## Unresolved questions

- UQ-I008-01: ファイルパスを `docs/ai/project/CLAUDE.project.md` とするか、
  別の命名（例: `docs/ai/CLAUDE.project.md` / `CLAUDE.project.md` root）とするか
  - 推奨: **`docs/ai/project/CLAUDE.project.md`**。ハーネス `docs/ai/` 配下で、
    かつ `docs/harness/` と明確に分離できる
- UQ-I008-02: 英/日の言語方針
  - 候補: (a) 日本語（要件定義と揃える）/ (b) 英語（ハーネス文書と揃える）/
    (c) 二言語
  - 推奨: **(a) 日本語**。読み手は要件定義と同一の人/AI を想定
- UQ-I008-03: ハーネス CLAUDE.md からこの supplement への参照経路
  - 候補: (a) ハーネス CLAUDE.md を改変（**禁止**）/ (b) root README.md に
    導線を置く（別タスクに切り出し）/ (c) I-008 自身で root README.md も更新
  - 推奨: **(b)**。本タスクは docs/ai/project/ 配下のみに閉じ、root README.md
    更新は別の軽タスクで実施
- UQ-I008-04: 「地雷マップ」の対象範囲
  - 候補: MVP で確実に踏むもののみ / 将来踏みそうなものまで含める
  - 推奨: MVP で確実に踏むものだけを明確に書き、将来分は「Wave X で追記予定」
    とコメント

## References

- `requirements_v0.2.md` §15.6 (CLAUDE.md への転記指示), §15 (Wave 分解)
- `requirements_v0.2_appendix_A_technical.md` §A.2, §A.5, §A.7
- `requirements_v0.2_appendix_B_ux.md` §B.4 (UI), §B.4.5 (カラートークン),
  §B.5.2 (6 層防御)
- ハーネス `CLAUDE.md`（参照のみ、改変禁止）
- ハーネス `AGENTS.md`（参照のみ、改変禁止）
- `docs/harness/FOUNDATION.md` Anchor 4 (cross-cutting docs の扱い)
