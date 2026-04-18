---
name: telemetry
description: Queries and displays skill activity logs for the project. Shows what ran, when, on which project, and whether it succeeded. Manual trigger or by asking about activity.
---

# /telemetry — Activity monitoring

Queries the project's activity logs and presents clearly what happened — which skills ran, on which projects, whether they succeeded, and how long they took.

## When to use

- When the user asks "what ran today?", "any errors?", "show me the activity"
- When the user explicitly types `/telemetry`
- When the user asks for an activity summary for any time period

## Log structure

```
logs/
├── reliable.log          # Everything that happened (general log)
├── skills/
│   ├── audit-php.log     # Per skill
│   └── ...
├── projects/
│   ├── my-project.log    # Per project
│   └── ...
└── archive/              # Old logs (rotated)
```

### Format of each line

```
[YYYY-MM-DD HH:MM:SS] [SKILL] [PROJECT] [STATUS] [DURATION] — Description
```

### Possible statuses

| Status | Meaning |
|--------|---------|
| `COMPLETED` | Executed successfully |
| `ERROR` | Failed — requires attention |
| `PARTIAL` | Completed partially |

## Process

### 1. Identify what the user wants

| User question | Action |
|---------------|--------|
| "What ran today?" | Read `logs/reliable.log`, filter by today's date |
| "How's the project doing?" | Read `logs/projects/{project}.log`, last 20 entries |
| "Any errors?" | Grep for `[ERROR]` in `logs/reliable.log` |
| "Show me the audit" | Read `logs/skills/{skill}.log` |
| "Weekly summary" | Read `logs/reliable.log`, group by day |
| `/telemetry` with no context | Summary of the last 24 hours |

### 2. Read the relevant logs

Use the reading utility to access log files. Never read more than 100 lines at once — if the period is large, summarize.

### 3. Present clearly

**For daily summaries:**

```
## Today's activity (2026-04-09)

| Time | Skill | Project | Status | Duration | Result |
|------|-------|---------|--------|----------|--------|
| 14:23 | audit-php | my-project | OK | 45s | 12 files, 3 violations |
| 14:24 | audit-security | my-project | OK | 32s | 0 violations |
| 15:00 | start | - | OK | 2s | Session started |

**Summary:** 3 actions, 0 errors, 3 violations found.
```

**For error alerts:**

```
## Errors detected

[14:25] audit-php — Failed to read file: permission denied
```

### 4. Suggest actions (if applicable)

- If there are errors: suggest investigation
- If there are many violations: suggest prioritized fixes
- If there's no activity: inform that everything is idle

## How to log (for other skills)

Every skill must log its actions using the utility:

```bash
~/your-project/infra/scripts/mnemosine-log.sh <skill> <project> <status> <duration> "<description>"
```

### Mandatory logging moments:

1. **On completion** — always log the result
2. **On failure** — always log the error
3. **On start** (optional) — only if the operation is long (>30s)

### Usage example inside a skill:

```bash
# On start (long operation)
mnemosine-log.sh audit-php my-project STARTED - "Auditing 15 PHP files"

# On completion (success)
mnemosine-log.sh audit-php my-project COMPLETED 45s "15 files audited, 3 ERROR violations, 1 WARNING"

# On completion (error)
mnemosine-log.sh audit-php my-project ERROR 12s "Failure: file not found"
```

## Rules

- **Never fabricate data.** If the log is empty, say it's empty.
- **Don't read logs older than 30 days** without the user explicitly asking (they're in `archive/`).
- **Summarize, don't dump.** The user wants to know "3 errors in the project", not 200 lines of raw log.
- **Alert proactively** if `/start` detects recent errors in the logs.
