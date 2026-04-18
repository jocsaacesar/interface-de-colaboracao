---
document: frontend-standards
version: 2.2.0
created: 2025-06-01
updated: 2026-04-16
total_rules: 38
severities:
  error: 21
  warning: 17
scope: HTML, CSS, and UX across all web projects
stack: frontend
applies_to: ["all"]
requires: [security-standards, js-standards]
replaces: [frontend-standards-v1]
---

# Frontend/UX/UI Standards — your organization

> Constitutional document. Delivery contract for every
> developer who touches frontend in our projects.
> Code that violates ERROR rules is not discussed — it is returned.

---

## How to use this document

### For the developer

1. Read this document before touching HTML, CSS, or UX in any project. JavaScript rules live in `js-standards.md`.
2. Reference rule IDs during development and before opening a PR.
3. Check the DoD at the end of this document before requesting review.

### For the auditor (human or AI)

1. Read the frontmatter to understand scope and dependencies.
2. Audit each file against the rules by ID and severity.
3. Classify violations: ERROR blocks merge, WARNING requires written justification.
4. Reference violations by rule ID (e.g., "violates UI-011").

### For Claude Code

1. Read the frontmatter to identify scope and dependencies.
2. When generating frontend code, apply all rules in this document automatically. For JS, apply `js-standards.md`.
3. In code review, reference violations by ID (e.g., "UI-012 — no static inline CSS").
4. Never generate code that violates ERROR rules. WARNING rules can be relaxed with explicit justification in the PR.

---

## Severities

| Level | Meaning | Action |
|-------|---------|--------|
| **ERROR** | Non-negotiable violation | Blocks merge. Fix before review. |
| **WARNING** | Strong recommendation | Must be justified in writing if ignored. |

---

## 1. Design tokens and visual identity

### UI-001 — Colors defined as CSS custom properties [ERROR]

**Rule:** All project colors are declared as CSS variables in `:root`. Never use hex, RGB, or HSL values directly in components.

**Checks:** Search for `#[0-9a-fA-F]`, `rgb(`, `hsl(` outside the `:root` block. Any occurrence in a component is a violation.

**Why:** The project works with multiple projects, each with its own visual identity. Centralized design tokens allow Claude Code to generate components without knowing the specific palette — just reference the variables. When the designer changes a color, the change propagates automatically.

**Correct example:**
```css
/* project tokens — defined once */
:root {
    --brand-primary: #E2C5B0;
    --brand-primary-hover: #d4b39e;
    --brand-secondary: #EFD7D3;
    --color-text: #3d3d3d;
    --color-text-muted: #939393;
    --color-bg: #faf8f6;
    --color-bg-card: #ffffff;
    --color-border: #e8e0da;
}
```

```html
<!-- correct usage — references the token -->
<div style="color: var(--color-success);">Operation completed</div>
```

**Incorrect example:**
```html
<!-- hardcoded color — breaks when palette changes -->
<div style="color: #198754;">Operation completed</div>
```

### UI-002 — Semantic colors for meaningful data [ERROR]

**Rule:** Data that carries meaning (status, categories, indicators) uses semantic tokens (e.g., `--color-success`, `--color-danger`, `--color-info`). Never mix meanings — green always means positive/success, red always means negative/error.

**Checks:** Inspect status badges/spans. Does the applied color contradict the displayed text? Violation.

**Why:** Projects frequently involve financial data, statuses, and metrics. If each developer picks arbitrary colors, users lose the ability to scan the interface quickly. Semantic consistency reduces interpretation errors.

### UI-003 — Typography via design tokens [WARNING]

**Rule:** Project fonts are declared as CSS variables. The application body uses the font stack defined in the `--font-family-base` token. Brand fonts (logo, special headings) are served as graphic assets or web fonts declared in the token.

**Checks:** Search for `font-family:` outside `:root`. Value that doesn't use `var(--font-family-*)` is a violation.

### UI-004 — Numeric values aligned in monospace font [WARNING]

**Rule:** Numbers that need visual alignment (monetary values, quantities in tables, metrics) use a monospace font via the `--font-family-mono` token or equivalent utility class.

**Checks:** Inspect numeric columns in tables and cards. Is the rendered font proportional? Violation.

### UI-005 — Logo as graphic asset, never recreated in CSS [ERROR]

**Rule:** The project logo is served as an optimized SVG or PNG. Never recreate logos via CSS, styled text, or combined icons.

**Checks:** Search for elements with class `logo` or `brand`. Is it an `<img>` with `src` pointing to SVG/PNG? If not, violation.

### UI-006 — Brand visual elements follow the project guide [WARNING]

**Rule:** Each project has a visual identity guide (provided by the designer). Decorative icons, patterns, slogans, and brand graphic elements must follow that guide. Don't invent brand visual elements without reference to the guide.

**Checks:** Does the decorative/brand icon element have a match in the project's identity guide? If not, violation.

---

## 2. CSS — conventions and restrictions

### UI-007 — Utility-first, custom CSS only when necessary [WARNING]

**Rule:** Prefer utility classes from the adopted CSS framework (Bootstrap, Tailwind, etc.). Custom CSS only when the utility doesn't cover the case (animations, pseudo-elements, very specific layouts).

**Checks:** Does newly added custom CSS have an equivalent framework utility? If so, violation.

### UI-008 — Grid system for layout, never manual positioning [ERROR]

**Rule:** Page layouts use the CSS framework's grid system (`container`, `row`, `col-*`, or Flexbox/Grid equivalents). Never use `float` or `position: absolute` for page layout.

**Checks:** Search for `float:` and `position: absolute` in page layout CSS. Any occurrence is a violation.

### UI-009 — Framework responsive breakpoints, no custom values [ERROR]

**Rule:** Use the native breakpoints of the adopted CSS framework. Never create media queries with arbitrary values.

**Checks:** Search for `@media` in custom CSS. Does the breakpoint value match the framework's? If not, violation.

### UI-010 — Framework components before custom components [WARNING]

**Rule:** Use the CSS framework's native components (cards, modals, alerts, tables, badges, dropdowns, toasts) before creating custom ones. Build from scratch only when the framework offers no solution.

**Checks:** Does the newly created custom component have a native framework equivalent? If so, violation.

### UI-011 — No !important [ERROR]

**Rule:** Never use `!important` in custom CSS. To override framework styles, use higher specificity or CSS custom properties.

**Checks:** Search for `!important` in project CSS/SCSS files. Any occurrence is a violation.

### UI-012 — No inline CSS in HTML [ERROR]

**Rule:** Styles live in CSS files or in framework utility classes. Never use the `style=""` attribute directly in HTML, except for dynamic values injected by backend/JS (e.g., progress bar width, user-defined color).

**Checks:** Search for `style="` in HTML. Is the value static (not injected by backend/JS)? Violation.

### UI-013 — Dark mode prepared via theme attribute [WARNING]

**Rule:** Use a theme attribute on `<html>` (e.g., `data-bs-theme="light"`, `data-theme="light"`) and respect the framework's CSS variables. Project design tokens should have variants for both themes.

**Checks:** Do tokens in `:root` have a corresponding `[data-theme="dark"]` variant? If not, violation.

---

## 3. UX — interaction and feedback

### UI-014 — Privacy mode for sensitive data [ERROR]

**Rule:** Interfaces displaying sensitive data (financial values, personal data, confidential metrics) must have a control that hides/shows that data. When hidden, values are replaced with `*****`. The state persists in `localStorage`.

**Checks:** Does the screen display a financial value or personal data? Is there a privacy toggle button? If not, violation.

### UI-015 — Primary actions accessible without scrolling [WARNING]

**Rule:** The initial screen of any application displays primary actions prominently, accessible without scrolling or deep navigation.

**Checks:** Open the initial screen at 375px viewport. Is the primary action visible without scrolling? If not, violation.

### UI-016 — Positive friction for destructive or irreversible operations [ERROR]

**Rule:** Every operation that significantly alters state (confirm transaction, cancel, delete, archive) requires explicit user confirmation via modal or intermediate step.

**Checks:** Click a destructive button (delete, cancel, archive). Does a confirmation modal/step appear? If not, violation.

### UI-017 — Visual feedback on every user action [ERROR]

**Rule:** Every user action produces immediate visual feedback: success toast, error alert, loading spinner. The user must never be left wondering if the action worked.

**Checks:** Execute each flow action. Does a toast/alert/spinner appear? If not, violation.

### UI-018 — Empty states with guidance [WARNING]

**Rule:** When a list, table, or section is empty, display a message guiding the user on what to do to populate it.

**Checks:** Empty a list/table (filter with no results or new data). Does an orientational message appear? If not, violation.

---

## 4. Forms

### UI-019 — Correct inputmode for numeric and monetary values [ERROR]

**Rule:** Monetary value fields use `inputmode="decimal"` to invoke the numeric keyboard with decimal separator on mobile devices. Integer quantity fields use `inputmode="numeric"`.

**Checks:** Search for `<input>` for monetary values. Does it have `inputmode="decimal"`? If not, violation.

### UI-020 — inputmode="numeric" for code/PIN fields [WARNING]

**Rule:** Numeric code fields (PIN, verification code, ZIP) use `inputmode="numeric"` to invoke the numeric keyboard without decimal separator.

### UI-021 — Labels mandatory on every form field [ERROR]

**Rule:** Every `<input>`, `<select>`, and `<textarea>` has an associated `<label>` via `for`/`id` attributes. Never use placeholder as a label substitute.

**Checks:** Inspect every `<input>`/`<select>`/`<textarea>`. Does it have a corresponding `<label for="...">`? If not, violation.

### UI-022 — Visual validation with framework classes [WARNING]

**Rule:** Use the CSS framework's validation classes (`is-valid`, `is-invalid` or equivalents) with visible error messages next to the field.

### UI-023 — Complex forms grouped with fieldset and legend [WARNING]

**Rule:** Forms with multiple sections use `<fieldset>` and `<legend>` to group related fields.

---

## 5. Tables and listings

### UI-024 — Responsive tables [ERROR]

**Rule:** Every table uses a responsive wrapper (e.g., `.table-responsive`) for horizontal scrolling on small screens.

**Checks:** Search for `<table>` without a `.table-responsive` wrapper (or equivalent). Any occurrence is a violation.

### UI-025 — Numeric values right-aligned in tables [ERROR]

**Rule:** Columns with numeric values (monetary, quantities, percentages) are right-aligned and use monospace font.

**Checks:** Inspect `<td>` with numeric values. Does it have `text-end` + `font-monospace` (or equivalent)? If not, violation.

### UI-026 — Status with colored semantic badges [WARNING]

**Rule:** Record statuses are displayed with badges using consistent semantic colors throughout the project.

---

## 6. Dashboards and data visualization

### UI-027 — Cards for dashboard metrics [WARNING]

**Rule:** Main dashboard metrics (KPIs, totals, counters) are displayed in standardized framework cards, organized in a responsive grid.

### UI-028 — Charts with accessible text alternative [ERROR]

**Rule:** Every chart (canvas, SVG, chart library) must have an accessible text description via `aria-label` or hidden text with a `visually-hidden` class.

**Checks:** Search for `<canvas>` or chart container. Does it have `aria-label` or `visually-hidden` with a description? If not, violation.

### UI-029 — Chart colors consistent with design tokens [WARNING]

**Rule:** Charts use the same colors defined in the project's design tokens. Semantic colors (success, error, warning) maintain the same meaning as other components.

---

## 7. Accessibility

### UI-030 — Minimum WCAG AA contrast [ERROR]

**Rule:** All text has a minimum contrast ratio of 4.5:1 against the background (WCAG AA). Large text (18px+ or 14px+ bold) accepts 3:1.

**Checks:** Test text-color/background-color pairs with a contrast tool. Ratio <4.5:1 (or <3:1 for large text) is a violation.

### UI-031 — Functional keyboard navigation [ERROR]

**Rule:** Every interactive element (buttons, links, inputs, modals) is accessible via keyboard (Tab, Enter, Escape). Tab order follows the logical visual order. No interactive element is keyboard-inaccessible.

**Checks:** Navigate the page using only Tab/Enter/Escape. Does any interactive element not receive focus or respond? Violation.

### UI-032 — ARIA roles in dynamic components [WARNING]

**Rule:** Dynamic components (modals, toasts, dropdowns, tabs, accordions) use correct ARIA roles and attributes. CSS framework components already implement ARIA — don't remove those attributes. Custom components must implement equivalent ARIA.

### UI-033 — No information conveyed by color alone [ERROR]

**Rule:** Visual indicators (status, success/error, categories) never depend only on color. Always accompanied by an icon, sign (+/-), text, or visual pattern.

**Checks:** Mentally remove colors (grayscale). Are indicators still distinguishable by icon/sign/text? If not, violation.

---

## 8. Documentation

### UI-038 — Comments explain the "why", never the "what" [WARNING]

**Rule:** Comments in CSS explain non-obvious decisions ("why"), never describe what the code does ("what"). Self-explanatory code needs no comment.

---

## 9. Mobile-first (rules added 2026-04-12, incident 0015)

### UI-040 — Action button never a direct child of flex-row in a card [ERROR]

**Rule:** Action buttons (CTA, logout, delete, configure) are never direct children of a horizontal `flex-row` container inside cards or profile/info sections. They must occupy their own block below the content.

**Checks:** Inspect cards with action buttons. Is the button a direct child of a `flex-row` container? If so, violation.

**Why:** On mobile (viewport <=640px), flex-row compresses the button laterally, reducing touch target and breaking the layout.

**Correct example:**
```tsx
<CardContent className="space-y-4">
  <div className="flex items-center gap-4">
    <Avatar />
    <Info />
  </div>
  <ActionButton className="w-full min-h-11" />
</CardContent>
```

**Incorrect example:**
```tsx
<CardContent>
  <div className="flex items-center gap-4">
    <Avatar />
    <Info />
    <ActionButton /> {/* squeezed on mobile */}
  </div>
</CardContent>
```

---

### UI-041 — Minimum 44x44px touch target on every interactive element [ERROR]

**Rule:** Every button, link, toggle, checkbox, and clickable element must have a minimum touch area of 44x44px (width x height). Use `min-h-11` (44px) in Tailwind.

**Checks:** DevTools mobile 375px. Interactive element with rendered dimension <44px on any axis is a violation.

**Why:** WCAG 2.5.5 (AAA) and Apple HIG recommend 44px. Mobile-first audiences with smaller screens need generous targets. A 32px button on a phone = touch error = frustration.

---

### UI-042 — Flex-row with >2 interactive children becomes flex-col on mobile [WARNING]

**Rule:** If a flex-row container has more than 2 interactive elements (buttons, links, inputs), it must use `flex-col` or responsive wrap (`flex-wrap`) at the mobile breakpoint (<=640px).

**Checks:** Flex-row with >2 interactive elements. Does it have `flex-col` or `flex-wrap` at the mobile breakpoint? If not, violation.

### UI-043 — Form fields empty by default [ERROR]

**Rule:** Every form field must start **empty** (no pre-filled value). Values like `0`, `0.00`, empty string displayed as content, or any default that looks like real data are prohibited. The field should show only the **placeholder** (hint text in muted color) until the user interacts.

**Checks:** Open a creation form. Does any field show a visible value (not a placeholder) before interaction? If so, violation.

**Why:** A field showing "0.00" as a value confuses the user — it looks like saved data, not an empty field. A placeholder communicates the expected format without polluting the form. Clean form = visual confidence.

**Exceptions:**
- Edit mode fields that load an existing value from the database
- Fields with explicit semantic defaults (e.g., date = today, status = active) where the default is the user's most likely choice

---

## Definition of Done — Delivery Checklist

> PRs that don't meet the DoD don't enter review. They are returned.

| # | Item | Rules | Verification |
|---|------|-------|--------------|
| 1 | No static inline CSS | UI-012 | Search for `style=` in HTML and verify if it's dynamic |
| 2 | No `!important` | UI-011 | Search for `!important` in CSS files |
| 3 | Colors via design tokens | UI-001, UI-002 | Search for hex/RGB values outside `:root` |
| 4 | Labels on all fields | UI-021 | Inspect every `<input>`, `<select>`, `<textarea>` |
| 5 | Responsive tables | UI-024 | Verify `.table-responsive` on every `<table>` |
| 6 | Charts with accessible text | UI-028 | Verify `aria-label` or `visually-hidden` on charts |
| 7 | WCAG AA contrast | UI-030 | Test with DevTools or contrast tool |
| 8 | Keyboard navigation | UI-031 | Navigate the page using only Tab/Enter/Escape |
| 9 | No information by color alone | UI-033 | Verify indicators have icon/sign/text beyond color |
| 10 | Visual feedback on actions | UI-017 | Test each action and verify toast/alert/spinner |
| 11 | Friction on destructive operations | UI-016 | Test delete/cancel and verify confirmation modal |
| 12 | Layout via grid system | UI-008 | Search for `float:` and `position: absolute` for layout |
| 13 | Buttons outside flex-row in cards | UI-040 | Inspect cards with buttons: is it in its own block? |
| 14 | Touch targets >=44px | UI-041 | DevTools mobile 375px: every interactive >=44x44px? |
| 15 | Responsive flex-row | UI-042 | >2 interactive elements in row: has flex-col on mobile? |
| 16 | Fields empty by default | UI-043 | New form: does any field start with a visible value (not placeholder)? |
