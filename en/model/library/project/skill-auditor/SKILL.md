---
name: skill-auditor
description: Audit orchestration skill for projects. Identifies which auditors to apply based on the stack, executes each one, consolidates results, and presents a unified report. Manual trigger only.
---

# /skill-auditor — Audit Orchestrator

Identifies which audit skills (`/audit-*`) apply to the project based on the stack, executes each one in sequence, consolidates results, and presents a unified report. Acts as a quality gate before creating a PR.

## When to use

- After `skill-executor` finishes an implementation.
- When the user requests a complete PR audit.
- As a prerequisite for creating a PR to staging.
- **Never** trigger automatically.

## Process

### Phase 1 — Identify applicable auditors

Based on the project stack, determine which auditors to run:

| Stack | Applicable auditors |
|-------|---------------------|
| PHP | `/audit-php` |
| OOP/Entities | `/audit-oop` |
| PHPUnit Tests | `/audit-tests` |
| Security | `/audit-security` |
| Cryptography | `/audit-crypto` |
| HTML/CSS | `/audit-frontend` |
| JavaScript | `/audit-js` |

### Phase 2 — Execute auditors in sequence

For each applicable auditor:

1. Execute the audit skill.
2. Collect the report (ERROR and WARNING violations).
3. Accumulate results.

Recommended order (from most critical to least):
1. Security (SEG-*)
2. Cryptography (CRYPTO-*)
3. PHP (PHP-*)
4. OOP (OOP-*)
5. Tests (TST-*)
6. Frontend (UI-*)
7. JavaScript (JS-*)

### Phase 3 — Consolidate report

Present a unified report:

```
## Complete Audit Report

**PR:** #<number> — <title>
**Branch:** <branch>
**Auditors executed:** <list>

### Overall summary

| Auditor | Errors | Warnings | Status |
|---------|--------|----------|--------|
| Security | 0 | 2 | Approved |
| PHP | 1 | 3 | Blocked |
| OOP | 0 | 1 | Approved |
| Tests | 2 | 0 | Blocked |

**Total:** {N} errors, {M} warnings

### Blocking violations (ERROR)

#### php-standards.md, PHP-024
- **File:** inc/entities/Order.php:15
- **Description:** FSM not defined
- **Fix:** Add STATUS_TRANSITIONS

#### test-standards.md, TST-005
- **File:** inc/managers/OrderManager.php
- **Description:** New code without corresponding test
- **Fix:** Create OrderManagerTest in tests/component/

### Warnings (recommendations)
{list of warnings}

### Verdict
{N} blocking errors. PR cannot be merged until fixed.
Would you like me to apply the corrections now?
```

### Phase 4 — Fix or escalate

If there are ERROR violations:
1. Ask the user whether to fix.
2. If authorized, fix and re-audit.
3. Repeat until ERRORs reach zero.

If there are only WARNINGs:
> "No blocking errors. The warnings are recommendations — would you like me to fix any?"

If no violations:
> "Audit complete. No violations found. PR ready for merge."

## Rules

- **All applicable auditors run.** Don't skip any for speed or convenience.
- **ERRORs block.** A PR with ERRORs cannot be created/merged.
- **WARNINGs require justification.** If the user decides to ignore a WARNING, record the justification.
- **Re-audit after corrections.** If corrections were made, run the audit again to confirm.
- **Never invent rules.** Each auditor follows exclusively its standards document.
- **Consolidated report before any action.** Show everything before fixing.
