---
document: oop-standards
version: 2.1.0
created: 2026-04-07
updated: 2026-04-16
total_rules: 27
severities:
  error: 14
  warning: 13
scope: Object-oriented design and architecture across all PHP projects
applies_to: ["all"]
requires: ["php-standards"]
replaces: ["oop-standards v1 (previous version)"]
---

# OOP Standards — your organization

> Constitutional document. Delivery contract for every
> developer who touches object-oriented programming in our projects.
> Code that violates ERROR rules is not discussed — it is returned.
> 27 rules | IDs: POO-001 to POO-027 (POO-028 removed — generic scope, not OOP)

---

## How to use this document

### For the developer

1. Read the rules that affect the classes you're creating or modifying.
2. Before opening a PR, go through the DoD at the end of the document.
3. Use rule IDs (e.g., POO-003) to reference decisions in code review.

### For the auditor (human or AI)

1. Read the frontmatter to understand scope and dependencies.
2. Audit the code against each rule by ID and severity.
3. Classify violations: ERROR blocks merge, WARNING requires written justification.
4. Reference violations by rule ID (e.g., "violates POO-017").

### For Claude Code

1. Read the frontmatter to know which projects and dependencies apply.
2. In code review, check each rule by ID — start with ERROR rules.
3. When reporting violations, always cite the ID (e.g., "violates POO-005 — Tell, Don't Ask").
4. Consult `php-standards` for language rules that complement this document.

---

## Severities

| Level | Meaning | Action |
|-------|---------|--------|
| **ERROR** | Non-negotiable violation | Blocks merge. Fix before review. |
| **WARNING** | Strong recommendation | Must be justified in writing if ignored. |

---

## 1. Domain modeling

### POO-001 — Classes represent domain nouns [ERROR]

**Rule:** Each entity class represents a real business concept. The class name dictates its role — no generic classes that try to be two things.

**Checks:** Grep for `^class ` — name should be a domain noun. Fails if generic names like `Item`, `Data`, `Helper`, `Record`, `Manager` appear without a domain prefix.

**Why:** Small teams need to understand the code in 5 minutes. A class called `Item` or `Data` forces the developer to read the entire body to understand what it does. Domain names eliminate that time loss.

**Correct example:**
```php
// each class maps a real business concept
class Order {}
class Customer {}
class Product {}
class Invoice {}
```

**Incorrect example:**
```php
// generic, ambiguous — nobody knows what it does without reading the body
class Item {}
class Record {}
class Data {}
class Helper {}
```

### POO-002 — Methods express intent with action verbs [ERROR]

**Rule:** Business methods use verbs that describe what the object **does**, never what it **exposes**. The method name should communicate business intent.

**Checks:** Grep for `public function set[A-Z]` in entities. Mutation methods should use domain verbs (`confirm`, `cancel`), not generic setters.

**Why:** AI-assisted development depends on self-explanatory code. A `confirm()` method communicates intent instantly. A `setStatus('confirmed')` method hides the business rule and requires the reader (human or AI) to guess the context.

**Correct example:**
```php
$order->confirm();
$account->transferTo($otherAccount, $amount);
$task->complete();
```

**Incorrect example:**
```php
$order->setStatus('confirmed');
$account->updateBalance($newBalance);
$task->setComplete(true);
```

### POO-003 — No anemic classes [ERROR]

**Rule:** Entities contain domain logic: state predicates, transitions, validations, and business calculations. Never bags of getters and setters.

**Checks:** Inspect entities — each must have at least 1 lifecycle method or state predicate besides getters. Fails if a class only has `get`/`set`/`__construct`.

**Why:** Anemic classes scatter business logic across managers, handlers, and scripts. When a new developer joins the team, they don't know where the rule lives. Rich entities concentrate logic where it belongs — in the object that knows its own data.

**Correct example:**
```php
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

    public function netAmount(): int
    {
        return $this->amountCents - $this->discountCents;
    }
}
```

**Incorrect example:**
```php
class Order
{
    public function getStatus(): string { return $this->status; }
    public function setStatus(string $s): void { $this->status = $s; }
    public function getAmountCents(): int { return $this->amountCents; }
}
// business logic scattered across managers and scripts
```

---

## 2. Encapsulation

### POO-004 — Properties always private [ERROR]

**Rule:** Every property is `private` (or `readonly` via constructor promotion). `protected` only in real inheritance hierarchies. Never `public`.

**Checks:** Grep for `public (?:string|int|float|bool|array|\?)\s+\$` in classes. Any `public` property without `readonly` is a violation.

**Why:** Public properties allow any part of the system to change the object's state without validation. In the project, where projects are maintained by small, rotating teams, a public property becomes a time bomb — someone will mutate it without knowing the business rules.

**Correct example:**
```php
class Customer
{
    private string $name;
    private string $email;
    private bool $active;
}
```

**Incorrect example:**
```php
class Customer
{
    public string $name;
    public string $email;
}
```

### POO-005 — Tell, Don't Ask [ERROR]

**Rule:** Never extract data from an object to make decisions outside of it. Tell the object what to do — it decides internally.

**Checks:** Grep for `if.*\$\w+->(?:status|get[A-Z])\(\).*===` outside the class itself. Decisions based on external getters are a violation.

**Why:** External decisions duplicate logic and create inconsistency. When the rule changes, you need to hunt down every place that does `if ($obj->status() === '...')` instead of modifying a single method in the entity. In the project, with few developers, that hunt becomes a production bug.

**Correct example:**
```php
$order->confirm();
// internally: checks if it can transition, changes status, throws exception if it can't
```

**Incorrect example:**
```php
if ($order->status() === 'pending') {
    $order->setStatus('confirmed');
}
```

### POO-006 — Private setters, mutation via business methods [ERROR]

**Rule:** Mutable properties are changed by methods that express business intent, never by public setters.

**Checks:** Grep for `public function set[A-Z]` — any public setter in an entity is a violation. Mutation must be via domain method.

**Why:** Public setters eliminate any encapsulation protection. In the project, any developer should be able to call entity methods without knowing internal rules — the business method guarantees the transition is valid. A setter guarantees nothing.

**Correct example:**
```php
class Task
{
    private string $status;

    public function complete(): void
    {
        if (!$this->canComplete()) {
            throw new InvalidOperationException('Task cannot be completed in this state.');
        }
        $this->status = self::STATUS_COMPLETED;
    }
}
```

**Incorrect example:**
```php
class Task
{
    public function setStatus(string $status): void
    {
        $this->status = $status;
    }
}
```

### POO-007 — Immutable objects when possible [WARNING]

**Rule:** For data that doesn't change after creation (configurations, Value Objects, read DTOs), use `readonly` in the constructor. No setters, no mutation.

**Checks:** Inspect VOs and DTOs — properties must have `readonly`. Grep for `function set` in those files should return zero.

**Why:** Immutable objects eliminate an entire category of bugs — nobody can accidentally mutate a value that should be constant. In small teams without exhaustive code review, immutability is an automatic safety net.

**Correct example:**
```php
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

**Incorrect example:**
```php
class ReportPeriod
{
    private DateTimeImmutable $start;
    private DateTimeImmutable $end;

    public function setStart(DateTimeImmutable $start): void
    {
        $this->start = $start;
    }
}
```

---

## 3. Inheritance and polymorphism

### POO-008 — Inheritance only for real subtypes [ERROR]

**Rule:** Inheritance only when the statement "X **is a** Y" is behaviorally true. To reuse code, use composition (dependency injection).

**Checks:** Grep for `extends` — each inheritance must pass the "X is a Y" test. Fails if a class inherits just to reuse a utility method.

**Why:** Poorly used inheritance creates rigid coupling that prevents evolution. In the project, projects change fast — a manager that inherits from `BaseManager` to reuse a method carries the entire weight of the parent class. Composition allows swapping parts without cascade effects.

**Correct example:**
```php
// real subtype — domain exception "is an" exception
abstract class DomainException extends \DomainException {}
class EntityNotFoundException extends DomainException {}
class InvalidTransitionException extends DomainException {}
```

**Incorrect example:**
```php
// inheritance to reuse code — "has functionality of", not "is a"
class OrderManager extends BaseManager {}
class CustomerManager extends BaseManager {}
```

### POO-009 — Concrete classes are final [WARNING]

**Rule:** Concrete classes not designed for extension should use `final`. Prevents accidental inheritance.

**Checks:** Grep for `^class ` (without `abstract`) — concrete classes without `final` that aren't hierarchy bases are a violation.

**Why:** Without `final`, any developer can inherit from a class that wasn't designed for it and create unpredictable behavior. In the project, where onboarding is fast and AI-assisted, `final` explicitly communicates: "this class was not made for extension".

**Correct example:**
```php
final class OrderRepository
{
    // ...
}
```

**Incorrect example:**
```php
// without final, another dev can inherit without knowing they shouldn't
class OrderRepository
{
    // ...
}
```

### POO-010 — Polymorphism replaces type-based switch/if [WARNING]

**Rule:** When multiple `if/else` or `switch` statements decide behavior based on the "type" of something, extract to a polymorphic hierarchy.

**Checks:** Grep for `switch.*\$type` or `if.*===.*'type'` — decisions by type in 3+ branches indicate a violation. Should be polymorphism.

**Why:** Each new type added via `switch` requires modifying existing code and retesting everything. With polymorphism, new types are new classes — no existing code is touched. Less risk, less regression.

**Correct example:**
```php
interface DiscountCalculator
{
    public function calculate(int $amountCents): int;
}

class PercentageDiscount implements DiscountCalculator
{
    public function __construct(private readonly float $percentage) {}

    public function calculate(int $amountCents): int
    {
        return (int) ($amountCents * $this->percentage);
    }
}

class FixedDiscount implements DiscountCalculator
{
    public function __construct(private readonly int $discountCents) {}

    public function calculate(int $amountCents): int
    {
        return min($this->discountCents, $amountCents);
    }
}
```

**Incorrect example:**
```php
function calculateDiscount(string $type, int $amount): int
{
    switch ($type) {
        case 'percentage': return (int) ($amount * 0.10);
        case 'fixed': return 500;
    }
}
```

---

## 4. Interfaces and abstractions

### POO-011 — Lean and specific interfaces [WARNING]

**Rule:** Interfaces define small, cohesive contracts. Never "fat interfaces" that force implementation of irrelevant methods.

**Checks:** Count methods per interface — more than 5 methods indicates a fat interface. Check if implementations have empty methods or `throw new \RuntimeException`.

**Why:** Fat interfaces force classes to implement methods that don't make sense for them. In the project, this generates empty methods or ones that throw `RuntimeException` — dead code that confuses anyone reading or auditing.

**Correct example:**
```php
interface Encryptable
{
    public function encrypt(string $data): string;
    public function decrypt(string $data): string;
}
```

**Incorrect example:**
```php
interface CentralService
{
    public function encrypt(string $data): string;
    public function calculateTotal(int $id): int;
    public function sendEmail(string $to, string $subject): void;
}
```

### POO-012 — Depend on abstractions, not concrete implementations [WARNING]

**Rule:** Managers and handlers receive interfaces when the dependency can vary. Stable dependencies (like `$wpdb`) can be concrete.

**Checks:** Inspect constructors of managers/handlers — variable dependencies (crypto, cache, notifications) should receive an interface, not a concrete class.

**Why:** Swapping a concrete implementation requires changing all classes that depend on it. With an interface, the swap is transparent. In the project, where encryption, cache, and external integrations can change between projects, abstracting is mandatory.

**Correct example:**
```php
class OrderManager
{
    public function __construct(
        private readonly CryptoInterface $crypto,
        private readonly \wpdb $wpdb, // stable, concrete is acceptable
    ) {}
}
```

**Incorrect example:**
```php
class OrderManager
{
    public function __construct(
        private readonly AES256Crypto $crypto, // what if the algorithm changes?
    ) {}
}
```

### POO-013 — Abstract classes as hierarchy templates [WARNING]

**Rule:** Abstract classes share state and behavior between real subtypes. Never use them as "utility method repositories".

**Checks:** Grep for `abstract class` — verify it has at least 1 real subtype via `extends`. Abstract class without a child or used as a bag of utilities is a violation.

**Why:** Abstract classes used as "bag of utilities" create forced inheritance. In the project, each class must justify its existence as a domain concept — utilities become functions or injected final classes.

**Correct example:**
```php
abstract class DomainException extends \DomainException
{
    public function __construct(
        string $message,
        private readonly string $businessCode,
    ) {
        parent::__construct($message);
    }

    public function businessCode(): string
    {
        return $this->businessCode;
    }
}
```

**Incorrect example:**
```php
abstract class BaseHelper
{
    protected function formatDate(string $date): string { /* ... */ }
    protected function sanitizeString(string $s): string { /* ... */ }
    protected function logError(string $msg): void { /* ... */ }
}

class OrderService extends BaseHelper {} // inherits to use formatDate()
```

---

## 5. Value Objects

### POO-014 — Primitive types with domain meaning become Value Objects [WARNING]

**Rule:** When a primitive carries validation or formatting rules, encapsulate it in a Value Object. Examples: money in cents, CPF, email, date range.

**Checks:** Grep for `int $amountCents`, `string $cpf`, `string $email` in entities — primitives with domain rules repeated in 2+ classes should be VOs.

**Why:** Loose primitives scatter validation across the entire system. In the project, an `int $amountCents` appears in entities, repositories, and handlers — if validation only exists in one place, the others are unprotected. Value Objects validate at creation and guarantee consistency in any context.

**Correct example:**
```php
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

    public function greaterThan(self $other): bool
    {
        return $this->cents > $other->cents;
    }

    public function formatted(): string
    {
        return '$' . number_format($this->cents / 100, 2, '.', ',');
    }
}
```

**Incorrect example:**
```php
// loose primitive without validation — any value passes
$total = $amountCents + $shippingCents;
if ($total < 0) { /* dispersed validation */ }
```

### POO-015 — Value Objects are immutable [ERROR]

**Rule:** Value Objects never change after creation. Operations return new instances.

**Checks:** Inspect VOs — all properties must be `readonly`. Operation methods must return `new self(...)`, never mutate `$this`.

**Why:** A mutable Value Object is a bug waiting to happen. If two objects share a reference to a VO and one of them changes the value, the other is affected without knowing. In the project, where entities pass VOs between layers, immutability is the only guarantee of integrity.

**Correct example:**
```php
$total = $price->add($shipping); // new Money, $price doesn't change
```

**Incorrect example:**
```php
$price->addTo($shipping); // changes the original object — side effect
```

### POO-016 — Comparison by value, not by reference [WARNING]

**Rule:** Value Objects implement an equality method based on attributes, never on memory reference.

**Checks:** Inspect VOs — an `equals(self)` method must exist. Grep for `===` comparing two VOs by reference is a violation.

**Why:** Two `Money(100)` objects created separately should be considered equal. Without a comparison method, PHP compares by reference and says they're different — generating subtle bugs in validations and tests.

**Correct example:**
```php
final class Money
{
    public function equals(self $other): bool
    {
        return $this->cents === $other->cents;
    }
}
```

**Incorrect example:**
```php
// reference comparison — two VOs with the same value are "different"
if ($moneyA === $moneyB) { /* false even with equal values */ }
```

---

## 6. Architectural patterns

### POO-017 — Entity: Rich Domain Model with FSM [ERROR]

**Rule:** Every entity with state follows the Rich Domain Model pattern with a finite state machine. Mandatory structure:

1. Status constants
2. `STATUS_TRANSITIONS` defining valid transitions
3. Parameterized constructor (valid state from creation)
4. Getters without `get_` prefix
5. Lifecycle methods (`confirm()`, `cancel()`) with Tell, Don't Ask
6. State predicates (`isConfirmed()`, `isPending()`)
7. Public `canTransitionTo()`
8. Tolerant `fromRow()` (never throws exception)
9. `toArray()` for serialization

**Checks:** Checklist per entity: (1) `STATUS_TRANSITIONS` present, (2) `fromRow` and `toArray` exist, (3) grep for `get_` returns zero, (4) at least 1 lifecycle method and 1 predicate.

**Why:** This pattern is the project's architectural contract. Any developer or AI that opens an entity knows exactly where to find each piece. Without a pattern, each entity is its own universe — impossible to audit or maintain with a small team.

**Correct example:**
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

    public function __construct(
        private readonly int $id,
        private readonly int $userId,
        private int $amountCents,
        private string $status = self::STATUS_PENDING,
        private readonly DateTimeImmutable $createdAt = new DateTimeImmutable(),
    ) {}

    // Getters without get_
    public function id(): int { return $this->id; }
    public function status(): string { return $this->status; }
    public function amountCents(): int { return $this->amountCents; }

    // Lifecycle methods
    public function confirm(): void
    {
        if (!$this->canTransitionTo(self::STATUS_CONFIRMED)) {
            throw new InvalidTransitionException($this->status, self::STATUS_CONFIRMED);
        }
        $this->status = self::STATUS_CONFIRMED;
    }

    public function cancel(): void
    {
        if (!$this->canTransitionTo(self::STATUS_CANCELLED)) {
            throw new InvalidTransitionException($this->status, self::STATUS_CANCELLED);
        }
        $this->status = self::STATUS_CANCELLED;
    }

    // Predicates
    public function isConfirmed(): bool { return $this->status === self::STATUS_CONFIRMED; }
    public function isPending(): bool { return $this->status === self::STATUS_PENDING; }

    // FSM
    public function canTransitionTo(string $newStatus): bool
    {
        return in_array($newStatus, self::STATUS_TRANSITIONS[$this->status] ?? [], true);
    }

    // Tolerant hydration
    public static function fromRow(object $row): self
    {
        $entity = (new \ReflectionClass(self::class))
            ->newInstanceWithoutConstructor();

        $entity->id = (int) $row->id;
        $entity->userId = (int) $row->user_id;
        $entity->amountCents = (int) $row->amount_cents;
        $entity->status = (string) $row->status;

        return $entity;
    }

    // Serialization
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->userId,
            'amount_cents' => $this->amountCents,
            'status' => $this->status,
        ];
    }
}
```

**Incorrect example:**
```php
class Order
{
    // no status constants
    // no STATUS_TRANSITIONS
    // no lifecycle methods
    private string $status;

    public function getStatus(): string { return $this->status; }
    public function setStatus(string $s): void { $this->status = $s; } // direct mutation
}
```

### POO-018 — Repository: uniform interface [ERROR]

**Rule:** Every repository follows the same method structure:

1. `findById(int $id): ?Entity`
2. `findAll(): array`
3. `create(Entity $e): int`
4. `update(Entity $e): bool`
5. `delete(int $id): bool`
6. `tableName(): string` (private)
7. `hydrate(object $row): Entity` (private)

**Checks:** Grep for `class.*Repository` — each repo must have `findById`, `create`, `update`, `tableName`, `hydrate`. Methods with non-standard names (`fetch`, `save`) are a violation.

**Why:** A uniform interface allows any developer (or AI) to navigate any repository without surprises. In the project, repositories are the single point of database access — uniformity eliminates doubts about where and how data is persisted.

**Correct example:**
```php
class OrderRepository
{
    public function __construct(
        private readonly \wpdb $wpdb,
    ) {}

    public function findById(int $id): ?Order
    {
        $row = $this->wpdb->get_row($this->wpdb->prepare(
            "SELECT * FROM {$this->tableName()} WHERE id = %d",
            $id
        ));

        return $row ? $this->hydrate($row) : null;
    }

    public function create(Order $order): int
    {
        $this->wpdb->insert($this->tableName(), [
            'user_id' => $order->userId(),
            'amount_cents' => $order->amountCents(),
            'status' => $order->status(),
        ]);

        return (int) $this->wpdb->insert_id;
    }

    private function tableName(): string
    {
        return $this->wpdb->prefix . 'orders';
    }

    private function hydrate(object $row): Order
    {
        return Order::fromRow($row);
    }
}
```

**Incorrect example:**
```php
class OrderRepository
{
    // methods with inconsistent names
    public function fetch(int $id): ?Order { /* ... */ }
    public function save(Order $o): void { /* ... */ }
    public function remove(int $id): void { /* ... */ }
    // no hydrate, no tableName — direct access scattered
}
```

### POO-019 — Manager: orchestration without domain logic [ERROR]

**Rule:** Managers coordinate operations between entities and repositories. Domain logic lives in the entity, never in the manager.

**Checks:** Grep for `if.*->status\(\)` or `if.*->get` inside `*Manager` classes — business conditions in the manager are a violation. They should be in the entity.

**Why:** Managers with domain logic become giant, untouchable classes — nobody knows where the business rule really lives. In the project, the entity is the source of truth. The manager only orchestrates: fetch, delegate, persist.

**Correct example:**
```php
class OrderManager
{
    public function __construct(
        private readonly OrderRepository $orders,
    ) {}

    public function confirmOrder(int $orderId): void
    {
        $order = $this->orders->findById($orderId);

        if (!$order) {
            throw new EntityNotFoundException('Order', $orderId);
        }

        $order->confirm(); // logic in the entity
        $this->orders->update($order);
    }
}
```

**Incorrect example:**
```php
class OrderManager
{
    public function confirmOrder(int $id): void
    {
        $order = $this->orders->findById($id);

        if ($order->status() !== 'pending') { // logic should be in the entity
            throw new \Exception('Cannot confirm');
        }

        // changes status directly — violates Tell, Don't Ask
    }
}
```

### POO-020 — Handler: system boundary [ERROR]

**Rule:** Handlers are the boundary between the external world (HTTP/AJAX request) and the domain. Responsibilities:

1. Verify authentication and authorization
2. Sanitize and validate input
3. Delegate to the manager
4. Return response

Handlers never contain domain logic nor access `$wpdb` directly.

**Checks:** Grep for `\$wpdb` and `global \$wpdb` in `*Handler` classes — any occurrence is a violation. Grep for `if.*status.*===` in the handler indicates leaked domain logic.

**Why:** Handlers that access the database or contain business logic mix boundary with domain. In the project, handlers are disposable — if the interface changes (from AJAX to REST, from WordPress to framework X), only the handler changes. Business logic remains intact in entities and managers.

**Correct example:**
```php
class OrderAjaxHandler
{
    public function __construct(
        private readonly OrderManager $manager,
    ) {}

    public function handleConfirm(): void
    {
        $this->checkPermission();

        $orderId = absint($_POST['order_id'] ?? 0);

        if (!$orderId) {
            wp_send_json_error(['message' => 'Order ID is required.']);
        }

        try {
            $this->manager->confirmOrder($orderId);
            wp_send_json_success(['message' => 'Order confirmed.']);
        } catch (EntityNotFoundException $e) {
            wp_send_json_error(['message' => 'Order not found.']);
        } catch (InvalidTransitionException $e) {
            wp_send_json_error(['message' => 'Invalid status transition.']);
        }
    }

    private function checkPermission(): void
    {
        check_ajax_referer('app_nonce', 'nonce');

        if (!current_user_can('manage_options')) {
            wp_send_json_error(['message' => 'No permission.'], 403);
        }
    }
}
```

**Incorrect example:**
```php
class OrderAjaxHandler
{
    public function handleConfirm(): void
    {
        global $wpdb; // direct database access in handler
        $row = $wpdb->get_row("SELECT * FROM orders WHERE id = ...");

        if ($row->status !== 'pending') { // domain logic in handler
            wp_send_json_error(['message' => 'Cannot confirm.']);
        }

        $wpdb->update('orders', ['status' => 'confirmed'], ['id' => $row->id]);
    }
}
```

---

## 7. SOLID

### POO-021 — SRP: one reason to change per class [ERROR]

**Rule:** Each class has a single responsibility. If a class does validation, calculation, and persistence, split into entity (calculation/validation), repository (persistence), and handler (input validation).

**Checks:** Inspect classes >200 LOC — if it contains `$wpdb` + business logic + email sending in the same class, it violates SRP. Each responsibility should be in a separate class.

**Why:** Classes with multiple responsibilities grow uncontrollably. In the project, with small teams and rotation, a class that does everything is a class nobody wants to touch. SRP ensures each change affects a single file — less conflict, less risk.

**Correct example:**
```php
// each class has ONE responsibility
class Order
{
    // responsibility: business rules of the order
    public function confirm(): void { /* ... */ }
    public function totalAmount(): int { /* ... */ }
}

class OrderRepository
{
    // responsibility: persistence
    public function findById(int $id): ?Order { /* ... */ }
    public function create(Order $o): int { /* ... */ }
}

class OrderManager
{
    // responsibility: orchestration
    public function confirmOrder(int $id): void { /* ... */ }
}
```

**Incorrect example:**
```php
class OrderService
{
    // does everything: validation, calculation, persistence, email sending
    public function confirm(int $id): void
    {
        $row = $this->wpdb->get_row("SELECT ...");      // persistence
        if ($row->status !== 'pending') { /* ... */ }     // domain logic
        $this->wpdb->update('orders', ['status' => 'confirmed'], ['id' => $id]); // persistence
        wp_mail($email, 'Order confirmed', '...');       // notification
    }
}
```

### POO-022 — OCP: extension without modification [WARNING]

**Rule:** When new behavior is needed (new type, new calculation rule), prefer polymorphism or strategy over `if/else` in existing code.

**Checks:** Grep for `switch` and `elseif` chains with 3+ branches on type/category — should be polymorphism or strategy pattern.

**Why:** Modifying existing code to add new behavior requires retesting everything that already worked. In the project, where automated tests are still being built, every change to stable code is a risk. Extension via polymorphism isolates the new without touching the existing.

### POO-023 — LSP: substitutable subtypes [WARNING]

**Rule:** Every child class must be able to replace the parent class without breaking behavior. If the subclass needs to disable a parent method, the design is wrong — extract to sibling classes.

**Checks:** Inspect child classes — grep for `throw new \RuntimeException` or empty method that overrides a parent method. A subtype that disables inherited behavior is a violation.

**Why:** Subtypes that break the parent class contract create silent bugs. In the project, where Claude Code audits inheritances automatically, an LSP violation generates unpredictable behavior that only appears in production.

### POO-024 — ISP: segregated interfaces [WARNING]

**Rule:** Small, cohesive interfaces. If a class needs to implement methods it doesn't use, the interface is fat — split it.

**Checks:** Grep for `implements` — verify the class implements all methods with real bodies. Empty method or `throw new \RuntimeException` in an implementation indicates a fat interface.

**Why:** In the project, interfaces are contracts between layers. A fat interface forces implementations to carry dead methods — code nobody calls but that appears in every audit as a potential failure point.

### POO-025 — DIP: dependency inversion [WARNING]

**Rule:** High-level modules (managers) depend on abstractions (interfaces), never on concrete implementations, when the dependency can vary.

**Checks:** Inspect type hints in manager constructors — variable dependencies (crypto, cache, notifications) must type-hint the interface, not the concrete class.

**Why:** In the project, dependencies like encryption, cache, and external services vary between projects. If a manager depends on `AES256Crypto` directly, changing the algorithm requires modifying the manager. With an interface, the swap is transparent and the manager doesn't even notice.

**Correct example:**
```php
interface CryptoInterface
{
    public function encrypt(string $data): string;
    public function decrypt(string $ciphertext): string;
}

class OrderManager
{
    public function __construct(
        private readonly CryptoInterface $crypto, // abstraction
        private readonly OrderRepository $orders,
    ) {}
}

// concrete implementation injected at composition
$manager = new OrderManager(new AES256Crypto($key), $repo);
```

**Incorrect example:**
```php
class OrderManager
{
    public function __construct(
        private readonly AES256Crypto $crypto, // concrete — what if it changes?
    ) {}
}
```

---

## 8. Enums and type safety

### POO-026 — Enums for closed domains [WARNING]

**Rule:** Statuses, types, and categories with a fixed set of values must use PHP Enums (8.1+), never loose strings.

**Checks:** Grep for `=== '` in status/type/category comparisons — if the value set is closed and known, it should be an Enum. Loose strings repeated in 2+ files are a violation.

**Why:** Loose strings accept any value — a typo like `'pendnig'` passes the compiler and only blows up in production. Enums validate at compile time and provide IDE autocompletion. In the project, where typos in status strings have caused inconsistent data, Enums are mandatory for closed domains.

**Correct example:**
```php
enum OrderStatus: string
{
    case Pending = 'pending';
    case Confirmed = 'confirmed';
    case Cancelled = 'cancelled';
}

enum ProductType: string
{
    case Physical = 'physical';
    case Digital = 'digital';
    case Service = 'service';
}
```

**Incorrect example:**
```php
$status = 'pendnig'; // typo — no compile-time error, silent bug
```

**Exceptions:** Projects running on PHP < 8.1 should use class constants as a workaround, but upgrading to Enums is a priority.

### POO-027 — Use DateTimeImmutable, never date strings [ERROR]

**Rule:** Dates are objects, never strings. Use `DateTimeImmutable` for all temporal properties.

**Checks:** Grep for `private.*string.*\$(created|updated|date|deadline|due|start|end)` — a temporal property typed as string is a violation. Must be `DateTimeImmutable`.

**Why:** Date strings have no timezone, no format validation, and no safe comparison operations. In the project, where projects deal with due dates, deadlines, and scheduling, an invalid date or wrong timezone causes direct business impact.

**Correct example:**
```php
private readonly DateTimeImmutable $createdAt;
private ?DateTimeImmutable $deadline;
```

**Incorrect example:**
```php
private string $createdAt; // '2026-04-08'
private ?string $deadline;  // no validation, no timezone, no operations
```

---

## Definition of Done — Delivery Checklist

> PRs that don't meet the DoD don't enter review. They are returned.

| # | Item | Rules | Verification |
|---|------|-------|--------------|
| 1 | Classes named with domain nouns | POO-001 | Visual inspection of class names |
| 2 | Methods express intent with verbs | POO-002 | Visual inspection of method names |
| 3 | Entities contain domain logic (not anemic) | POO-003 | Verify entity has lifecycle methods, predicates, and calculations |
| 4 | Private attributes, no public setters | POO-004, POO-006 | Search for `public` properties and public `setX()` |
| 5 | Tell, Don't Ask respected | POO-005 | Search for external decisions based on getters |
| 6 | Inheritance only for real subtypes | POO-008 | Verify every inheritance passes the "is a" test |
| 7 | Immutable Value Objects | POO-015 | Verify `readonly` and absence of setters in VOs |
| 8 | Entity follows Rich Domain Model with FSM | POO-017 | Check status constants, STATUS_TRANSITIONS, lifecycle, predicates, fromRow, toArray |
| 9 | Repository follows uniform interface | POO-018 | Check findById, findAll, create, update, delete, hydrate, tableName |
| 10 | Manager orchestrates without domain logic | POO-019 | Verify that business conditions are in the entity |
| 11 | Handler validates and delegates (no $wpdb, no logic) | POO-020 | Search for `$wpdb` and business conditions in the handler |
| 12 | SOLID respected | POO-021 to POO-025 | Audit by rule |
| 13 | Dates use DateTimeImmutable | POO-027 | Search for `string` in temporal properties |
| 14 | Enums for closed domains | POO-026 | Search for loose strings for status/type/category |
