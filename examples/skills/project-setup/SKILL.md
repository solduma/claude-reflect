---
name: project-setup
description: The user's conventions for scaffolding and configuring a code project — package managers (uv for Python, pnpm for Node; never pip/poetry/conda/npm/yarn), .env/APP_ENV configuration rules, the pre-commit hook, and the canonical ruff / ESLint / pytest configs. Invoke when creating a new project, adding linters/formatters, wiring env config, setting up the pre-commit hook, or writing tests. Not needed for routine edits to an already-configured project.
---

# Project Setup Conventions

## Package management

| Env | Use | Forbidden |
|---|---|---|
| Python | `uv` | `pip`, `poetry`, `conda` |
| Node.js | `pnpm`, `pnpx` | `npm`, `yarn`, `npx` |

## Configuration & secrets

- `APP_ENV=dev` (default) or `APP_ENV=prod` selects `.env.{APP_ENV}` at startup.
- `.env.dev` — tracked in git (no secrets); `.env.prod` — gitignored.
- `.env.example` — key names only, always tracked. `.gitignore` must include `.env*` **except** `.env*.example`.
- Never hardcode secrets, API keys, or passwords — always use env vars.
- **Never branch on `APP_ENV` in code** — read config values instead.

## Pre-commit hook

Activate once per clone: `make hooks` or `git config core.hooksPath .githooks`.

| Staged path | Checks |
|---|---|
| `api/` | `ruff check` + `lint-imports` |
| `web/` | `pnpm lint` (eslint) + `tsc --noEmit` |

Formatting is not enforced by the hook — run `make fmt` manually. Bypass with `--no-verify` only as a last resort.

## ruff (`pyproject.toml`)

```toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E","W","F","I","B","C4","UP","SIM","RUF"]
ignore = ["E501","B008"]

[tool.ruff.lint.isort]
known-first-party = ["app"]
```

## ESLint (`eslint.config.js`)

```js
import js from "@eslint/js";
import tseslint from "typescript-eslint";

export default tseslint.config(
  js.configs.recommended,
  ...tseslint.configs.recommendedTypeChecked,
  {
    rules: {
      "no-console": ["warn", { allow: ["warn", "error"] }],
      "prefer-const": "error",
      "eqeqeq": ["error", "always"],
      "no-var": "error",
      "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
      "@typescript-eslint/no-explicit-any": "warn",
      "@typescript-eslint/consistent-type-imports": "error",
      "@typescript-eslint/no-floating-promises": "error",
      "@typescript-eslint/no-misused-promises": "error",
    },
  }
);
```

## Testing

**Frameworks**: Python → `pytest` / Node.js → `vitest`.

### Priority

| Priority | Scope | Target |
|---|---|---|
| P1 — Unit | Core business logic, pure functions | >90% coverage |
| P2 — Integration/E2E | Major feature happy paths | ≥1 per feature |
| P3 — Regression | Write a reproducing test before fixing any reported bug | — |

**Do not test**: simple getters/setters, UI layout pixels, third-party library internals.

### Strategy

- **Testing Pyramid**: many unit → moderate integration → minimal E2E.
- **Test behavior, not implementation**: assert inputs/outputs only — not internal structure — so refactors don't break tests.

### AAA pattern

```ts
test('should deduct mileage when user spends points', () => {
  const user = { mileage: 5000 };               // Arrange
  const updated = useMileage(user, 2000);        // Act
  expect(updated.mileage).toBe(3000);            // Assert
});
```
