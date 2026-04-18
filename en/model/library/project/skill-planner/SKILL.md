---
name: skill-planner
description: Planning skill for projects. Receives a demand from the user, analyzes context, creates a structured plan with modules, and delivers an estimate. Manual trigger only.
---

# /skill-planner — Project Planner

Receives a demand (feature, refactoring, migration, fix), analyzes the current state of the code, consults standards and history, and produces a structured plan with sequential modules.

## When to use

- When the user asks to plan a feature, migration, or significant change.
- Before executing complex tasks involving multiple files or layers.
- **Never** trigger automatically.

## Process

### Phase 1 — Understand the demand

1. Read the user's request and confirm understanding.
2. If the demand is ambiguous, ask before planning.
3. Identify: scope (which layers/files), risks (what could break), dependencies (what must exist first).

### Phase 2 — Analyze the current state

1. Read the project's `CLAUDE.md` to understand phase, stack, conventions.
2. Consult `docs/` for applicable standards.
3. Consult `learning/` for previous incidents in the area.
4. Check recent PRs:
   ```bash
   gh pr list --state all --limit 5
   ```

### Phase 3 — Structure the plan

1. Break the demand into **sequential modules** (each module is an independent PR).
2. For each module, define:
   - **Title** — what it does
   - **Affected files** — which it creates, modifies, or deletes
   - **Dependencies** — which modules need to be ready first
   - **Risks** — what could go wrong
   - **Acceptance criteria** — how to know it's done
3. Order modules by dependency (foundation first, polish last).

### Phase 4 — Present to the user

Plan format:

```
## Plan: {title}

**Demand:** {request summary}
**Modules:** {count}
**Estimate:** {approximate time}

### Module 0 — {title}
- **Does:** {description}
- **Files:** {list}
- **Depends on:** none
- **Risk:** {description}
- **Acceptance:** {criteria}

### Module 1 — {title}
- **Does:** {description}
- **Files:** {list}
- **Depends on:** Module 0
- **Risk:** {description}
- **Acceptance:** {criteria}

### Next step
Approve the plan and execute Module 0?
```

### Phase 5 — Await approval

1. **Never** execute without explicit user approval.
2. The user may approve the entire plan, module by module, or request adjustments.
3. If approved, delegate to `skill-executor`.

## Rules

- **Plan before code.** Never jump to execution without an approved plan for complex tasks.
- **Independent modules.** Each module is a PR that can be reverted without affecting the others.
- **Explicit risks.** If something might break, say so beforehand — not after.
- **Honest estimates.** If you don't know the time, say "I can't estimate this" instead of guessing.
- **Consult history.** Check `learning/` before planning areas with previous incidents.
- **Tight scope.** Plan the minimum necessary for the demand. Extras become backlog, not modules.
