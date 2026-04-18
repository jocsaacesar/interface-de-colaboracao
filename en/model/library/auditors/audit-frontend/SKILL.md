---
name: audit-frontend
description: Audits HTML, CSS, JavaScript, and UX in the open PR against the rules defined in docs/ux-ui-standards.md. Covers visual identity, CSS framework, UX, forms, accessibility, and interactivity. Manual trigger only.
---

# /audit-frontend — Frontend and UX/UI Standards Auditor

Reads the rules from `docs/ux-ui-standards.md`, identifies HTML, CSS, and JavaScript files changed in the open (unmerged) PR, and compares each file against every applicable rule. Focuses on: brand visual tokens, CSS framework conventions, UX, forms, tables, dashboards, accessibility, and JavaScript.

## When to use

- **ONLY** when the user explicitly types `/audit-frontend`.
- Run before merging a PR — acts as a visual and UX quality gate.
- **Never** trigger automatically, nor as part of another skill.

## Minimum required standards

> This section contains the complete standards used by the audit. Edit to customize for your project.

# UX/UI and visual style standards

## Description

Reference document for interface, user experience, and visual style auditing in the project. Defines brand visual tokens, CSS framework conventions, UX patterns, and accessibility. The `/audit-frontend` skill reads this document and compares it against the target code.

## Scope

- All HTML in project templates and pages
- All CSS in `assets/css/`
- All JavaScript in `assets/js/`

## References

- [WCAG 2.1 — Web Content Accessibility Guidelines](https://www.w3.org/TR/WCAG21/)
- [HTML Living Standard — Input modes](https://html.spec.whatwg.org/multipage/interaction.html#input-modalities:-the-inputmode-attribute)

## Severity

- **ERROR** — Violation blocks approval. Must be fixed before merge.
- **WARNING** — Strong recommendation. Must be justified if ignored.

---

## 1. Brand visual tokens

### UI-001 — Colors defined as CSS custom properties [ERROR]

All brand colors are declared as CSS variables at the root. Never use hex values directly in components.

```css
/* assets/css/style.css */
:root {
    /* Brand colors */
    --app-primary: #XXXXXX;
    --app-primary-hover: #XXXXXX;
    --app-primary-light: #XXXXXX;

    /* Semantic */
    --app-success: #198754;
    --app-error: #dc3545;
    --app-info: #0dcaf0;

    /* Neutrals */
    --app-bg: #faf8f6;
    --app-bg-card: #ffffff;
    --app-text: #3d3d3d;
    --app-text-muted: #939393;
    --app-border: #e8e0da;
}
```

```html
<!-- correct — uses variable -->
<div style="color: var(--app-success);">Operation completed</div>

<!-- incorrect — hardcoded color -->
<div style="color: #198754;">Operation completed</div>
```

### UI-002 — Semantic colors for domain data [ERROR]

Each type of domain data has a fixed semantic color. Never mix meanings.

### UI-003 — Brand typography [WARNING]

The project font is declared via CSS custom property. Body uses a safe font stack as fallback.

```css
:root {
    --app-font-family: 'YourFont', sans-serif;
    --app-font-mono: monospace;
}

body {
    font-family: var(--app-font-family);
    color: var(--app-text);
    background-color: var(--app-bg);
}
```

### UI-004 — Numeric values in monospace font [WARNING]

Numbers that need visual alignment use monospace font.

```html
<!-- correct -->
<span class="font-monospace">1,500.00</span>
```

### UI-005 — Brand logo and icon [ERROR]

The logo is a graphic asset — never recreated via CSS or text. Served as optimized SVG or PNG.

### UI-006 — Brand visual elements [WARNING]

Visual identity includes icons, patterns, and tagline. Use as decorative elements per the brand guide.

---

## 2. CSS framework — best practices

### UI-007 — Utility-first, custom CSS only when necessary [WARNING]

Prefer the CSS framework's utility classes. Custom CSS only when utilities don't cover the case.

### UI-008 — Grid system for layout, never manual positioning [ERROR]

Layouts use the framework's grid system. Never use `float`, `position: absolute` for page layout.

### UI-009 — Standard framework responsive breakpoints [ERROR]

Use the framework's native breakpoints. Never create media queries with custom values.

### UI-010 — Native framework components, don't reinvent [WARNING]

Use framework components (cards, modals, alerts, tables, badges) before creating custom components.

### UI-011 — No !important [ERROR]

Never use `!important` in custom CSS. If you need to override, use higher specificity or CSS custom properties.

### UI-012 — No inline CSS in HTML [ERROR]

Styles live in CSS files or utility classes. Never `style=""` directly in HTML, except for dynamic values injected by code (e.g., progress bar width).

### UI-013 — Dark mode ready [WARNING]

Use a theme attribute on `<html>` and respect the framework's CSS variables. When dark mode is implemented, just switch the attribute.

---

## 3. Domain UX

### UI-014 — Privacy mode (hide sensitive data) [ERROR]

If the domain requires it, the dashboard must have a button to hide/show sensitive data.

### UI-015 — Quick actions on the dashboard [WARNING]

The home screen displays primary actions prominently. Always accessible without scrolling or deep navigation.

### UI-016 — Positive friction for critical operations [ERROR]

Every operation that changes critical state requires explicit user confirmation via modal.

### UI-017 — Visual feedback on every action [ERROR]

Every user action produces visual feedback: success toast, error alert, loading spinner. The user never wonders whether the action worked.

### UI-018 — Empty states with guidance [WARNING]

When a list is empty, display a message guiding the user on what to do.

---

## 4. Forms

### UI-019 — Correct inputmode for numeric fields [ERROR]

Numeric value fields use `inputmode="decimal"` or `inputmode="numeric"` to invoke the numeric keyboard on mobile devices.

### UI-020 — inputmode="numeric" for code/PIN fields [WARNING]

### UI-021 — Labels required on every form field [ERROR]

Every `<input>`, `<select>`, and `<textarea>` has an associated `<label>` via `for`/`id`. Never use placeholder as a label substitute.

### UI-022 — Visual validation via CSS framework [WARNING]

Use the CSS framework's validation classes for error messages.

### UI-023 — Forms grouped with fieldset and legend [WARNING]

Complex forms use `<fieldset>` and `<legend>` to group related fields.

---

## 5. Tables and listings

### UI-024 — Responsive tables [ERROR]

Every table uses a responsive mechanism for horizontal scrolling on small screens.

### UI-025 — Right-aligned values in tables [ERROR]

Columns with numeric values are right-aligned and use monospace font.

### UI-026 — Status with colored badges [WARNING]

Statuses are displayed with badges using semantic colors.

---

## 6. Dashboards and charts

### UI-027 — Cards for dashboard metrics [WARNING]

Key metrics are displayed in cards with responsive layout.

### UI-028 — Charts with accessible text alternative [ERROR]

Every chart must have an accessible text description via `aria-label` or hidden text.

### UI-029 — Chart colors consistent with brand tokens [WARNING]

Charts use the same colors defined in CSS custom properties.

---

## 7. Accessibility

### UI-030 — Minimum WCAG AA contrast [ERROR]

All text has a minimum contrast ratio of 4.5:1 against the background (WCAG AA). Large text (18px+) accepts 3:1.

### UI-031 — Functional keyboard navigation [ERROR]

Every interactive element is accessible via keyboard (Tab, Enter, Escape). Logical tab order.

### UI-032 — ARIA roles on dynamic components [WARNING]

Dynamic components (modals, toasts, dropdowns) use correct ARIA roles.

### UI-033 — No information conveyed by color alone [ERROR]

Indicators never rely solely on color. Always accompanied by an icon, sign (+/-), or text.

```html
<!-- correct — color + sign -->
<span class="text-success font-monospace">+1,500.00</span>
<span class="text-danger font-monospace">-800.00</span>

<!-- incorrect — color only -->
<span class="text-success font-monospace">1,500.00</span>
<span class="text-danger font-monospace">800.00</span>
```

---

## 8. JavaScript and interactivity

### UI-034 — Vanilla JS or declared framework [ERROR]

All JavaScript follows the project convention (vanilla, specific framework, etc.). No unauthorized libraries.

### UI-035 — Events via addEventListener, no inline onclick [ERROR]

```javascript
// correct
document.getElementById('btn').addEventListener('click', handleClick);

// incorrect
// <button onclick="handleClick()">
```

### UI-036 — Fetch for AJAX, never XMLHttpRequest [WARNING]

Backend communication via `fetch()`.

### UI-037 — Loading state on every async operation [ERROR]

While an async operation is in progress, the triggering button is disabled with a spinner.

---

## Audit checklist

The `/audit-frontend` skill must verify, for each file:

**Visual tokens:**
- [ ] Colors via CSS custom properties, never hardcoded
- [ ] Correct semantic colors
- [ ] Numeric values in monospace font

**CSS framework:**
- [ ] Utility-first, custom CSS only when necessary
- [ ] Grid system for layout
- [ ] Native framework breakpoints
- [ ] No `!important`
- [ ] No static inline CSS

**Domain UX:**
- [ ] Positive friction on critical operations
- [ ] Visual feedback on every action
- [ ] Empty states with guidance

**Forms:**
- [ ] Correct `inputmode` on numeric fields
- [ ] Labels associated via for/id on every field
- [ ] Visual validation via framework

**Tables:**
- [ ] Responsive tables
- [ ] Right-aligned values in monospace

**Dashboards:**
- [ ] Charts with accessible text alternative
- [ ] Chart colors consistent with tokens

**Accessibility:**
- [ ] Minimum WCAG AA contrast (4.5:1)
- [ ] Functional keyboard navigation
- [ ] No information conveyed by color alone

**JavaScript:**
- [ ] Project JS convention respected
- [ ] addEventListener, no inline onclick
- [ ] fetch() for AJAX
- [ ] Loading state on async operations

## Process

### Phase 1 — Load the ruleset

1. Read the **Minimum required standards** section of this document.
2. Internalize all rules with their IDs, descriptions, examples, and severities (ERROR/WARNING).
3. Do not summarize or recite the document back.

### Phase 2 — Identify the open PR

1. Run `gh pr list --state open --base develop --json number,title,headBranch --limit 1`.
2. If there are multiple open PRs, list all and ask the user which one to audit.
3. If there are no open PRs, inform the user and stop.
4. Run `gh pr diff <number>` to get the full PR diff.
5. Filter `.php` (templates with HTML), `.css`, `.js` files from the project.

### Phase 3 — Audit file by file

For each file changed in the PR:

1. Read the complete file (not just the diff — context matters).
2. Compare against **every rule** from `docs/ux-ui-standards.md`, one by one, in document order.
3. For each violation found, record:
   - **File** and **line(s)** where it occurs
   - **Rule ID** violated (e.g., ux-ui-standards.md, UI-012)
   - **Severity** (ERROR or WARNING)
   - **What's wrong** — concise description
   - **How to fix** — specific correction for that snippet
4. If the file violates no rules, record as approved.

### Phase 4 — Report

Present the report to the user in the standard audit format.

### Phase 5 — Correction plan

If there are ERROR violations:

1. List the necessary corrections grouped by file.
2. Order by severity (ERRORs first, WARNINGs after).
3. Ask the user: "Would you like me to apply the corrections now?"

## Rules

- **Never change code during the audit.** The skill is read-only until the user explicitly requests correction.
- **Never audit files outside the PR.** Only files changed in the open PR.
- **Always reference the violated rule ID.** The report must be traceable to the standards document.
- **Never invent rules.** The ruleset is exclusively `docs/ux-ui-standards.md`.
- **Be methodical and procedural.** Each file is compared against each rule, in document order, without skipping.
- **Fidelity to the document.** If the code violates a rule in the document, report it. If the document doesn't cover the case, don't report it.
- **Check consistency with visual identity.** Colors must use brand custom properties, never hex directly.
- **Show the complete report before any action.** Never apply corrections without explicit approval.
