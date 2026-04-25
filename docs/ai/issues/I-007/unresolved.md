# Unresolved: I-007

## UQ-I007-01: Node / pnpm バージョンの指定方法

- 候補: (a) `.nvmrc` / `packageManager` 参照 / (b) workflow 内ハードコード
- 推奨: **(a)**（single source of truth、I-001 成果と整合）
- 要人間判断: **no**

## UQ-I007-02: Playwright ブラウザキャッシュ

- 推奨: `actions/cache` で `~/.cache/ms-playwright` を key キャッシュ
- 要人間判断: **no**

## UQ-I007-03: axe smoke テストの失敗基準

- 候補:
  - (a) violation 0 厳格
  - (b) `impact: serious|critical` のみ fail、moderate/minor は warning
- 推奨: **(b)**。Wave 4 の実画面タスクで (a) に強化
- 要人間判断: **yes**（A11y ゴール（WCAG 2.1 Level AA）との整合確認）

## UQ-I007-04: Vitest カバレッジ閾値

- 候補: 未設定 / 0 / 80
- 推奨: **未設定**。Wave 1 の core 実装タスクで 80 に引き上げ
- 要人間判断: **no**

## UQ-I007-05: CI matrix 範囲

- 候補: ubuntu-latest のみ / ubuntu + windows-latest
- 推奨: **ubuntu-latest のみ**（Windows は別途オペレータが手元で確認）
- 要人間判断: **yes**（Harness Anchor 7 の Windows first-class と衝突しないか確認）

## UQ-I007-06: ブランチ保護との紐付け

- 論点: 本タスクで `.github/` に CODEOWNERS / branch ruleset を置くか
- 推奨: **置かない**（GitHub repo 設定で別途実施、Anchor 5 と整合）
- 要人間判断: **no**

## UQ-I007-07: concurrency / cancel-in-progress の方針

- 推奨: PR には `concurrency: pr-${{ github.head_ref }}` + cancel-in-progress=true
  を設定
- 要人間判断: **no**

## 解消の期限

全 UQ は I-007 `ready-for-impl` 遷移時までに contract.md 反映。
