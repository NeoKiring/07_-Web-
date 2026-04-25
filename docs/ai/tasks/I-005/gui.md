# GUI Validation: I-005

## Recipe path

`docs/ai/tasks/I-005/gui.md` (this file)

## Session name

`[I-005][gui][claude]`

## Lane identity

- task id: I-005
- lane: gui
- tool: Claude (default owner per CLAUDE.md GUI authority rule)
- writable: no (pinned commit、artifacts-only lane)
- target commit: pinned impl head commit from `status.yaml`

## Worktree

- path: `.worktrees/I-005__gui__<shortsha>`
- create command (Linux/mac):
  ```bash
  scripts/harness/new-inspection-worktree.sh I-005 gui <HEAD_COMMIT_SHA>
  ```
- create command (Windows):
  ```powershell
  pwsh scripts/harness/new-inspection-worktree.ps1 -TaskId I-005 -Lane gui -Commit <HEAD_COMMIT_SHA>
  ```

## Runtime allocation used

**Required**。impl lane と **別の** port / user-data を使う (GUI single-instance
制約のため impl lane が dev を走らせていない状態で gui lane を起動):

```bash
scripts/harness/alloc-runtime.sh I-005 gui
scripts/harness/gen-worktree-env.sh I-005 gui
# → .worktrees/I-005__gui__<shortsha>/.env.worktree.local 生成
#   APP_PORT, USER_DATA_DIR, LOG_DIR を含む
```

- impl lane が dev server を走らせていない状態で開始 (GUI single-instance)
- `.runtime/allocations.json` に lane=gui の allocation 記録

## Read first

- `docs/harness/FOUNDATION.md` (Anchor 3 runtime, Anchor 6 GUI)
- `docs/harness/policies/runtime-isolation.md`
- `AGENTS.md`, `CLAUDE.md` (§GUI validator behavior, §Claude GUI authority rule)
- `docs/ai/tasks/I-005/contract.md` §GUI verification
- `docs/ai/tasks/I-005/status.yaml`
- `docs/ai/tasks/I-005/handoff.md` (impl lane の結果)
- Appendix B §B.4.5 (カラートークン CSS 変数)、§B.4.6 (ダーク対応)

## Manual frontmost steps

### Pre-flight

1. impl lane が走っていないことを確認 (GUI single-instance)
2. worktree に cd、`.env.worktree.local` が存在、`APP_PORT` に有効値が
   入っていることを確認
3. `pnpm install` は skip (pinned commit の lockfile を使用、root から
   `pnpm install --frozen-lockfile` は一度実行が必要なら先に)

### Build & Start

4. `pnpm --filter web build` が 0 exit することを観測 (impl lane の結果と一致)
5. `pnpm --filter web start --port $APP_PORT` を起動
   - または `pnpm --filter web dev --port $APP_PORT` でも可 (build 結果の
     観測が目的なので dev でも成立)
6. ブラウザで `http://localhost:$APP_PORT` にアクセス

### Observation A: Placeholder rendering (Tailwind 適用確認)

7. placeholder ページ (I-004 で作った `<main>資産・収入インフレ影響可視化
   プラットフォーム (placeholder)</main>`) が表示される
8. Tailwind の base スタイルが適用されている
   (フォント / リセット CSS の痕跡、text-align 等の差異)
9. console error 無し (DevTools の Console タブ確認、赤エラー 0)
10. Network タブで `globals.css` が 200 OK

### Observation B: Light/Dark theme toggle (`defaultTheme="system"`)

11. DevTools の Elements で `<html>` タグの `class` 属性を観測
    - OS ライトモード時: `class` 属性無し または `class=""`
    - OS ダークモード時: `class="dark"`
12. OS のテーマを切替 (macOS: システム設定 > 外観、Windows: 設定 > 個人用設定 > 色)
13. ブラウザに戻り、`<html>` の class が **動的に変化**することを観測
    - ページリロード不要で切り替わる (`next-themes` の `enableSystem` 動作)
14. 背景色が light ⇔ dark で切り替わることを目視確認
    (`--background` CSS 変数 の light/dark 分岐動作)

### Observation C: CSS 変数による色解決 (UQ-I005-04 OKLCH + 参照のみ方針)

15. DevTools > Elements > `<html>` で `:root` を選択、Computed タブで以下を確認:
    - `--series-income` の Computed value が解決済みの色値 (実色値は
      OKLCH 関数が computed に残る環境もあるが、無効でないこと)
    - `--series-networth`, `--series-cpi` も同様
    - `--background`, `--foreground` が light 時と dark 時で異なる値
16. Elements タブで `<main>` を選択、background-color / color が `var(--...)`
    経由で解決されていることを確認 (hex 直接指定がないこと)

### Observation D: shadcn UI コンポーネントの存在確認

17. ファイル一覧確認 (shell で可): `ls apps/web/components/ui/ | wc -l` が
    24 以上
18. 主要コンポーネントのインポートが解決されることを CLI で確認:
    `pnpm --filter web typecheck` が 0 exit (Observation A の build で既に確認済み、
    重複確認として記録)

### Cleanup

19. dev server を停止 (Ctrl+C)
20. `scripts/harness/release-runtime.sh I-005 gui` (実装未提供なら
    `.runtime/allocations.json` から該当 allocation を手動で削除)

## Result

- PASS / FAIL / DEFERRED

### Record template (実行時に埋める)

- Observation A: (PASS / FAIL / notes)
- Observation B: (PASS / FAIL / notes — 特に OS 切替での class 変化)
- Observation C: (PASS / FAIL / notes — CSS 変数解決、ハードコード無し)
- Observation D: (PASS / FAIL / notes — 24 コンポーネントカウント)

### Screenshot (recommended)

- `gui_assets/I-005_light.png` (light モード、placeholder 描画)
- `gui_assets/I-005_dark.png` (dark モード、同じページ)
  (gui lane は writable でないため、screenshot は別途 impl lane か human が
  commit、または `docs/ai/tasks/I-005/gui.md` の末尾に base64 添付)

## Notes

- **本タスクは `may_be_deferred_by_human: no`** (contract.md GUI verification 参照)。
  Done condition に含まれるため defer 不可
- impl lane と gui lane の runtime allocation は別 port。`.runtime/allocations.json`
  に両方登録されるが、**同時起動はしない** (GUI single-instance)
- OS のテーマ切替で `<html>` class が変化しない場合:
  - `next-themes` の `attribute="class"` 設定確認 (theme-provider.tsx)
  - `suppressHydrationWarning` が `<html>` に付いているか確認 (layout.tsx)
  - いずれか未設定なら Must Fix (review lane で指摘、impl lane が修正)
- CSS 変数がハードコードで上書きされていた場合 (DevTools で直接 hex 値が出る):
  - Must Fix として review.md に記録 (項目 15)
- Claude は GUI lane の default owner だが、**最終 GUI 合格は human の判断**。
  `Result` 欄に `PASS (provisional, awaiting human confirmation)` と
  記録することは許容、完全 PASS は human acceptance 後

## Claude が実行する際の stop conditions

- impl lane が同時に dev server を走らせている (GUI lock 競合)
- OS のテーマ切替機能が使えない環境 (VM 等) → `DEFERRED` で human に委譲
- `APP_PORT` が allocation できない
- `pnpm --filter web build` が 0 exit しない (impl lane に差し戻し、
  review に `MUST-FIX` で記録)

停止時は `Result: FAIL` または `DEFERRED` として記録、`status.yaml` の
`gui_status` を `blocked` に変更して handoff.
