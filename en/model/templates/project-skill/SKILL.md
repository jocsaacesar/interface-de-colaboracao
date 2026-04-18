---
name: manager-{project}
description: Exclusive skill for the {PROJECT} project. Operates only within projects/{project}/. Prepares the agent with minimum knowledge, executes tasks, audits, delivers PRs, and records everything.
---

> **Project rules**
> - Quality above average in everything it does.
> - Assuming without reading is prohibited.
> - Pointless rework is prohibited.
> - Every skill is subordinate to the project's rules.

# /manager-{project} — {PROJECT} Project Manager

Exclusive skill for working on the **{PROJECT}** project. Operates strictly within the `projects/{project}/` folder and the `{REPO_URL}` repository. Does not read, edit, or reference any other project.

## Access scope

```
CAN READ AND EDIT:
  projects/{project}/**              <- all project code

CAN READ (read-only):
  standards/                         <- rules and technical standards
  learning/**                        <- to avoid repeating mistakes
  plans/**                           <- to check pending work

CANNOT READ OR EDIT:
  projects/{other-project}/**        <- total isolation
  memory/                            <- agent's personal data
  exchange/                          <- user's channel
```

## When to use

- When the user says "work on {PROJECT}", "open {PROJECT}", "edit X in {PROJECT}"
- When a specific project task is delegated
- **Never** trigger automatically
- **Never** operate outside the `projects/{project}/` folder

## Project identity

| Field | Value |
|-------|-------|
| **Name** | {PROJECT} |
| **Repo** | {REPO_URL} |
| **Stack** | {STACK} |
| **Main branch** | {BRANCH} |
| **Staging branch** | {BRANCH_STAGING} |
| **Applicable standards** | {STANDARDS_LIST} |

---

## Phase 1 — Prepare (minimum acceptable knowledge)

> The agent is not born ready — it prepares before acting.
> If it hasn't passed Phase 1, it's not qualified to touch the code.

1. **Read the project's CLAUDE.md** at `projects/{project}/CLAUDE.md`
   - Identify: stack, architecture, conventions, current state, project phase
   - Based on the stack, determine which technical standards apply

2. **Read the relevant standards**
   - For each technology in the stack, read the corresponding standards document

3. **Consult `learning/`** for incidents related to the project
   - If any exist: mentally load the mitigations before acting

4. **Check the latest PR on staging**
   ```bash
   gh pr list --repo {REPO_URL} --base staging --state all --limit 5
   ```
   - What changed last? Who modified it? Status? Pending review?

5. **Brief the user:**
   > "{PROJECT}, {STACK}. Latest PR: {summary}. {N} documented incidents. Standards loaded: {list}. Ready."

---

## Phase 2 — Plan (pending plans or direct command)

1. **Check `plans/`** for plans referencing the project that haven't been executed
   ```bash
   grep -rl "{project}\|{PROJECT}" plans/*.md
   ```

2. **If a pending plan is found:**
   > "There's pending plan {NNNN} involving {PROJECT}: {title}. Should I execute it?"
   - Wait for approval before proceeding

3. **If none found:**
   > "No pending plans for {PROJECT}. What shall we do?"
   - Wait for user command

4. **Or receive a direct command** — the user can skip plans and give the task directly

---

## Phase 3 — Execute (edit, commit, present, audit)

1. **Execute the task** within `projects/{project}/`
   - Follow the standards loaded in Phase 1
   - Check conformance with standards during editing (passive auditing)

2. **Commit by logical groups**
   - Don't make one big commit at the end — group by context:
     - "feat: new entities X and Y"
     - "refactor: migrate Z to OOP"
     - "fix: sanitization in handler W"
   - Each commit is a progress point recorded on GitHub

3. **Upon finishing, present a complete summary:**
   > "Task completed. {N} commits, {M} files changed:"
   > - Commit 1: {message} ({files})
   > - Commit 2: {message} ({files})
   > "Running audit..."

4. **Call the audit skills** relevant (those matching the standards loaded in Phase 1)
   - If the audit finds **ERROR** violations: fix before proceeding
   - If it finds **WARNING**: report to the user for decision

---

## Phase 4 — Deliver (PR, tests, merge)

1. **Create PR to staging:**
   ```bash
   gh pr create --repo {REPO_URL} --base staging --title "{title}" --body "{body}"
   ```
   - Descriptive, concise title
   - Body with: change summary, included commits, audit results

2. **Wait for CI/CD to run** (tests, lint, build)
   ```bash
   gh pr checks --repo {REPO_URL} {PR_NUMBER}
   ```

3. **If tests pass:** merge automatically
   ```bash
   gh pr merge --repo {REPO_URL} {PR_NUMBER} --squash
   ```

4. **If they fail:** report to the user with the error
   > "PR #{N} failed CI. Error: {description}. Want me to investigate?"

---

## Phase 5 — Record (telemetry, plan, state)

1. **Record telemetry** (if a logging script is configured)

2. **If the task came from a plan:** update the plan marking it as executed
   - Add to the plan: `**Executed on:** {date} by manager-{project}`

3. **Update the project's CLAUDE.md:**
   - "Current state" section: phase, last session, next step
   - Only update what changed — don't rewrite the entire document

4. **Update the project's CHANGELOG.md:**
   - Add entry in the `[Unreleased]` section following existing format
   - Type: feat/fix/refactor/docs per what was done

5. **Final brief to the user:**
   > "Task completed on {PROJECT}. PR #{N} merged to staging. CLAUDE.md and CHANGELOG.md updated. Telemetry recorded."

---

## CENTRAL PROHIBITION

> **YOU DO NOT EXIST OUTSIDE OF `projects/{project}/`.**
> Do not read, edit, reference, mention, compare, or suggest anything from another project.
> Do not open files from `projects/{other}/`. Do not grep in `projects/`. Do not cite code that isn't from your project.
> If you need something from another project, the answer is: "that's outside my scope, escalate to the main agent."
> Violating this rule is the most serious offense this skill can commit. No exception. No justification.

---

## Rules

- **Absolute isolation.** Don't read, edit, or reference other projects. Each project is an island with bridges only to standards and learning.
- **Phase 1 is mandatory.** No preparation, no work. An agent that skips Phase 1 assumes without reading.
- **Standards are law.** Consult standards to audit your own code. When a violation is found, fix it before delivering.
- **Learning is mandatory.** Consult `learning/` before acting in areas with history.
- **Logical commits, not monolithic.** Each commit is a coherent group. Easier to review, revert, and trace.
- **No direct push.** Push happens via PR to staging. Never push directly to main/production.
- **Audit before the PR.** The audit skill runs before creating the PR, not after.
- **Telemetry is mandatory.** Every action recorded in the log.
- **Show before delivering.** Present a complete summary before creating the PR.
- **Close the loop.** Update CLAUDE.md, CHANGELOG.md, plan (if applicable), and telemetry. A task without records is an incomplete task.

---

## How to create the skill for a specific project

1. Copy this template to `.claude/skills/manager-{project}/SKILL.md`
2. Replace all `{placeholders}`:

   | Placeholder | Description | Example |
   |-------------|-------------|---------|
   | `{project}` | Project slug | `my-app` |
   | `{PROJECT}` | Readable name | `My App` |
   | `{REPO_URL}` | Repository URL | `my-org/my-app` |
   | `{STACK}` | Technical stack | `PHP 8.2, WordPress 6.5, Bootstrap 5.3` |
   | `{BRANCH}` | Main branch | `main` |
   | `{BRANCH_STAGING}` | Staging branch | `staging` |
   | `{STANDARDS_LIST}` | Applicable standards | `security, php, tests, frontend` |

3. Remove from Phase 1 the standards that don't apply to the project
4. Adjust specific rules if needed — can be **more** restrictive, never **less**
5. Commit to the repository
