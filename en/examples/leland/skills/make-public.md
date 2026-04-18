# /make-public — Publish Session Work (Example)

Simplified version of the `/make-public` skill used in Leland's collaboration interface.

## What it does

1. **Audits** — Identifies everything created or modified during the session.
2. **Classifies** — Separates files into: already public, personal with public value, personal without public value.
3. **Sanitizes** — Creates clean versions of valuable personal content (removes names, emails, identifiable info).
4. **Updates JOURNAL.md** — Adds decision entries from the session.
5. **Checks protection** — Confirms that .gitignore covers all personal folders.
6. **Reports and waits** — Shows what will be published. Does nothing until the user confirms.

## Key design decisions

- **Never commits on its own.** The user always sees and approves what goes public.
- **Privacy over completeness.** When in doubt, skip the file and ask.
- **Originals untouched.** Sanitized versions go to `examples/`, never overwrite the source.
- **Pedagogical value test.** If sanitizing destroys the lesson, the file is skipped entirely.
- **Complements, doesn't replace /wrap-up.** Publish first, then close the session.

## Full implementation

See the actual skill at `.claude/skills/make-public/SKILL.md` in the main project.
