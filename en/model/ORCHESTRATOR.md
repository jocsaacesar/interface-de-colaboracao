# ORCHESTRATOR.md

AI orchestration manual. Consulted on demand — **not loaded automatically**.

## Skill library

```
library/
├── auditors/      # 7 auditors — linked via symlink (same skill, different projects)
└── project/       # 4 pipeline skills — templates (each project copies and customizes per stack)
    ├── skill-planner/    # Interprets request -> creates plan + tasks in the project folder
    ├── skill-executor/   # Takes the plan -> writes code
    ├── skill-tester/     # Creates tests against standards (unit, integration, etc.)
    └── skill-auditor/    # Orchestrates the project's stack auditors
```

**Auditors:** symlink (identical process, just filtered by stack).
**Project skills:** customized copy (process diverges by stack — PHP != Next.js/TS != Python, etc.).

When the template in the library evolves, update projects **consciously** — not automatically.

## Project pipeline

```
User requests something -> Manager orchestrates:
    1. Planner (interprets, creates plan, creates tasks)
    2. Executor (takes the plan, writes code)
    3. Tester (creates tests against standards)
    4. Auditor (orchestrates stack audits)
```

**Nothing happens in a project without going through the manager. Ever.**

The plan created by the planner lives in the **project folder** where it will be executed, not in `plans/`.

## When to call each skill

### Session (automatic or semi-automatic)

| Trigger | Skill | Condition |
|---------|-------|-----------|
| User greets or types `/start` | `/start` | Always at the beginning |
| User types `/wrap-up` | `/wrap-up` | Always at the end |
| User asks to remember something or creates something new | — | Save to persistent memory |

### Project management (on user command)

| Trigger | Skill |
|---------|-------|
| User requests work on a project | `/manager-{project}` (create with `/create-skill` using the `skill-project` template) |
| Open PR needs approval | `/approve-pr` -> calls the project's auditors via symlink |

### Auditing (called by the manager or by `/approve-pr`)

The project manager knows which auditors to apply based on the stack. Auditors live in `library/auditors/` and are linked via symlink in `projects/{slug}/.claude/skills/`.

**Example stack mapping:**

| Stack | Available auditors |
|-------|--------------------|
| PHP | php, oop, security, tests |
| Next.js/TS | js, frontend, security, crypto, tests |
| Python | security, tests |
| Full-stack | php, oop, js, frontend, security, crypto, tests |

Adjust according to your stack. Auditors are independent — only enable the ones that make sense.

### Proactive (the AI decides on its own)

| Situation | Action |
|-----------|--------|
| Error detected (red CI, bug, violation) | `/active-learning` immediately |
| Skill completed or failed | `mnemosine-log.sh` (mandatory telemetry) |

### On user command (never automatic)

| Trigger | Skill |
|---------|-------|
| Create new skill | `/create-skill` |
| View activity | `/telemetry` |
| Review text | `/review-text` |
| Publish work | `/make-public` |
| Explore skills | `/marketplace` |

## Skill levels

```
Global (.claude/skills/)
├── Session: start, wrap-up, get-started
├── Operational: create-skill, telemetry, active-learning
├── Management: manager-{project}, approve-pr
└── Utility: review-text, make-public, marketplace

Library (library/auditors/)
└── 7 auditors: crypto, frontend, js, php, oop, security, tests
    -> linked via symlink in projects/{slug}/.claude/skills/
```

## Decision flow

```
User requests something
    ├── Is it about a specific project?
    │   ├── Yes -> call /manager-{project}
    │   │         the manager handles everything (5 phases: prepare, plan, execute, deliver, record)
    │   └── No -> execute directly
    │
    ├── Does it need auditing?
    │   ├── Open PR -> /approve-pr (orchestrates the project's auditors)
    │   └── Specific code -> call individual auditor
    │
    └── Did something go wrong?
        └── /active-learning (proactive, without waiting for the user to ask)
```

## Plans

Three types in `plans/`:

| Type | Prefix | When to create |
|------|--------|---------------|
| **Backlog** | `backlog-NNN` | Idea, improvement, tech debt — no deadline |
| **Operational** | `ops-NNN` | Concrete execution with deliverable and deadline |
| **Emergency** | `urg-NNN` | Production is down — maximum priority, generates learning entry on close |

Completed or discarded -> `plans/archive/`.

Summarized plan status lives at the bottom of `CLAUDE.md` — updated by `/wrap-up`, read by `/start`.

## How to create a project manager

1. Run `/create-skill` and choose the `skill-project` template
2. Define the scope (project folder, stack, auditors)
3. The generated skill will have 5 phases: prepare, plan, execute, deliver, record
4. Link the relevant auditors via symlink:
   ```bash
   cd projects/my-project/.claude/skills/
   ln -s ../../../../library/auditors/audit-php audit-php
   ln -s ../../../../library/auditors/audit-tests audit-tests
   ```
