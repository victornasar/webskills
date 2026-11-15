# AGENTS

This repository is a **skill kit**, not an application. Host agents (Cursor, Claude Code, Codex, Windsurf, etc.) load the packages under this tree and follow their `SKILL.md` process.

## Read first

| Doc | When |
| --- | --- |
| [README.md](README.md) | Overview, philosophy, install, pipeline |
| [conventions/feature-directories.md](conventions/feature-directories.md) | Preferred app layout after init |

## Skills (run explicitly)

| Skill | Path | Job |
| --- | --- | --- |
| `web-start` | [web-start/SKILL.md](web-start/SKILL.md) | Greenfield empty Next.js App Router baseline |
| `add-shadcn` | [add-shadcn/SKILL.md](add-shadcn/SKILL.md) | Locked shadcn/ui + core primitives on an existing app |
| `init-readme` | [init-readme/SKILL.md](init-readme/SKILL.md) | Minimal project README + light AGENTS.md Project blurb |

Each skill is **user-invoked** (`disable-model-invocation: true`). Do not auto-run them. Flag sources of truth live in each skill’s `scripts/` when present — do not invent flags.

## Kit rules

- Do not scaffold apps into this kit directory (self-hit guards in each skill).
- Do not merge these skills into one mega-process unless the human asks.
- Failures: leave the target tree as-is; surface the error; stop.
- Success: minimal report, then stop — no unsolicited `dev`, browser, commit, or deploy.
