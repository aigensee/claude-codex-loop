# <Project name> — shared agent rules

Read by every agent (Claude, Codex). Claude-only additions live in
`.claude/CLAUDE.md`. Keep this file short: facts belong in the repo's docs.

## Repo map

| Path | What it is | Read first |
|---|---|---|
| `<app>/` | <one line> | `<docs/README.md>` |

## Shared rules

- Reply in the language the maintainer writes in.
- Unknown intent: write `[NEEDS INPUT: <question>]` and add it to
  `docs/open-questions.md`; never invent a rationale. Check ADRs in
  `<docs/decisions/>` first.
- A change to a route, env var, business rule or decision updates its doc
  in the same change.
- Never write secrets (keys, passwords, tokens, `.env` values) into code,
  docs, commits, handoff files or logs.

## Roles

| Agent | Does | Never |
|---|---|---|
| **Claude** | Task analysis, architecture, implementation plan, code review, deployment and production operations | Edit code itself (see `.claude/CLAUDE.md`) |
| **Codex** | Implementation, bug fixes, targeted automated tests, within the approved plan | Deploy, touch servers or production data, commit or push to `main` (work on the branch named in `PLAN.md`), change scope without asking |

Handoff files (one task at a time): `.agent/TASK.md` → `PLAN.md` (Claude)
→ `RESULT.md` (Codex) → `REVIEW.md` (Claude). Each file's header says what
goes in it. When a task is approved, move the four files to
`.agent/<task-slug>/`.

## Exploring code

1. Use the code index first if there is one (`<codegraph / LSP / ctags>`)
   for symbols, callers, impact and affected tests.
2. Open source files only after narrowing the area. Grep is for literals
   (strings, config keys, SQL, docs).
3. Git history only when current code and docs don't explain the intent.

## Testing

Run the checks for every part you changed, and report the real output.

| Part | Checks |
|---|---|
| `<backend>` | `<go build ./... && go vet ./... && go test ./...>` |
| `<frontend>` | `<npm run lint && npx tsc --noEmit && npm run build>` |

Add targeted tests for the code you changed. Don't rewrite unrelated tests.
Tests never call real paid providers — use mocks.

## Production restrictions

- **Only the human approves a deploy**, every time. Claude carries it out;
  Codex never deploys.
- `<A push to main deploys X>` — so pushing to `main` counts as deploying.
- Don't run migrations, seeds or write scripts against production
  databases. `<list env files that point at prod>`
- Real paid provider calls and real payments: estimate the cost and get
  the maintainer's go-ahead first.
- Deploy procedure: `<docs/operations.md>`.
