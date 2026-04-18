---
name: active-learning
description: Registers errors and incidents following a structured protocol. Conducts an interview to document error, context, fix, and mitigation. Manual trigger or when the AI identifies an incident.
---

# /active-learning — Incident registration

Conducts the project's learning protocol. When something goes wrong, this skill guides the full registration: what happened, why it happened, what we did to fix it, and what we did to make sure it never happens again.

It's not punishment. It's a vaccine.

## When to use

- When the user explicitly types `/active-learning`
- When the AI identifies an incident that needs to be registered
- When something goes wrong and someone says "log this"
- **Never** trigger automatically without confirmation — errors need human context

## When other skills should SUGGEST `/active-learning`

Auxiliary skills (`/approve-pr`, auditors, project managers)
should **explicitly suggest** that the user runs `/active-learning` when
they detect any of these signals during their flow:

- **CI red** that wasn't expected
- **Unhandled exception** or production bug discovered during the skill
- **Late fix** — code change that should have been validated earlier
- **Audit that caught something big** — high-severity finding that should have been seen before
- **Self-recognition of error** by the AI
- **Validation skip** discovered in retrospect (e.g., SKIPPED test that masked a bug)

The suggestion should be **explicit and proactive**:

> "Detected [error type] during this flow. I recommend running
> `/active-learning` to formally register the incident before proceeding.
> Confirm we should run it?"

**Do not trigger automatically** (hard rule above) — only suggest, wait for
user confirmation. But the suggestion should appear before the skill moves on,
not as a hidden footnote.

## Process

### Phase 1 — Identify the incident

Check the next available sequential number in `learning/errors/`:

```bash
ls learning/errors/*.md 2>/dev/null | wc -l
```

The incident number is sequential: `0001`, `0002`, etc. Once assigned, it never changes.

### Phase 2 — Interview (one question at a time)

#### Question 1 — What happened?

> "Tell me what went wrong. Facts, no judgment. What happened exactly?"

**Capture:** Objective description of the error. No blame, no justification — just the facts.

#### Question 2 — What was the context?

> "What was the situation? What was being done? What were the links in the chain that led to this?"

**Capture:** The sequence of events and decisions. The links in the chain. Why it happened, not who did it.

#### Question 3 — What did we do to fix it?

> "How did we resolve it? What was the immediate action? If it hasn't been fixed yet, what needs to be done?"

**Capture:** The fix applied or planned. Concrete action, not intention.

#### Question 4 — What do we do to make sure it never happens again?

> "What's the mitigation? What changes in the process, documentation, or rules so that this becomes immunity?"

**Capture:** Preventive action. Can be: new project rule, skill update, new audit check, additional documentation.

### Phase 3 — Generate the 4 files

Based on the answers, generate:

#### `learning/errors/{NNNN}-{slug}.md`
```markdown
---
incident: {NNNN}
date: {YYYY-MM-DD}
project: {project or "general"}
status: resolved | in-progress
---

# {Descriptive error title}

{Objective description of what happened. Facts, no judgment.}
```

#### `learning/context/{NNNN}-{slug}.md`
```markdown
---
incident: {NNNN}
---

# Context — {Title}

## Situation
{What was being done}

## Links in the chain
{Sequence of events and decisions that led to the error}

## Ignored indicators
{Signals that could have prevented it, if any}
```

#### `learning/fix/{NNNN}-{slug}.md`
```markdown
---
incident: {NNNN}
fixed_on: {YYYY-MM-DD}
---

# Fix — {Title}

## Immediate action
{What was done to resolve it}

## Changed files
{List of modified files, if applicable}

## Verification
{How to confirm the fix worked}
```

#### `learning/mitigation/{NNNN}-{slug}.md`
```markdown
---
incident: {NNNN}
mitigated_on: {YYYY-MM-DD}
type: rule | skill | process | documentation
---

# Mitigation — {Title}

## What changes
{Description of the preventive change}

## Where it changes
{Project rules? Minimum standard? Skill? Process?}

## How to verify the mitigation works
{Test or check that proves the prevention}
```

### Phase 4 — Show and approve

Show all 4 complete files to the user before saving.

> "Here's the incident record. Take your time — want to adjust anything before I save?"

Wait for explicit approval.

### Phase 5 — Save and log telemetry

1. Save the 4 files in `learning/`
2. Log telemetry:

```bash
bash ~/your-project/infra/scripts/mnemosine-log.sh active-learning {project} COMPLETED {duration} "Incident {NNNN} registered: {title}"
```

3. If the mitigation involves a change to project rules or standards, inform:

> "The mitigation suggests a change to {document}. Want me to propose the change now?"

### Phase 6 — Query past incidents

If the user calls `/active-learning` and asks about existing incidents (e.g., "have we had a problem with this before?"), the skill should:

1. Search `learning/errors/` by keywords
2. If a related incident is found, show the summary
3. Alert: "We had incident {NNNN} about this. The mitigation was: {summary}. Check if it's being followed."

## Rules

- **One question at a time.** Don't dump the entire form.
- **No judgment.** The record is factual. There are no individual culprits.
- **Show before saving.** Always. No exceptions.
- **Descriptive slug.** The file name should be readable: `0001-force-push-overwrote-repo.md`, not `0001-error.md`.
- **Never delete incidents.** Resolved incidents remain as records. They're a vaccine, not a shame.
- **Telemetry is mandatory.** Log to the script when complete.
