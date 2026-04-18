---
document: js-standards
version: 2.1.0
created: 2025-06-01
updated: 2026-04-16
total_rules: 37
severities:
  error: 21
  warning: 16
stack: js
scope: All JavaScript code — vanilla JS, frameworks, Node.js, build scripts
applies_to: ["all"]
requires: []
replaces: ["js-standards v2.0.0"]
---

# JavaScript Standards — your organization

> Constitutional document. Delivery contract for every
> developer who touches JavaScript in our projects.
> Code that violates ERROR rules is not discussed — it is returned.

---

## How to use this document

### For the developer

1. Read this document before writing JavaScript in any project.
2. Use the rule IDs (JS-001 to JS-037) to reference in PRs and code reviews.
3. Check the DoD at the end before opening any Pull Request.

### For the auditor (human or AI)

1. Read the frontmatter to understand scope and dependencies.
2. Audit the code against each rule by ID.
3. Classify violations by the severity defined in this document.
4. Reference violations by rule ID (e.g., "violates JS-014").

### For Claude Code

1. Read the frontmatter to identify scope and severities.
2. When reviewing JS code, check each rule by ID.
3. ERROR violations block merge — report as blocking.
4. WARNING violations should be reported, but accept written justification.
5. Always reference by ID (e.g., "violates JS-027").

---

## Severities

| Level | Meaning | Action |
|-------|---------|--------|
| **ERROR** | Non-negotiable violation | Blocks merge. Fix before review. |
| **WARNING** | Strong recommendation | Must be justified in writing if ignored. |

---

## 1. Fundamental principles

### JS-001 — KISS: simplicity first [WARNING]

**Rule:** Code should be as simple as possible. If there's a direct way to solve it, use that. Abstractions, patterns, and indirections only enter when the problem demands it.

**Checks:** Grep for wrapper classes, factories, or adapters without more than one consumer. Function with >1 level of indirection without justification = violation.

### JS-002 — DRY: one rule, one place [ERROR]

**Rule:** Logic is implemented in a single place. If the same calculation or validation appears in two files, extract to a shared module.

**Checks:** Grep for identical or near-identical code blocks in distinct files. Duplication >3 lines of logic = violation.

### JS-003 — YAGNI: don't build what you don't need now [WARNING]

**Rule:** Never implement functions, classes, or parameters thinking about "future possibilities". Implement strictly what the current requirement demands.

**Checks:** Function with parameters no caller passes, or code branch with no test exercising it = violation.

### JS-004 — Separation of concerns [ERROR]

**Rule:** Each JS file has a clear scope. A file never mixes form logic, DOM manipulation, and AJAX communication without structure. Separate into functions with single responsibility.

**Checks:** Function with >1 responsibility (validates + sends + renders) = violation. Each function should do one thing.

### JS-005 — Law of Demeter: only talk to your neighbors [WARNING]

**Rule:** Don't chain calls that traverse multiple objects. Only access properties and methods of the immediate object.

**Checks:** Grep for chains with 3+ consecutive dots (e.g., `a.b.c.d`). Chaining >2 levels without intermediate variable = violation.

---

## 2. Style and naming

### JS-006 — Variables and functions in camelCase [ERROR]

**Rule:** Every variable and function must use camelCase. No exceptions.

**Checks:** Grep for `var [a-z]+_[a-z]` and `function [a-z]+_[a-z]`. snake_case in a variable or function = violation.

### JS-007 — Constants in UPPER_SNAKE_CASE [WARNING]

**Rule:** Constant values that don't change during execution must use UPPER_SNAKE_CASE.

**Checks:** Grep for `var [a-z]` or `const [a-z]` assigned to a fixed literal value. Constant in camelCase = violation.

### JS-008 — Descriptive names, no obscure abbreviations [WARNING]

**Rule:** Variables, functions, and parameters must have names that describe their purpose. Abbreviations are only accepted when universally known (url, id, btn).

**Checks:** Variables of 1-2 characters (except `i`, `j`, `e`, `_`) or non-universal abbreviations = violation.

### JS-009 — Named functions, never loose anonymous ones [WARNING]

**Rule:** Functions should have descriptive names for debugging and stack traces. Exception: short one-line callbacks in `.then()` or `.forEach()`.

**Checks:** Grep for `function\s*\(` (anonymous) with body >1 line. Anonymous callback with >1 line = violation.

---

## 3. File structure

### JS-010 — One file per page/feature [ERROR]

**Rule:** Each JS file corresponds to one page or isolated feature. Never a monolithic file with all application logic.

**Checks:** JS file with >300 lines or with >2 distinct responsibilities = violation. Inspect directory structure.

### JS-011 — Conditional script loading [ERROR]

**Rule:** Each JS file should be loaded only on the page or context that uses it. Never load all scripts on all pages. In WordPress, use `wp_enqueue_script()` with a page condition. In other contexts, use the equivalent strategy (dynamic import, lazy loading, routes).

**Checks:** Grep for `wp_enqueue_script` without page conditional, or global `<script>` without lazy/conditional = violation.

### JS-012 — Encapsulated initialization pattern [ERROR]

**Rule:** Every frontend JS file must encapsulate its logic. In the browser, use `document.addEventListener('DOMContentLoaded', ...)` or IIFE. In Node.js, use modules (module.exports / export). Never pollute the global scope.

**Checks:** File without `DOMContentLoaded`, IIFE, or `module.exports` at the top = violation. `var` in global scope outside encapsulation = violation.

### JS-013 — Guard clause at the start [ERROR]

**Rule:** If the page's main element or required resource doesn't exist, return immediately. Never execute logic against elements that may be null.

**Checks:** Grep for `getElementById`/`querySelector` without `if (!el) return` in the following lines = violation.

---

## 4. DOM manipulation

### JS-014 — Selection by ID or semantic class, never by tag [ERROR]

**Rule:** Use `getElementById` or `querySelector` with semantic selectors. Never select by generic tag (`div`, `p`, `span`).

**Checks:** Grep for `querySelector('div')`, `querySelector('p')`, `querySelectorAll('span')` and similar without class/ID = violation.

### JS-015 — IDs and classes with project namespace prefix [WARNING]

**Rule:** Elements manipulated by JS should use the project's defined namespace prefix to avoid collision with external libraries or other scripts.

**Checks:** Grep for `getElementById` and `querySelector` whose selector doesn't start with the project prefix = violation.

### JS-016 — addEventListener, never inline onclick [ERROR]

**Rule:** Events must be registered via `addEventListener`. Never use `onclick`, `onsubmit`, or similar attributes in HTML.

**Checks:** Grep for `onclick=`, `onsubmit=`, `onchange=` and similar in HTML/PHP files = violation.

### JS-017 — Create elements via DOM API, never innerHTML for dynamic data [ERROR]

**Rule:** To insert dynamic user data, use `textContent` or DOM API (`createElement`, `appendChild`). `innerHTML` is only acceptable for static templates without user data.

**Checks:** Grep for `innerHTML\s*=` followed by a variable (not a static string literal) = violation.

---

## 5. AJAX communication

### JS-018 — fetch() for all communication, never XMLHttpRequest [ERROR]

**Rule:** All asynchronous communication must use `fetch()`. XMLHttpRequest is prohibited.

**Checks:** Grep for `XMLHttpRequest`, `new XMLHttpRequest`, `$.ajax`, `$.get`, `$.post` = violation.

### JS-019 — Nonce or token mandatory in every AJAX request [ERROR]

**Rule:** Every AJAX request must include an authentication/verification token (nonce in WordPress, CSRF token in other frameworks). Never hardcode tokens in HTML.

**Checks:** Grep for `fetch()` calls without `nonce`, `csrf`, `token`, or `_wpnonce` in body/headers = violation. Grep for hardcoded token in string literal = violation.

### JS-020 — Action/endpoint with namespace prefix [ERROR]

**Rule:** Every AJAX action or endpoint name must use the project's namespace prefix to avoid collision. In WordPress, prefix the action. In REST APIs, use namespace in the URL.

**Checks:** Grep for `'action',` followed by string without project prefix = violation. REST endpoint without namespace in URL = violation.

### JS-021 — Error handling in every request [ERROR]

**Rule:** Every `fetch()` call must handle three paths: success, business error (`json.success === false` or HTTP status 4xx/5xx), and network error (`.catch()`).

**Checks:** Grep for `fetch(` and verify the chain includes `.catch(`. Fetch without `.catch()` = violation. Fetch without business error branch = violation.

### JS-022 — FormData for backend submission, never manual JSON without need [WARNING]

**Rule:** Prefer `FormData` for form submission. Manual JSON only when the API explicitly requires `application/json`. In WordPress, `FormData` is mandatory for `admin-ajax.php`.

---

## 6. Visual feedback and UX

### JS-023 — Loading state in every async operation [ERROR]

**Rule:** While an async operation is in progress, the element that triggered it must be disabled and show a visual loading indicator. Prevents double clicks and informs the user.

**Checks:** Grep for `fetch(` and verify the button/element is disabled before and re-enabled in `.finally()`. Fetch without pre-send `disabled = true` = violation.

### JS-024 — Feedback on every user action [ERROR]

**Rule:** Every user action must produce visual feedback: alert for errors, success message, or UI state change. The user must never be left without knowing the result of an action.

**Checks:** Each action handler (submit, click, etc.) must have a visual feedback call (alert, toast, CSS class). Handler without feedback = violation.

### JS-025 — Client validation as UX, not as security [WARNING]

**Rule:** JS validation serves for quick user feedback. Real validation always happens on the backend. Never rely solely on client validation.

---

## 7. Security

### JS-026 — Never store sensitive data on the client [ERROR]

**Rule:** Authentication tokens, passwords, API keys never go in `localStorage`, `sessionStorage`, or JS-accessible cookies. Sensitive data in memory (JS variable) dies with the page — and that's correct behavior.

**Checks:** Grep for `localStorage.setItem`, `sessionStorage.setItem`, `document.cookie` with token/password/key = violation.

### JS-027 — No eval(), Function(), or innerHTML with user data [ERROR]

**Rule:** Never execute dynamic code with `eval()` or `new Function()`. Never insert user data via `innerHTML`. These practices are XSS vectors.

**Checks:** Grep for `eval(`, `new Function(`, `innerHTML\s*=` with non-static data = violation. Zero tolerance.

### JS-028 — Backend data is suspect [WARNING]

**Rule:** Even data from your own backend should be inserted with `textContent`, never with `innerHTML`. The database may have been compromised or contain malicious data inserted via another vector.

---

## 8. Compatibility and performance

### JS-029 — Modern JavaScript without unnecessary transpilation [WARNING]

**Rule:** Prefer vanilla JS compatible with modern browsers. ES6+ features (`const`, `let`, arrow functions, template literals) are acceptable. If the project doesn't use a build step, code must run directly in the browser. If it uses a build step, document it in the project's CLAUDE.md.

**Checks:** Grep for `await`, `?.`, `??` in a project without a build step = violation. Check the project's CLAUDE.md to confirm if a build step exists.

**Exceptions:** Projects with a documented build step (Next.js, Vite, etc.) can use any feature supported by the transpiler.

### JS-030 — No unnecessary external libraries [ERROR]

**Rule:** External libraries only enter when justified by complexity not worth reimplementing. jQuery is prohibited. Each dependency must be approved and documented.

**Checks:** Grep for `jquery`, `$.(`, `$.ajax` = violation. Grep for `<script src=` external not documented in the project's CLAUDE.md = violation.

### JS-031 — Event delegation for dynamic lists [WARNING]

**Rule:** For elements added/removed dynamically, use event delegation on the parent container. Never register listeners on each individual item.

**Checks:** Grep for `.forEach(` + `addEventListener` inside a loop on dynamic lists = violation. Verify the listener is on the parent container.

### JS-032 — No polling, prefer events [WARNING]

**Rule:** Never use `setInterval` to check for state changes. Use DOM events, fetch callbacks, MutationObserver, or WebSockets when needed.

**Checks:** Grep for `setInterval` = violation (except UI timers like countdowns). Each occurrence must have documented justification.

---

## 9. Formatting

### JS-033 — Indentation with 4 spaces [ERROR]

**Rule:** All indentation must use 4 spaces. Tabs are prohibited.

**Checks:** Grep for `\t` (literal tab) in JS files = violation. Verify with editor/linter.

### JS-034 — Opening braces on the same line [WARNING]

**Rule:** Opening braces go on the same line as the declaration. Never on the next line.

**Checks:** Grep for `^\s*\{` on an isolated line after `if`, `else`, `function`, `for`, `while` = violation.

### JS-035 — Maximum 120 characters per line [WARNING]

**Rule:** Lines exceeding 120 characters should be wrapped with logical alignment.

**Checks:** `grep -P '.{121,}' *.js`. Line >120 characters = violation.

### JS-036 — Semicolons mandatory [ERROR]

**Rule:** Every statement ends with `;`. Never rely on ASI (Automatic Semicolon Insertion).

**Checks:** Grep for statement lines (assignment, call, return) that don't end with `;` = violation.

### JS-037 — Single quotes for strings [WARNING]

**Rule:** Prefer single quotes for strings. Template literals (backticks) only when interpolation or multiline strings are needed.

**Checks:** Grep for strings with double quotes (`"..."`) without need = violation. Backtick without `${` = violation.

---

## Definition of Done — Delivery Checklist

> PRs that don't meet the DoD don't enter review. They are returned.

| # | Item | Rules | Verification |
|---|------|-------|--------------|
| 1 | Semicolons on all statements | JS-036 | Search for lines without `;` at the end |
| 2 | Indentation with 4 spaces, no tabs | JS-033 | Verify with editor/linter |
| 3 | No `eval()`, `Function()`, or `innerHTML` with user data | JS-027 | Grep for `eval(`, `new Function(`, `innerHTML =` |
| 4 | No sensitive data in localStorage/sessionStorage | JS-026 | Grep for `localStorage`, `sessionStorage` |
| 5 | Nonce/token in every AJAX request | JS-019 | Verify every `fetch()` call |
| 6 | Error handling (success + error + catch) in every fetch | JS-021 | Verify `.catch()` in every fetch chain |
| 7 | Loading state in async operations | JS-023 | Verify `disabled` and spinner on submit buttons |
| 8 | Visual feedback on every user action | JS-024 | Manually test each flow |
| 9 | Guard clause at the start of each initialization | JS-013 | Verify `if (!element) return;` |
| 10 | No unapproved external libraries | JS-030 | Verify imports and external scripts |
| 11 | Variables in camelCase, constants in UPPER_SNAKE_CASE | JS-006, JS-007 | Visual inspection |
| 12 | Named functions (no long anonymous ones) | JS-009 | Verify `function () {` with more than 1 line |
| 13 | DOMContentLoaded or equivalent encapsulation | JS-012 | Verify start of file |
| 14 | Semantic selectors with project prefix | JS-014, JS-015 | Verify `querySelector` and `getElementById` |
| 15 | Lines with maximum 120 characters | JS-035 | Verify with editor/linter |
