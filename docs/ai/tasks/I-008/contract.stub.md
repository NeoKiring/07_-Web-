# Task Contract: I-008

本ファイルは **stub**。`dev-plan` で finalized へ昇格。
Verification commands / Touched files / Forbidden files は
v0.2 + Appendix A/B レビュー済み前提での推定記述。

## Identity
- task id: I-008
- title: project-specific supplement document (CLAUDE.project.md)
- area: docs/project
- slug: docs-project-supplement
- batch id: BATCH-WAVE0

## Objective

プロジェクト固有の AI 向け supplement `docs/ai/project/CLAUDE.project.md` を
作成し、要件 v0.2 §15.6 の「CLAUDE.md への転記」要請を、ハーネス CLAUDE.md を
改変せずに満たす橋渡しとする。

## Business / user value

Wave 1 以降の全 impl lane が、ハーネス CLAUDE.md + project supplement を
セットで参照することで、プロジェクト固有のガードレール（型規約 / カラートークン
/ 6 層防御 / 地雷マップ）に常時アクセスできる。

## In scope

- `docs/ai/project/CLAUDE.project.md` (new)
  - §1 プロジェクト要件の索引
  - §2 型規約（Appendix A §A.2 要旨 + 参照）
  - §3 UI 採用ポリシー（Appendix B §B.4 要旨 + 参照）
  - §4 カラートークン（Appendix B §B.4.5 CSS 変数）
  - §5 ガードレール（Appendix B §B.5.2 6 層防御への索引、本文再掲なし）
  - §6 NFR 要旨（NFR-003/004/005/009）
  - §7 地雷マップ（箇条書き、MVP で確実に踏むもののみ）
  - §8 Wave 別読書ガイド（Wave 0〜5、Wave 単位）
- `docs/ai/project/README.md` (new, 1 段落 + link)

## Out of scope

- ハーネス `CLAUDE.md` / `AGENTS.md` / `CODEX.md` の改変（Forbidden）
- `docs/harness/**` の改変
- 要件定義 v0.2 / Appendix A / B の改訂
- 実装・設定ファイルの変更
- root `README.md` の改訂（I-001 で作成済、追加導線は別タスクに切り出し）
- Codex / Copilot 向け supplement（Phase A では不要）
- Wave ごとの Issue 単位 supplement（task shaping 成果物が担う）
- 6 層防御の本文転記（参照のみ、二重管理回避）

## Touched files

- `docs/ai/project/CLAUDE.project.md` (new)
- `docs/ai/project/README.md` (new)

## Forbidden files

- `docs/harness/**` (**特に厳格**)
- `AGENTS.md`, `CLAUDE.md`, `CODEX.md` (repo root, ハーネス同梱)
- `.gtrconfig.v4`, `.claude/**`, `.codex/**`, `.agents/**`, `scripts/harness/**`
- `.runtime/**`, `.worktrees/**`
- `docs/ai/tasks/**`（self 除く）, `docs/ai/issues/**`（self 除く）, `docs/ai/plans/**`
- `requirements_v0.2.md`, `requirements_v0.2_appendix_A_technical.md`,
  `requirements_v0.2_appendix_B_ux.md`（要件定義本体、改変禁止）
- I-001 で作成した root ファイル（`pnpm-workspace.yaml`, `.gitignore`,
  `.nvmrc`, `.editorconfig`, `.env.example`, `package.json`, `README.md`）
- I-002〜I-007 の全成果物
- `apps/**`, `packages/**`, `tsconfig*.json`, `eslint.config.js`,
  `commitlint.config.js`, `lint-staged.config.js`, `.husky/**`,
  `.github/**`, `prisma/**`

## Serial-only areas touched
- no
- details:
  - 新規ディレクトリ `docs/ai/project/` 配下のみ
  - 既存 serial-only エリア（root manifest / lockfile / tsconfig.base.json /
    shared global settings / app bootstrap）に触れない
  - Wave 0 内で **唯一並列可能**なタスク。I-001 完了後、他 Wave 0 タスクと
    並列走行して良い

## Verification commands

```text
# 1. 必須ファイルの存在
test -f docs/ai/project/CLAUDE.project.md
test -f docs/ai/project/README.md

# 2. 必要セクション 8 点が揃っている
for sec in "要件" "型規約" "UI" "カラートークン" "ガードレール" "NFR" "地雷" "Wave"; do
  grep -qE "## .*$sec" docs/ai/project/CLAUDE.project.md || { echo "missing section keyword: $sec"; exit 1; }
done

# 3. 6 層防御の本文を転記していない（参照のみ）
# ヒューリスティック: Appendix B §B.5.2 の層名 6 点がすべて列挙されているのに
# 本文が 400 文字以上連続することを検知
awk '/層1|層2|層3|層4|層5|層6/{found=1} found{lines++} END{ if(lines>40) exit 1 }' docs/ai/project/CLAUDE.project.md

# 4. ハーネス CLAUDE.md からのコピペが無い（単純な完全一致検知）
# ハーネス文書と共通する特徴的な文言が大量に一致しないこと（planning 時に
# 具体パターンを決定、stub 段階ではプレースホルダー）
! grep -qF 'Anchor 1: Role separation' docs/ai/project/CLAUDE.project.md
! grep -qF 'Anchor 4: Serial-only' docs/ai/project/CLAUDE.project.md

# 5. 地雷マップに最低限の禁止項目
for keyword in localStorage number Decimal null 'packages/core' ハードコード; do
  grep -q "$keyword" docs/ai/project/CLAUDE.project.md || { echo "missing mine: $keyword"; exit 1; }
done

# 6. 相対パスでの索引
grep -qE 'requirements_v0\.2\.md' docs/ai/project/CLAUDE.project.md
grep -qE 'appendix_A' docs/ai/project/CLAUDE.project.md
grep -qE 'appendix_B' docs/ai/project/CLAUDE.project.md

# 7. ハーネス同梱ファイルに touch 無し
git diff --name-only HEAD~1 -- AGENTS.md CLAUDE.md CODEX.md docs/harness/ \
  .gtrconfig.v4 .claude/ .codex/ .agents/ scripts/harness/ | { ! grep -q .; }

# 8. I-001〜I-007 の成果物に touch 無し
git diff --name-only HEAD~1 -- apps/ packages/ tsconfig.base.json tsconfig.json \
  eslint.config.js .prettierrc .husky/ commitlint.config.js lint-staged.config.js \
  .github/ package.json pnpm-workspace.yaml pnpm-lock.yaml | { ! grep -q .; }

# 9. ハーネス artifact validator
scripts/harness/validate-task-artifacts.sh I-008
```

## GUI verification
- required: no
- recipe path: n/a
- final frontmost validation required: no

## Runtime isolation
- required: no
- notes: docs のみ。runtime 起動なし、allocations.json 登録不要

## Done definition

- Verification 1〜9 全 PASS
- `scripts/harness/validate-task-artifacts` が I-008 に対して PASS
- `status.yaml` state `implemented` 以上
- `handoff.md` に以下記録:
  - ファイルパス（UQ-I008-01 最終値）
  - 言語方針（UQ-I008-02）
  - root README.md への導線追加を別タスクに切り出した旨（UQ-I008-03）
  - 地雷マップのスコープ（UQ-I008-04）
  - Wave 1 以降に追記すべき候補（TODO として次タスクへ引き継ぐ）
- `review.md` verdict `PASS` / `PASS-WITH-NOTES`、Must Fix 解消
- Forbidden files に touch 無し（特にハーネス同梱ファイル）

## Blocked if

- I-001 が `merged` 未到達（最小前提として root README / .gitignore 等の
  path 運用が確定しているべき）
- UQ-I008-01（ファイルパス）が未決
- 本タスクで `CLAUDE.md` を上書きする必要があるとの判断が出た
  （Forbidden 違反、即 blocker）

## Review focus

- **Forbidden 遵守**: ハーネス同梱ファイル / 要件定義本体 / 他タスク成果物に
  touch が無いこと（Verification 項目 7, 8）
- **参照のみ方針**: 6 層防御の本文が転記されていないこと（項目 3）
- **地雷マップの実効性**: 項目 5 の keyword すべて含まれているか、文脈が
  Wave 1 以降の impl lane に通じる具体性か
- **セクション網羅性**: §1〜§8 相当の内容がすべて存在（項目 2）

## Merge order
- before: (none) — 並列タスク
- after: I-001（最小前提）
- notes:
  - I-002〜I-007 の完了を待たない
  - I-001 merge 後に並列レーンで走行可能
  - Wave 0 全体の完了要件としては他 7 タスクと同等

## Notes for implementer
- writable lane is `impl` only（docs のみだが手続きは通す）
- tool ownership: default = Codex（impl）/ Claude（review）
- ハーネス CLAUDE.md から転記したくなったら stop（参照のみ）
- 6 層防御の本文を書き始めたら stop（Appendix B §B.5.2 への参照で済ませる）
- role / stop conditions / tool ownership を書き始めたら stop（ハーネスの仕事）
- 「Wave X で追記予定」コメントは許容（TODO 管理として）
