# Skill taxonomy — 3 levels

---

## The 3 levels

### Level 1 — Global Skills

**Purpose:** meta-work — things the agent does to keep its own operation running, outside of any specific project.

| Attribute | Value |
|---|---|
| Invoker | The user (human) via Claude Code CLI |
| Scope | Any working directory |
| Edits client code? | **No** — edits framework, memory, learning, plans |
| Sees client data? | No |
| Detection | Automatic by Claude Code (path `.claude/skills/`) |
| Telemetry | Required |

**Examples:**
- `/start`, `/wrap-up`, `/get-started`
- `/telemetry`, `/marketplace`
- `/create-skill`, `/active-learning`
- `/review-text`, `/make-public`

**Location:** `your-project/.claude/skills/`
**Naming pattern:** simple verb (`start`, `telemetry`) or verb-object (`make-public`, `active-learning`)

---

### Level 2 — Project Management Skills (dev-facing)

**Purpose:** work within a project — refactor, audit, feature, fix, PR delivery.

| Attribute | Value |
|---|---|
| Invoker | The user via CLI, **or** the agent autonomously during a work session |
| Scope | Strictly `projects/{slug}/` or `prod/{slug}/` — **absolute isolation** |
| Edits client code? | **Yes** |
| Sees client data? | Yes (dev environment with staging/fake data) |
| Detection | Automatic by Claude Code |
| Telemetry | Required |
| Subordinate to | Technical standards applicable to the project's stack |

**Examples:**
- `/manager-{project}` — project orchestrators
- `/approve-pr`
- `/audit-{standard}` — stack-specific audits

**Location:** `your-project/.claude/skills/` (same directory as Level 1 — both detected by the CLI)
**Naming pattern:**
- `manager-{slug}` for project orchestrators
- `audit-{standard}` for specific audits
- `{action}-{context}` for surgical actions

---

### Level 3 — Programmatic Skills (worker-facing)

**Purpose:** process client data in production, without a human in the loop. Receives standardized `.md`, produces standardized `.md`.

| Attribute | Value |
|---|---|
| Invoker | Worker (Node/TS code) via Claude Agent SDK — **never via CLI** |
| Scope | One queue job + dedicated work folder |
| Edits client code? | **No** — produces `.md`, never commits code |
| Sees client data? | **Only pseudonymized** — the sanitization boundary is impassable |
| Detection | Manual (worker loads explicitly by path) |
| Claude model | **Fixed per skill** (Haiku/Sonnet/Opus defined in SKILL.md) |
| Telemetry | Extended: job_id, input/output tokens, USD cost, latency, model |
| Isolation | Total per project — a skill from one project cannot read files from another |

**Examples (future):**
- `core/sanitize-pii` (Haiku) — cross-cutting
- `core/summarize` (Haiku) — cross-cutting
- `core/extract-data` (Sonnet) — cross-cutting
- `{project}/interpret-submission` (Sonnet)
- `{project}/generate-plan` (Sonnet)

**Location:** separate SaaS repo, in `packages/skills/`
**Naming pattern:** `{scope}/{verb-object}` where scope is `core` (cross-cutting) or project slug

---

## Folder structure — does it accommodate all 3 levels?

### Today (Levels 1 + 2 mixed)

```
your-project/
└── .claude/skills/
    ├── active-learning/         <- L1
    ├── approve-pr/              <- L2
    ├── wrap-up/                 <- L1
    ├── audit-php/               <- L2
    ├── get-started/             <- L1
    ├── create-skill/            <- L1
    ├── manager-{project}/       <- L2
    ├── start/                   <- L1
    ├── marketplace/             <- L1
    ├── review-text/             <- L1
    ├── telemetry/               <- L1
    └── make-public/             <- L1
```

Flat skills, mixing L1 and L2. Works, but doesn't scale mentally when it hits 40-50.

### Tomorrow (with Level 3 entering)

```
your-project/                           (agent repo — current)
└── .claude/skills/
    ├── start/                          <- L1 — unchanged
    ├── wrap-up/
    ├── telemetry/
    ├── manager-{project}/              <- L2 — unchanged
    ├── audit-php/
    └── ... (existing ones)

saas-repo/                              (new repo — separate)
└── packages/skills/
    ├── core/                           <- L3 cross-cutting
    │   ├── sanitize-pii/
    │   │   └── SKILL.md                (with frontmatter: model: haiku)
    │   ├── summarize/
    │   └── extract-data/
    └── {project}/                      <- L3 per project
        ├── interpret-submission/
        └── generate-plan/
```

The natural separation is **by invoker**:
- **Levels 1 and 2 live together** in `.claude/skills/` because both are auto-detected by the Claude Code CLI.
- **Level 3 lives in a separate repo** because it's loaded programmatically by the worker via Claude Agent SDK, not by the CLI. It **doesn't need** to be in `.claude/skills/`.

### Visual sub-organization (optional)

If you want to visually distinguish Level 1 vs Level 2 within the same directory, **three options**:

**A) Name prefix** — `global-start/`, `project-manager-{slug}/`. Compatible today, but invocation names get verbose. **Not recommended.**

**B) Subdirectories** — `global/start/`, `project/manager-{slug}/`. Depends on Claude Code CLI detecting skills in subdirs — **not confirmed**, needs testing with 1 skill before moving everything.

**C) Keep flat, taxonomy documented (recommendation)** — skills stay as they are. Anyone who needs to know the level consults this document. Anyone creating a new skill follows the naming pattern. Simplest and most stable option.

---

## Criteria for classifying new skills

When creating a new skill, answer 3 questions:

1. **Does it edit client code?** Yes -> Level 2 or 3. No -> Level 1.
2. **Who invokes — human via CLI or programmatic worker?** CLI -> Level 1 or 2. Worker -> Level 3.
3. **Does it operate within `projects/{slug}/`?** Yes -> Level 2. No -> Level 1 or 3.

Flowchart:

```
Edits client code?
├── No -> Level 1 (Global — agent meta-work)
└── Yes
    ├── Via CLI, with human in the loop? -> Level 2 (Project dev-facing)
    └── Via worker, without human in the loop? -> Level 3 (Programmatic worker)
```

---

## Quick matrix

| Aspect | Level 1 Global | Level 2 Project (dev) | Level 3 Worker (prod) |
|---|---|---|---|
| Invoker | User via CLI | User via CLI or agent | Worker via Agent SDK |
| Scope | Any working dir | `projects/{slug}/` | Dedicated work folder |
| Edits client code? | No | Yes | No (produces `.md`) |
| Sees PII? | N/A | Yes (dev) | **No** (only pseudonymized) |
| Claude model | CLI default | CLI default | **Fixed per skill** (Haiku/Sonnet/Opus) |
| Where it lives | `.claude/skills/` | `.claude/skills/` | `packages/skills/` (separate repo) |
| Example | `/start` | `/manager-{project}` | `{project}/generate-plan` |

---

## Evolution — skills to create along the way

### To better orchestrate existing skills
- `/skills-list` — shows all skills organized by level with short descriptions
- `/skills-status` — shows aggregated telemetry (invocations/day, success/failure, average duration per skill)
- `/skills-audit` — audits existing skills against the standard template and reports format inconsistencies, missing telemetry, non-standard SKILL.md

### In the future (with programmatic worker)
- **L3 core:** `core/sanitize-pii`, `core/summarize`, `core/extract-data`
- **L3 per project:** domain-specific skills
