---
name: make-public
description: Sanitizes and publishes session work to public folders. Protects personal data, updates examples and journal. Manual trigger only.
---

# /make-public — Publish session work

Takes what was created or modified during the session, separates personal from public, sanitizes sensitive content, and prepares it for the public repository.

## When to use

- **ONLY** when the user explicitly types `/make-public`.
- Normally run near the end of the session, after the work is done but before `/wrap-up`.
- Never trigger automatically.

## Process

### Phase 1 — Audit changes

Identify everything that changed during the current session:

1. Check `memory/` for new or updated memory files.
2. Check `exchange/outbox/` for new deliverables.
3. Check `guides/` for new or updated guides.
4. Check `templates/` for new or updated templates.
5. Check `.claude/skills/` for new or updated skills.
6. Check `CLAUDE.md` for structural changes.
7. Check `JOURNAL.md` for new entries.

Build a list of all changed files, categorized as:
- **Already public** — guides/, templates/, examples/, JOURNAL.md, README.md, CONTRIBUTING.md
- **Personal — with public value** — memory files, skills, deliverables that teach something
- **Personal — no public value** — user configs, drafts, temporary items

### Phase 2 — Sanitize personal content

For each file marked as "personal — with public value":

1. **Memory files** -> Create sanitized version in `examples/`:
   - Remove the user's real name — replace with generic terms ("the user", "the project owner").
   - Remove specific external references (company names, URLs, credentials).
   - Keep the structure, type, and lesson intact — the format IS the teaching.
   - Preserve the **Why** and **How to apply** sections — they're the most valuable parts.

2. **Skill files** -> Create simplified description in `examples/`:
   - Don't copy the complete SKILL.md (that's the real implementation).
   - Write a summary: what it does, key design decisions, where to find the real version.

3. **Exchange deliverables** -> Evaluate case by case:
   - Study plans, frameworks, models -> sanitize and add to `examples/` or `guides/`.
   - Personal drafts, one-off responses -> skip.

### Sanitization rules

These rules are **non-negotiable**:

- **Never publish the user's real name.** Use "the user" or "the project owner".
- **Never publish email addresses, company names, or URLs** that identify the user.
- **Never publish raw conversation excerpts.** Reframe insights as lessons.
- **Never publish financial, health, or credential information.**
- **When in doubt, don't publish.** Ask the user.
- **Preserve pedagogical value.** The goal of sanitization is to protect privacy while keeping the lesson. If sanitizing destroys the lesson, skip the file or ask how to handle it.

### Phase 3 — Update JOURNAL.md

Review the session for decisions worth documenting:

1. Read the current `JOURNAL.md`.
2. Identify decisions made during this session that aren't yet recorded.
3. For each new decision, write an entry following the format:
   - **What we decided** — the decision itself.
   - **Why** — the motivation or constraint.
   - **What we learned** — the insight or principle.
4. Add entries at the top of the journal (most recent first, below the header).
5. Record only **decisions and insights**, not activity. "We created 5 files" is not a journal entry. "We chose decision-based logging over daily logs because X" is.

### Phase 4 — Update examples/README.md

If new example files were added:

1. Read `examples/README.md`.
2. Update the structure section to reflect new files.
3. Update descriptions if new patterns are demonstrated.

### Phase 5 — Verify protection

Before presenting results to the user:

1. Read `.gitignore` and confirm it covers:
   - `memory/` (memory files)
   - `exchange/` (personal file exchange)
   - `.claude/settings.local.json` (local config)
2. If any new personal folder was created during the session that isn't covered, **add it to .gitignore**.
3. Do a mental check: "If someone clones this repo right now, can they discover anything about the user's real identity?" If so, something was missed.

### Phase 6 — Report and confirm

Present a clear summary to the user:

```
## Ready to publish

### New/updated public files:
- [list of files that will be visible in the repo]

### Sanitized from personal:
- [original file] -> [sanitized destination]

### Skipped (personal, no public value):
- [files that weren't published and why]

### Protection verified:
- .gitignore covers: [list]

Confirm to proceed?
```

**DO NOT commit or stage anything until the user confirms.**

After confirmation:
- Stage only the public files.
- DO NOT stage anything in memory/, exchange/, or .claude/settings.local.json.
- Suggest a commit message that describes what was published.

## Rules

- **Never auto-commit.** Always wait for explicit user confirmation.
- **Never publish personal data.** When in doubt, skip and ask.
- **Never modify the original files.** Sanitized versions go to `examples/`, never overwrite the originals.
- **Never sanitize by just deleting content.** If removing personal info makes the file useless, skip it entirely.
- **The user has the final word.** If they say "don't publish this", don't insist.
- **Keep the journal honest.** Don't inflate decisions. If nothing worth recording happened, say so.
- **This skill complements /wrap-up, it doesn't replace it.** Run this first to publish, then /wrap-up to close the session.
