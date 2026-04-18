# Standards Document Template — your organization

> This file is a **structural template**. It contains no real rules.
> It serves as a mandatory guide for creating any `*-standards.md` document
> within the organization.
>
> **For Claude Code:** when creating a new standards document, read this template
> in its entirety before writing anything. Follow the structure, format, and
> guidelines exactly as described. Conduct an interview with the user
> to fill in the content — never make up rules without validation.

---

## How to use this template

### If you are Claude Code

1. Read this template completely.
2. Identify which domain the user wants to standardize.
3. Conduct the interview described in the "Creation process" section.
4. Generate the document following the mandatory structure.
5. Show the result for approval before saving.

### If you are a developer

1. Read the standards document for the domain that affects your work.
2. Use rule IDs to reference in PRs and code reviews.
3. Check the DoD before opening any Pull Request.

### If you are an auditor (human or AI)

1. Read the frontmatter to understand scope and dependencies.
2. Audit the code against each rule by ID.
3. Classify violations by the severity defined in the document.
4. Reference violations by rule ID (e.g., "violates PHP-038").

---

## Process for creating a new standards document

When the user asks to create a new `*-standards.md`, Claude Code must
conduct a structured interview before writing. Never generate rules
without user validation.

### Phase 1 — Understand the domain

Mandatory questions:

1. **What is the domain?** (e.g., PHP, JavaScript, CSS, databases, infrastructure)
2. **Which projects does this standard cover?** (all, or specific ones?)
3. **Is there code already in production in this domain?** If so, what patterns
   are already being followed in practice?
4. **Is there external reference documentation?** (PSR, OWASP, MDN, WordPress Codex, etc.)

### Phase 2 — Identify what is non-negotiable

Mandatory questions:

5. **What has already caused problems in production?** Incidents, bugs, fatals, corrupted
   data — these automatically become ERROR rules.
6. **What is critical by the nature of the business?** (e.g., financial data,
   personal data, authentication)
7. **What practices has the team already rejected in code review?** Implicit patterns
   that need to become explicit rules.

### Phase 3 — Define the level of rigor

Mandatory questions:

8. **Is this standard for an experienced team or for onboarding?** This determines the
   depth of explanations and examples.
9. **Which rules are blocking (ERROR) and which are recommendations (WARNING)?**
   The user defines severity, not Claude.
10. **Are there known exceptions?** Cases where a rule doesn't apply
    must be documented in the rule itself.

### Phase 4 — Generate and validate

11. Generate the document following the mandatory structure below.
12. Show the complete document to the user.
13. Wait for approval or adjustments.
14. Save only after explicit approval.

---

## Mandatory document structure

Every `*-standards.md` document in the project must follow exactly this structure.
Sections may be added, but none of the mandatory ones may be removed.

```markdown
---
document: {domain}-standards
version: 1.0.0
created: {YYYY-MM-DD}
updated: {YYYY-MM-DD}
total_rules: {number}
severities:
  error: {number}
  warning: {number}
scope: {description of where this standard applies}
applies_to: [{list of projects or "all"}]
requires: [{list of other *-standards.md that this document references}]
replaces: [{previous documents this replaces, if any}]
---
```

### Frontmatter — mandatory fields

| Field | Type | Description |
|-------|------|-------------|
| `document` | string | Unique identifier. Format: `{domain}-standards` |
| `version` | string | SemVer of the document. MAJOR when changing ERROR rules, MINOR when adding rules, PATCH for text corrections |
| `created` | date | Creation date (YYYY-MM-DD) |
| `updated` | date | Last change date (YYYY-MM-DD) |
| `total_rules` | int | Total number of rules in the document |
| `severities.error` | int | Number of rules that block merge |
| `severities.warning` | int | Number of rules that are strong recommendations |
| `scope` | string | Textual description of where the standard applies |
| `applies_to` | list | Covered projects. Use `["all"]` for universal |
| `requires` | list | Standards documents that this references. Empty if independent |
| `replaces` | list | Documents that this replaces. Empty if new |

---

### Document header

```markdown
# {Domain} Standards — your organization

> Constitutional document. Delivery contract for every
> developer who touches {domain} in our projects.
> Code that violates ERROR rules is not discussed — it is returned.
```

**Header rules:**
- The phrase "Delivery contract" is mandatory. It reinforces that this is not a suggestion.
- The phrase about ERROR rules being returned is mandatory. It defines the culture.

---

### Section: How to use this document

Mandatory. Explains how each audience should use the document.
Three fixed audiences: **developer**, **auditor**, **Claude Code**.

```markdown
## How to use this document

### For the developer
{How to consult during development and before opening a PR}

### For the auditor (human or AI)
{How to audit code against the rules by ID and severity}

### For Claude Code
{How to interpret the frontmatter, apply rules in code review,
and reference violations by ID}
```

---

### Section: Severities

Mandatory. Always the same table — do not alter the meanings.

```markdown
## Severities

| Level | Meaning | Action |
|-------|---------|--------|
| **ERROR** | Non-negotiable violation | Blocks merge. Fix before review. |
| **WARNING** | Strong recommendation | Must be justified in writing if ignored. |
```

**Rules about severities:**
- ERROR = born from a real incident, security risk, or explicit project decision.
- WARNING = quality improvement that admits justified exceptions.
- Never create a third level. Two is sufficient. Simplicity.

---

### Thematic sections (document body)

The body is organized in **numbered thematic sections**. Each section groups
rules by concern (not by syntactic aspect).

```markdown
## {N}. {Thematic section name}
```

**Grouping guidelines:**
- Group by **concern** (security, architecture, performance), not by
  mechanical aspect (indentation, variable names).
- Maximum 10 sections. If it exceeds 10, the document is trying to cover
  too many domains — split it.
- Order: from most critical to least critical. Security before formatting.

**When to create a new document vs. add to an existing one:**
- Create a new `*-standards.md` when the domain has **10+ rules of its own**
  that don't fit naturally in any existing document.
- Below 10 rules, add as a section in the closest document.
- When in doubt, ask the user: "do these rules belong to {existing
  document} or do they justify their own document?"

---

### Mandatory format for each rule

Every rule follows exactly this format. No exceptions.

```markdown
### {ID} — {Descriptive title} [{SEVERITY}]

**Rule:** {Objective description of what is mandatory or prohibited.
One or two sentences. No ambiguity.}

**Checks:** {Concise mechanical check — how to confirm compliance.
One line, maximum two. Can be a grep command, visual inspection, or test.}

**Why:** {Real project motivation for this rule. Can be an
incident, a business decision, a team limitation, data sensitivity. Never
"because it's best practice". Always "because in the project, X happened/matters".}

**Correct example:**
​```{language}
// example context
{code that follows the rule}
​```

**Incorrect example:**
​```{language}
// example context
{code that violates the rule}
​```

**Exceptions:** {Situations where the rule does not apply. If there are no exceptions,
omit this line.}

**References:** {IDs of related rules in other standards documents.
E.g., SEG-011. If none, omit this line.}
```

### ID convention

| Component | Format | Example |
|-----------|--------|---------|
| Prefix | Domain abbreviation in UPPER | `PHP`, `SEG`, `WP`, `JS`, `UI` |
| Separator | Hyphen | `-` |
| Number | Three digits, zero-padded | `001`, `042`, `100` |
| Complete | `{PREFIX}-{NNN}` | `PHP-038`, `SEG-011` |

**ID rules:**
- IDs are immutable. Once assigned, an ID never changes.
- Removed rules get a `[REMOVED]` status — the ID is not reused.
- New rules receive the next available sequential number.

### Rules about examples

- Every example must be **compilable/executable** in the project context.
  No pseudocode.
- The correct example always comes **before** the incorrect one.
- Examples must be **minimal** — only the code necessary to demonstrate
  the rule. No irrelevant boilerplate.
- If the rule is conceptual (e.g., KISS principle), the example shows a
  concrete application, not the abstract principle.
- **Depth by target audience:** if the document serves onboarding
  (question 8 of the interview), examples should include explanatory comments
  in the code and the "Why" should give more business context.
  If for an experienced team, minimal examples without comments suffice.

### Rules about "Why"

- Never use generic phrases: "it's best practice", "improves readability",
  "industry standard".
- Always connect to the project's reality: incident, business decision,
  team limitation, data sensitivity.
- If the motivation is an incident, reference the PR where it happened.
- If it's a business decision, explain which one (e.g., "financial data requires
  encryption for compliance").
- The motivation helps judge exceptions: if the "why" doesn't apply to
  the case, the rule may not apply.

---

### Section: Documentation and versioning

Mandatory. Defines how code is documented and how changes are
tracked. Rules in this section follow the **same mandatory format**
as all others (ID, severity, "Why", examples).

```markdown
## {N}. Documentation and versioning

### {PREFIX}-{NNN} — {Documentation rule title} [{SEVERITY}]

**Rule:** {Objective description}

**Checks:** {Concise mechanical check — how to confirm compliance.}

**Why:** {Real motivation}

**Correct example:**
​```{language}
{code/commit/changelog that follows the rule}
​```

**Incorrect example:**
​```{language}
{code/commit/changelog that violates the rule}
​```
```

**Topics this section must cover (as formal rules, not prose):**
- Code comments: when they are mandatory (explain "why") and
  when they are noise (explain "what"). Self-explanatory code needs no
  comment.
- Semantic commits: required format (`feat:`, `fix:`, `refactor:`,
  `docs:`, `test:`, `chore:`).
- CHANGELOG: how and when to update the `[Unreleased]` section.
- SemVer: how the project interprets MAJOR/MINOR/PATCH in the project context.

---

### Section: Definition of Done (DoD)

Mandatory. Last section of the document. It is the final checklist before the PR.

```markdown
## Definition of Done — Delivery Checklist

> PRs that don't meet the DoD don't enter review. They are returned.

| # | Item | Rules | Verification |
|---|------|-------|--------------|
| 1 | {item} | {IDs} | {how to verify} |
| 2 | {item} | {IDs} | {how to verify} |
| ... | ... | ... | ... |
```

**DoD rules:**
- Each checklist item references one or more rules by ID.
- The "Verification" column says **how** to confirm (command, visual inspection, test).
- Maximum 15 items. If it exceeds that, the checklist loses practical usefulness.
- Order from fastest to slowest verification.

---

## Universal rules for all standards documents

These rules apply to any `*-standards.md` created in the project.

### About content

1. **Every rule is born from production or an explicit decision.** Don't add
   rules "just because" or "because the framework recommends it". If there's no
   concrete motivation, it's not a rule — it's an opinion.

2. **ERROR rules are non-negotiable.** If someone questions an ERROR rule,
   the answer is: "show the incident that justifies the exception, or fix it".

3. **WARNING rules admit documented exceptions.** The developer can
   ignore a WARNING if they write the justification in the PR. The auditor validates
   whether the justification is acceptable.

4. **No duplication between documents.** If a security rule is already in
   `security-standards.md`, the PHP document cross-references it
   (e.g., "see SEG-011"), never copies the rule.

5. **Examples are mandatory.** A rule without an example is a subjective rule.
   If you can't exemplify it, the rule isn't clear enough.

6. **Direct language.** No "it is recommended", "should", "when possible".
   Use "must", "never", "always", "prohibited". Ambiguity generates
   different interpretations.

### About maintenance

7. **The document is versioned with SemVer.**
   - MAJOR: change to an existing ERROR rule (behavior change).
   - MINOR: addition of new rules.
   - PATCH: text correction, example improvement, wording adjustment.

8. **Removed rules don't disappear.** They are marked as `[REMOVED]`
   with the justification and date. The ID is never reused.

9. **Periodic review.** Every standards document should be reviewed
   when a production incident reveals a gap.

10. **Whoever changes the standard needs approval.** Changes to ERROR rules
    go through the technical lead. Changes to WARNING rules can
    be proposed by any team member via PR.

### About the relationship between documents

11. **The project's constitution is the supreme law.** No standards document
    can contradict the constitution. In case of conflict, the constitution wins.

12. **Standards documents are independent but connected.** Each document
    covers a domain. Cross-references connect related rules.
    Reading one document should be self-contained — the reader doesn't need to
    read the others to understand the domain's rules.

13. **Precedence hierarchy (vertical):**
    ```
    project constitution               ← supreme law, never violated
    └── *-standards.md                ← rules by domain
        └── project rules             ← specializations per project (CLAUDE.md)
    ```
    Project rules can be **more restrictive** than the standard,
    never **less**.

14. **Conflict resolution between documents at the same level (horizontal):**
    Standards documents may have rules that create tension (e.g.,
    "maximum 20 lines per method" vs. "rich entities with complete lifecycle methods").
    When this happens:
    - A rule with **ERROR** severity prevails over **WARNING**.
    - If both are ERROR, the **more specific domain** wins (e.g.,
      `crypto-standards` beats `php-standards` on crypto matters;
      `` beats `php-standards` on WP API matters).
    - If the conflict can't be resolved by specificity, **escalate to the
      technical lead** for a documented decision.
    - Resolved conflicts should become an **explicit exception** in the rule
      that yields, referencing the rule that prevails.

---

## Folder structure

```

├── project constitution               ← constitution (to be created)
├── standards-template.md              ← this file (structural template)
└── standards/
    ├── php-standards.md
    ├── oop-standards.md
    ├── security-standards.md
    ├── testing-standards.md
    ├──.md
    ├── frontend-standards.md
    ├── js-standards.md
    └── crypto-standards.md
```

---

## Glossary of terms used in standards documents

Terms that appear in `*-standards.md` documents and that may not be
obvious to developers new to the project.

| Term | Definition |
|------|-----------|
| **System boundary** | The point where external data enters the system (AJAX handlers, REST endpoints, forms). This is where validation and sanitization happen. |
| **Rich entity** | A domain class that contains business logic (predicates, state transitions, calculations), not just getters and setters. Opposite of "anemic entity". |
| **FSM (Finite State Machine)** | Finite State Machine. In the project, implemented as a `STATUS_TRANSITIONS` constant in the entity, with lifecycle methods for each transition. |
| **from_row()** | Static method that hydrates an entity from a database row. In the project, it must be tolerant (never throw an exception). |
| **Cross-reference** | Reference between rules of different documents. Format: `{ID}` (e.g., SEG-011). Prevents rule duplication between documents. |
| **DoD (Definition of Done)** | Delivery checklist that must be fulfilled before opening a PR. Functions as a minimum contract. |
| **Guard clause** | Early return at the beginning of a method to eliminate invalid cases before the main logic. Reduces nesting. |
| **Lifecycle method** | Entity method that executes a state transition with built-in validation (e.g., `confirm()`, `cancel()`, `publish()`). |
| **Hydrate** | Convert a raw database row (`stdClass`) into a typed entity instance. |
| **Value Object** | Immutable object defined by its value, not by identity. E.g., `Money(100, 'BRL')`, `Email('user@example.com')`. Two VOs with the same values are equal. |
| **SemVer** | Semantic versioning (MAJOR.MINOR.PATCH). MAJOR = breaking change, MINOR = new feature, PATCH = fix. |
| **Benevolent dictator** | The technical lead. Final authority over technical and standards decisions in the project. |

**Rule:** each `*-standards.md` document can add an optional glossary
with terms specific to its domain. Terms that already appear in this table
should not be redefined — only referenced.

---

## Quality checklist for the document itself

Before considering a `*-standards.md` ready, verify:

- [ ] Complete frontmatter with all mandatory fields
- [ ] Header with "Delivery contract" and phrase about ERROR rules
- [ ] "How to use" section with all three audiences (developer, auditor, Claude Code)
- [ ] Severities table present and unaltered
- [ ] All rules follow the mandatory format (ID, rule, checks, why, examples)
- [ ] All IDs follow the `{PREFIX}-{NNN}` convention
- [ ] No rule without an example
- [ ] No ERROR rule without a "Why" connected to a concrete fact
- [ ] Documentation and versioning section present
- [ ] DoD present with maximum 15 items referencing rules by ID
- [ ] Cross-references to rules in other documents (no duplication)
- [ ] No contradiction with the project constitution
- [ ] Document reviewed and approved by the user before saving
