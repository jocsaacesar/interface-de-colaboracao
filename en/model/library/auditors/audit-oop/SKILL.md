---
name: audit-oop
description: Audits OOP architecture and design in the open PR against the rules defined in docs/oop-standards.md. Delivers a violations report and correction plan. Manual trigger only.
---

# /audit-oop — Object-Oriented Design Auditor

Reads the rules from `docs/oop-standards.md`, identifies PHP files changed in the open (unmerged) PR, and compares each file against every applicable rule. Focuses on architecture and design: domain modeling, encapsulation, project patterns (entity, repository, manager, handler), SOLID, and Value Objects.

Complements `/audit-php`, which covers syntax and language rules.

## When to use

- **ONLY** when the user explicitly types `/audit-oop`.
- Run before merging a PR — acts as an architectural quality gate.
- **Never** trigger automatically, nor as part of another skill.

## Minimum required standards

> This section contains the complete standards used by the audit. Edit to customize for your project.

# Object-oriented programming standards

## Description

Reference document for auditing object-oriented architecture and design in the project. Defines how classes should be modeled, how objects relate, and how the project's architectural patterns should be applied. The `/audit-oop` skill reads this document and compares it against the target code.

Complements `docs/php-standards.md`, which covers syntax, formatting, and language rules. This document covers **design and architecture**.

## Scope

- All PHP code within the project directories
- Focus on: entities, repositories, managers, handlers

## References

- `docs/php-standards.md` — PHP language rules (complementary)
- [PHP-FIG PSR-4](https://www.php-fig.org/psr/psr-4/) — Autoloading
- SOLID Principles (Robert C. Martin)
- Domain-Driven Design — Eric Evans (applicable concepts)

## Severity

- **ERROR** — Violation blocks approval. Must be fixed before merge.
- **WARNING** — Strong recommendation. Must be justified if ignored.

---

## 1. Domain modeling

### OOP-001 — Classes represent domain nouns [ERROR]

Each entity class represents a real business concept. The class name dictates its role — no "catch-all" classes that try to be two things.

```php
// correct — clear domain concepts
class Order {}
class Customer {}
class Product {}
class OrderItem {}

// incorrect — generic, ambiguous
class Item {}
class Record {}
class Data {}
```

### OOP-002 — Methods express intent with action verbs [ERROR]

Business methods use verbs that describe what the object **does**, not what it **exposes**.

```php
// correct — clear intent
$order->confirm();
$account->transferTo($otherAccount, $amount);
$goal->recordProgress($value);

// incorrect — no intent, mechanical operation
$order->setStatus('confirmed');
$account->updateBalance($newBalance);
```

### OOP-003 — No anemic classes [ERROR]

Entities contain domain logic: state predicates, transitions, validations, and business calculations. Never bags of getters and setters.

```php
// correct — rich entity with behavior
class Order
{
    public function confirm(): void
    {
        if (!$this->canTransitionTo(self::STATUS_CONFIRMED)) {
            throw new InvalidTransitionException($this->status, self::STATUS_CONFIRMED);
        }
        $this->status = self::STATUS_CONFIRMED;
    }

    public function isConfirmed(): bool
    {
        return $this->status === self::STATUS_CONFIRMED;
    }

    public function netValue(): int
    {
        return $this->valueCents - $this->discountCents;
    }
}

// incorrect — anemic, logic lives elsewhere
class Order
{
    public function getStatus(): string { return $this->status; }
    public function setStatus(string $s): void { $this->status = $s; }
    public function getValueCents(): int { return $this->valueCents; }
}
```

---

## 2. Encapsulation

### OOP-004 — Attributes always private [ERROR]

Every property is `private` (or `readonly` via constructor promotion). `protected` only in real inheritance hierarchies. Never `public`.

```php
// correct
class Customer
{
    private int $balanceCents;
    private string $name;
    private bool $active;
}

// incorrect
class Customer
{
    public int $balanceCents;
    public string $name;
}
```

### OOP-005 — Tell, Don't Ask [ERROR]

Don't extract data from an object to make decisions outside of it. Tell the object what to do — it decides internally.

```php
// correct — the object decides
$order->confirm();
// internally: checks if it can transition, changes status, throws if it can't

// incorrect — external decision
if ($order->status() === 'pending') {
    $order->setStatus('confirmed');
}
```

### OOP-006 — Private setters, mutation via business methods [ERROR]

Mutable properties are changed by methods that express business intent, never by public setters.

```php
// correct
class Goal
{
    private string $status;

    public function achieve(): void
    {
        if ($this->currentValueCents < $this->targetValueCents) {
            throw new GoalNotAchievedException();
        }
        $this->status = self::STATUS_ACHIEVED;
    }
}

// incorrect
class Goal
{
    public function setStatus(string $status): void
    {
        $this->status = $status;
    }
}
```

### OOP-007 — Immutable objects when possible [WARNING]

For data that doesn't change after creation (configurations, Value Objects, read DTOs), use `readonly` in the constructor. No setters, no mutation.

```php
// correct — immutable
class ReportPeriod
{
    public function __construct(
        private readonly DateTimeImmutable $start,
        private readonly DateTimeImmutable $end,
    ) {
        if ($end <= $start) {
            throw new InvalidPeriodException();
        }
    }
}
```

---

## 3. Inheritance and polymorphism

### OOP-008 — Inheritance only for real subtypes [ERROR]

Inheritance only when the statement "X **is a** Y" is behaviorally true. To reuse code, use composition (dependency injection).

```php
// correct — real subtype
abstract class DomainException extends \DomainException {}
class InsufficientBalanceException extends DomainException {}
class OrderNotFoundException extends DomainException {}

// incorrect — inheritance to reuse code
class FinanceManager extends BaseManager {} // "has features of", not "is a"
```

### OOP-009 — Concrete classes are final [WARNING]

Concrete classes not designed for extension should use `final`. Prevents accidental inheritance.

### OOP-010 — Polymorphism replaces switch/if on type [WARNING]

When multiple `if/else` or `switch` statements decide behavior based on the "type" of something, extract into a polymorphic hierarchy.

```php
// correct — polymorphism
interface InterestCalculator
{
    public function calculate(int $valueCents, int $days): int;
}

class SimpleInterest implements InterestCalculator
{
    public function calculate(int $valueCents, int $days): int
    {
        return (int) ($valueCents * 0.01 * $days);
    }
}

// incorrect — switch on type
function calculateInterest(string $type, int $value, int $days): int
{
    switch ($type) {
        case 'simple': return (int) ($value * 0.01 * $days);
        case 'compound': return (int) ($value * ((1.01 ** $days) - 1));
    }
}
```

---

## 4. Interfaces and abstractions

### OOP-011 — Lean and specific interfaces [WARNING]

Interfaces define small and cohesive contracts. Never "fat interfaces" that force implementation of irrelevant methods.

### OOP-012 — Depend on abstractions, not concrete implementations [WARNING]

Managers and handlers receive interfaces when the dependency can vary. Stable dependencies may be concrete.

### OOP-013 — Abstract classes as hierarchy templates [WARNING]

Abstract classes share state and behavior among real subtypes. Never use them as "utility method repositories."

---

## 5. Value Objects

### OOP-014 — Primitive types with domain meaning become Value Objects [WARNING]

When a primitive carries validation or formatting rules, encapsulate it in a Value Object.

```php
// correct — Value Object with validation
final class Money
{
    public function __construct(
        private readonly int $cents,
    ) {
        if ($cents < 0) {
            throw new NegativeValueException($cents);
        }
    }

    public function cents(): int
    {
        return $this->cents;
    }

    public function add(self $other): self
    {
        return new self($this->cents + $other->cents);
    }

    public function formatted(): string
    {
        return '$' . number_format($this->cents / 100, 2);
    }
}
```

### OOP-015 — Value Objects are immutable [ERROR]

Value Objects never change after creation. Operations return new instances.

### OOP-016 — Comparison by value, not by reference [WARNING]

Value Objects implement an equality method based on attributes, not memory reference.

---

## 6. Project architectural patterns

### OOP-017 — Entity: Rich Domain Model with FSM [ERROR]

Every entity with state follows the Rich Domain Model pattern with a finite state machine.

Required structure:
1. Status constants
2. `STATUS_TRANSITIONS` defining valid transitions
3. Parameterized constructor (valid state since creation)
4. Getters without `get_` prefix
5. Lifecycle methods (`confirm()`, `cancel()`) with Tell, Don't Ask
6. State predicates (`isConfirmed()`, `isPending()`)
7. Public `canTransitionTo()`
8. Tolerant `fromRow()` (never throws exception)
9. `toArray()` for serialization

### OOP-018 — Repository: uniform interface [ERROR]

Every repository follows the same method structure.

Required methods:
1. `findById(int $id): ?Entity`
2. `findAll(): array`
3. `create(Entity $e): int`
4. `update(Entity $e): bool`
5. `delete(int $id): bool`
6. `tableName(): string` (private)
7. `hydrate(object $row): Entity` (private)

### OOP-019 — Manager: orchestration without domain logic [ERROR]

Managers coordinate operations between entities and repositories. Domain logic lives in the entity, not in the manager.

```php
// correct — manager orchestrates
class OrderManager
{
    public function confirmOrder(int $orderId): void
    {
        $order = $this->orders->findById($orderId);

        if (!$order) {
            throw new OrderNotFoundException($orderId);
        }

        $order->confirm(); // logic in the entity
        $this->orders->update($order);
    }
}

// incorrect — manager with domain logic
class OrderManager
{
    public function confirmOrder(int $id): void
    {
        $order = $this->orders->findById($id);

        if ($order->status() !== 'pending') { // logic should be in the entity
            throw new \Exception('Cannot confirm');
        }
    }
}
```

### OOP-020 — Handler: system boundary [ERROR]

Handlers are the boundary between the external world (HTTP request) and the domain. Responsibilities:
1. Verify authentication and authorization
2. Sanitize and validate input
3. Delegate to the manager
4. Return response

Handlers never contain domain logic nor access the database directly.

---

## 7. SOLID applied to the project

### OOP-021 — SRP: one reason to change per class [ERROR]

### OOP-022 — OCP: extension without modification [WARNING]

### OOP-023 — LSP: substitutable subtypes [WARNING]

### OOP-024 — ISP: segregated interfaces [WARNING]

### OOP-025 — DIP: dependency inversion [WARNING]

---

## 8. Enums and type safety

### OOP-026 — Enums for closed domains [WARNING]

Statuses, types, and categories with a fixed set of values should use PHP Enums (8.1+), not loose strings.

```php
// correct
enum OrderType: string
{
    case Sale = 'sale';
    case Exchange = 'exchange';
    case Return = 'return';
}

// incorrect — loose string
$type = 'sale'; // can be anything, no validation
```

### OOP-027 — Use DateTimeImmutable, never date strings [ERROR]

Dates are objects, not strings. Use `DateTimeImmutable` for all temporal properties.

```php
// correct
private readonly DateTimeImmutable $createdAt;
private ?DateTimeImmutable $deadline;

// incorrect
private string $createdAt; // '2026-04-07'
private ?string $deadline;
```

---

## Audit checklist

The `/audit-oop` skill must verify, for each file:

**Modeling and encapsulation:**
- [ ] Classes represent domain concepts (clear names)
- [ ] Methods express intent with action verbs
- [ ] Entity is not anemic (contains domain logic)
- [ ] Attributes are private (never public)
- [ ] Tell, Don't Ask respected (decisions inside the object)
- [ ] No public setters (mutation via business methods)

**Inheritance and polymorphism:**
- [ ] Inheritance only for real subtypes
- [ ] Composition over inheritance for code reuse
- [ ] Switch/if on type replaced by polymorphism when applicable

**Interfaces:**
- [ ] Lean and specific interfaces
- [ ] Dependencies that can vary receive an interface

**Value Objects:**
- [ ] Primitives with domain meaning encapsulated in VO
- [ ] Value Objects are immutable
- [ ] Dates use DateTimeImmutable

**Project patterns:**
- [ ] Entity follows Rich Domain Model (FSM, lifecycle, predicates, fromRow, toArray)
- [ ] Repository follows uniform interface (findById, findAll, create, update, delete, hydrate)
- [ ] Manager orchestrates without domain logic
- [ ] Handler validates and delegates (never accesses DB, never contains domain logic)

**SOLID:**
- [ ] One responsibility per class (SRP)
- [ ] Extension without modification when applicable (OCP)
- [ ] Substitutable subtypes (LSP)
- [ ] Segregated interfaces (ISP)
- [ ] Dependency inversion when the dependency varies (DIP)

## Process

### Phase 1 — Load the ruleset

1. Read the **Minimum required standards** section of this document.
2. Internalize all rules with their IDs, descriptions, examples, and severities (ERROR/WARNING).
3. Do not summarize or recite the document back.

### Phase 2 — Identify the open PR

1. Run `gh pr list --state open --base develop --json number,title,headBranch --limit 1` to find the most recent open PR against `develop`.
2. If there are multiple open PRs, list all and ask the user which one to audit.
3. If there are no open PRs, inform the user and stop.
4. Run `gh pr diff <number>` to get the full PR diff.
5. Filter only `.php` files from the project.

### Phase 3 — Audit file by file

For each PHP file changed in the PR:

1. Read the complete file (not just the diff — context matters).
2. Compare against **every rule** from `docs/oop-standards.md`, one by one, in document order.
3. For each violation found, record:
   - **File** and **line(s)** where it occurs
   - **Rule ID** violated (e.g., oop-standards.md, OOP-017)
   - **Severity** (ERROR or WARNING)
   - **What's wrong** — concise description
   - **How to fix** — specific correction for that snippet
4. If the file violates no rules, record as approved.

### Phase 4 — Report

Present the report to the user in the following format:

```
## OOP Audit Report

**PR:** #<number> — <title>
**Branch:** <branch>
**Files audited:** <count>
**Ruleset:** docs/oop-standards.md

### Summary

- Errors: <count>
- Warnings: <count>
- Approved files: <count>

### Violations

#### <file.php>

| Line | Rule | Severity | Description | Fix |
|------|------|----------|-------------|-----|
| 10 | OOP-003 | ERROR | Anemic entity, only getters/setters | Add domain logic |
| 25 | OOP-005 | ERROR | Status decision outside the entity | Move to lifecycle method |

#### <other-file.php>
Approved — no violations found.
```

### Phase 5 — Correction plan

If there are ERROR violations:

1. List the necessary corrections grouped by file.
2. Order by severity (ERRORs first, WARNINGs after).
3. For each correction, indicate exactly what to change and where.
4. Ask the user: "Would you like me to apply the corrections now?"

If there are only WARNINGs or no violations:

> "No blocking errors. The warnings are recommendations — would you like me to fix any?"

## Rules

- **Never change code during the audit.** The skill is read-only until the user explicitly requests correction.
- **Never audit files outside the PR.** Only PHP files changed in the open PR.
- **Always reference the violated rule ID.** The report must be traceable to the standards document.
- **Never invent rules.** The ruleset is exclusively `docs/oop-standards.md` — no opinions, no extra suggestions.
- **Be methodical and procedural.** Each file is compared against each rule, in document order, without skipping.
- **Fidelity to the document.** If the code violates a rule in the document, report it. If the document doesn't cover the case, don't report it.
- **Show the complete report before any action.** Never apply corrections without explicit approval.
