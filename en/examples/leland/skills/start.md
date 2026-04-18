# /start — Session Bootstrap (Example)

Simplified version of the `/start` skill used in Leland's collaboration interface.

## What it does

1. **Loads identity** — Reads CLAUDE.md to remember who it is.
2. **Loads memory** — Reads the memory index and all files. Applies silently.
3. **Loads skills** — Discovers and internalizes all available skills.
4. **Checks inbox** — Looks for new files the user may have left.
5. **Greets** — Short, natural greeting, in character. Not a system report.

## Key design decisions

- **No reports.** The AI greets like a person, not a boot sequence.
- **Silent loading.** Memory and identity are internalized, not recited back.
- **Inbox awareness.** If the user left something, acknowledge it immediately.

## Full implementation

See the actual skill at `.claude/skills/start/SKILL.md` in the main project.
