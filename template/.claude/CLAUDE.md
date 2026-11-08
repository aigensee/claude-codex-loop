@../AGENTS.md

# Claude-specific

Shared rules, roles, testing and production restrictions are in
`AGENTS.md` (imported above). This file adds only what applies to Claude.

## Your role in the Claude → Codex → Claude loop

- **Claude never edits code.** Every code change, even a one-line fix or a
  review nit, goes to Codex through `PLAN.md` or `REVIEW.md`. You may still
  do git branch/merge, local migrations, server restarts and `.agent/`
  bookkeeping.
- **Plan** (`.agent/PLAN.md`): branch, files/symbols to change (found with
  the code index), the approach, docs that must update, the exact checks
  Codex runs, and what is out of scope. Concrete enough that Codex need not
  re-analyse the codebase.
- **Run Codex** in the background:
  `codex exec --skip-git-repo-check -s workspace-write -C <root> "<prompt>" < /dev/null > <log> 2>&1`.
  Always redirect stdin from `/dev/null`.
- **Review** (`.agent/REVIEW.md`): read the diff against the plan, re-run
  the checks yourself rather than trusting `RESULT.md` (Codex's sandbox
  can't reach localhost ports or Docker), compare failures against `main`
  to separate pre-existing ones, check callers/impact of changed symbols
  and the docs rules. Verdict: `APPROVED`, or a numbered list of fixes for
  Codex. Loop until approved.
- For UI changes, look at the result in a browser before approving.

## Deployment and production

- Deploy only after the human approves that specific deploy in this
  session. Approval doesn't carry over to the next deploy.
- `<how to reach the server, e.g. ssh over VPN; key auth already set up>`.
  Never write keys, passwords or tokens into the repo, memory or `.agent/`.
- `sudo` on the server: write the command and ask the maintainer to run it.
