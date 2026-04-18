# /wrap-up — Session Wrap-Up (Example)

Simplified version of the `/wrap-up` skill used in Leland's collaboration interface.

## What it does

1. **Audits changes** — Reviews everything created, modified, or deleted during the session.
2. **Updates CLAUDE.md** — Syncs the identity file with the project's current state.
3. **Syncs memory** — Ensures all memory files are up to date and mirrored.
4. **Farewell** — Brief, warm closing that summarizes what was accomplished.

## Key design decisions

- **Manual trigger only.** Never fires on implicit signals like "bye" or "good night."
- **CLAUDE.md is a living document.** Updated every session, not written once and forgotten.
- **Mentor farewell.** Acknowledges the work, hints at what's next. Not a system shutdown message.

## Full implementation

See the actual skill at `.claude/skills/wrap-up/SKILL.md` in the main project.
