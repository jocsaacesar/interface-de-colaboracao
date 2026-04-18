---
name: approve-pr
description: Orchestrates audits on the open PR, applies fixes automatically, runs tests, and merges. Manual trigger only.
---

# /approve-pr — Quality pipeline and merge

Takes over the full flow of an open PR: runs the project's standard audits, applies fixes automatically, executes tests, and — if everything passes — performs the merge. It's the conductor that orchestrates the auditor skills and takes the code to production.

## When to use

- **ONLY** when the user explicitly types `/approve-pr`.
- Run when the PR is ready for final review and merge.
- **Never** trigger automatically, nor as part of another skill.

## Process

### Phase 1 — Identify the PR

1. Run `gh pr list --state open --json number,title,headBranch,baseRefName --limit 5` to list open PRs.
2. If there's more than one open PR, list them all and ask the user which one to approve.
3. If there are no open PRs, inform and exit.
4. Run `gh pr diff <number>` to get the full diff.
5. Inform the user:

> "PR #<number> — <title> (branch: <branch> -> <base>). Starting quality pipeline."

### Phase 2 — Run audits

Run **all** available audits in the project in sequence, collecting the report from each one.

For each audit:
- Load the corresponding ruleset (minimum standards embedded in the SKILL.md of each auditor skill)
- Audit all PR files against the rules
- Collect violations (ERROR and WARNING) with file, line, rule, and fix

**Note:** Available audits depend on the project's stack. Adapt this phase to the auditor skills installed in your `.claude/skills/` or linked in the project.

### Phase 3 — Consolidated report

Present a unified report to the user:

```
## Consolidated report — PR #<number>

**Audits executed:** N/N
**Total ERRORs:** <count>
**Total WARNINGs:** <count>

### By audit

| Audit | ERRORs | WARNINGs | Status |
|-------|--------|----------|--------|
| [name] | X | X | OK/ERROR |

### Violations (ERRORs)

[Detailed list with file, line, rule, description, and proposed fix]

### Warnings

[List of WARNINGs — they don't block the merge]
```

If there are **zero ERRORs**, skip to Phase 5 (tests).

### Phase 4 — Apply fixes

If there are ERRORs with possible automatic fixes:

1. Apply all fixes automatically, without asking for individual confirmation.
2. Inform the user what was fixed.
3. Commit the fixes in a **separate commit** (don't mix with the PR's original code).
   - Message: `Fix audit violations (<rule IDs>)`

If there are ERRORs that **cannot be fixed automatically**:

4. **Stop the pipeline.** Do not merge.
5. List the pending ERRORs with details and what needs manual intervention.

> "Pipeline blocked. <X> error(s) need manual correction before merging. See above."

Stop here — the user fixes manually and runs `/approve-pr` again.

### Phase 5 — Run tests

1. Execute the project's relevant test suite.
2. If all tests pass, inform:

> "Tests: all passing."

3. If any test fails:

> "Pipeline blocked. <X> test(s) failing after fixes. See the details below."

List the failing tests and stop. Do not merge.

### Phase 6 — Merge

If all audits passed (zero ERRORs) and all tests passed:

1. Present the final summary:

```
## Ready to merge

**PR:** #<number> — <title>
**ERRORs fixed:** <count>
**WARNINGs (non-blocking):** <count>
**Tests:** passing
**Fix commits:** <count>

Executing merge.
```

2. Run `gh pr merge <number> --merge` (or `--squash` per project convention).
3. Confirm:

> "PR #<number> merged successfully."

## Rules

- **Never merge with unresolved ERRORs.** If an ERROR remains that couldn't be auto-fixed, the pipeline blocks.
- **Never merge without passing tests.** If tests fail after fixes, the pipeline blocks.
- **Always commit fixes in a separate commit.** Don't mix audit fixes with the PR's original code.
- **Never merge without showing the final consolidated report.** The user sees the result before the merge happens.
- **WARNINGs don't block.** They're listed in the report but don't prevent the merge.
- **Never invent rules.** The rulesets are exclusively the minimum standards embedded in each auditor skill's SKILL.md.
- **Never run audits on files outside the PR.** Only what's in the diff.
