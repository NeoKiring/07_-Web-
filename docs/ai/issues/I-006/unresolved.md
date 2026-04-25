# Unresolved: I-006

## UQ-I006-01: ESLint config の配置

- 候補:
  - (a) root `eslint.config.js` に全集約
  - (b) `packages/eslint-config/` 独立パッケージ
- 推奨: **(a)**（Wave 0 段階で過剰分離しない）
- 要人間判断: **yes**

## UQ-I006-02: Prettier の詳細設定

- 推奨: `{ printWidth: 100, semi: true, singleQuote: true, trailingComma: "all",
  arrowParens: "always" }`
- 要人間判断: **yes**

## UQ-I006-03: Conventional Commits の scope 一覧

- 推奨: `core`, `db`, `ingestion`, `ui`, `types`, `web`, `infra`, `docs`, `deps`
  （`core!:` で Draft PR を示唆、Appendix B §B.5.2 層 1）
- 要人間判断: **yes**

## UQ-I006-04: pre-commit での NFR-003 パターン検知方式

- 候補:
  - (a) shell grep で staged file name を検査
  - (b) lint-staged のカスタム関数
- 推奨: **(a)**（依存最小、bash 3 系でも動く）
- 要人間判断: **no**

## UQ-I006-05: `eslint-plugin-tailwindcss` の採否

- 候補: 採用 / 不採用
- 推奨: **不採用、Wave 4 で判断**（Tailwind v4 対応が不十分な版を入れて後で直す
  リスクを避ける）
- 要人間判断: **yes**

## UQ-I006-06: `no-number-for-amount` カスタムルールの実装

- 論点: Appendix A §A.5 のカスタムルールをどこまで実装するか
- 候補:
  - (a) 骨子のみ（TODO コメント）、Wave 1 で有効化
  - (b) 本タスクで完全実装
- 推奨: **(a)**（有効化すると I-001〜I-005 の既存コードが落ちる可能性を回避）
- 要人間判断: **yes**

## UQ-I006-07: typecheck の pre-commit 実行

- 論点: `pnpm -r typecheck` を pre-commit に含めるか
- 候補:
  - (a) 含めない（staged lint + format のみ、typecheck は CI で）
  - (b) 含める（重いが確実）
- 推奨: **(a)**（R-I006-03: 重すぎる hook は開発者が `--no-verify` する）
- 要人間判断: **no**

## 解消の期限

全 UQ は I-006 `ready-for-impl` 遷移時までに contract.md 反映。
UQ-I006-03（scope 一覧）は Wave 1 以降の PR タイトルに波及するため優先解消。
