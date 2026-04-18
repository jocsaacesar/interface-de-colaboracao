---
name: wrap-up
description: Session closing. Audits what was done, updates state, syncs memories, commits pending changes, generates briefing, and says goodbye. ONLY when the user types /wrap-up. Never trigger automatically.
---

# /wrap-up — Session closing

The agent doesn't leave without closing the door. This skill ends the work session by saving all state, recording what was done, and preparing the ground so the next session picks up right where this one left off.

## When to use

- **ONLY** when the user explicitly types `/wrap-up`
- **Never** trigger on greetings, farewells, or implicit signals
- **Never** trigger automatically — the user decides when the day is over

## Process

### Phase 1 — Audit the session

1. **What was done today?** Review the conversation history and list:
   - Decisions made
   - Files created or edited
   - Skills created or updated
   - Plans created or executed
   - Incidents registered
   - Commits and pushes performed

2. **What's still pending?** Identify:
   - Tasks mentioned but not completed
   - Plans approved but not executed
   - Loose threads that came up during work

3. **Check for unregistered incidents** — scan the session for:
   - CI red that happened (even if it was fixed)
   - Bug, exception, or operational error
   - Audit that caught something that should have been caught earlier
   - Any self-recognition of error by the AI

   **For EACH signal found**, check if there's a corresponding incident in
   `learning/errors/`. If NOT, **alert before closing the session**:

   > "Found {N} incident signals in this session without formal registration:
   > - {signal 1}
   > - {signal 2}
   > I can't close the session without running `/active-learning` for each one.
   > Want me to run it now? (recommended) or do you authorize closing anyway?"

   **Do not close without explicit user resolution.** If there are unregistered incidents
   and the user authorizes closing anyway, record that decision in the session state
   as "pending incidents for next session" — but only with explicit authorization.

### Phase 2 — Update state

1. **Plan status in `CLAUDE.md`** — update the "Plan status" section:
   - Update the date: `(updated: YYYY-MM-DD)`
   - **Operational:** update each ops status (new progress, completed, blocked). If completed, remove from the table and move the file to `plans/archive/`.
   - **Emergency:** add if new ones came up, remove if resolved.
   - **Backlog:** add new ones, update summary if there was progress, remove if discarded.
   - **New plans created in the session:** add to the corresponding table.
   - This section is the **quick source of truth** — `/start` reads it, not the plan files.

2. **CLAUDE.md** — update:
   - "Current state": summary of what was done in the session
   - Skills: if new skills were created, add to the table
   - Structure: if new folders were created, update

3. **Plans** — if any plan was executed or progressed:
   - Update status in the plan file
   - Mark completed tasks with `[x]`

### Phase 3 — Sync memories

1. Copy project memories to the system folder:
   ```bash
   cp memory/*.md ~/.claude/projects/$(pwd | sed 's|/|-|g')/memory/ 2>/dev/null
   ```

2. Update system memories if necessary:
   - Create new memory if something relevant for future sessions came up

### Phase 4 — Commit and push pending changes

1. Check for uncommitted changes:
   ```bash
   git status
   ```

2. If there are any, commit with a descriptive message:
   ```
   Session closing: {summary of what changed}
   ```

3. Push to remote.

4. Check for pending changes in subprojects:
   ```bash
   for p in projects/*/; do echo "$p: $(git -C $p status --short | wc -l) pending"; done
   ```
   If there are any, alert — don't commit without approval.

### Phase 5 — Healthcheck (optional)

If the project has production URLs, test them all. If any fail, alert before closing.

```bash
# Example — adapt the URLs to your project
URLS=(
  "https://your-domain.com"
)

for url in "${URLS[@]}"; do
  code=$(curl -sI -o /dev/null -w "%{http_code}" --max-time 10 "$url" 2>/dev/null)
  echo "$url: $code"
done
```

- **200 and 302 are OK.**
- **Any other code is an alert.** Report to the user before closing.

### Phase 6 — Log telemetry

```bash
bash ~/your-project/infra/scripts/mnemosine-log.sh wrap-up - COMPLETED {duration} "Session closed. {N} decisions, {M} commits, {P} plans. Next: {summary}"
```

### Phase 7 — Closing briefing

Present an executive summary of the day. Format:

```
## Session {date}

### What we did
- {item 1}
- {item 2}
- ...

### Numbers
- {N} commits | {M} files changed | {P} plans
- Skills: {Z} active

### Pending for next session
- {item 1}
- {item 2}

### Critical decisions (revisit in 7 days)
- {decision, if any}
```

### Phase 8 — Farewell

Say goodbye in the character defined in CLAUDE.md. Short, with attitude.

Tone examples:

If it was a productive day:
> "Good work today. {N} commits, {M} plans, and not a single mediocre line. Tomorrow `/start` and I'm here."

If things are still pending:
> "Full day. {X} is still pending — I won't forget. When you're back, `/start` and I'll pick up where we left off."

If it was a foundation day:
> "Today we built the foundation. {N} skills, {M} processes. Tomorrow the real work begins."

## Rules

- **Never leave without updating state.** An outdated CLAUDE.md is institutional amnesia.
- **Never leave without telemetry.** If it wasn't logged, the session didn't exist.
- **Never leave without pushing.** Local work that doesn't reach the remote is lost work.
- **Never dump a technical log.** The briefing is for a human, not a machine.
- **The farewell is short.** 2-3 lines maximum.
- **Alert about pending items.** If something was left behind, say so. Don't pretend everything is wrapped up.
