---
name: add-clerk
description: >-
  Adds Clerk authentication infrastructure to an existing Next.js App Router
  app via the official Clerk CLI (accountless keys, public-by-default proxy,
  in-app sign-in/sign-up routes), applies the shadcn theme when shadcn is
  present, then runs clerk doctor and a build smoke check.
disable-model-invocation: true
---

# add-clerk

Post-`init-next` (and optional `add-shadcn`) auth layer. Installs authentication **infrastructure**, not application features: no dashboard, no example pages, no header or user controls, no route protection, no roles. The official Clerk CLI owns the files; this skill owns guards, the shadcn theme hookup, and verification.

Flag source of truth: [`scripts/init.sh`](scripts/init.sh) — do not restate or invent flags.

## Locked defaults

| Knob | Value |
| --- | --- |
| Init | `clerk@latest init --framework next --pm pnpm --accountless --no-skills -y` |
| Credentials | Accountless temporary dev keys in `.env.local` (unclaimed app; claim later with `clerk auth login`) |
| Proxy | `proxy.ts` (Next 16+) / `middleware.ts` (Next ≤15), chosen by the CLI; bare `clerkMiddleware()` — every route public |
| Routes | `app/sign-in/[[...sign-in]]/page.tsx`, `app/sign-up/[[...sign-up]]/page.tsx` (CLI-generated, `<Suspense>`-wrapped) |
| Layout | `<ClerkProvider>` inside `<body>` only |
| Theme | Only if `components.json` exists: `@clerk/ui` + `shadcn` theme + `@clerk/ui/themes/shadcn.css` |
| Env vars | `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`, `CLERK_SECRET_KEY` (+ CLI sign-in/sign-up URL vars) — `.env.example` is not touched |

## Steps

1. **Resolve target**
   - Default: current workspace root. Use another path only if the user named one.
   - Completion: absolute target path chosen.

2. **Self-hit guard**
   - Abort if the target is this skill package (`SKILL.md` with `name: add-clerk`).
   - Completion: target is not the skill package.

3. **Compatibility guard**
   - Abort unless all hold:
     - `package.json` exists and lists `next`
     - `app/` or `src/app/` exists
     - `pnpm-lock.yaml` or packageManager pnpm — abort if `pnpm` missing on PATH
   - `scripts/init.sh` also aborts if `@clerk/nextjs` is already a dependency, or if a `proxy.ts` / `middleware.ts` already exists (root or `src/`).
   - Completion: compatible, uninitialized project.

4. **Init**
   - Run this skill’s `scripts/init.sh` with the absolute target (network required; creates one unclaimed Clerk application).
   - Completion: script exits 0.

5. **shadcn theme (only if `components.json` exists)**
   - In the root layout (`app/layout.tsx` or `src/app/layout.tsx`): add `import { shadcn } from "@clerk/ui/themes";` and change the existing `<ClerkProvider>` to `<ClerkProvider appearance={{ theme: shadcn }}>`.
   - In the global stylesheet (`app/globals.css` or `src/app/globals.css`): add `@import "@clerk/ui/themes/shadcn.css";` on the line directly after `@import "tailwindcss";`.
   - Touch nothing else. Do not edit the sign-in/sign-up pages; their `<Suspense>` boundaries are required by Cache Components.
   - Completion: theme prop and CSS import each present exactly once — or step skipped because `components.json` is absent.

6. **Verify artifacts**
   - `package.json` lists `@clerk/nextjs` (and `@clerk/ui` if `components.json` exists).
   - `proxy.ts` or `middleware.ts` exists and calls `clerkMiddleware()` with no `auth.protect()`.
   - Both sign-in and sign-up `page.tsx` files exist and render `<SignIn />` / `<SignUp />` inside `<Suspense>`.
   - Root layout renders `<ClerkProvider>` inside `<body>` and nothing else from Clerk (no `UserButton`, `SignInButton`, header).
   - `.gitignore` contains `.clerk/`.
   - Never print, read aloud, or copy values from `.env.local` or `.clerk/`.
   - Completion: all expected artifacts present.

7. **Doctor + smoke check**
   - From the target: `pnpm dlx clerk@latest doctor`, then `pnpm build`.
   - On any failure: leave the tree as-is, surface the error, stop. No rollback.
   - Completion: both exit 0.

8. **Report and stop**
   - Report only: target path; Clerk initialized on an unclaimed temporary app; `/sign-in` and `/sign-up` routes; all routes public (protect individually with `await auth.protect()`); shadcn theme applied or skipped; `doctor` + `pnpm build` passed; env var names (not values); claim the app with `pnpm dlx clerk@latest auth login`.
   - Mention once: the CLI keeps host state in `~/Library/Preferences/clerk-cli/` (macOS) — the only write outside the project.
   - Do not start `dev`, open a browser, commit, claim the app, or deploy unless the user asks in the same turn.
   - Completion: minimal report delivered; no unsolicited follow-on.

## Ask only when blocked

Ask for a different path only when the default target fails a guard or the user already named another path that needs clarification.
