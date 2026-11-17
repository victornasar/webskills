---
name: add-seo
description: >-
  Adds SEO plumbing to an existing Next.js App Router app with Next.js
  built-ins only: NEXT_PUBLIC_SITE_URL in add-env's lib/env.ts, a lib/site.ts
  config, root metadata, sitemap, robots, and an Open Graph image. Writes no
  marketing copy; values to fill in are marked TODO(seo).
disable-model-invocation: true
---

# add-seo

SEO **mechanisms**, not content. Every project-specific value lives in one file, `lib/site.ts`, and anything the developer (or their agent) must write is a `TODO(seo)` placeholder. Run it after `add-env`, which it requires, and before `add-guardrails`.

Generation source of truth: [`scripts/init.sh`](scripts/init.sh). The script writes every file. Do not hand-write or restate the templates.

## Locked defaults

| Knob | Value |
| --- | --- |
| Packages | none: `metadata`, `sitemap.ts`, `robots.ts`, `opengraph-image.tsx`, `next/og` |
| Site URL | `NEXT_PUBLIC_SITE_URL: z.url()` in `lib/env.ts` `client` + `runtimeEnv`; `.env.example` gets `NEXT_PUBLIC_SITE_URL=`, `.env.local` gets `http://localhost:3000`. Skipped if already declared |
| Config | `lib/site.ts`: `name` (from `package.json`), `description` (`TODO(seo)` placeholder), `url` (env, localhost fallback for `SKIP_ENV_VALIDATION` builds), `routes` (`["/"]`) |
| Root metadata | `metadataBase`, title template `%s \| name`, description, `openGraph.siteName` + `type`. **No** canonical or `og:url`: Next.js would inherit them on every page |
| Sitemap | maps over `site.routes`; no filesystem scan |
| Robots | allow all, points at `/sitemap.xml` |
| OG image | 1200×630, `site.name` centred on a plain dark background |
| AGENTS.md | appends a `## SEO` section when `AGENTS.md` exists: where values live, `TODO(seo)`, routes, per-page canonicals |
| Existing config | replaces only the untouched `create-next-app` metadata; anything customized aborts. Never merges |
| Out of scope | JSON-LD, keywords, per-page metadata, `llms.txt`, AEO/GEO/SXO, Vercel-specific URLs |

## Steps

1. **Resolve target**
   - Default: current workspace root. Use another path only if the user named one.
   - Completion: absolute target path chosen.

2. **Self-hit guard**
   - Abort if the target is this skill package (`SKILL.md` with `name: add-seo`).
   - Completion: target is not the skill package.

3. **Compatibility guard**
   - Abort unless all hold:
     - `package.json` exists and lists `next`
     - `app/` or `src/app/` exists
     - `pnpm-lock.yaml` or packageManager pnpm. Abort if `pnpm` missing on PATH
   - `scripts/init.sh` also aborts, before writing anything, if: `lib/site.ts` exists (already initialized), `add-env` has not run, `next.config.ts` does not import the env module, `sitemap.*` / `robots.*` / `opengraph-image.*` already exist in `app/`, root `metadata` / `generateMetadata` is customized, or `lib/env.ts` is not in the shape `add-env` generates.
   - Completion: compatible, uninitialized project.

4. **Generate**
   - Run this skill’s `scripts/init.sh` with the absolute target. It takes no other input.
   - Do not open, print, or copy `.env*` files yourself.
   - Completion: script exits 0.

5. **Verify artifacts**
   - `lib/site.ts`, `app/sitemap.ts`, `app/robots.ts`, `app/opengraph-image.tsx` exist.
   - `app/layout.tsx` imports `site` from `@/lib/site` and sets `metadataBase`.
   - `lib/env.ts` declares `NEXT_PUBLIC_SITE_URL` in `client` and `runtimeEnv`.
   - If `AGENTS.md` exists, it contains `## SEO` exactly once.
   - Completion: all expected artifacts present.

6. **Smoke check**
   - From the target: `pnpm build`.
   - A failure listing `Invalid environment variables` means a variable is missing or invalid in this environment. That is validation working. Report the names, leave the tree as-is, stop.
   - Any other failure: leave the tree as-is, surface the error, stop. No rollback.
   - Completion: `pnpm build` exits 0.

7. **Lint check**
   - From the target: `pnpm lint`.
   - Completion: no errors from the generated files.

8. **Report and stop**
   - Report only: target path; files written; `pnpm build` passed.
   - Note: replace `TODO(seo)` in `lib/site.ts`; set `NEXT_PUBLIC_SITE_URL` to the production URL in production; add public routes to `site.routes`; give each page its own `alternates.canonical`.
   - Do not write the description or other copy for the user. Do not start `dev`, open a browser, commit, or deploy unless the user asks in the same turn.
   - Completion: minimal report delivered; no unsolicited follow-on.

## Ask only when blocked

Ask for a different path only when the default target fails a guard or the user already named another path that needs clarification.
