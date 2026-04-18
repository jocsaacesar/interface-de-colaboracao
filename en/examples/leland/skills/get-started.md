# /get-started — Onboarding (Example)

Simplified version of the `/get-started` skill used in Leland's collaboration interface.

## What it does

1. **Welcome** — Explains what will happen (~5 minutes).
2. **Interview** — Asks five questions, one at a time:
   - Who are you? (role, experience)
   - What are you building? (project, goals)
   - How do you like to work? (collaboration style)
   - What should the AI avoid? (anti-patterns)
   - Name and language? (AI identity, conversation language)
3. **Builds identity** — Generates a personalized CLAUDE.md. Shows for approval.
4. **Creates memory** — User profile, project context, preferences, language convention.
5. **Sets up workspace** — Creates folder structure and checks .gitignore.
6. **First greeting** — Loads everything and greets as the newly created AI, in character.

## Key design decisions

- **Conversation, not a form.** One question at a time. Reacts naturally to answers.
- **Shows before saving.** The generated CLAUDE.md is shown for approval before writing.
- **No forced template.** The personality is shaped by the user's answers, not copied from Leland.
- **Runs once.** After setup, the user works with `/start`, `/make-public`, and `/wrap-up`.

## Full implementation

See the actual skill at `.claude/skills/get-started/SKILL.md` in the main project.
