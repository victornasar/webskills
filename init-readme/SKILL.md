---
name: init-readme
description: >-
  Writes a short high-signal README.md for a Next.js app and lightly updates
  AGENTS.md with a Project blurb when present.
disable-model-invocation: true
---

# init-readme

Post-init project brief. Minimal README + light AGENTS.md Project section. No badges, no emoji (unless the user asks), no long essays.

## Feature directories

Single source of truth: [`../conventions/feature-directories.md`](../conventions/feature-directories.md). Document that layout in the README; do not scaffold empty `features/` folders unless the user asks.

## Steps

1. **Resolve target**
   - Default: current workspace root. Use another path only if the user named one.
   - Completion: absolute target path chosen.

2. **Self-hit guard**
   - Abort if the target is this skill package (`SKILL.md` with `name: init-readme`).
   - Completion: target is not the skill package.

3. **Project guard**
   - Abort if `package.json` is missing.
   - Completion: `package.json` present.

4. **Collect inputs**
   - **Name**: use if already provided; else default to `package.json` `name`, else folder basename. Ask only if still unclear.
   - **One-sentence description**: required. Ask if not already provided in the request.
   - **Extra tech** (optional): e.g. “Drizzle + Postgres”. Ask only if the user hinted at stack add-ons without naming them; otherwise omit or use what they already stated.
   - **Detect baseline tech** from the tree (do not ask):
     - Always assume Next.js App Router + TypeScript + Tailwind + pnpm when those files/deps are present.
     - Include **shadcn/ui** in the stack line iff `components.json` exists.
   - Completion: name + one-sentence description in hand; optional extra tech resolved.

5. **README overwrite policy**
   - If `README.md` is missing → write.
   - If `README.md` looks like the stock create-next-app README (e.g. mentions “create-next-app” / “Getting Started” with deploy boilerplate) → replace.
   - If `README.md` looks customized or detailed → ask before overwriting; abort if the user declines.
   - Completion: permission to write established.

6. **Write `README.md`**
   - Contents only:
     1. `# <name>`
     2. One-sentence description (paragraph).
     3. `## Stack` — short bullet or comma list: Next.js App Router, TypeScript, Tailwind CSS, pnpm; add shadcn/ui if detected; append any optional extra tech.
     4. `## Getting started` — `pnpm install`, `pnpm dev`, `pnpm build` (fenced shell block).
     5. `## Project structure` — brief note from [`../conventions/feature-directories.md`](../conventions/feature-directories.md): thin `app/`, domain in `features/<name>/`, primitives in `components/ui`, shared non-UI in `lib/`. Short fenced tree OK; no essay.
   - Nothing else: no badges, no license section, no emoji unless requested.
   - Completion: `README.md` written.

7. **Update `AGENTS.md` (if present)**
   - If `AGENTS.md` exists, add or replace a short `## Project` section containing the one-sentence description (and optionally the project name). Keep the rest of the file intact.
   - If `AGENTS.md` is missing, skip (do not create one here).
   - Completion: `AGENTS.md` updated or correctly skipped.

8. **Report and stop**
   - Report only: target path; `README.md` written; whether `AGENTS.md` was updated.
   - Do not commit, open editors beyond the write, or start follow-on skills unless asked.
   - Completion: minimal report delivered; no unsolicited follow-on.

## Ask only when needed

Ask for description (always if missing), overwrite confirmation (custom README), or path clarification. Prefer defaults for the project name.
