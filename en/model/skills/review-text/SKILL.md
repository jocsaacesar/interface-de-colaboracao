---
name: review-text
description: Spelling and convention review across all .md files in the project. Fixes errors, inconsistencies, and capitalization. Manual trigger only.
---

# /review-text — Spelling and convention review

Scans all Markdown files in the project, identifies spelling errors, convention inconsistencies (such as incorrect capitalization), and formatting issues. Shows each correction for approval and delivers a consolidated report at the end.

## When to use

- **ONLY** when the user explicitly types `/review-text`.
- Never trigger automatically, nor as part of another skill.

## Process

### Phase 1 — Discovery

1. List all `.md` files in the project, including subfolders: root, `guides/`, `templates/`, `examples/`, `.claude/skills/`, `.github/`.
2. Ignore folders in `.gitignore` (`memory/`, `exchange/`).
3. Inform the user how many files will be reviewed:

> "Found X Markdown files to review. Starting."

### Phase 2 — Review

For each file, read the full content and check:

**Spelling and grammar:**
- Typos and spelling errors.
- Subject-verb agreement.
- Missing or incorrect punctuation.

**Conventions:**
- Headings: sentence case capitalization (not Title Case). Exceptions: proper nouns, acronyms, command names.
- Punctuation in lists: consistency (all with periods or none).
- Consistent use of "you" (don't mix formal and informal styles).

**Markdown formatting:**
- Hierarchical headings (don't skip levels: `##` straight to `####`).
- Internal links pointing to correct paths (verify the referenced file exists).
- Valid frontmatter (name, description, type fields in memories and skills).

**Cross-file consistency:**
- Folder and command names written the same way everywhere.
- Cross-references using the same terms (don't call it "templates" in one place and "models" in another).

### Phase 3 — Correction with approval

For each correction found:

1. **Clear correction** (obvious typo, missing punctuation): fix directly and add to the list of applied corrections.
2. **Ambiguous correction** (could be correct depending on intent, word choice, tone): present to the user with context:

> **File:** `guides/skills.md`, line 42
> **Found:** "This makes the process Predictable and Debuggable"
> **Suggestion:** "This makes the process predictable and debuggable"
> **Reason:** Title Case capitalization — convention uses sentence case.
> **Fix? (y/n)**

Wait for response before moving to the next ambiguous correction.

### Phase 4 — Consolidated report

After reviewing all files, present a summary:

```
## Review report

- **Files reviewed:** X
- **Errors found:** X
- **Auto-corrected:** X (clear spelling)
- **Corrected with approval:** X (ambiguous, approved by user)
- **Kept as-is:** X (ambiguous, user chose not to correct)
- **Error-free files:** X
```

## Rules

- **Never alter code** inside ` ```code``` ` blocks — only body text and headings.
- **Never alter file or folder names** — only content.
- **Never alter frontmatter** of SKILL.md or memory files (name, description, type) — it could break system discovery.
- **Never correct without showing first.** Clear corrections are applied and listed in the report. Ambiguous corrections require individual approval.
- **Never change tone or rewrite sentences.** The review is for spelling and convention, not editorial.
- **Respect capitalization exceptions:** proper nouns, acronyms (AI, PR, EN-US), command names (/start), and file names (CLAUDE.md) keep their original spelling.
