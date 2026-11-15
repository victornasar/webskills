---
name: add-env
description: >-
  Adds build-time environment variable validation to an existing Next.js App
  Router app with @t3-oss/env-nextjs + zod, adopting the variable names already
  present in .env* files, and writes a committed .env.example.
disable-model-invocation: true
---

# add-env

Standalone env-validation layer for any `init-next`-style app, with or without Clerk. Installs env **infrastructure**: a typed `lib/env.ts`, build-time validation, and a names-only `.env.example`. Adopts variables other skills already wrote (e.g. `add-clerk`’s `.env.local`); run it after them.

Generation source of truth: [`scripts/init.sh`](scripts/init.sh) — the script writes every file; do not hand-write or restate the template.

## Locked defaults

| Knob | Value |
| --- | --- |
| Packages | `@t3-oss/env-nextjs` + `zod` |
| File | `lib/env.ts` (`src/lib/env.ts` when the project uses `src/`) |
| Discovery | Names only from `.env` and `.env.*` (not `.env.example`, not `.envrc`), dotenv line grammar, deduped + sorted |
| Schema | Every name → `z.string().min(1)`; `NEXT_PUBLIC_*` → `client`, all else → `server` |
| Build validation | `next.config.ts` first line: `import "./lib/env";` |
| Escape hatch | `skipValidation: !!process.env.SKIP_ENV_VALIDATION` |
| Empty values | `emptyStringAsUndefined: true` — `KEY=` counts as missing |
| `.env.example` | Each name with an empty value; `!.env.example` appended to `.gitignore` so it is tracked |
| No variables | Full setup anyway: empty `server` / `client` / `runtimeEnv`, empty `.env.example` |
| App code | Untouched — existing `process.env.X` reads stay as they are |

## Steps

1. **Resolve target**
   - Default: current workspace root. Use another path only if the user named one.
   - Completion: absolute target path chosen.

2. **Self-hit guard**
   - Abort if the target is this skill package (`SKILL.md` with `name: add-env`).
   - Completion: target is not the skill package.

3. **Compatibility guard**
   - Abort unless all hold:
     - `package.json` exists and lists `next`
     - `app/` or `src/app/` exists
     - `pnpm-lock.yaml` or packageManager pnpm — abort if `pnpm` missing on PATH
   - `scripts/init.sh` also aborts if `next.config.ts` is missing, `@t3-oss/env-nextjs` is already a dependency, `lib/env.ts` exists, or `.env.example` exists (never overwritten).
   - Completion: compatible, uninitialized project.

4. **Generate**
   - Run this skill’s `scripts/init.sh` with the absolute target (network required).
   - Do not open, print, or copy `.env*` files yourself — the script reads names only and never outputs values.
   - Completion: script exits 0 and prints the server/client counts.

5. **Verify artifacts**
   - `package.json` lists `@t3-oss/env-nextjs` and `zod`.
   - `lib/env.ts` exists; its names match `.env.example` exactly.
   - `next.config.ts` first line imports `./lib/env` (or `./src/lib/env`).
   - `.gitignore` contains `!.env.example`, and `git check-ignore .env.example` reports nothing.
   - Completion: all expected artifacts present.

6. **Smoke check**
   - From the target: `pnpm build`.
   - A failure listing `Invalid environment variables` means an adopted variable is empty or missing in this environment — that is validation working. Report the variable names, leave the tree as-is, stop. Do not delete schema entries or set `SKIP_ENV_VALIDATION` to force a pass.
   - Any other failure: leave the tree as-is, surface the error, stop. No rollback.
   - Completion: `pnpm build` exits 0.

7. **Lint check**
   - From the target: `pnpm lint`.
   - Completion: no errors from `lib/env.ts` or `next.config.ts`.

8. **Report and stop**
   - Report only: target path; `lib/env.ts` with N server / M client names; `.env.example` tracked; build validation on (`SKIP_ENV_VALIDATION=1` to bypass, e.g. Docker/CI without secrets); `pnpm build` passed. Names may be listed; values never.
   - Note: new variables go in three places — `lib/env.ts` schema, `runtimeEnv`, `.env.example`. Tighten types (URLs, enums) by hand.
   - Do not start `dev`, open a browser, commit, or deploy unless the user asks in the same turn.
   - Completion: minimal report delivered; no unsolicited follow-on.

## Ask only when blocked

Ask for a different path only when the default target fails a guard or the user already named another path that needs clarification.
