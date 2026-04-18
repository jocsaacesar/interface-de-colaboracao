---
name: skill-executor
description: Execution skill for projects. Receives an approved plan or direct command, implements code following standards, commits by logical groups, and presents results. Manual trigger only.
---

# /skill-executor — Project Executor

Receives an approved plan (from `skill-planner`) or a direct command from the user and implements code following the project's standards. Commits by logical groups, presents results, and delegates to auditing.

## When to use

- When there is an approved plan to execute.
- When the user gives a direct implementation command.
- **Never** trigger automatically.

## Process

### Phase 1 — Prepare (minimum knowledge)

1. **Read the project's CLAUDE.md** — stack, architecture, conventions, current state.
2. **Read the applicable standards** in `docs/` — each stack has its standards document.
3. **Consult `learning/`** for incidents related to the work area.
4. **Check the latest PR:**
   ```bash
   gh pr list --state all --limit 5
   ```

### Phase 2 — Execute

1. **Implement the task** following the standards loaded in Phase 1.
2. **Apply the code principles** (see `code-principles.md` in this directory).
3. **Check conformance** with standards during editing (passive auditing).

### Phase 3 — Commit by logical groups

Don't make one big commit at the end — group by context:
- "feat: new entities X and Y"
- "refactor: migrate Z to OOP"
- "fix: sanitization in handler W"

Each commit is a progress point recorded in the repository.

### Phase 4 — Present results

Upon finishing, present a complete summary:

```
Task completed. {N} commits, {M} files changed:
- Commit 1: {message} ({files})
- Commit 2: {message} ({files})
Running audit...
```

### Phase 5 — Audit

1. Call the audit skills relevant to the stack.
2. If the audit finds **ERROR** violations: fix before proceeding.
3. If it finds **WARNING**: report to the user for decision.
4. Reference violations by standard ID (e.g., php-standards.md, PHP-025).

### Phase 6 — Deliver PR

1. Create PR:
   ```bash
   gh pr create --base staging --title "{title}" --body "{body}"
   ```
2. Wait for CI/CD to run:
   ```bash
   gh pr checks {PR_NUMBER}
   ```
3. If tests pass: report success.
4. If they fail: report the error to the user.

## Rules

- **Phase 1 is mandatory.** No preparation, no work. Assuming without reading is a violation.
- **Standards are law.** Consult the standards documents and audit your own code.
- **Learning is mandatory.** Consult `learning/` before acting in areas with history.
- **Logical commits, not monolithic.** Each commit is a coherent group.
- **No direct push.** Push happens via PR to staging. Never push directly to main/production.
- **Audit before the PR.** Auditing runs before creating the PR, not after.
- **Show before delivering.** Present a complete summary before creating the PR.
