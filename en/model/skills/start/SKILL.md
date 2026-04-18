---
name: start
description: Session bootstrap. Loads identity, memories, learning records, plan status, recent errors, and skills. Triggered by greeting or /start command.
---

# /start — Session bootstrap

The agent doesn't start a conversation in the dark. This skill loads everything needed to be fully present, informed, and in compliance with the project's rules from the very first message.

## When to use

- Every time a new conversation starts
- When the user explicitly says `/start`
- When the user greets with intent to work ("good morning", "let's get started", "I'm here")

## Process

### Phase 1 — Load identity

Read the project's `CLAUDE.md` at the root of the working directory. This file defines who the AI is, how it behaves, which projects it manages, and the conventions. Internalize — don't summarize back to the user.

### Phase 2 — Load memories

1. Read `memory/MEMORY.md` — index of all memories.
2. Read all memory files listed in the index.
3. Note what changed since the last conversation (if detectable).
4. DO NOT recite memories back to the user. Use silently.

### Phase 3 — Check learning records

1. Check `learning/errors/` for registered incidents.
2. If there are recent incidents (last 7 days), load mentally.
3. If there are relevant mitigations for the session's likely work, keep in mind.
4. DO NOT list incidents to the user unless asked.

### Phase 4 — Check plan status

1. Read the **"Plan status"** section in `CLAUDE.md` (already loaded in Phase 1 — DO NOT open plan files).
2. Identify:
   - **Overdue operational plans** (past deadline) — alert in the greeting
   - **In-progress operational plans** — mention briefly
   - **Emergency plans** — top priority, alert first
   - **Backlog** — mention only if there are no operational or emergency plans
3. DO NOT read the files in `plans/backlog/`, `plans/operational/`, or `plans/emergency/`. The status in CLAUDE.md is the quick source of truth.

### Phase 5 — Check recent telemetry errors

1. Read the last 20 lines of `logs/reliable.log` (if it exists).
2. Filter for `[ERROR]` — if there are recent errors, note them.
3. If there are unresolved errors, alert the user in the greeting.

### Phase 6 — Load skills

1. List all directories in `.claude/skills/` (global skills).
2. Read the `SKILL.md` of each skill — the entire file, not just the frontmatter.
3. Internalize activation conditions, process, and rules.
4. From this point on, treat skills as executables.
5. DO NOT list skills to the user unless asked.

### Phase 7 — Context snapshot

1. Check project status (if there are project subfolders):
   ```bash
   for p in projects/*/; do echo "$p: $(git -C $p branch --show-current 2>/dev/null)"; done
   ```
2. Note active branches and any divergence.

### Phase 8 — Greet

Respond as the AI defined in CLAUDE.md. Keep it short, natural, and informative.

The greeting should include:
- Acknowledge the user
- If there are **emergency plans**: alert first (top priority)
- If there are **overdue operational plans**: alert with deadline
- If there are **in-progress operational plans**: mention status
- If there are recent telemetry errors: alert
- If everything is clear: mention relevant backlog
- Signal readiness

**Tone examples:**

If there's an emergency:
> "urg-001 active — {title}. Priority zero. Everything else waits."

If there's an overdue operational plan:
> "ops-003 is past deadline (Sunday). 2 more ops in progress. Which one takes priority?"

If everything is clear:
> "0 emergencies, 2 ops on track, 7 in backlog. Go."

### Phase 9 — Log telemetry

```bash
bash ~/your-project/infra/scripts/mnemosine-log.sh start - COMPLETED {duration} "Session started. {N} memories, {M} incidents, {O} ops, {U} urg, {B} backlog"
```

## Rules

- **Never dump a status report.** The agent is a partner, not a boot log.
- **Never skip Phase 3.** Learning is immunity. Ignoring it means repeating mistakes.
- **Alert proactively.** If there are errors, emergencies, or overdue ops, speak up. Don't wait for the user to ask.
- **If CLAUDE.md doesn't exist**, warn — identity is non-negotiable.
- **The entire process should feel instant.** The user perceives a natural greeting, not mechanical phases.
- **Telemetry is mandatory.** Log the initialization.
