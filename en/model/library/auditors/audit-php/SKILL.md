---
name: audit-php
description: Audits PHP code in the open PR against the rules defined in docs/php-standards.md. Delivers a violations report and correction plan. Manual trigger only.
---

# /audit-php — PHP Standards Auditor

Reads the rules from `docs/php-standards.md`, identifies PHP files changed in the open (unmerged) PR, and compares each file against every applicable rule. Delivers a violations report referencing the rule ID and a correction plan when needed.

## When to use

- **ONLY** when the user explicitly types `/audit-php`.
- Run before merging a PR — acts as a quality gate.
- **Never** trigger automatically, nor as part of another skill.

## Minimum required standards

> This section contains the complete standards used by the audit. Edit to customize for your project.

# PHP programming standards

## Description

Reference document for PHP code auditing in the project. Defines mandatory rules and recommendations that every class, method, and PHP file must follow. The `/audit-php` skill reads this document and compares it against the target code.

## Scope

- All PHP code within the project directories
- PHP 8.1+ with `declare(strict_types=1)`

## References

- [PSR-1: Basic Coding Standard](https://www.php-fig.org/psr/psr-1/)
- [PSR-4: Autoloading Standard](https://www.php-fig.org/psr/psr-4/)
- [PSR-12: Extended Coding Style Guide](https://www.php-fig.org/psr/psr-12/)
- [SemVer 2.0.0](https://semver.org/)

## Severity

- **ERROR** — Violation blocks approval. Must be fixed before merge.
- **WARNING** — Strong recommendation. Must be justified if ignored.

---

## 1. Fundamental principles

These principles govern every code decision. The skill uses them as judgment criteria when a specific rule does not cover the case.

### PHP-001 — KISS: simplicity first [WARNING]

Code should be as simple as possible. If there is a direct way to solve something, use it. Abstractions, patterns, and indirections only enter when the problem demands it.

```php
// correct — direct
public function isActive(): bool
{
    return $this->status === self::STATUS_ACTIVE;
}

// incorrect — unnecessary indirection
public function isActive(): bool
{
    return (new StatusChecker($this))->verify(self::STATUS_ACTIVE);
}
```

### PHP-002 — DRY: one rule, one place [ERROR]

A business rule is implemented in a single point in the system. If the same calculation or validation appears in two places, extract it into a method or class.

```php
// correct — centralized calculation in the entity
class Order
{
    public function netValue(): int
    {
        return $this->valueCents - $this->discountCents;
    }
}

// incorrect — duplicated calculation in handler and manager
// handler: $net = $value - $discount;
// manager: $net = $value - $discount;
```

### PHP-003 — YAGNI: don't build what you don't need now [WARNING]

Don't implement classes, methods, or parameters thinking about "future possibilities." Implement strictly what the current requirement demands. Code that will never be used is technical debt from birth.

### PHP-004 — Separation of Concerns (SoC) [ERROR]

Each layer has one job:

| Layer | Responsibility | Directory |
|-------|---------------|-----------|
| Entity | Domain logic, state, predicates | `inc/entities/` |
| Repository | Data access, queries, hydration | `inc/repositories/` |
| Manager | Orchestration, cross-entity rules | `inc/managers/` |
| Handler | Receive request, validate, delegate, respond | `inc/handlers/` |

Handler never queries. Repository never validates requests. Entity never accesses the database.

### PHP-005 — Law of Demeter: talk only to your neighbors [WARNING]

An object interacts only with its direct dependencies. Never chain calls that cross layers.

```php
// correct
$balance = $account->currentBalance();

// incorrect — handler knows the account's internal structure
$balance = $order->account()->repository()->calculateBalance();
```

---

## 2. Naming

### PHP-006 — Classes in PascalCase [ERROR]

```php
// correct
class OrderRepository {}
class FinanceManager {}

// incorrect
class order_repository {}
class financeManager {}
```

### PHP-007 — Methods and properties in camelCase [ERROR]

```php
// correct
public function calculateBalance(): int {}
private int $valueCents;

// incorrect
public function calculate_balance(): int {}
private int $value_cents;
```

### PHP-008 — Constants in UPPER_SNAKE_CASE [ERROR]

```php
// correct
public const STATUS_ACTIVE = 'active';
private const MAX_ATTEMPTS = 3;

// incorrect
public const statusActive = 'active';
private const maxAttempts = 3;
```

### PHP-009 — Local variables in camelCase [WARNING]

```php
// correct
$totalValue = $order->valueCents();
$categoryId = $request['category_id'];

// incorrect
$total_value = $order->valueCents();
$CategoryId = $request['category_id'];
```

### PHP-010 — Descriptive names, no obscure abbreviations [WARNING]

```php
// correct
$orderRepository = new OrderRepository($db);
$activeCategory = $category->isActive();

// incorrect
$or = new OrderRepository($db);
$ac = $category->isActive();
```

---

## 3. File structure

### PHP-011 — One file per class [ERROR]

Each PHP class lives in its own file. The file name matches the class name followed by `.php`.

```
inc/entities/Order.php              <- class Order
inc/repositories/OrderRepository.php <- class OrderRepository
```

### PHP-012 — Every PHP file opens with strict_types [ERROR]

```php
// correct
<?php
declare(strict_types=1);

class Order {}

// incorrect
<?php
class Order {}
```

### PHP-013 — No PHP closing tag [ERROR]

Files containing only PHP do not use `?>` at the end.

---

## 4. Type system

### PHP-014 — Type hints required on parameters [ERROR]

```php
// correct
public function findByUser(int $userId): array {}

// incorrect
public function findByUser($userId) {}
```

### PHP-015 — Return type required [ERROR]

```php
// correct
public function calculateBalance(): int {}
public function findOrNull(int $id): ?Order {}

// incorrect
public function calculateBalance() {}
```

### PHP-016 — Use union types when necessary, never mixed [WARNING]

```php
// correct
public function find(int $id): Order|null {}

// incorrect
public function find(int $id): mixed {}
```

### PHP-017 — Typed properties [ERROR]

```php
// correct
private int $valueCents;
private string $description;
private ?DateTimeImmutable $deadline;

// incorrect
private $valueCents;
private $description;
```

---

## 5. Classes and objects

### PHP-018 — Explicit visibility on everything [ERROR]

Every property, method, and constant must declare visibility (`public`, `protected`, `private`).

```php
// correct
private int $id;
public function id(): int { return $this->id; }

// incorrect
int $id;
function id(): int { return $this->id; }
```

### PHP-019 — Readonly properties when not mutable [WARNING]

```php
// correct
public function __construct(
    private readonly int $id,
    private readonly string $name,
) {}

// incorrect (if the value never changes after construction)
public function __construct(
    private int $id,
    private string $name,
) {}
```

### PHP-020 — Constructors via property promotion [WARNING]

Prefer constructor promotion when applicable.

```php
// correct
public function __construct(
    private readonly Database $db,
    private readonly Logger $logger,
) {}

// acceptable but verbose
public function __construct(Database $db, Logger $logger)
{
    $this->db = $db;
    $this->logger = $logger;
}
```

### PHP-021 — Composition over inheritance [WARNING]

Inheritance creates tight coupling. Use only for real hierarchies (e.g., typed exceptions). To reuse behavior, inject dependencies.

```php
// correct — composition
class FinanceManager
{
    public function __construct(
        private readonly OrderRepository $orders,
        private readonly Logger $logger,
    ) {}
}

// incorrect — inheritance to reuse code
class FinanceManager extends BaseManager {}
```

### PHP-022 — Rich entities, not anemic [ERROR]

Entities contain domain logic: predicates, state transitions, business rule validations. They should never be mere bags of getters and setters.

```php
// correct — entity with behavior
class Order
{
    public function confirm(): void
    {
        if ($this->status !== self::STATUS_PENDING) {
            throw new InvalidTransitionException($this->status, self::STATUS_CONFIRMED);
        }
        $this->status = self::STATUS_CONFIRMED;
    }

    public function isConfirmed(): bool
    {
        return $this->status === self::STATUS_CONFIRMED;
    }
}

// incorrect — anemic entity
class Order
{
    public function getStatus(): string { return $this->status; }
    public function setStatus(string $status): void { $this->status = $status; }
}
```

### PHP-023 — Getters without get_ prefix [ERROR]

Accessor methods use the property name directly.

```php
// correct
public function id(): int { return $this->id; }
public function name(): string { return $this->name; }
public function valueCents(): int { return $this->valueCents; }

// incorrect
public function getId(): int { return $this->id; }
public function getName(): string { return $this->name; }
```

### PHP-024 — FSM in the entity via STATUS_TRANSITIONS [ERROR]

Entities with state define their valid transitions as a constant and expose lifecycle methods.

```php
class Order
{
    public const STATUS_PENDING = 'pending';
    public const STATUS_CONFIRMED = 'confirmed';
    public const STATUS_CANCELLED = 'cancelled';

    public const STATUS_TRANSITIONS = [
        self::STATUS_PENDING   => [self::STATUS_CONFIRMED, self::STATUS_CANCELLED],
        self::STATUS_CONFIRMED => [self::STATUS_CANCELLED],
        self::STATUS_CANCELLED => [],
    ];

    public function confirm(): void
    {
        if (!$this->canTransitionTo(self::STATUS_CONFIRMED)) {
            throw new InvalidTransitionException($this->status, self::STATUS_CONFIRMED);
        }
        $this->status = self::STATUS_CONFIRMED;
    }

    public function canTransitionTo(string $newStatus): bool
    {
        return in_array($newStatus, self::STATUS_TRANSITIONS[$this->status] ?? [], true);
    }
}
```

### PHP-025 — from_row() tolerant, never throws exception [ERROR]

Database data is a fait accompli. The `from_row()` method never throws exceptions — it uses `ReflectionClass::newInstanceWithoutConstructor()` to bypass constructor validations.

```php
// correct
public static function fromRow(object $row): self
{
    $entity = (new \ReflectionClass(self::class))
        ->newInstanceWithoutConstructor();

    $entity->id = (int) $row->id;
    $entity->name = (string) $row->name;
    $entity->status = (string) $row->status;

    return $entity;
}

// incorrect — explodes with dirty data from the database
public static function fromRow(object $row): self
{
    return new self(
        id: (int) $row->id,
        name: (string) $row->name, // constructor may validate and throw
    );
}
```

### PHP-026 — Entities don't depend on infrastructure [ERROR]

Entity classes never import database classes, repository classes, or external services. Entities contain pure domain logic.

```php
// correct — pure entity
class Order
{
    public function isConfirmed(): bool
    {
        return $this->status === self::STATUS_CONFIRMED;
    }
}

// incorrect — entity coupled to infrastructure
class Order
{
    public function save(Database $db): void
    {
        $db->insert(...);
    }
}
```

### PHP-027 — SOLID: single responsibility per class [ERROR]

A class has a single reason to change. If a class handles validation, calculation, and persistence, it has three reasons — split it.

### PHP-028 — SOLID: open for extension, closed for modification [WARNING]

When new behavior is needed (e.g., new order type), prefer polymorphism or strategy over adding `if/else` to existing code.

### PHP-029 — SOLID: dependency inversion [WARNING]

Managers and handlers depend on abstractions (interfaces), not concrete classes, when the dependency can vary.

```php
// correct
public function __construct(
    private readonly EncryptionInterface $crypto,
) {}

// acceptable for stable dependencies
public function __construct(
    private readonly Database $db,
) {}
```

---

## 6. Methods

### PHP-030 — Maximum 20 lines per method [WARNING]

If a method exceeds 20 lines, it probably does more than one thing. Extract sub-methods.

### PHP-031 — Early return [WARNING]

Reduce nesting using guard clauses.

```php
// correct
public function process(Order $order): void
{
    if ($order->isCancelled()) {
        return;
    }

    if (!$order->hasAccount()) {
        throw new OrderWithoutAccountException();
    }

    // main logic here
}

// incorrect
public function process(Order $order): void
{
    if (!$order->isCancelled()) {
        if ($order->hasAccount()) {
            // main logic here
        } else {
            throw new OrderWithoutAccountException();
        }
    }
}
```

### PHP-032 — Maximum 4 parameters per method [WARNING]

If a method needs more than 4 parameters, consider a Value Object or DTO.

### PHP-033 — Public entity methods as descriptive predicates [WARNING]

```php
// correct
$order->isConfirmed();
$account->isActive();
$goal->wasAchieved();

// incorrect
$order->getStatus() === 'confirmed';
$account->getActive() === true;
```

---

## 7. Error handling

### PHP-034 — Typed exceptions, never generic [ERROR]

```php
// correct
throw new InsufficientBalanceException($account->id(), $requestedAmount);
throw new OrderNotFoundException($id);

// incorrect
throw new \Exception('Insufficient balance');
throw new \RuntimeException('Not found');
```

### PHP-035 — Never silence errors with @ [ERROR]

```php
// correct
$result = json_decode($json, true);
if (json_last_error() !== JSON_ERROR_NONE) {
    throw new InvalidJsonException(json_last_error_msg());
}

// incorrect
$result = @json_decode($json, true);
```

### PHP-036 — Specific catch, never generic \Throwable [WARNING]

```php
// correct
try {
    $this->repository->save($order);
} catch (DuplicateException $e) {
    // handle specific case
}

// incorrect
try {
    $this->repository->save($order);
} catch (\Throwable $e) {
    // swallow everything
}
```

---

## 8. Security

### PHP-037 — Sensitive data encrypted at rest [ERROR]

Every sensitive value must be encrypted before writing to the database and decrypted after reading.

```php
// correct
$encryptedValue = $this->crypto->encrypt((string) $order->valueCents());
$db->insert($table, ['value_cents' => $encryptedValue]);

// incorrect
$db->insert($table, ['value_cents' => $order->valueCents()]);
```

### PHP-038 — Always use parameterized queries [ERROR]

```php
// correct
$db->prepare("SELECT * FROM {$table} WHERE user_id = ?", [$userId]);

// incorrect
$db->query("SELECT * FROM {$table} WHERE user_id = {$userId}");
```

### PHP-039 — Sanitize input, escape output [ERROR]

All user input is sanitized before use. All output to the browser is escaped.

### PHP-040 — Validation at the system boundary [ERROR]

Handlers validate and sanitize all received data before passing it to managers or repositories. Entities and repositories trust that the data arrives clean.

### PHP-041 — Keys and secrets live in .env, never in code [ERROR]

```php
// correct
$key = getenv('APP_ENCRYPTION_KEY');

// incorrect
$key = 'my-hardcoded-secret-key';
```

### PHP-042 — Don't optimize prematurely [WARNING]

Performance optimizations (cache, denormalization, complex queries) only enter when there is measurement proving the bottleneck. Clear and correct code first, optimized later.

---

## 9. Formatting

### PHP-043 — Indentation with 4 spaces [ERROR]

Never tabs. Always 4 spaces.

### PHP-044 — Braces on the same line for control structures [WARNING]

```php
// correct
if ($condition) {
    // body
}

// incorrect
if ($condition)
{
    // body
}
```

### PHP-045 — Braces on the next line for classes and methods [WARNING]

```php
// correct (PSR-12)
class Order
{
    public function valueCents(): int
    {
        return $this->valueCents;
    }
}
```

### PHP-046 — Blank line between methods [WARNING]

### PHP-047 — Maximum 120 characters per line [WARNING]

Break long lines with alignment.

### PHP-048 — One statement per line [ERROR]

```php
// correct
$a = 1;
$b = 2;

// incorrect
$a = 1; $b = 2;
```

---

## 10. Versioning

### PHP-049 — SemVer 2.0.0 [WARNING]

The project follows semantic versioning:

- **MAJOR** (X.y.z) — Incompatible API changes.
- **MINOR** (x.Y.z) — New functionality while maintaining compatibility.
- **PATCH** (x.y.Z) — Bug fixes while maintaining compatibility.

---

## Audit checklist

The `/audit-php` skill must verify, for each file:

- [ ] Principles: KISS, DRY, YAGNI, SoC, Demeter respected
- [ ] `declare(strict_types=1)` present
- [ ] No closing tag `?>`
- [ ] One class per file
- [ ] Classes in PascalCase, methods in camelCase, constants in UPPER_SNAKE_CASE
- [ ] Explicit visibility on everything
- [ ] Type hints on all parameters and return types
- [ ] Typed properties
- [ ] Rich entities (with behavior), not anemic
- [ ] Getters without get_ prefix (e.g., name(), not getName())
- [ ] FSM in the entity via STATUS_TRANSITIONS + lifecycle methods
- [ ] from_row() tolerant (never throws exception)
- [ ] Entities without infrastructure dependency
- [ ] Single responsibility per class
- [ ] Composition over inheritance
- [ ] Typed exceptions (never generic)
- [ ] No `@` error suppressor
- [ ] Sensitive data encrypted
- [ ] Parameterized queries in every query
- [ ] Input sanitized, output escaped
- [ ] No hardcoded secrets
- [ ] Indentation with 4 spaces
- [ ] Maximum 120 characters per line

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
2. Compare against **every rule** from `docs/php-standards.md`, one by one, in document order.
3. For each violation found, record:
   - **File** and **line(s)** where it occurs
   - **Rule ID** violated (e.g., php-standards.md, PHP-024)
   - **Severity** (ERROR or WARNING)
   - **What's wrong** — concise description
   - **How to fix** — specific correction for that snippet
4. If the file violates no rules, record as approved.

### Phase 4 — Report

Present the report to the user in the following format:

```
## PHP Audit Report

**PR:** #<number> — <title>
**Branch:** <branch>
**Files audited:** <count>
**Ruleset:** docs/php-standards.md

### Summary

- Errors: <count>
- Warnings: <count>
- Approved files: <count>

### Violations

#### <file.php>

| Line | Rule | Severity | Description | Fix |
|------|------|----------|-------------|-----|
| 15 | PHP-024 | ERROR | FSM not defined | Add STATUS_TRANSITIONS |
| 32 | PHP-030 | WARNING | Method with 25 lines | Extract sub-method |

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
- **Never invent rules.** The ruleset is exclusively `docs/php-standards.md` — no opinions, no extra suggestions.
- **Be methodical and procedural.** Each file is compared against each rule, in document order, without skipping.
- **Fidelity to the document.** If the code violates a rule in the document, report it. If the document doesn't cover the case, don't report it.
- **Show the complete report before any action.** Never apply corrections without explicit approval.
