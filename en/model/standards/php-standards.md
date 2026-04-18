---
document: php-standards
version: 4.0.0
created: 2026-04-08
updated: 2026-04-16
total_rules: 43
severities:
  error: 27
  warning: 16
scope: All PHP code across all projects
stack: php
applies_to: [all]
requires: [security-standards, oop-standards]
replaces: [php-standards v3.0.0]
---

# PHP Standards — your organization

> Constitutional document. Delivery contract for every
> developer who touches PHP in our projects.
> Code that violates ERROR rules is not discussed — it is returned.
>
> 43 rules | IDs: PHP-002 to PHP-051 (with gaps from rules moved to other documents)
> Universal principles (KISS, YAGNI, SoC, Demeter, SOLID) -> oop-standards.md / executor skill
> Workflow (commits, SemVer, CHANGELOG) -> future process document

---

## How to use this document

### For the developer

1. Read this entire document before writing the first line of code in any project.
2. Before opening a PR, go through the DoD checklist at the end of this document.
3. When you receive a code review note referencing an ID (e.g., "violates PHP-025"), look up the rule here and fix it.
4. If you disagree with a WARNING rule, write your justification in the PR. If you disagree with an ERROR rule, talk to the technical lead before writing the code.

### For the auditor (human or AI)

1. Read the frontmatter to understand scope and dependencies with other documents.
2. Audit each PHP file against the rules by ID and severity.
3. Classify violations: ERROR blocks merge, WARNING requires written justification.
4. Reference violations by rule ID (e.g., "violates PHP-034 — generic exception").
5. In case of doubt between two documents, consult the precedence hierarchy in `standards-template.md`.

### For Claude Code

1. When doing code review, read this document and apply each relevant rule to the diff.
2. Reference violations by exact ID (e.g., "PHP-025: fromRow() using new self() violates the rule").
3. Respect severity: ERROR is blocking, WARNING is a strong recommendation.
4. Use cross-references to flag violations in other documents when applicable (e.g., "see also SEG-011").
5. Never invent rules not in this document. If you identify a gap, report it to the user.

---

## Severities

| Level | Meaning | Action |
|-------|---------|--------|
| **ERROR** | Non-negotiable violation | Blocks merge. Fix before review. |
| **WARNING** | Strong recommendation | Must be justified in writing if ignored. |

---

## 1. Security

> Security comes first because the project handles sensitive data across all
> projects — financial, health, educational. A leak is not a "bug"
> — it's a compliance incident.
>
> Detailed security rules live in `security-standards.md`. This section
> covers only what is specific to pure PHP.

### PHP-037 — Sensitive data always encrypted at rest [ERROR]

**Rule:** All sensitive data (financial values, personal data, confidential descriptions) must be encrypted before writing to the database and decrypted after reading. Use the project's encryption class.

**Checks:** `grep -rn "->insert\|->update\|INSERT INTO\|UPDATE.*SET" inc/repositories/` — repositories of sensitive entities must call `encrypt()` before persisting fields like amount, description, personal data.

**Why:** The project operates systems that store real financial and personal data. A database dump exposed without encryption delivers the complete history of every user. Encryption at rest is the last barrier: even with database access, the data is useless without the key.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Repository encrypts BEFORE writing to database.
// Even if someone accesses the table directly, they only see ciphertext.
$encryptedAmount = $this->crypto->encrypt(
    (string) $entry->amountCents()
);
$encryptedDescription = $this->crypto->encrypt(
    $entry->description()
);

$this->repository->insert([
    'user_id'     => $entry->userId(),
    'amount_cents' => $encryptedAmount,      // encrypted
    'description'  => $encryptedDescription,  // encrypted
    'status'       => $entry->status(),       // status is not sensitive
]);
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// DANGER: sensitive data written in plaintext.
// Any unauthorized access to the database exposes everything.
$this->repository->insert([
    'user_id'     => $entry->userId(),
    'amount_cents' => $entry->amountCents(),  // plaintext!
    'description'  => $entry->description(),   // plaintext!
    'status'       => $entry->status(),
]);
```

**References:** SEG-011, SEG-012, SEG-013

---

### PHP-038 — Parameterized queries mandatory [ERROR]

**Rule:** Every SQL query that receives variable data must use prepared statements with typed placeholders. No exceptions, even if the variable comes from another internal query. The specific parameterization form depends on the framework.

**Checks:** `grep -rn "->query(.*\$\|\".*{\$" inc/` should return empty. Any direct variable interpolation in SQL is a violation.

**Why:** SQL injection is the #1 attack vector in the OWASP Top 10. In systems handling sensitive data, an injection can expose or corrupt entire records. The rule is mechanical, not contextual: always parameterize, without judging whether it "seems safe".

**Correct example:**
```php
<?php
declare(strict_types=1);

// Prepared statement with typed placeholders.
// The driver escapes values automatically.
$stmt = $pdo->prepare(
    "SELECT * FROM entries WHERE user_id = :userId AND status = :status"
);
$stmt->execute([
    ':userId' => $userId,
    ':status' => $status,
]);
$results = $stmt->fetchAll();
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// VULNERABLE: direct interpolation allows SQL injection.
// A malicious $userId like "1 OR 1=1" returns all records.
$results = $pdo->query(
    "SELECT * FROM entries WHERE user_id = {$userId}"
);
```

**References:** SEG-001, SEG-002

---

### PHP-039 — Sanitize input, escape output [ERROR]

**Rule:** All data entering the system via request must be sanitized before any use. All data going to the browser must be escaped with functions appropriate to the context (HTML, attribute, URL, JS). Specific functions depend on the framework (see WordPress equivalents).

**Checks:** `grep -rn "echo.*\$_\|echo.*->.*().*;" inc/` — output without `htmlspecialchars`/`esc_html` is a violation. `grep -rn "\$_POST\[.*\]\|\$_GET\[.*\]" inc/` outside handlers indicates missing sanitization.

**Why:** Handlers are the system boundary in the projects. Unsanitized data reaching a manager or repository can corrupt records or open XSS vectors. Input sanitization and output escaping are two complementary barriers — neither substitutes the other.

**Correct example:**
```php
<?php
declare(strict_types=1);

// INPUT: sanitize in the handler, before any use.
$description = trim(strip_tags($_POST['description'] ?? ''));
$categoryId = (int) ($_POST['category_id'] ?? 0);

// OUTPUT: escape before printing to HTML.
echo '<p>' . htmlspecialchars($entry->description(), ENT_QUOTES, 'UTF-8') . '</p>';
echo '<input value="' . htmlspecialchars($entry->name(), ENT_QUOTES, 'UTF-8') . '">';
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// DANGER: direct use of $_POST without sanitization.
$description = $_POST['description'];

// DANGER: output without escaping allows XSS.
echo '<p>' . $entry->description() . '</p>';
```

**References:** SEG-003, SEG-004

---

### PHP-040 — Validation at the system boundary [ERROR]

**Rule:** Handlers validate and sanitize all received data before passing to managers or repositories. Entities and repositories trust that data arrives clean. Validation includes type, format, and domain (e.g., status only accepts whitelist values).

**Checks:** `grep -rn "\$_POST\|\$_GET\|\$_REQUEST" inc/managers/ inc/repositories/ inc/entities/` should return empty. Superglobals only appear in handlers.

**Why:** The project architecture follows clear layers (handler > manager > repository > entity). If validation leaks into inner layers, it creates duplication and coupling with the request. The handler is the only entry point — if it lets dirty data through, everything downstream is compromised.

**Correct example:**
```php
<?php
declare(strict_types=1);

// The handler is the ONLY layer that touches $_POST.
// It sanitizes, validates, and only then delegates to the manager.
class CreateEntryHandler
{
    public function handle(): void
    {
        // 1. Sanitization
        $description = trim(strip_tags($_POST['description'] ?? ''));
        $amountCents = (int) ($_POST['amount_cents'] ?? 0);
        $status = trim(strip_tags($_POST['status'] ?? ''));

        // 2. Domain validation (status whitelist)
        $allowedStatuses = ['pending', 'confirmed'];
        if (!in_array($status, $allowedStatuses, true)) {
            $this->respondError('Invalid status.');
            return;
        }

        // 3. Required field validation
        if ($amountCents === 0 || $description === '') {
            $this->respondError('Required fields.');
            return;
        }

        // 4. Delegate — manager receives clean data
        $this->manager->createEntry($description, $amountCents, $status);
    }
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// WRONG: handler passes raw data to manager.
// Validation should have happened HERE, not inside the manager.
class CreateEntryHandler
{
    public function handle(): void
    {
        $this->manager->createEntry(
            $_POST['description'],   // no sanitization!
            $_POST['amount_cents'],  // no type conversion!
            $_POST['status']         // no whitelist!
        );
    }
}
```

**References:** SEG-015, SEG-016, SEG-017, OOP-020

---

### PHP-041 — Keys and secrets live in .env, never in code [ERROR]

**Rule:** Encryption keys, API tokens, database credentials, and any secret must be loaded from environment variables or `.env` files. Never hardcoded in source code.

**Checks:** `grep -rn "password\|secret\|token\|api_key" inc/ --include="*.php" | grep -v "getenv\|env(\|_ENV"` — any match with a hardcoded literal string is a violation.

**Why:** The repository is shared between developers and Claude Code. A secret committed in code is accessible to everyone with repo access — and to the Git history forever, even if removed later. In the project, the encryption key protects real data; if it leaks, all encrypted data is exposed.

**Correct example:**
```php
<?php
declare(strict_types=1);

// The key comes from the environment. Never appears in source code.
// In production, defined on the server. In dev, in the local .env.
$key = getenv('APP_ENCRYPTION_KEY');

if ($key === false || $key === '') {
    // Explicit failure is better than running without encryption.
    throw new MissingConfigException('APP_ENCRYPTION_KEY is not set.');
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// DANGER: key hardcoded in source code.
// Anyone with repo access sees this key.
// And it stays in Git history FOREVER.
$key = 'my-hardcoded-secret-key-12345';
```

**References:** SEG-013, SEG-014

---

## 2. Duplication

> Duplicated code is the #1 source of silent divergence.

### PHP-002 — DRY: one rule, one place [ERROR]

**Rule:** A business rule is implemented in a single point of the system. If the same calculation or validation appears in two places, extract to a method or class.

**Checks:** Visual inspection in code review: look for identical calculations or validations in more than one file. `grep -rn "<suspicious-expression>" inc/` with the candidate duplicated logic.

**Why:** In the project, there was a case where the net value calculation appeared both in the creation handler and in the report manager. When the discount rule changed, only one was updated — generating report divergence for weeks. One rule, one place, zero divergence.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Calculation lives in the entity — single source of truth.
// Handler, manager, and report all use this method.
class Entry
{
    public function netAmount(): int
    {
        // Centralized business rule: amount - discount.
        return $this->amountCents - $this->discountCents;
    }
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// DUPLICATION: same calculation in two places.
// If the rule changes, someone will forget to update one of them.

// In the handler:
$net = $amount - $discount;

// In the report manager (copy of the same logic):
$net = $amount - $discount;
```

**References:** OOP-003, OOP-005

---

## 3. Typing and strict mode

> PHP without typing is a loaded gun. With sensitive data,
> a wrong type is not a "warning" — it's corrupted data.

### PHP-012 — Every PHP file opens with strict_types [ERROR]

**Rule:** Every PHP file containing code (classes, functions, scripts) must start with `declare(strict_types=1)` immediately after the opening `<?php` tag.

**Checks:** `grep -rL "strict_types" inc/` should return empty. Any PHP file without this declaration is a violation.

**Why:** Without strict_types, PHP silently coerces types: `"123abc"` becomes `123` in numeric context, without error. In a financial system, silent coercion of `"1500.50"` to `1500` (truncation) can mean lost cents on every transaction. strict_types forces immediate TypeError, revealing the bug before it corrupts data.

**Correct example:**
```php
<?php
// strict_types MUST be the first statement, before any code.
// This forces PHP to reject incompatible types with TypeError.
declare(strict_types=1);

class Entry
{
    // With strict_types, passing "123" (string) to $id (int) throws TypeError.
    public function __construct(
        private readonly int $id,
        private readonly string $name,
    ) {}
}
```

**Incorrect example:**
```php
<?php
// WITHOUT strict_types, PHP accepts "123abc" as integer without error.
// This can silently corrupt data.
class Entry
{
    public function __construct(
        private readonly int $id,
        private readonly string $name,
    ) {}
}
```

---

### PHP-014 — Type hints mandatory on parameters [ERROR]

**Rule:** Every method or function parameter must have an explicit type hint. No exceptions.

**Checks:** PHPStan level 6+ or `grep -rn "function.*(\$" inc/` — parameter without type before `$` is a violation.

**Why:** Type hints are the executable documentation of a method's contract. In the project, where Claude Code performs automated code review, type hints allow detecting incompatibilities without running the code. Passing a string where an int is expected can mean arithmetic with the wrong type — and corrupted data.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Type hints make the contract explicit: int in, array out.
// Any call with the wrong type throws TypeError immediately.
public function findByUser(int $userId): array
{
    // ...
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// Without type hint, $userId can be anything: string, null, array.
// The error only surfaces deep inside the query, if at all.
public function findByUser($userId)
{
    // ...
}
```

**References:** OOP-004

---

### PHP-015 — Return type mandatory [ERROR]

**Rule:** Every method must declare its return type. Use `void` for methods without return. Use `?Type` or `Type|null` for nullable returns.

**Checks:** `grep -rn "function .*)[^:]" inc/ --include="*.php"` — method without `:` after parentheses indicates missing return type. PHPStan level 6+ detects automatically.

**Why:** The return type is the method's output contract. In the project, managers depend on repository returns to make decisions. A repository that returns `null` when the manager expects an object causes a fatal in production. The explicit return type forces the IDE and PHP to detect this before deployment.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Typed return: the caller knows EXACTLY what to expect.
public function calculateBalance(): int
{
    return $this->valueCents - $this->discountCents;
}

// Nullable return: the caller knows they need to check for null.
public function findOrNull(int $id): ?Entry
{
    // ...
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// No return type: returns int? string? null? Nobody knows.
public function calculateBalance()
{
    return $this->valueCents - $this->discountCents;
}
```

---

### PHP-016 — Use union types when necessary, never mixed [WARNING]

**Rule:** When a method can return or receive more than one type, use union types (`int|string`). Never use `mixed`, which is the equivalent of "anything goes".

**Checks:** `grep -rn ": mixed\|mixed \$" inc/` should return empty. Any use of `mixed` as a type is a violation.

**Why:** `mixed` eliminates all type information — it's the opposite of strong typing. In the project, automated code review (Claude Code) cannot validate data flow when a method returns `mixed`. Union types document exactly which types are possible, enabling static analysis.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Union type: either returns the entity, or returns null.
// The caller knows they need to handle these two cases.
public function find(int $id): Entry|null
{
    // ...
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// mixed: could be anything. String? Int? Array? Null? Object?
// Impossible to know without reading the entire implementation.
public function find(int $id): mixed
{
    // ...
}
```

---

### PHP-017 — Typed properties [ERROR]

**Rule:** Every class property must have an explicit type. Nullable properties use `?Type`.

**Checks:** `grep -rn "private \$\|protected \$\|public \$" inc/` — property without type between visibility and `$` is a violation.

**Why:** Properties without types allow assignment of any value. In entities representing sensitive data, a `$valueCents` property without a type can accidentally receive a string, generating incorrect calculations that only surface in the final report. The type on the property is the last barrier before corrupted data.

**Correct example:**
```php
<?php
declare(strict_types=1);

class Entry
{
    // Explicit types: PHP rejects wrong-type assignment.
    private int $valueCents;
    private string $description;
    private ?DateTimeImmutable $deadline; // can be null
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

class Entry
{
    // No type: $valueCents can become string, null, array...
    // And PHP won't complain until arithmetic time.
    private $valueCents;
    private $description;
}
```

---

## 4. Naming

> Clear names eliminate the need for comments. In the project, where lean teams
> read each other's code constantly, a bad name costs everyone's time.

### PHP-006 — Classes in PascalCase [ERROR]

**Rule:** Every PHP class uses PascalCase (each word starts with uppercase, no separators).

**Checks:** `grep -rn "^class [a-z]\|^class .*_" inc/` should return empty. Class with lowercase initial or underscore is a violation.

**Why:** Naming consistency is what allows any developer to navigate between projects without relearning conventions. PascalCase for classes is the PSR-1 standard, and all projects follow the same convention.

**Correct example:**
```php
<?php
declare(strict_types=1);

// PascalCase: each word with uppercase initial.
class EntryRepository {}
class FinanceManager {}
class BankAccount {}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// snake_case and camelCase are not accepted for classes.
class entry_repository {}
class financeManager {}
```

---

### PHP-007 — Methods and properties in camelCase [ERROR]

**Rule:** All class methods and properties use camelCase (first word lowercase, subsequent words start with uppercase).

**Checks:** Visual inspection: methods and properties must use camelCase (generic PHP) or snake_case (WP projects). Mixing conventions in the same project is a violation.

**WordPress exception (Amendment 2026-04-09):** Projects built on WordPress follow WordPress Coding Standards naming convention — `snake_case` for methods, functions, properties, and variables. Justification: consistency with the host ecosystem is more valuable than uniformity with PSR in WP projects. WordPress core uses snake_case throughout (`get_users()`, `wp_send_json_success()`, `add_action()`); mixing conventions in the same file creates cognitive noise. Classes remain `PascalCase` (PHP-006, no conflict). Constants remain `UPPER_SNAKE_CASE` (PHP-008, no conflict). Approved by the technical lead on 2026-04-09.

**Why:** camelCase for methods and properties visually distinguishes "what the class is" (PascalCase) from "what the class does" (camelCase). In projects with dozens of entities and repositories, this consistency speeds up code reading. In WordPress projects, snake_case serves the same purpose as the ecosystem's native convention.

**Correct example (generic PHP):**
```php
<?php
declare(strict_types=1);

// camelCase: first word lowercase, subsequent words uppercase.
public function calculateBalance(): int {}
private int $valueCents;
protected string $fullName;
```

**Correct example (WordPress projects):**
```php
<?php
declare(strict_types=1);

// snake_case: WordPress convention, consistent with core.
public function calculate_balance(): int {}
private int $value_cents;
protected string $full_name;
```

**Incorrect example (mixing conventions in the same project):**
```php
<?php
declare(strict_types=1);

// WRONG: camelCase and snake_case mixed in the same codebase.
public function calculateBalance(): int {}
public function get_total_cents(): int {}
```

---

### PHP-008 — Constants in UPPER_SNAKE_CASE [ERROR]

**Rule:** Every class constant uses UPPER_SNAKE_CASE (all uppercase, words separated by underscore).

**Checks:** `grep -rn "const [a-z]" inc/` should return empty. Constant with lowercase letter is a violation.

**Why:** Constants represent immutable domain values (statuses, limits, configurations). UPPER_SNAKE_CASE visually distinguishes them from properties and methods. In the project, status constants (`STATUS_PENDING`, `STATUS_CONFIRMED`) are used in entity FSMs — instant visual identification is critical.

**Correct example:**
```php
<?php
declare(strict_types=1);

// UPPER_SNAKE_CASE: visually distinct from properties and methods.
public const STATUS_ACTIVE = 'active';
private const MAX_ATTEMPTS = 3;
public const DEFAULT_CURRENCY = 'BRL';
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// camelCase and PascalCase are not accepted for constants.
public const statusActive = 'active';
private const maxAttempts = 3;
```

---

### PHP-009 — Local variables in camelCase [WARNING]

**Rule:** Local variables (inside methods) use camelCase. Exception: variables representing database array keys (which use snake_case) may keep the original format.

**Checks:** Visual inspection during code review: local variables with PascalCase (`$CategoryId`) or snake_case outside of WP/database context are a violation.

**WordPress exception (Amendment 2026-04-09):** Same exception as PHP-007 — WordPress projects use snake_case for local variables, consistent with the ecosystem.

**Why:** Naming consistency in local variables eases reading of long methods and reduces ambiguity. In the project, the only accepted exception is direct mapping from database columns (`$row->user_id`), where forcing camelCase would create confusion. In WordPress projects, snake_case is the native standard.

**Correct example:**
```php
<?php
declare(strict_types=1);

// camelCase for local variables.
$totalValue = $entry->valueCents();
$categoryId = (int) ($request['category_id'] ?? 0);
$isActive = $account->isActive();
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// snake_case and PascalCase are not accepted for local variables.
$total_value = $entry->valueCents();
$CategoryId = (int) ($request['category_id'] ?? 0);
```

---

### PHP-010 — Descriptive names, no obscure abbreviations [WARNING]

**Rule:** Variable, method, and class names must be descriptive enough to be understood without additional context. Abbreviations are only accepted when universal in the domain (e.g., `$id`, `$url`, `$db`).

**Checks:** Visual inspection: 1-2 letter variables (`$lr`, `$ca`, `$s`) that aren't `$i`/`$id`/`$db`/`$e` are a violation.

**Why:** In the project, Claude Code audits code without access to the developer's mental context. Names like `$lr` or `$ca` force the auditor (human or AI) to trace the definition to understand what the variable contains. Descriptive names make code self-documenting.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Descriptive: any developer understands without looking at the definition.
$entryRepository = new EntryRepository($db);
$isActiveCategory = $category->isActive();
$currentBalanceCents = $account->currentBalance();
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// Obscure abbreviations: what is "lr"? "ca"? "s"?
$lr = new EntryRepository($db);
$ca = $category->isActive();
$s = $account->currentBalance();
```

---

### PHP-013 — No PHP closing tag [ERROR]

**Rule:** Files containing only PHP don't use `?>` at the end.

**Checks:** `grep -rl "?>" inc/ --include="*.php"` should return empty (except templates with mixed HTML).

**Why:** The closing tag `?>` allows accidental whitespace after it, which PHP sends as output. In handlers returning JSON, this invisible whitespace corrupts the response and causes parsing errors on the frontend. All projects use JSON handlers extensively — the closing tag is prohibited.

**Correct example:**
```php
<?php
declare(strict_types=1);

class Entry
{
    // ... class code
}
// File ends here. No ?>
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

class Entry
{
    // ... class code
}
?> 
```

---

## 5. Classes and objects

> This is the largest section because it defines how the project models domain.
> Rich entities, FSM, and tolerant fromRow() are the backbone
> of all projects.

### PHP-018 — Explicit visibility on everything [ERROR]

**Rule:** Every property, method, and constant must declare visibility (`public`, `protected`, `private`). No exceptions.

**Checks:** `grep -rn "^\s*function \|^\s*const \|^\s*\$" inc/ --include="*.php" | grep -v "public\|private\|protected"` — match indicates missing visibility.

**Why:** PHP allows omitting visibility (default is `public`). In the project, implicit visibility is prohibited because it hides the developer's intent. A method without `private` looks public by accident, not by design. In code review, explicit visibility allows validating whether the class's public API is correct.

**Correct example:**
```php
<?php
declare(strict_types=1);

class Entry
{
    // Explicit visibility on EVERYTHING: property, method, constant.
    private int $id;
    private string $status;
    public const STATUS_PENDING = 'pending';

    public function id(): int
    {
        return $this->id;
    }

    private function validateTransition(string $new): bool
    {
        return in_array($new, self::STATUS_TRANSITIONS[$this->status] ?? [], true);
    }
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

class Entry
{
    // WITHOUT visibility: is public by default, but was it intentional?
    int $id;
    const STATUS_PENDING = 'pending';

    function id(): int
    {
        return $this->id;
    }
}
```

**References:** OOP-004

---

### PHP-019 — Readonly properties when not mutable [WARNING]

**Rule:** Properties that don't change after construction must be declared as `readonly`.

**Checks:** Inspect constructors: properties like `$id`, `$userId`, `$createdAt` without `readonly` are candidates for violation. Verify no reassignment outside the constructor.

**Why:** `readonly` is a PHP guarantee that the value won't be changed. In entities, `$id` and `$userId` never change after the object is created. Without `readonly`, a bug can reassign a record's ID without anyone noticing. Explicit immutability prevents entire classes of bugs.

**Correct example:**
```php
<?php
declare(strict_types=1);

// readonly: PHP guarantees these values are never reassigned.
public function __construct(
    private readonly int $id,
    private readonly string $name,
    private readonly int $userId,
) {}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// Without readonly: nothing prevents $id from being reassigned by mistake.
public function __construct(
    private int $id,
    private string $name,
    private int $userId,
) {}
```

**Exceptions:** Properties changed by lifecycle methods (e.g., `$status` changes via `confirm()`, `cancel()`).

**References:** OOP-007

---

### PHP-020 — Constructors via property promotion [WARNING]

**Rule:** Prefer constructor promotion (PHP 8.0+) for injecting dependencies and defining properties.

**Checks:** Visual inspection: constructor that declares property + manually assigns (`$this->x = $x`) instead of using promotion (`private readonly X $x`) is a candidate for violation.

**Why:** Constructor promotion reduces boilerplate significantly. In repositories and managers in the project that receive 2-4 dependencies, the version without promotion has twice the lines with no clarity gain. Less code = fewer places for bugs.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Constructor promotion: declaration + assignment in a single line.
// Less boilerplate, same clarity.
class FinanceManager
{
    public function __construct(
        private readonly EntryRepository $entries,
        private readonly EncryptionInterface $crypto,
    ) {}
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// Verbose: 2 properties + 2 assignments = 4 extra lines.
// No new information compared to promotion.
class FinanceManager
{
    private EntryRepository $entries;
    private EncryptionInterface $crypto;

    public function __construct(
        EntryRepository $entries,
        EncryptionInterface $crypto
    ) {
        $this->entries = $entries;
        $this->crypto = $crypto;
    }
}
```

---


### PHP-022 — Rich entities, not anemic [ERROR]

**Rule:** Entities contain domain logic: state predicates, transitions, business rule validations. They must never be just bags of getters and setters.

**Checks:** `grep -rn "function set[A-Z]" inc/entities/` should return empty. Public setters indicate an anemic entity. Entities must have predicates (`is*`, `can*`) or lifecycle methods.

**Why:** In the project, the logic of "a pending entry can be confirmed, but a cancelled one cannot" BELONGS to the Entry entity. If this logic lives in the manager, any new manager can ignore the restriction and confirm a cancelled entry. Rich entities protect business invariants at the source.

**Correct example:**
```php
<?php
declare(strict_types=1);

// RICH entity: contains domain logic, predicates, transitions.
// No external code can violate the transition rules.
class Entry
{
    // Predicate: answers about state without exposing the property.
    public function isConfirmed(): bool
    {
        return $this->status === self::STATUS_CONFIRMED;
    }

    // Lifecycle method: transition with built-in validation.
    public function confirm(): void
    {
        if ($this->status !== self::STATUS_PENDING) {
            throw new InvalidTransitionException(
                $this->status,
                self::STATUS_CONFIRMED
            );
        }
        $this->status = self::STATUS_CONFIRMED;
    }

    // Business calculation: centralized in the entity.
    public function netValue(): int
    {
        return $this->valueCents - $this->discountCents;
    }
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// ANEMIC entity: just getters and setters.
// Any external code can set status to any value.
// No business rule is protected.
class Entry
{
    public function getStatus(): string
    {
        return $this->status;
    }

    // DANGER: allows setting "confirmed" even if current is "cancelled".
    public function setStatus(string $status): void
    {
        $this->status = $status;
    }
}
```

**References:** OOP-003, OOP-017

---

### PHP-023 — Getters without get_ prefix [ERROR]

**Rule:** Accessor methods use the property name directly, without the `get` prefix. Boolean predicates use `is`, `was`, `can`, `has`.

**Checks:** `grep -rn "function get[A-Z]" inc/entities/` should return empty.

**Why:** Deliberate project standard: `$entry->valueCents()` is cleaner than `$entry->getValueCents()`. In reading chains that appear in templates and reports, the `get` prefix is visual noise that adds no information. Predicates with descriptive verbs (`isActive()`, `wasCancelled()`) read as natural language.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Accessors: property name, no prefix.
public function id(): int { return $this->id; }
public function name(): string { return $this->name; }
public function valueCents(): int { return $this->valueCents; }

// Predicates: descriptive verbs.
public function isConfirmed(): bool { return $this->status === self::STATUS_CONFIRMED; }
public function hasAccount(): bool { return $this->accountId !== null; }
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// get_ prefix is prohibited in the projects.
public function getId(): int { return $this->id; }
public function getName(): string { return $this->name; }
public function getValueCents(): int { return $this->valueCents; }
```

**References:** OOP-002

---

### PHP-024 — FSM in the entity via STATUS_TRANSITIONS [ERROR]

**Rule:** Entities with state define their valid transitions as a `STATUS_TRANSITIONS` constant and expose lifecycle methods for each transition. The `canTransitionTo()` method is mandatory.

**Checks:** `grep -rn "STATUS_TRANSITIONS" inc/entities/` — every entity with `$status` must have this constant. `grep -rn "canTransitionTo" inc/entities/` confirms the mandatory method.

**Why:** Without an explicit FSM, state transitions are controlled by logic scattered across managers and handlers. In the project, there was a case where the absence of an FSM allowed a cancelled record to be "reconfirmed" by a handler that didn't check the previous state. With FSM in the entity, invalid transitions are impossible — the entity protects itself.

**Correct example:**
```php
<?php
declare(strict_types=1);

class Entry
{
    public const STATUS_PENDING = 'pending';
    public const STATUS_CONFIRMED = 'confirmed';
    public const STATUS_CANCELLED = 'cancelled';

    // Transition map: from each status, which destinations are valid.
    public const STATUS_TRANSITIONS = [
        self::STATUS_PENDING   => [self::STATUS_CONFIRMED, self::STATUS_CANCELLED],
        self::STATUS_CONFIRMED => [self::STATUS_CANCELLED],
        self::STATUS_CANCELLED => [], // terminal state, no exit
    ];

    // Lifecycle method: transition validated by the FSM.
    public function confirm(): void
    {
        if (!$this->canTransitionTo(self::STATUS_CONFIRMED)) {
            throw new InvalidTransitionException(
                $this->status,
                self::STATUS_CONFIRMED
            );
        }
        $this->status = self::STATUS_CONFIRMED;
    }

    public function cancel(): void
    {
        if (!$this->canTransitionTo(self::STATUS_CANCELLED)) {
            throw new InvalidTransitionException(
                $this->status,
                self::STATUS_CANCELLED
            );
        }
        $this->status = self::STATUS_CANCELLED;
    }

    // Query method: can be used by UIs to enable/disable buttons.
    public function canTransitionTo(string $newStatus): bool
    {
        return in_array(
            $newStatus,
            self::STATUS_TRANSITIONS[$this->status] ?? [],
            true
        );
    }
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// WITHOUT FSM: any status can become any other.
// No transition constant, no validation.
class Entry
{
    public function setStatus(string $status): void
    {
        // Accepts ANY value. "cancelled" -> "confirmed"? Ok.
        // "pending" -> "invented_status"? Ok too.
        $this->status = $status;
    }
}
```

**References:** OOP-017

---

### PHP-025 — fromRow() tolerant, never throws exception [ERROR]

**Rule:** The `fromRow()` method converts a database row into an entity instance. It NEVER throws an exception. Uses `ReflectionClass::newInstanceWithoutConstructor()` to bypass constructor validations. Database data is a fait accompli — it's not the hydrator's job to reject what's already persisted.

**Checks:** `grep -rn "new self\|new static" inc/entities/` inside `fromRow()` is a violation. `grep -rn "newInstanceWithoutConstructor" inc/entities/` must match in every entity with `fromRow()`.

**Why:** In the project, a production fatal was caused by `fromRow()` using `new self()`. The constructor validated required fields and threw an exception when a legacy field was empty in the database. Result: entire page down because hydration exploded on historical data missing the field. The rule was born from this incident: fromRow() doesn't judge, fromRow() hydrates.

**Correct example:**
```php
<?php
declare(strict_types=1);

// TOLERANT fromRow(): uses Reflection to skip the constructor.
// Never throws exception. Database data is a fait accompli.
public static function fromRow(object $row): self
{
    // newInstanceWithoutConstructor() skips all __construct validation.
    // This is intentional: database data already exists, doesn't need validation.
    $entity = (new \ReflectionClass(self::class))
        ->newInstanceWithoutConstructor();

    // Explicit cast for each property.
    // If the field doesn't exist in $row, use a safe default.
    $entity->id = (int) ($row->id ?? 0);
    $entity->name = (string) ($row->name ?? '');
    $entity->status = (string) ($row->status ?? self::STATUS_PENDING);
    $entity->valueCents = (int) ($row->value_cents ?? 0);

    return $entity;
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// DANGER: new self() goes through the constructor, which may validate and throw exception.
// If the database has legacy data with an empty field, FATAL in production.
public static function fromRow(object $row): self
{
    return new self(
        id: (int) $row->id,
        name: (string) $row->name,     // constructor validates required field
        status: (string) $row->status, // constructor can throw exception here
    );
}
```

---

### PHP-026 — Entities don't depend on infrastructure [ERROR]

**Rule:** Entity classes (`inc/entities/`) never import database access, repository classes, external services, or any infrastructure dependency. Entities contain pure domain logic.

**Checks:** `grep -rn "use.*Repository\|use.*PDO\|use.*wpdb\|global \$wpdb" inc/entities/` should return empty.

**Why:** Entities in the project are the innermost layer of the system. If an entity depends on database access, it cannot be tested without infrastructure. In the project, entity unit tests must run in milliseconds, without setup. Additionally, entities are shared across projects — coupling to infrastructure prevents reuse.

**Correct example:**
```php
<?php
declare(strict_types=1);

// PURE entity: no infrastructure dependencies.
// Can be tested with new Entry() without database, without framework.
class Entry
{
    public function isConfirmed(): bool
    {
        return $this->status === self::STATUS_CONFIRMED;
    }

    public function netValue(): int
    {
        return $this->valueCents - $this->discountCents;
    }
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// WRONG: entity coupled to infrastructure (direct database access).
// Impossible to test without database. Impossible to reuse outside the framework.
class Entry
{
    public function save(\PDO $pdo): void
    {
        $stmt = $pdo->prepare("INSERT INTO entries (value_cents) VALUES (:val)");
        $stmt->execute([':val' => $this->valueCents]);
    }
}
```

**References:** OOP-017, PHP-004

---


## 6. Methods

> Methods are the atomic unit of work. If a method is complex,
> the class is probably doing too much.

### PHP-030 — Maximum 20 lines per method [WARNING]

**Rule:** If a method exceeds 20 lines of code (excluding blank lines and comments), it probably does more than one thing. Extract sub-methods with descriptive names.

**Checks:** Visual line count per method (excluding blanks and comments). Method with >20 LOC is a candidate for violation.

**Why:** In the project, code review is done by developer + Claude Code. Long methods make both harder: the developer loses context, Claude Code has a higher chance of failing the analysis. Short methods with descriptive names are self-documenting and easier to unit test.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Main method: 5 lines, delegating to named sub-methods.
// Each sub-method has single responsibility and descriptive name.
public function processEntry(Entry $entry): void
{
    $this->validateEntry($entry);
    $this->applyBusinessRules($entry);
    $this->persist($entry);
    $this->notifyObservers($entry);
}

private function validateEntry(Entry $entry): void
{
    if (!$entry->hasAccount()) {
        throw new EntryWithoutAccountException();
    }
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// Method with 40+ lines doing validation, calculation, persistence and notification.
// Impossible to know what each block does without reading line by line.
public function processEntry(Entry $entry): void
{
    if (!$entry->hasAccount()) { throw new EntryWithoutAccountException(); }
    if ($entry->isCancelled()) { return; }
    $value = $entry->valueCents();
    $discount = $entry->discountCents();
    $net = $value - $discount;
    // ... 30 more lines of mixed logic
}
```

---

### PHP-031 — Early return [WARNING]

**Rule:** Reduce nesting using guard clauses. Invalid or trivial cases exit early, main logic stays at the end without extra indentation.

**Checks:** Visual inspection: method with >2 levels of nested `if` is a candidate for refactoring with early return.

**Why:** In the project, handlers validate multiple conditions before delegating. Without early return, the handler becomes a pyramid of nested `if`s. Early return keeps the code linear: each guard eliminates a case, and the main logic stays at the base indentation level.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Guard clauses eliminate invalid cases at the beginning.
// Main logic stays at the end, without nesting.
public function process(Entry $entry): void
{
    // Guard 1: trivial case, exit early.
    if ($entry->isCancelled()) {
        return;
    }

    // Guard 2: invalid case, throw exception.
    if (!$entry->hasAccount()) {
        throw new EntryWithoutAccountException();
    }

    // Main logic: no nesting, easy to read.
    $entry->confirm();
    $this->repository->save($entry);
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// Pyramid of nested ifs: hard to read, easy to get wrong.
public function process(Entry $entry): void
{
    if (!$entry->isCancelled()) {
        if ($entry->hasAccount()) {
            // Main logic buried 2 levels deep.
            $entry->confirm();
            $this->repository->save($entry);
        } else {
            throw new EntryWithoutAccountException();
        }
    }
}
```

---

### PHP-032 — Maximum 4 parameters per method [WARNING]

**Rule:** If a method needs more than 4 parameters, consider a Value Object or DTO to group related data.

**Checks:** `grep -rn "function.*\$.*\$.*\$.*\$.*\$" inc/` — match with 5+ `$` in the signature indicates >4 parameters.

**Why:** Methods with many parameters are hard to call correctly (which parameter is which?), hard to test (too many combinations), and indicate the method does too many things. In the project, when a handler needs to pass many data points to the manager, the pattern is to create a DTO.

**Correct example:**
```php
<?php
declare(strict_types=1);

// DTO groups related data into a single typed object.
// The method receives ONE parameter with clear meaning.
class CreateEntryDTO
{
    public function __construct(
        public readonly int $userId,
        public readonly string $description,
        public readonly int $valueCents,
        public readonly int $categoryId,
        public readonly string $status,
    ) {}
}

public function createEntry(CreateEntryDTO $data): Entry
{
    // $data->userId, $data->description, etc.
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// 5 parameters: which is which when calling? Easy to swap.
public function createEntry(
    int $userId,
    string $description,
    int $valueCents,
    int $categoryId,
    string $status
): Entry {
    // ...
}
```

**References:** OOP-014

---

### PHP-033 — Entity public methods as descriptive predicates [WARNING]

**Rule:** Entity methods that answer questions about the object's state should have names that read as natural language questions: `is*()`, `was*()`, `can*()`, `has*()`.

**Checks:** `grep -rn "->get.*() ==\|->get.*() ===\|->get.*() !=" inc/` — comparison with a getter outside the entity indicates a missing predicate in the entity.

**Why:** In the project, descriptive predicates make manager and handler code readable as prose: `if ($entry->isConfirmed())` reads as natural language. This reduces the distance between the business requirement and the code that implements it, making code review easier for everyone — including the technical lead reviewing business logic.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Predicates that read as natural questions.
$entry->isConfirmed();   // "is the entry confirmed?"
$account->isActive();    // "is the account active?"
$goal->wasAchieved();    // "was the goal achieved?"
$entry->canCancel();     // "can the entry cancel?"
$account->hasBalance();  // "does the account have balance?"
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// Exposing internal property and comparing outside the entity.
// Violates encapsulation and doesn't read as natural language.
$entry->getStatus() === 'confirmed';
$account->getActive() === true;
$goal->getCurrentValue() >= $goal->getTargetValue();
```

**References:** OOP-002, OOP-005

---

## 7. Error handling

> Silenced errors are the worst category of bug: the system appears to work,
> but the data is wrong. In the project, where we handle sensitive data,
> a silenced error can mean incorrect data in the report.

### PHP-034 — Typed exceptions, never generic [ERROR]

**Rule:** Every thrown exception must be from a domain-specific class. Never use `\Exception`, `\RuntimeException`, or `\LogicException` directly.

**Checks:** `grep -rn "new \\\\Exception\|new \\\\RuntimeException\|new \\\\LogicException" inc/` should return empty.

**Why:** Typed exceptions allow granular handling: the handler can catch `InsufficientBalanceException` and return a friendly message, while `RecordNotFoundException` returns a 404. With generic `\Exception`, the handler doesn't know what happened and can't make decisions. In the project, each error type has a different response for the user.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Typed exception: the handler knows EXACTLY what happened.
// Can return a specific message for the user.
throw new InsufficientBalanceException(
    $account->id(),
    $requestedAmount,
    $account->currentBalance()
);

throw new RecordNotFoundException($id);
throw new InvalidTransitionException($currentStatus, $desiredStatus);
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// Generic exception: the handler doesn't know if it's balance, permission,
// or record not found. Can only show the raw message.
throw new \Exception('Insufficient balance');
throw new \RuntimeException('Not found');
```

**References:** OOP-002

---

### PHP-035 — Never silence errors with @ [ERROR]

**Rule:** The `@` error suppression operator is prohibited. Errors must be handled explicitly with return value checking or try/catch.

**Checks:** `grep -rn "@\$\|@file\|@json\|@array\|@unlink\|@fopen\|@mail" inc/` should return empty.

**Why:** The `@` hides errors that may indicate real problems: JSON parse failure, corrupted configuration file, deprecated function. In the project, a `@json_decode()` on sensitive data can silently return `null`, and the system continues processing as if the data were empty. The real error only surfaces days later, when the report comes out wrong.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Explicit handling: if JSON is invalid, we know immediately.
$result = json_decode($json, true);
if (json_last_error() !== JSON_ERROR_NONE) {
    throw new InvalidJsonException(json_last_error_msg());
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// @ hides the error. If JSON is invalid, $result is null
// and the system continues processing null as if it were a valid array.
$result = @json_decode($json, true);
```

---

### PHP-036 — Specific catch, never generic \Throwable [WARNING]

**Rule:** Catch blocks must catch specific exceptions. Never catch `\Throwable` or generic `\Exception`, unless it's the last-resort handler that must always return a valid response.

**Checks:** `grep -rn "catch.*\\\\Throwable\|catch.*\\\\Exception[^a-zA-Z]" inc/` — match outside last-resort handlers is a violation.

**Why:** `catch (\Throwable)` swallows EVERYTHING: TypeError, OutOfMemoryError, logic errors. In the project, there was a case where a generic catch in a repository hid a TypeError caused by corrupted data — the record was silently ignored and didn't appear in reports. Specific catch ensures we only handle what we know how to handle.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Specific catch: we know exactly what we're handling.
try {
    $this->repository->save($entry);
} catch (DuplicateException $e) {
    // Handle specifically: duplicate record.
    $this->respondError('Record already exists.');
}
// TypeError, OutOfMemory, etc. propagate naturally — as they should.
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// Generic catch: swallows TypeError, OutOfMemory, anything.
// If there's a memory problem, the system "handles" it as a duplicate.
try {
    $this->repository->save($entry);
} catch (\Throwable $e) {
    // "Handle everything" == handle nothing properly.
    error_log($e->getMessage());
}
```

**Exceptions:** Request handlers that must ALWAYS return a valid response can have a generic catch as a last resort, as long as it logs and returns a generic error.

---

## 8. Performance

> Premature optimization is the root of all evil, but known performance
> problems are prohibited. This section covers patterns that have already
> caused real problems in the project.

### PHP-042 — Don't optimize prematurely [WARNING]

**Rule:** Performance optimizations (cache, denormalization, complex queries with multiple JOINs) only enter when there's measurement proving the bottleneck. Clear and correct code first, optimize later with data.

**Checks:** Code review inspection: query with >2 JOINs, manual cache, or denormalization must have a comment with measurement justifying it. No measurement = violation.

**Why:** Projects are internal systems with dozens to hundreds of simultaneous users, not millions. Most perceived bottlenecks are false positives. In the project, prematurely "optimized" code has produced unreadable queries that nobody could debug. Clarity and correctness beat perceived performance.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Clear and direct code. If performance becomes a problem,
// we measure with profiling and optimize with concrete data.
public function findMonthEntries(int $userId, string $yearMonth): array
{
    $entries = $this->repository->findByUserAndMonth($userId, $yearMonth);

    // Filter in PHP — clear, testable, debuggable.
    return array_filter(
        $entries,
        fn(Entry $e) => $e->isConfirmed()
    );
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// Premature "optimization": complex query with subquery and CASE
// to avoid the PHP filter. Nobody will understand this in 3 months.
// And there's no measurement proving the PHP filter was a problem.
$sql = "SELECT *, (CASE WHEN status = 'confirmed' THEN 1 ELSE 0 END) as is_conf
        FROM entries
        WHERE user_id = :userId
        AND DATE_FORMAT(created_at, '%Y-%m') = :yearMonth
        HAVING is_conf = 1";
```

---

### PHP-050 — Queries inside loops are prohibited [ERROR]

**Rule:** Never execute SQL queries inside loops (`for`, `foreach`, `while`, `array_map`). Every operation needing data for a collection must use a single query with `WHERE IN` or equivalent, and process results in memory.

**Checks:** Visual inspection: any call to repository/`$wpdb`/`$pdo` inside `foreach`/`for`/`while`/`array_map` is a violation. `grep -A5 "foreach\|for (" inc/ | grep "->find\|->query"` helps detect.

**Why:** In the project, dashboards display dozens of records, each with relationships. One query per iteration turns a 50-item listing into 50+ database queries. In production, this already caused timeouts in reports. The rule is absolute: if there's a loop, there's no query inside.

**Correct example:**
```php
<?php
declare(strict_types=1);

// ONE query fetches ALL records at once.
// The loop processes only data already loaded in memory.
$entries = $this->repository->findByIds($ids);

// Index by ID for O(1) access per record.
$entriesById = [];
foreach ($entries as $entry) {
    $entriesById[$entry->id()] = $entry;
}

// Now use the map — no additional query.
foreach ($ids as $id) {
    $entry = $entriesById[$id] ?? null;
    if ($entry !== null) {
        $results[] = $entry->toArray();
    }
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// N+1 PROBLEM: one query per iteration.
// 50 records = 50 database queries. Guaranteed timeout.
foreach ($ids as $id) {
    // WRONG: query inside loop!
    $entry = $this->repository->findById($id);
    $results[] = $entry->toArray();
}
```

**Exceptions:** Operations requiring individual atomicity (e.g., transactions where each needs its own lock). In that case, document the reason in the code.

---

### PHP-051 — Critical errors must go to monitoring [ERROR]

**Rule:** Every unhandled exception and every critical error (encryption failure, database connection failure, invalid state transition in a sensitive operation) must be logged to the monitoring system via `error_log()` with sufficient context for diagnosis. Never swallow errors silently.

**Checks:** `grep -B2 -A5 "catch" inc/ | grep -L "error_log\|throw"` — catch block without `error_log()` or re-throw is a violation (swallowed error).

**Why:** In the project, silent errors have caused situations where data remained inconsistent for days without anyone noticing. In one case, a migration without a lock duplicated data multiple times and was only detected because a user reported it — not by the system. Proactive monitoring is mandatory: if something broke, the team needs to know before the user.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Log error with sufficient context for diagnosis.
// Who? What? When? Which data? Which operation?
try {
    $this->repository->save($entry);
} catch (DuplicateException $e) {
    // Log with context: user, entity, operation, error.
    error_log(sprintf(
        '[APP][ERROR] Duplicate when saving entry. user_id=%d, entry_id=%d, error=%s',
        $entry->userId(),
        $entry->id(),
        $e->getMessage()
    ));

    // Re-throw or handle — but NEVER swallow silently.
    throw $e;
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// WRONG: empty catch swallows the error. Nobody finds out.
// The record wasn't saved, but the system continues as if nothing happened.
try {
    $this->repository->save($entry);
} catch (\Throwable $e) {
    // silence... the user will never know the data was lost
}
```

**References:** PHP-034, PHP-035, PHP-036

---

## 9. File structure and formatting

> Predictable structure allows any developer to find any file
> in less than 5 seconds. Consistent formatting eliminates style
> discussions in code review. In the project, these rules are mechanical — they require
> no judgment.

### PHP-011 — One file per class [ERROR]

**Rule:** Each PHP class lives in its own file. The filename is the class name followed by `.php`.

**Checks:** `grep -rn "^class " inc/ --include="*.php" -l | sort | uniq -d` — file with >1 class is a violation. Filename must match the class name.

**Why:** One file per class is a prerequisite for autoloading (PSR-4) and for fast navigation in the project. In the project, the folder convention (`entities/`, `repositories/`, `managers/`, `handlers/`) depends on one file per class to work. Two classes in the same file means one of them is in the wrong folder.

**Correct example:**
```
inc/entities/Entry.php                <-- Entry class
inc/entities/BankAccount.php          <-- BankAccount class
inc/repositories/EntryRepository.php  <-- EntryRepository class
inc/managers/FinanceManager.php       <-- FinanceManager class
inc/handlers/CreateEntryHandler.php   <-- CreateEntryHandler class
```

**Incorrect example:**
```
inc/entities/Finance.php  <-- contains Entry AND BankAccount in the same file
inc/utils/helpers.php     <-- contains 5 loose classes
```

**References:** OOP-001

---

### PHP-043 — Indentation with 4 spaces [ERROR]

**Rule:** All indentation uses 4 spaces. Never tabs. No exceptions.

**Checks:** `grep -rPn "\t" inc/ --include="*.php"` should return empty. Any tab is a violation.

**Why:** Tabs render differently in each editor and in each diff tool. In the project, where code review happens on GitHub and in Claude Code, inconsistent tab rendering causes visual confusion. 4 spaces is deterministic: looks the same everywhere.

**Correct example:**
```php
<?php
declare(strict_types=1);

class Entry
{
    // 4 spaces of indentation at each level.
    public function valueCents(): int
    {
        return $this->valueCents;
    }
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

class Entry
{
	// Tab: renders as 2, 4, or 8 spaces depending on the editor.
	public function valueCents(): int
	{
		return $this->valueCents;
	}
}
```

---

### PHP-044 — Opening braces on the same line for control structures [WARNING]

**Rule:** In control structures (`if`, `else`, `for`, `foreach`, `while`, `switch`), the opening brace goes on the same line as the instruction.

**Checks:** `grep -rPn "^\s*(if|else|for|foreach|while|switch).*\n\s*\{" inc/` — opening brace on the following line of a control structure is a violation.

**Why:** We follow PSR-12 for control structures. Braces on the same line save vertical lines, keeping more code visible on screen. In methods of 20 lines (PHP-030), every line counts.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Brace on the same line as the control instruction.
if ($entry->isConfirmed()) {
    return $entry->valueCents();
}

foreach ($entries as $entry) {
    $total += $entry->valueCents();
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// Brace on the next line for control: wastes vertical space.
if ($entry->isConfirmed())
{
    return $entry->valueCents();
}
```

---

### PHP-045 — Opening braces on the next line for classes and methods [WARNING]

**Rule:** In class and method declarations, the opening brace goes on the next line (Allman style).

**Checks:** `grep -rn "class.*{$\|function.*){.*{$" inc/` — brace `{` on the same line as class or method declaration is a violation.

**Why:** PSR-12 differentiates classes/methods (brace on next line) from controls (brace on same line). In the project, this visual distinction helps quickly identify where a class or method starts versus a control block.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Class: brace on the next line.
class Entry
{
    // Method: brace on the next line.
    public function valueCents(): int
    {
        return $this->valueCents;
    }
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// Class with brace on the same line: doesn't follow PSR-12.
class Entry {
    public function valueCents(): int {
        return $this->valueCents;
    }
}
```

---

### PHP-046 — Blank line between methods [WARNING]

**Rule:** Every method is separated from the next by exactly one blank line.

**Checks:** Visual inspection: two consecutive methods without a blank line between `}` and the next `public`/`private`/`protected` declaration is a violation.

**Why:** Blank lines between methods create visual separation that facilitates quick reading. In the project, rich entities can have 10+ methods (accessors, predicates, lifecycle methods). Without separation, the code becomes an unreadable monolithic block.

**Correct example:**
```php
<?php
declare(strict_types=1);

public function id(): int
{
    return $this->id;
}

public function name(): string
{
    return $this->name;
}

public function isConfirmed(): bool
{
    return $this->status === self::STATUS_CONFIRMED;
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

public function id(): int
{
    return $this->id;
}
public function name(): string
{
    return $this->name;
}
public function isConfirmed(): bool
{
    return $this->status === self::STATUS_CONFIRMED;
}
```

---

### PHP-047 — Maximum 120 characters per line [WARNING]

**Rule:** No line of code should exceed 120 characters. Break long lines with coherent alignment.

**Checks:** `awk 'length > 120' inc/**/*.php` — any returned line is a violation.

**Why:** Code review on GitHub and in Claude Code uses fixed-width windows. Long lines force horizontal scrolling, which hides part of the code during review. 120 characters accommodates most method calls and queries without forced breaks.

**Correct example:**
```php
<?php
declare(strict_types=1);

// Long line broken with coherent alignment.
$stmt = $pdo->prepare(
    "SELECT * FROM entries WHERE user_id = :userId AND status = :status ORDER BY created_at DESC"
);
$stmt->execute([
    ':userId' => $userId,
    ':status' => $status,
]);
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// Single line with 150+ characters: horizontal scroll in review.
$stmt = $pdo->prepare("SELECT * FROM entries WHERE user_id = :userId AND status = :status ORDER BY created_at DESC LIMIT 100");
$stmt->execute([':userId' => $userId, ':status' => $status]);
```

---

### PHP-048 — One statement per line [ERROR]

**Rule:** Each PHP statement occupies its own line. Never two statements separated by `;` on the same line.

**Checks:** `grep -rn ";.*;" inc/ --include="*.php" | grep -v "for ("` — match (except `for` header) indicates multiple statements on the same line.

**Why:** Statements stacked on the same line are invisible in diffs. If two statements are on the same line and one changes, the diff shows the entire line as changed, making it hard to identify which statement changed. In the project, where code review is mandatory, every change needs to be visible.

**Correct example:**
```php
<?php
declare(strict_types=1);

// One statement per line: each one individually visible in the diff.
$value = 100;
$discount = 10;
$net = $value - $discount;
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

// Two statements on the same line: hard to audit in diff.
$value = 100; $discount = 10;
$net = $value - $discount; $result = $net * 2;
```

---

## 10. Documentation

> Self-explanatory code. Comments only when the "why" is not obvious.

### PHP-053 — PHPDoc mandatory on methods with non-obvious logic [WARNING]

**Rule:** PHPDoc is mandatory when the method contains logic that isn't evident from the name and signature. The PHPDoc explains "why" the method exists or "why" the implementation is the way it is, never "what" the method does (the name already says that). Self-explanatory code needs no comment.

**Checks:** Visual inspection: method with Reflection, complex regex, or non-obvious business rule without PHPDoc is a violation. PHPDoc that repeats the method name ("Returns the id") is also a violation (noise).

**Correct example:**
```php
<?php
declare(strict_types=1);

// WITHOUT PHPDoc: the name and signature say it all.
// Comment here would be noise.
public function isConfirmed(): bool
{
    return $this->status === self::STATUS_CONFIRMED;
}

/**
 * Hydrates entity from a database row WITHOUT going through the constructor.
 *
 * Uses Reflection because legacy data may have empty fields that the
 * constructor would reject. fromRow() never throws exception — database data
 * is a fait accompli.
 */
public static function fromRow(object $row): self
{
    $entity = (new \ReflectionClass(self::class))
        ->newInstanceWithoutConstructor();
    // ...
    return $entity;
}
```

**Incorrect example:**
```php
<?php
declare(strict_types=1);

/**
 * Checks if the entry is confirmed.
 *
 * @return bool Returns true if confirmed, false otherwise.
 */
// NOISE: the name already says this. The PHPDoc adds no information.
public function isConfirmed(): bool
{
    return $this->status === self::STATUS_CONFIRMED;
}
```

---

## Definition of Done — Delivery Checklist

> PRs that don't meet the DoD don't enter review. They are returned.

| # | Item | Rules | Verification |
|---|------|-------|--------------|
| 1 | `declare(strict_types=1)` in every PHP file | PHP-012 | `grep -rL "strict_types" inc/` should return empty |
| 2 | No closing tag `?>` | PHP-013 | `grep -rl "?>" inc/ --include="*.php"` should return empty |
| 3 | Type hints on all parameters and returns | PHP-014, PHP-015 | Code review + static analysis (PHPStan level 6+) |
| 4 | Typed properties with explicit visibility | PHP-017, PHP-018 | Code review: no property without type or visibility |
| 5 | Rich entities with FSM and predicates | PHP-022, PHP-024, PHP-033 | Entities have STATUS_TRANSITIONS, lifecycle methods, and descriptive predicates |
| 6 | `fromRow()` uses Reflection, never `new self()` | PHP-025 | `grep -rn "new self\|new static" inc/entities/` should return zero in fromRow() |
| 7 | Sensitive data encrypted at rest | PHP-037 | Repositories of sensitive entities use encryption before INSERT/UPDATE |
| 8 | Parameterized queries | PHP-038 | No query with direct variable interpolation |
| 9 | No queries inside loops | PHP-050 | No foreach/for/while contains calls to repository or database |
| 10 | Typed exceptions, no `@` suppression | PHP-034, PHP-035 | `grep -rn "@\$\|@file\|@json\|@array" inc/` and `grep -rn "new \\\\Exception" inc/` return empty |
| 11 | Critical errors logged with context | PHP-051 | Catch blocks do error_log() with `[APP]` prefix and context data |
| 12 | Input sanitized in handler | PHP-039, PHP-040 | Handlers sanitize all $_POST/$_GET data before delegating |
| 13 | PSR-12 formatting | PHP-043 to PHP-048 | 4-space indentation, correct braces, lines < 120 chars |
