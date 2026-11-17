---
name: add-guardrails
description: >-
  Adds ESLint bans that remove judgment calls from agents in an existing
  Next.js App Router app: no effects, process.env only in the typed env module,
  features imported only through their public API, and no inline
  eslint-disable escapes.
disable-model-invocation: true
---

# add-guardrails

Mechanical checks instead of prose guidance. Every ban is an `error`, and inline `eslint-disable` comments are inert, so an agent cannot reason its way past one. Run it after `add-env`; it requires `lib/env.ts`.

Generation source of truth: [`scripts/init.sh`](scripts/init.sh) — the script writes every file; do not hand-write or restate the rules.

## Locked defaults

| Knob | Value |
| --- | --- |
| Packages | none — core ESLint rules on the existing `eslint-config-next` setup |
| Rules file | `eslint.guardrails.mjs`, spread last into `eslint.config.mjs` |
| Effects | `useEffect`, `useLayoutEffect`, `useInsertionEffect` banned — named imports and `React.*` / namespace access. No wrapper, no exemption |
| Env | `process.env` (incl. destructuring) banned outside `lib/env.ts` and root `*.config.*` |
| Features | `features/<name>/…` deep imports banned everywhere (alias or relative); relative imports may not leave their feature |
| Inline escape | `linterOptions.noInlineConfig: true` — `eslint-disable` comments do nothing |
| Ignored | `components/ui/**` (vendored shadcn) |
| Severity | `error` for every ban |
| AGENTS.md | appends a `## Guardrails` section when `AGENTS.md` exists |
| App code | untouched — existing violations are reported, never rewritten |

## Feature directories

Enforces the import side of [`../conventions/feature-directories.md`](../conventions/feature-directories.md): `index.ts` is a feature's only public entry. This skill does not scaffold `features/`.

## Steps

1. **Resolve target**
   - Default: current workspace root. Use another path only if the user named one.
   - Completion: absolute target path chosen.

2. **Self-hit guard**
   - Abort if the target is this skill package (`SKILL.md` with `name: add-guardrails`).
   - Completion: target is not the skill package.

3. **Compatibility guard**
   - Abort unless all hold:
     - `package.json` exists and lists `next` and `eslint`
     - `app/` or `src/app/` exists
     - `pnpm-lock.yaml` or packageManager pnpm — abort if `pnpm` missing on PATH
   - `scripts/init.sh` also aborts if `eslint.config.mjs` is missing or lacks the `export default eslintConfig;` line, `eslint.guardrails.mjs` exists, or `lib/env.ts` is missing (run `add-env` first).
   - Completion: compatible, uninitialized project.

4. **Generate**
   - Run this skill’s `scripts/init.sh` with the absolute target.
   - Completion: script exits 0.

5. **Verify artifacts**
   - `eslint.guardrails.mjs` exists.
   - `eslint.config.mjs` imports `./eslint.guardrails.mjs` and contains `eslintConfig.push(...guardrails);` directly above `export default eslintConfig;`.
   - If `AGENTS.md` exists, it contains `## Guardrails` exactly once.
   - Completion: all expected artifacts present.

6. **Lint check**
   - From the target: `pnpm lint`.
   - Errors from `no-restricted-imports`, `no-restricted-syntax`, or `no-restricted-properties` mean existing code violates a ban — that is the guardrail working. Report each file:line and rule, leave the tree as-is, stop. Do not rewrite the code, loosen the rules, or add ignores to force a pass.
   - Any other failure: leave the tree as-is, surface the error, stop. No rollback.
   - Completion: `pnpm lint` exits 0 with no errors.

7. **Report and stop**
   - Report only: target path; bans active (effects, `process.env`, feature imports, inline disables); `components/ui` ignored; `pnpm lint` passed.
   - Note: `pnpm build` does not run lint — enforcement happens only where `pnpm lint` runs.
   - Do not start `dev`, open a browser, commit, or deploy unless the user asks in the same turn.
   - Completion: minimal report delivered; no unsolicited follow-on.

## Ask only when blocked

Ask for a different path only when the default target fails a guard or the user already named another path that needs clarification.
