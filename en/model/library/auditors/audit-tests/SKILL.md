---
name: audit-tests
description: Audits PHPUnit tests in the open PR against the rules defined in docs/test-standards.md. Delivers a violations report and correction plan. Manual trigger only.
---

# /audit-tests — Test Standards Auditor

Reads the rules from `docs/test-standards.md`, identifies test files changed in the open (unmerged) PR, and compares each file against every applicable rule. Focuses on test quality: organization, naming, coverage by layer, determinism, isolation, and anti-patterns.

Complements `/audit-php` (syntax) and `/audit-oop` (architecture).

## When to use

- **ONLY** when the user explicitly types `/audit-tests`.
- Run before merging a PR — acts as a test quality gate.
- **Never** trigger automatically, nor as part of another skill.

## Minimum required standards

> This section contains the complete standards used by the audit. Edit to customize for your project.

# Test standards

## Description

Reference document for test auditing in the project. Defines how tests should be written, organized, and what they should cover. The `/audit-tests` skill reads this document and compares it against the tests in the open PR.

Complements `docs/php-standards.md` (syntax) and `docs/oop-standards.md` (architecture).

## Scope

- PHPUnit tests within `tests/`
- Coverage of: entities, repositories, managers, handlers
- Focus on tests that simulate real-world conditions
- Organization in 5 layers following the test pyramid

## References

- `docs/php-standards.md` — PHP language rules
- `docs/oop-standards.md` — OOP architecture patterns
- [PHPUnit 12.x](https://docs.phpunit.de/en/12.0/)

## Severity

- **ERROR** — Violation blocks approval. Must be fixed before merge.
- **WARNING** — Strong recommendation. Must be justified if ignored.

---

## 1. Test pyramid

### TST-001 — Five layers, wide base, narrow top [ERROR]

The project follows a test pyramid with 5 layers. Each layer has defined scope, cost, and proportion. The base (unit tests) concentrates the highest volume. The top (functional) has few high-value tests.

| Layer | Directory | What it tests | Cost/Effort |
|-------|-----------|---------------|-------------|
| Unit | `tests/unit/` | Entities, Value Objects — pure domain logic | Low |
| Component | `tests/component/` | Managers with mocks — isolated orchestration | Low-medium |
| Integration | `tests/integration/` | Repositories with real DB, encryption | Medium |
| API | `tests/api/` | Handlers — full request/response | Medium-high |
| Functional | `tests/functional/` | Page renders, end-to-end flows | High |

Expected proportion (approximate):

```
         /\          Functional       ~5%
        /  \         API              ~10%
       /    \        Integration      ~15%
      /      \       Component        ~20%
     /________\      Unit             ~50%
```

**Rule:** the higher in the pyramid, fewer and more selective the tests.

### TST-002 — Each test lives in the correct layer [ERROR]

A test that accesses the database is not a unit test. A test that mocks everything is not an integration test. Classify correctly:

| If the test... | Layer |
|----------------|-------|
| Tests pure logic without external dependencies | Unit |
| Tests orchestration with repository mocks | Component |
| Accesses a real database | Integration |
| Simulates an HTTP request with authentication | API |
| Verifies that a page renders with the framework loaded | Functional |

---

## 2. Philosophy

### TST-003 — Tests simulate real conditions [ERROR]

Tests exist to prove that code works in situations that actually happen. Don't test invented scenarios that never occur in production.

```php
// correct — simulates real usage
public function testConfirmPendingOrderTransitionsToConfirmed(): void
{
    $order = OrderFactory::pending();

    $order->confirm();

    $this->assertSame('confirmed', $order->status());
}

// incorrect — scenario that never happens
public function testOrderWithNegativeId(): void
{
    // Negative IDs never exist in the database, useless test
}
```

### TST-004 — Bug found = missing test [ERROR]

If a bug appears, the first step is to write a test that reproduces it. Then fix it. The test ensures the bug never returns.

### TST-005 — All new code has tests [ERROR]

Every entity, repository, manager, and handler delivered in a PR must have corresponding tests in the appropriate pyramid layer. Code without tests doesn't merge.

---

## 3. Organization and naming

### TST-006 — Directory structure mirrors the code in 5 layers [ERROR]

```
project/
├── inc/
│   ├── entities/Order.php
│   ├── repositories/OrderRepository.php
│   ├── managers/OrderManager.php
│   └── handlers/OrderHandler.php
└── tests/
    ├── unit/
    │   ├── OrderTest.php
    │   └── MoneyTest.php
    ├── component/
    │   └── OrderManagerTest.php
    ├── integration/
    │   └── OrderRepositoryTest.php
    ├── api/
    │   └── OrderHandlerTest.php
    └── functional/
        └── HomePageTest.php
```

### TST-007 — Test names describe behavior with context [ERROR]

Use the pattern: `test` + action + context + expected result. Without the word "should."

```php
// correct — clear behavior
public function testConfirmWhenPendingTransitionsToConfirmed(): void {}
public function testConfirmWhenAlreadyConfirmedThrowsException(): void {}
public function testCreateWithNegativeValueThrowsException(): void {}

// incorrect — vague, doesn't say what to expect
public function testConfirm(): void {}
public function testOrder(): void {}
public function testShouldConfirmTheOrder(): void {} // "should" prohibited
```

### TST-008 — Short descriptions, maximum 100 characters [WARNING]

---

## 4. Test structure

### TST-009 — AAA pattern: Arrange, Act, Assert [ERROR]

Every test follows three blocks separated by a blank line: prepare, execute, verify.

```php
// correct — clear AAA
public function testConfirmWhenPendingTransitions(): void
{
    // Arrange
    $order = OrderFactory::pending();

    // Act
    $order->confirm();

    // Assert
    $this->assertSame('confirmed', $order->status());
}
```

### TST-010 — One assertion per unit test [WARNING]

Unit and component tests validate a single behavior with one assertion. Integration, API, and functional tests may have up to 3 related assertions.

### TST-011 — Test the three paths: happy, invalid, boundary [ERROR]

Every tested behavior covers:
1. **Happy path** — works as expected
2. **Invalid case** — rejects wrong input
3. **Boundary case** — behavior at the edge (zero, empty, maximum)

---

## 5. Test data

### TST-012 — Factories, never fixtures [ERROR]

Use factories to create test objects. Factories are controllable, flexible, and explicit. Fixtures are fragile and opaque.

```php
// correct — factory
class OrderFactory
{
    public static function pending(array $overrides = []): Order
    {
        return new Order(
            id: $overrides['id'] ?? 1,
            userId: $overrides['userId'] ?? 100,
            valueCents: $overrides['valueCents'] ?? 15000,
            status: Order::STATUS_PENDING,
        );
    }

    public static function confirmed(array $overrides = []): Order
    {
        $order = self::pending($overrides);
        $order->confirm();
        return $order;
    }
}
```

### TST-013 — Create only what's necessary [WARNING]

Each test builds strictly the minimum data needed for the scenario.

### TST-014 — No loose duplicate values between setup and assertion [ERROR]

Never repeat literals between construction and verification. Read from the object, not from duplicated strings.

```php
// correct — reads from object
$order = OrderFactory::pending(['valueCents' => 5000]);
$id = $this->repository->create($order);
$saved = $this->repository->findById($id);
$this->assertSame($order->valueCents(), $saved->valueCents());

// incorrect — duplicated value
$this->assertSame(5000, $saved->valueCents()); // 5000 repeated
```

---

## 6. Isolation by layer

### TST-015 — Unit tests: no external dependencies [ERROR]

Tests in `tests/unit/` work with in-memory objects. No database, no network, no filesystem.

### TST-016 — Component tests: mock dependencies [ERROR]

Tests in `tests/component/` isolate the subject by mocking its dependencies.

### TST-017 — Integration tests: real database, no mocks [ERROR]

Tests in `tests/integration/` use a real database. No database mocks.

### TST-018 — API tests: full request/response [ERROR]

Tests in `tests/api/` simulate complete requests, including authentication and payload.

### TST-019 — Functional tests: framework loaded, page renders [ERROR]

Tests in `tests/functional/` load the complete framework and verify that pages render correctly.

### TST-020 — Mock external dependencies, never the subject [ERROR]

Mock dependencies that are not the test's responsibility. Never mock the object being tested.

### TST-021 — No dependency on external state [ERROR]

Tests don't depend on environment variables, system time, files on disk, or the state of other tests. Each test is self-sufficient.

---

## 7. Determinism

### TST-022 — Tests are deterministic [ERROR]

The same test running 100 times produces the same result. No `time()`, `rand()`, `uniqid()`, `new DateTimeImmutable()` without an argument.

### TST-023 — Execution order doesn't matter [ERROR]

No test depends on another test having run first. Each test prepares its own state.

---

## 8. Coverage by layer

### TST-024 — Unit: entities cover complete FSM [ERROR]

Every entity with a state machine must have unit tests for:
1. Each valid transition
2. Each invalid transition (throws exception)
3. Each state predicate
4. Construction with valid parameters
5. Construction with invalid parameters
6. `fromRow()` with clean data
7. `fromRow()` with dirty data (doesn't explode)
8. `toArray()` returns all fields

### TST-025 — Component: managers cover orchestration [ERROR]

### TST-026 — Integration: repositories cover CRUD + encryption [ERROR]

### TST-027 — API: handlers cover security and contract [ERROR]

### TST-028 — Functional: critical flows and rendering [WARNING]

---

## 9. Anti-patterns

### TST-029 — No complex hooks or shared state [WARNING]

Avoid complex `setUp()` methods that build shared state between tests.

### TST-030 — No tests that test the framework [ERROR]

Don't test whether PHP's native functions work. Test **our** code.

### TST-031 — No fantasy tests [ERROR]

Don't test impossible or extremely unlikely scenarios that never happen in real usage.

---

## Audit checklist

The `/audit-tests` skill must verify, for each test file:

**Pyramid:**
- [ ] Test is in the correct layer
- [ ] Pyramid proportion respected

**Philosophy:**
- [ ] Tests simulate real-world conditions
- [ ] All new code has corresponding tests
- [ ] Three paths covered: happy, invalid, boundary

**Organization:**
- [ ] Directory structure in 5 layers mirrors the code
- [ ] Names describe behavior with context (no "should")

**Structure:**
- [ ] AAA pattern (Arrange, Act, Assert)
- [ ] One assertion per unit/component test
- [ ] No loose duplicate values

**Data:**
- [ ] Factories used, never fixtures
- [ ] Only necessary data created

**Isolation:**
- [ ] Unit: no database, no network
- [ ] Component: mock dependencies
- [ ] Integration: real database, no mocks
- [ ] API: full request/response
- [ ] Mocks only on dependencies, never the subject
- [ ] No dependency on external state

**Determinism:**
- [ ] No time(), rand(), uniqid(), or DateTimeImmutable without argument
- [ ] Execution order doesn't matter

**Coverage:**
- [ ] Unit: entities with complete FSM tested
- [ ] Component: managers with orchestration tested
- [ ] Integration: repositories with CRUD
- [ ] API: handlers with security

**Anti-patterns:**
- [ ] No complex setUp() or shared state
- [ ] No tests that test the framework
- [ ] No fantasy tests

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
5. Filter `*Test.php` files within `tests/`.
6. Also check whether PHP files changed in the PR have corresponding tests.

### Phase 3 — Audit file by file

For each test file changed in the PR:

1. Read the complete file (not just the diff — context matters).
2. Compare against **every rule** from `docs/test-standards.md`, one by one, in document order.
3. For each violation found, record:
   - **File** and **line(s)** where it occurs
   - **Rule ID** violated (e.g., test-standards.md, TST-009)
   - **Severity** (ERROR or WARNING)
   - **What's wrong** — concise description
   - **How to fix** — specific correction for that snippet
4. If the file violates no rules, record as approved.

### Phase 4 — Report

Present the report to the user in the standard audit format (table with Line, Rule, Severity, Description, Fix).

### Phase 5 — Correction plan

If there are ERROR violations:

1. List the necessary corrections grouped by file.
2. Order by severity (ERRORs first, WARNINGs after).
3. Ask the user: "Would you like me to apply the corrections now?"

## Rules

- **Never change code during the audit.** The skill is read-only until the user explicitly requests correction.
- **Never audit files outside the PR.** Only test files and code changed in the open PR.
- **Always reference the violated rule ID.** The report must be traceable to the standards document.
- **Never invent rules.** The ruleset is exclusively `docs/test-standards.md`.
- **Be methodical and procedural.** Each file is compared against each rule, in document order, without skipping.
- **Fidelity to the document.** If the test violates a rule in the document, report it. If the document doesn't cover the case, don't report it.
- **Check cross-coverage.** If the PR has new code without tests, report it as TST-005.
- **Show the complete report before any action.** Never apply corrections without explicit approval.
