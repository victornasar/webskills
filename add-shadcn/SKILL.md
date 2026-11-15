---
name: add-shadcn
description: >-
  Adds shadcn/ui to an existing Next.js App Router + Tailwind app with locked
  defaults and a fixed set of core primitives, then smoke-builds.
disable-model-invocation: true
---

# add-shadcn

Post-`web-start` UI kit layer. Deterministic shadcn init + fixed primitives. No demos, no example pages, no per-run flag overrides.

Flag / component source of truth: [`scripts/init.sh`](scripts/init.sh) — do not restate or invent flags.

## Locked defaults

| Knob | Value |
| --- | --- |
| Init | `shadcn@latest init -d --base radix --css-variables --no-monorepo -y` |
| Style | `radix-nova` (CLI v4 default from `-d`) |
| Base color | `neutral` |
| CSS variables | yes |
| Color space | oklch (preset writes these into CSS) |
| RSC | yes |
| Alias | `@/` (`components`, `ui`, `lib`, `hooks`) |
| Components | `button` `input` `label` `card` `dialog` `dropdown-menu` `separator` `sonner` `skeleton` |
| Omitted | `form` — current registry is a no-op (no files) |

## Feature directories

Follow the kit convention: [`../conventions/feature-directories.md`](../conventions/feature-directories.md). This skill only populates `components/ui/` (+ `lib/utils`); it does not scaffold `features/`.

## Steps

1. **Resolve target**
   - Default: current workspace root. Use another path only if the user named one.
   - Completion: absolute target path chosen.

2. **Self-hit guard**
   - Abort if the target is this skill package (`SKILL.md` with `name: add-shadcn`).
   - Completion: target is not the skill package.

3. **Compatibility guard**
   - Abort unless all hold:
     - `package.json` exists and lists `next`
     - Tailwind is present (`tailwindcss` in `package.json`, or `app/globals.css` / `src/app/globals.css` imports Tailwind)
     - `app/` or `src/app/` exists
     - `pnpm-lock.yaml` or packageManager pnpm — prefer pnpm; abort if `pnpm` missing on PATH
   - Abort if `components.json` already exists (already initialized).
   - Completion: compatible, uninitialized project.

4. **Init + add primitives**
   - Run this skill’s `scripts/init.sh` with the absolute target (network required).
   - Completion: script exits 0.

5. **Toaster mount (sonner)**
   - If root layout (`app/layout.tsx` or `src/app/layout.tsx`) does not already render `Toaster` from `@/components/ui/sonner`, add a single `<Toaster />` in `<body>` and the matching import.
   - Do not change `page.tsx`. Do not add demo toasts or other layout chrome.
   - Completion: Toaster present once in root layout.

6. **Verify artifacts**
   - Confirm `components.json` exists.
   - Confirm each locked component file exists under `components/ui/` (or `src/components/ui/` if the project uses `src/`):
     `button`, `input`, `label`, `card`, `dialog`, `dropdown-menu`, `separator`, `sonner`, `skeleton` (each as `*.tsx`).
   - Confirm `lib/utils.ts` (or `src/lib/utils.ts`) exists.
   - Completion: all expected paths present.

7. **Smoke check**
   - From the target: `pnpm build`.
   - On failure: leave the tree as-is, surface the error, stop. No rollback.
   - Completion: `pnpm build` exits 0.

8. **Report and stop**
   - Report only: target path; shadcn initialized (`radix-nova` / `neutral`); components added; `pnpm build` passed.
   - Do not start `dev`, open a browser, commit, or deploy unless the user asks in the same turn.
   - Completion: minimal report delivered; no unsolicited follow-on.

## Ask only when blocked

Ask for a different path only when the default target fails a guard or the user already named another path that needs clarification.
