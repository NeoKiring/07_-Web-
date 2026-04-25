# Launch: I-008 impl

## Lane identity
- task id: I-008
- lane: impl
- tool: Codex
- writable: yes

## Branch / commit target
- implementation branch: `ai/docs/project/I-008-docs-project-supplement`
- target commit for inspection lanes: (to be set by impl after first commit)

## Worktree
- path: `.worktrees/I-008__impl`
- create command (Linux/mac):
  ```bash
  scripts/harness/new-impl-lane.sh I-008 docs/project docs-project-supplement main
  ```
- create command (Windows):
  ```powershell
  pwsh scripts/harness/new-impl-lane.ps1 -TaskId I-008 -Area docs/project -Slug docs-project-supplement -BaseBranch main
  ```

## Parallel execution note

**本タスクは Wave 0 内で唯一の並列可能タスク**。
- 起動条件: **I-001 merged のみ** (他 7 タスクの完了を待たない)
- 他 Wave 0 タスクの impl lane と **同時進行可能** (別 worktree なら衝突なし)
- 作業領域は `docs/ai/project/` のみ、serial-only 領域に触れない

## Session name
`[I-008][impl][codex]`

## Read first
- `docs/harness/FOUNDATION.md` (Anchor 1/4/8)
- `AGENTS.md`, `CODEX.md`
- **`CLAUDE.md` (ハーネス側、転記禁止の参照元、絶対に改変しない)**
- `docs/ai/tasks/I-008/contract.md` (finalized)
- `docs/ai/tasks/I-008/status.yaml`
- `docs/ai/tasks/I-001/handoff.md` (merged 後、root README.md の構造を確認)
- `docs/ai/plans/BATCH-WAVE0/uq-decisions.md` (グループ 9 全項目)
- 要件 v0.2 §15.6 (CLAUDE.md への転記要請の元文)
- Appendix A §A.2 (型規約、§2 要旨の参照元)
- Appendix B §B.4, §B.4.5, §B.4.6, §B.5.2 (UI + 6 層防御、§3-5 要旨の参照元)
- NFR-003, NFR-004, NFR-005, NFR-009 (§6 要旨の参照元)

## Start instruction

1. **前提確認**: I-001 merged 済みを `git log main` で確認、未 merge なら blocked
   - 他 7 タスクの完了を **待たない** (UQ-I008 / contract で parallel 確定)
2. impl worktree に cd、`status.yaml` を `state: in-progress` に更新
3. `docs/ai/project/` ディレクトリを作成 (`mkdir -p docs/ai/project/`)
4. `docs/ai/project/CLAUDE.project.md` を作成 (日本語、UQ-I008-02):
   
   以下 8 セクション構成。**本文転記禁止、参照のみ**:
   
   ### §1 プロジェクト要件の索引
   - `../../requirements_v0.2.md` (本要件定義) への相対リンク + 1-2 文要旨
   - Appendix A (技術実装) / B (UX + ガードレール) への相対リンク
   
   ### §2 型規約 (Appendix A §A.2 要旨 + 参照)
   - 見出しのみ: `Amount`, `YearMonth`, `CurrencyCode`, Branded Types、
     金額は `Decimal` のみ、`number` 禁止
   - **本文は Appendix A §A.2 を参照** (転記禁止)
   - リンク: `../../../requirements_v0.2_appendix_A_technical.md#A.2`
   
   ### §3 UI 採用ポリシー (Appendix B §B.4 要旨 + 参照)
   - 見出しのみ: 1 コンポーネント = 1 ライブラリ / shadcn プリミティブは
     `apps/web/components/ui/` / `packages/ui` はチャート共通のみ /
     Tremor は Card/Metric/BadgeDelta のみ
   - **本文は Appendix B §B.4 を参照**
   
   ### §4 カラートークン (Appendix B §B.4.5 要旨 + 参照)
   - CSS 変数名リスト (`--series-income`, `--series-networth`, `--series-cpi`)
   - OKLCH 表記、ハードコード禁止の **見出しのみ**
   - **実色値は書かない** (参照のみ)
   
   ### §5 ガードレール (Appendix B §B.5.2 6 層防御への索引)
   - **各層の名称のみ列挙**、本文再掲なし
   - リンクで Appendix B §B.5.2 へ誘導
   - 「層 1: ... / 層 2: ... / 層 3: ... / 層 4: ... / 層 5: ... / 層 6: ...」
     を 1 行ずつ名称のみ (6 行)
   
   ### §6 NFR 要旨
   - NFR-003: Phase A セキュリティ・pre-commit (I-006 で実装済)
   - NFR-004: `packages/core` UI/DB 非依存
   - NFR-005: AI 主体開発ガードレール
   - NFR-009: (該当項の要旨)
   
   ### §7 地雷マップ (MVP で確実に踏むもののみ、UQ-I008-04)
   - `localStorage` / `sessionStorage` を Artifact-like UI 実装で使わない
   - 金額に `number` を使わない (`Decimal` / `Amount` のみ)
   - CPI 未取得月は `null` を保つ (0 に fallback しない)
   - `Decimal × number` の四則演算を書かない
   - shadcn `<Card>` の中に Tremor `<Card>` を入れ子にしない
   - カラー値をハードコードしない (CSS 変数経由のみ)
   - `packages/core` から `@repo/db` / `@repo/ui` / `@repo/ingestion` に依存しない
   - (Wave X で追記予定) の TODO コメント
   
   ### §8 Wave 別読書ガイド (UQ-I008-05、Wave 0〜5、各 3-5 行 index)
   - Wave 0: 本文書 + `docs/harness/FOUNDATION.md` + AGENTS.md + 要件 §15.1-2
   - Wave 1: Appendix A §A.2 (型) + §A.5 + `packages/core` 系
   - Wave 2: 要件 §3-5 + Appendix A §A.1 (Prisma)
   - Wave 3: Appendix A §A.3 (API)
   - Wave 4: Appendix B §B.1-4 (UX + UI)
   - Wave 5: Phase B 関連 (Wave X で追記予定)

5. `docs/ai/project/README.md` を作成 (1 段落 + link):
   ```markdown
   # docs/ai/project/
   
   このディレクトリはプロジェクト固有の AI 向け supplement を格納します。
   ハーネス bundle の `CLAUDE.md` / `AGENTS.md` / `CODEX.md` を改変せず、
   本プロジェクト特有の型規約・UI 採用ポリシー・カラートークン・ガードレール
   を AI 実装レーンに伝達します。
   
   - [CLAUDE.project.md](./CLAUDE.project.md)
   ```

6. **Forbidden 厳守**:
   - ハーネス同梱ファイル (`CLAUDE.md`, `AGENTS.md`, `CODEX.md`,
     `docs/harness/**`, `.claude/**`, `.codex/**`, `.agents/**`,
     `scripts/harness/**`) 一切 touch しない
   - 要件定義本体 (`requirements_v0.2.md`, Appendix A, B) 一切 touch しない
   - root `README.md` を触らない (UQ-I008-03 (b) で別 follow-up タスク確定)
   - I-001〜I-007 の全成果物を触らない

7. contract.md の Verification commands 1〜12 を実行、全 PASS を確認:
   - 特に項目 10 (他タスク成果物の touch 無し) と 11 (docs/ai/project/ 配下のみ)
     を厳守

8. 変更を 1 commit にまとめる。コミットメッセージ:
   `docs(docs): add CLAUDE.project.md project-specific supplement (I-008)`

9. `status.yaml` を `state: implemented` に更新

10. `handoff.md` 記入:
    - ファイルパス `docs/ai/project/CLAUDE.project.md` 確定
    - 言語: 日本語
    - root README.md 導線追加を別 follow-up タスクに切り出した旨 (Wave 0 完走後
      に軽タスクとして提起)
    - 地雷マップ: MVP のみに絞った、Wave X で追記予定の TODO 位置
    - Wave 別読書ガイド: Wave 5 は「追記予定」コメント
    - 参照のみ方針を徹底 (6 層防御本文、型本文、カラー実値を転記していない)

## Stop conditions

- I-001 が merged でない
- ハーネス同梱ファイル (`CLAUDE.md` 等) を編集する必要が出た **→ 即 blocker**、
  Forbidden 違反の重大度高
- 要件定義本体 (`requirements_v0.2.md`, Appendix A/B) を編集する必要が出た
- 6 層防御の本文を書き始めた → stop (参照のみ方針)
- 型実装のコード例を書き始めた → stop (Wave 1 の仕事)
- カラー実値 (hex/rgb/hsl/oklch) を転記し始めた → stop
- root `README.md` を触りたくなった → stop (UQ-I008-03 (b))
- I-002〜I-007 の成果物を touch する必要が出た → stop
- role / stop conditions / tool ownership を書き始めた → stop (ハーネスの仕事)
- Codex / Copilot 向け supplement を書きたくなった → stop (Phase A 不要)
- Verification commands のいずれかが PASS しない、かつ 2 回の serious attempt
  でも解消できない

停止時は `handoff.md` を作成し `status.yaml` を `blocked` に更新、
Forbidden 違反の場合は diff を revert してから停止 (`git reset --hard HEAD~1`
を慎重に使う、別タスクの成果物に触れていないことを `git diff origin/main`
で事前確認)。
