---
name: audit-js
description: Audits JavaScript code in the open PR against the rules defined in docs/js-standards.md. Covers principles, naming, DOM, AJAX, security, UX, and formatting. Manual trigger only.
---

# /audit-js — JavaScript Standards Auditor

Reads the rules from `docs/js-standards.md`, identifies JavaScript files changed in the open (unmerged) PR, and compares each file against every applicable rule. Focuses on: engineering principles, naming, file structure, DOM manipulation, AJAX communication, visual feedback, client-side security, and formatting.

Complements `/audit-frontend` (which covers UX/UI and visual identity).

## When to use

- **ONLY** when the user explicitly types `/audit-js`.
- Run before merging a PR — acts as a JavaScript quality gate.
- **Never** trigger automatically, nor as part of another skill.

## Minimum required standards

> This section contains the complete standards used by the audit. Edit to customize for your project.

# JavaScript programming standards

## Description

Reference document for JavaScript code auditing in the project. Defines mandatory rules and recommendations that every file, function, and JS module must follow. The `/audit-js` skill reads this document and compares it against the target code.

## Scope

- All JavaScript within `assets/js/`
- Vanilla JS or the declared project framework
- AJAX communication via `fetch()`

## References

- [MDN Web Docs — JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
- [WCAG 2.1](https://www.w3.org/TR/WCAG21/)
- `docs/ux-ui-standards.md` — UX/UI standards (complementary)

## Severity

- **ERROR** — Violation blocks approval. Must be fixed before merge.
- **WARNING** — Strong recommendation. Must be justified if ignored.

---

## 1. Fundamental principles

### JS-001 — KISS: simplicity first [WARNING]

Code should be as simple as possible.

### JS-002 — DRY: one rule, one place [ERROR]

Logic is implemented in a single point. If the same calculation or validation appears in two files, extract into a shared module.

### JS-003 — YAGNI: don't build what you don't need now [WARNING]

### JS-004 — Separation of concerns [ERROR]

Each JS file has a clear scope. A file doesn't mix form logic, DOM manipulation, and AJAX communication without structure.

### JS-005 — Law of Demeter: talk only to your neighbors [WARNING]

---

## 2. Style and naming

### JS-006 — Variables and functions in camelCase [ERROR]

```javascript
// correct
var totalValue = 0;
function calculateBalance() {}

// incorrect
var total_value = 0;
function calculate_balance() {}
```

### JS-007 — Constants in UPPER_SNAKE_CASE [WARNING]

### JS-008 — Descriptive names, no obscure abbreviations [WARNING]

### JS-009 — Named functions, never loose anonymous ones [WARNING]

Functions should have descriptive names for easier debugging and stack traces.

---

## 3. File structure

### JS-010 — One file per page/feature [ERROR]

Each JS file corresponds to an isolated page or feature.

### JS-011 — Conditional loading per page [ERROR]

Each JS file is loaded only on the page that uses it. Never load all scripts on all pages.

### JS-012 — Initialization pattern via DOMContentLoaded [ERROR]

Every JS file starts with `document.addEventListener('DOMContentLoaded', ...)` and encapsulates all logic within that scope.

### JS-013 — Guard clause at the top [ERROR]

If the page's main element doesn't exist, return immediately.

```javascript
document.addEventListener('DOMContentLoaded', function () {
    var form = document.getElementById('my-form');
    if (!form) return; // guard clause

    // rest of the logic
});
```

---

## 4. DOM manipulation

### JS-014 — Selection by ID or semantic class, never by tag [ERROR]

Use `getElementById` or `querySelector` with semantic selectors. Never select by generic tag.

### JS-015 — IDs and classes with project prefix [WARNING]

Elements manipulated by JS use a project prefix to avoid collisions.

### JS-016 — addEventListener, never inline onclick [ERROR]

### JS-017 — Create elements via DOM API, never innerHTML for dynamic data [ERROR]

For inserting dynamic user data, use `textContent` or DOM API. `innerHTML` is only acceptable for static templates without user data (prevents XSS).

---

## 5. AJAX communication

### JS-018 — fetch() for all communication, never XMLHttpRequest [ERROR]

### JS-019 — Security token in every AJAX request [ERROR]

Every request includes the appropriate security token (CSRF, nonce, etc.) for the project's framework.

### JS-020 — Action/endpoint with project prefix [ERROR]

### JS-021 — Error handling in every request [ERROR]

Every `fetch()` call handles success, business error, and network error (`.catch()`).

```javascript
// correct — three paths handled
fetch(url, { method: 'POST', body: formData })
    .then(function (resp) { return resp.json(); })
    .then(function (json) {
        if (json.success) {
            // success
        } else {
            showAlert(json.data.message, 'danger');
        }
    })
    .catch(function () {
        showAlert('Connection error. Please try again.', 'danger');
    });
```

### JS-022 — FormData for submission when applicable [WARNING]

---

## 6. Visual feedback and UX

### JS-023 — Loading state on every async operation [ERROR]

While an AJAX operation is in progress, the triggering button is disabled with a spinner.

### JS-024 — Feedback on every user action [ERROR]

Every action produces visual feedback. The user never wonders about the result.

### JS-025 — Client-side validation as UX, not security [WARNING]

Client-side JS validation is for quick user feedback. Real validation happens on the backend.

---

## 7. Security

### JS-026 — Never store sensitive data on the client [ERROR]

Authentication tokens, passwords, API keys never go in `localStorage`, `sessionStorage`, or JS-accessible cookies.

### JS-027 — No eval(), Function(), or innerHTML with user data [ERROR]

Never execute dynamic code. Never insert user data via `innerHTML`. Prevents XSS.

### JS-028 — Backend data is suspect [WARNING]

Even data from your own backend should be inserted with `textContent`, not `innerHTML`.

---

## 8. Compatibility and performance

### JS-029 — Compatibility with target browsers [WARNING]

JavaScript must be compatible with the project's target browsers.

### JS-030 — No unnecessary external libraries [ERROR]

Libraries only enter when justified. The project convention defines which are authorized.

### JS-031 — Event delegation for dynamic lists [WARNING]

For elements that are dynamically added/removed, use event delegation on the parent container.

### JS-032 — No polling, prefer events [WARNING]

Don't use `setInterval` to check state changes. Use DOM events, fetch callbacks, or MutationObserver.

---

## 9. Formatting

### JS-033 — Indentation with 4 spaces [ERROR]

### JS-034 — Braces on the same line [WARNING]

### JS-035 — Maximum 120 characters per line [WARNING]

### JS-036 — Semicolons required [ERROR]

Every statement ends with `;`.

### JS-037 — Single quotes for strings [WARNING]

Prefer single quotes. Template literals only when interpolation is needed.

---

## Audit checklist

The `/audit-js` skill must verify, for each file:

**Principles:**
- [ ] KISS, DRY, YAGNI, SoC, Demeter respected
- [ ] Separation of concerns (one file = one feature)

**Naming:**
- [ ] Variables and functions in camelCase
- [ ] Constants in UPPER_SNAKE_CASE
- [ ] Descriptive names
- [ ] Named functions

**Structure:**
- [ ] One file per page/feature
- [ ] Conditional loading
- [ ] Initialization via DOMContentLoaded
- [ ] Guard clause at the top

**DOM:**
- [ ] Selection by ID/semantic class
- [ ] Project prefix on IDs/classes manipulated by JS
- [ ] addEventListener (no inline onclick)
- [ ] textContent for dynamic data

**AJAX:**
- [ ] fetch() for all communication
- [ ] Security token in every request
- [ ] Success, error, and catch handling

**UX:**
- [ ] Loading state on async operations
- [ ] Visual feedback on every action

**Security:**
- [ ] No sensitive data on the client
- [ ] No eval(), Function(), or innerHTML with user data

**Compatibility:**
- [ ] No unnecessary libraries
- [ ] Event delegation for dynamic lists

**Formatting:**
- [ ] Indentation with 4 spaces
- [ ] Semicolons required
- [ ] Maximum 120 characters per line

## Process

### Phase 1 — Load the ruleset

1. Read the **Minimum required standards** section of this document.
2. Internalize all rules with their IDs, descriptions, examples, and severities (ERROR/WARNING).
3. Do not summarize or recite the document back.

### Phase 2 — Identify the open PR

1. Run `gh pr list --state open --base develop --json number,title,headRefName --limit 1`.
2. If there are multiple open PRs, list all and ask the user which one to audit.
3. If there are no open PRs, inform the user and stop.
4. Run `gh pr diff <number>` to get the full PR diff.
5. Filter only `.js` files from the project.

### Phase 3 — Audit file by file

For each JavaScript file changed in the PR:

1. Read the complete file (not just the diff — context matters).
2. Compare against **every rule** from `docs/js-standards.md`, one by one, in document order.
3. For each violation found, record:
   - **File** and **line(s)** where it occurs
   - **Rule ID** violated (e.g., js-standards.md, JS-018)
   - **Severity** (ERROR or WARNING)
   - **What's wrong** — concise description
   - **How to fix** — specific correction for that snippet
4. If the file violates no rules, record as approved.

### Phase 4 — Report

Present the report to the user in the standard audit format.

### Phase 5 — Correction plan

If there are ERROR violations:

1. List the necessary corrections grouped by file.
2. Ask the user: "Would you like me to apply the corrections now?"

## Rules

- **Never change code during the audit.** The skill is read-only until the user explicitly requests correction.
- **Never audit files outside the PR.** Only JavaScript files changed in the open PR.
- **Always reference the violated rule ID.** The report must be traceable to the standards document.
- **Never invent rules.** The ruleset is exclusively `docs/js-standards.md`.
- **Be methodical and procedural.** Each file is compared against each rule, in document order, without skipping.
- **Fidelity to the document.** If the code violates a rule in the document, report it. If the document doesn't cover the case, don't report it.
- **Show the complete report before any action.** Never apply corrections without explicit approval.
