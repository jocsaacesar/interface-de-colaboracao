---
document: testing-standards
version: 2.2.0
created: 2025-01-01
updated: 2026-04-16
total_rules: 33
severities:
  error: 27
  warning: 6
scope: Automated testing standards for all projects
applies_to: ["all"]
requires: ["php-standards", "oop-standards"]
replaces: ["testing-standards v2.1.0"]
---

# Testing Standards — your organization

> Constitutional document. Delivery contract for every
> developer who touches tests in our projects.
> Code that violates ERROR rules is not discussed — it is returned.

---

## How to use this document

### For the developer

1. Read this document before writing the first test for any feature.
2. Check the DoD at the end before opening any Pull Request.
3. Use the rule IDs (TST-001 to TST-033) to reference in PRs and code reviews.

### For the auditor (human or AI)

1. Read the frontmatter to understand scope and dependencies.
2. Audit each test file against the rules by ID and severity.
3. Classify violations: ERROR blocks merge, WARNING requires justification.
4. Reference violations by rule ID (e.g., "violates TST-009").

### For Claude Code

1. Read the frontmatter to identify scope and related documents.
2. When generating or reviewing tests, apply all ERROR rules as blocking.
3. When reporting violations, reference by ID (e.g., "TST-012 — uses fixture instead of factory").
4. Never generate tests that violate ERROR rules in this document.

---

## Severities

| Level | Meaning | Action |
|-------|---------|--------|
| **ERROR** | Non-negotiable violation | Blocks merge. Fix before review. |
| **WARNING** | Strong recommendation | Must be justified in writing if ignored. |

---

## 1. Test pyramid

### TST-001 — Five layers, wide base, narrow top [ERROR]

**Rule:** The project must adopt a test pyramid with 5 layers. The base (unit tests) holds the largest volume. The top (functional/end-to-end) has few high-value tests.

**Checks:** Count files per directory (`tests/unit/`, `components/`, `integration/`, `api/`, `functional/`) and validate that the proportion follows the pyramid (unit tests >= 40%).

**Why:** The project operates with small teams and 24/7 AI-assisted development. Without a well-defined pyramid, expensive tests dominate the suite, CI gets slow, and the autonomous agent loses the ability to validate changes quickly. The wide base of unit tests is what enables continuous iteration without human supervision.

| Layer | Suggested directory | What it tests | Cost/Effort |
|-------|-------------------|---------------|-------------|
| Unit | `tests/unit/` | Entities, Value Objects — pure domain logic | Low |
| Component | `tests/components/` | Managers/services with mocks — isolated orchestration | Low-medium |
| Integration | `tests/integration/` | Repositories with real database, external services | Medium |
| API | `tests/api/` | Endpoints/handlers — complete request/response | Medium-high |
| Functional | `tests/functional/` | End-to-end flows, page rendering | High |

Expected proportion (approximate):

```
         /\          Functional       ~5%
        /  \         API              ~10%
       /    \        Integration      ~15%
      /      \       Component        ~20%
     /________\      Unit             ~50%
```

**Correct example:**
```
project/
└── tests/
    ├── unit/             # ~50% of tests
    ├── components/       # ~20% of tests
    ├── integration/      # ~15% of tests
    ├── api/              # ~10% of tests
    └── functional/       # ~5% of tests
```

**Incorrect example:**
```
project/
└── tests/
    ├── unit/             # 3 tests
    └── functional/       # 47 tests — inverted pyramid
```

### TST-002 — Each test lives in the correct layer [ERROR]

**Rule:** A test that accesses a database is never a unit test. A test that mocks everything is never an integration test. Classify each test in the correct layer based on its actual dependencies.

**Checks:** In each test file, verify that the real dependencies (database, network, mocks) are compatible with the layer of the directory where the file lives.

**Why:** Wrong classification breaks trust in the pyramid. If unit tests access the database, they become slow and fragile. If integration tests mock everything, they test nothing real. The autonomous agent depends on this classification to decide which tests to run in each context.

| If the test... | Layer |
|----------------|-------|
| Tests pure logic without external dependency | Unit |
| Tests orchestration with mocked dependencies | Component |
| Accesses a real database or external service | Integration |
| Simulates a complete HTTP request with authentication | API |
| Verifies page rendering or end-to-end flow | Functional |

**Correct example:**
```php
// tests/unit/OrderTest.php — no external dependency
public function testCancelWhenPendingTransitions(): void
{
    $order = OrderFactory::pending();
    $order->cancel();
    $this->assertSame('cancelled', $order->status());
}
```

**Incorrect example:**
```php
// tests/unit/OrderTest.php — accesses database, should be integration
public function testCreateOrderPersists(): void
{
    $id = $this->repository->create(OrderFactory::pending());
    $this->assertNotNull($this->repository->findById($id));
}
```

---

## 2. Philosophy

### TST-003 — Tests simulate real conditions [ERROR]

**Rule:** Tests must prove that code works in situations that actually happen in production. Never test invented scenarios that never occur.

**Checks:** For each test, confirm that the scenario described in the name corresponds to a real system use case.

**Why:** The project develops with AI generating code autonomously. Tests are the only safety net that guarantees generated code works under real conditions. Tests of fictional scenarios consume CI time without adding protection.

**Correct example:**
```php
// simulates real use — state transition that happens in production
public function testConfirmPendingOrderTransitionsToConfirmed(): void
{
    $order = OrderFactory::pending();

    $order->confirm();

    $this->assertSame('confirmed', $order->status());
}
```

**Incorrect example:**
```php
// scenario that never happens
public function testOrderWithNegativeId(): void
{
    // Negative IDs never exist in the database, useless test
}
```

### TST-004 — Bug found = missing test [ERROR]

**Rule:** When a bug appears in production or in review, the first step is to write a test that reproduces the bug. Then fix it. The test ensures the bug never returns.

**Checks:** In bugfix PRs, verify that at least one new test exists whose name references the bug and that fails without the fix applied.

**Why:** Small teams don't have dedicated manual QA. If a bug escapes once without a regression test, it will escape again — especially with AI generating code that may reintroduce the same problematic pattern.

**Correct example:**
```php
// Bug #142: negative discount was allowed — regression test
public function testApplyNegativeDiscountThrowsException(): void
{
    $order = OrderFactory::confirmed();

    $this->expectException(DomainException::class);
    $order->applyDiscount(-500);
}
```

**Incorrect example:**
```php
// Bug reported, fixed directly in code without test
// → no test written, bug can return on next refactoring
```

### TST-005 — All new code has tests [ERROR]

**Rule:** Every entity, repository, service, and endpoint delivered in a PR must have corresponding tests in the appropriate pyramid layer. Code without tests never merges.

**Checks:** Compare code files added/modified in the PR with existing test files. Each new class must have at least one corresponding test file.

**Why:** The autonomous agent operates 24/7 without human supervision. Code without tests is code that can break silently. In the project, tests are the operating contract — not a bonus, but a minimum delivery requirement.

**Correct example:**
```php
// PR adds Product entity + complete unit tests
// tests/unit/ProductTest.php exists with coverage of the 3 paths
```

**Incorrect example:**
```php
// PR adds Product entity without any test
// "I'll add tests later" — never happens
```

**Exceptions:** Pure presentation templates (HTML with framework calls like `get_header()`, `render()`) don't require unit tests — they are covered by functional tests when the flow justifies it.

---

## 3. Organization and naming

### TST-006 — Folder structure mirrors the code in 5 layers [ERROR]

**Rule:** The test directory structure must mirror the source code structure, organized in the 5 pyramid layers. Each testable class must have its corresponding test file in the correct layer.

**Checks:** Confirm that the 5 pyramid directories exist and that each test file is in the directory corresponding to its layer.

**Why:** A predictable structure allows the autonomous agent to find and execute relevant tests without manual configuration. When a code file changes, the agent knows exactly where the corresponding test is.

**Correct example:**
```
project/
├── src/
│   ├── entities/Order.php
│   ├── repositories/OrderRepository.php
│   ├── services/OrderService.php
│   └── endpoints/OrderEndpoint.php
└── tests/
    ├── unit/
    │   └── OrderTest.php
    ├── components/
    │   └── OrderServiceTest.php
    ├── integration/
    │   └── OrderRepositoryTest.php
    ├── api/
    │   └── OrderEndpointTest.php
    └── functional/
        └── OrderFlowTest.php
```

**Incorrect example:**
```
project/
└── tests/
    ├── OrderTest.php            # everything in one directory
    ├── OrderRepositoryTest.php  # no layer separation
    └── OrderEndpointTest.php    # impossible to know what each test does
```

### TST-007 — Test names describe behavior with context [ERROR]

**Rule:** Use the pattern: `test` + action + context + expected result. Without the word "should". Contexts with "when", "with", "without".

**Checks:** Search for `function test` in test files. No name should contain "should". Each name must have action + context + result.

**Why:** Descriptive names work as living documentation. When the autonomous agent reports a failure, the test name must say exactly what broke — without needing to open the code.

**Correct example:**
```php
public function testConfirmWhenPendingTransitionsToConfirmed(): void {}
public function testConfirmWhenAlreadyConfirmedThrowsException(): void {}
public function testCreateWithNegativeValueThrowsException(): void {}
public function testCalculateTotalWithoutItemsReturnsZero(): void {}
```

**Incorrect example:**
```php
public function testConfirm(): void {}               // vague
public function testOrder(): void {}                  // says nothing
public function testShouldConfirmTheOrder(): void {}  // "should" prohibited
```

### TST-008 — Short descriptions, maximum 100 characters [WARNING]

**Rule:** If the test name exceeds 100 characters, the scenario is too complex — split into smaller tests or use more concise contexts.

**Checks:** `grep -oP 'function \K(test\w+)'` in each test file and measure length. No name >100 characters.

**Why:** Long names break CI report formatting and make rapid reading of results harder for both the autonomous agent and the developer.

**Correct example:**
```php
public function testCancelWhenPendingRemovesFromInventory(): void {}
// 52 characters — clear and concise
```

**Incorrect example:**
```php
public function testCancelOrderWhenStatusIsPendingAndUserHasAdminPermissionRemovesItemsFromInventoryAndNotifiesManager(): void {}
// 127 characters — split into smaller tests
```

---

## 4. Test structure

### TST-009 — AAA pattern: Arrange, Act, Assert [ERROR]

**Rule:** Every test follows three blocks separated by blank lines: prepare (Arrange), execute (Act), verify (Assert).

**Checks:** Inspect the body of each test — there must be 3 visual blocks separated by blank lines. One-liners or tests without separation violate.

**Why:** AAA makes tests readable by anyone or any AI that has never seen the code. In the project, the autonomous agent needs to understand the test's intent to suggest fixes. Tests without clear structure are opaque.

**Correct example:**
```php
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

**Incorrect example:**
```php
public function testConfirm(): void
{
    $this->assertSame('confirmed', OrderFactory::pending()->confirm()->status());
}
```

### TST-010 — One assertion per unit test [WARNING]

**Rule:** Unit and component tests should validate a single behavior with one assertion. Integration, API, and functional tests may have up to 3 related assertions.

**Checks:** Count `assert*` per method in `unit/` and `components/` — maximum 1. In `integration/`, `api/`, `functional/` — maximum 3.

**Why:** One assertion per test makes failures surgical — when it breaks, the test name says exactly what failed. With multiple assertions, the first failure masks the rest.

**Correct example:**
```php
// unit — one assertion
public function testConfirmTransitionsStatus(): void
{
    $order = OrderFactory::pending();

    $order->confirm();

    $this->assertSame('confirmed', $order->status());
}

// integration — up to 3 related assertions
public function testCreateOrderPersistsAllFields(): void
{
    $id = $this->repository->create($order);

    $saved = $this->repository->findById($id);
    $this->assertNotNull($saved);
    $this->assertSame($order->totalCents(), $saved->totalCents());
    $this->assertSame($order->status(), $saved->status());
}
```

**Incorrect example:**
```php
// unit with multiple assertions — split into separate tests
public function testConfirm(): void
{
    $order = OrderFactory::pending();
    $order->confirm();

    $this->assertSame('confirmed', $order->status());
    $this->assertNotNull($order->confirmationDate());
    $this->assertTrue($order->isConfirmed());
}
```

### TST-011 — Test the three paths: happy, invalid, boundary [ERROR]

**Rule:** Every tested behavior must cover: happy path (works as expected), invalid case (rejects wrong input), and boundary case (behavior at the frontier: zero, empty, maximum).

**Checks:** For each tested behavior, confirm that at least 3 tests exist: one happy, one invalid (exception/rejection), and one boundary (zero/empty/maximum).

**Why:** AI-generated code tends to cover only the happy path. Real bugs live at boundaries and in invalid inputs. Without coverage of all three paths, the safety net has holes.

**Correct example:**
```php
// Happy path
public function testConfirmWhenPendingTransitions(): void {}

// Invalid case
public function testConfirmWhenCancelledThrowsException(): void {}

// Boundary case
public function testCalculateTotalWithoutItemsReturnsZero(): void {}
```

**Incorrect example:**
```php
// Only happy path — no error or boundary coverage
public function testConfirmTransitions(): void {}
// and nothing else
```

---

## 5. Test data

### TST-012 — Factories, never fixtures [ERROR]

**Rule:** Use factories to create test objects. Fixtures (JSON, YAML, shared files) are prohibited.

**Checks:** Search for `fixture`, `.json`, `.yaml` in test directories. Search for `*Factory` classes — they must exist for each tested entity.

**Why:** Factories are explicit — the test shows exactly what it's building. Fixtures are opaque, fragile, and create coupling between tests. In autonomous operation, the agent needs to understand the test setup by reading only the code, without hunting for external files.

**Correct example:**
```php
class OrderFactory
{
    public static function pending(array $overrides = []): Order
    {
        return new Order(
            id: $overrides['id'] ?? 1,
            clientId: $overrides['clientId'] ?? 100,
            totalCents: $overrides['totalCents'] ?? 15000,
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

**Incorrect example:**
```php
// fixtures/order.json — fragile, hard to trace, shared between tests
// fixtures/order.yaml — same problem
```

### TST-013 — Create only what's necessary [WARNING]

**Rule:** Each test should build strictly the minimum data for the scenario. Don't load complete objects when a partial one suffices.

**Checks:** Inspect the Arrange of each test — objects created that aren't used in Act or Assert indicate excessive setup.

**Why:** Excessive setup makes tests slow and makes it harder to identify what's actually being tested. In AI operation, bloated tests generate unnecessary context that consumes tokens and reduces analysis quality.

**Correct example:**
```php
public function testIsActiveReturnsTrueWhenStatusActive(): void
{
    $account = AccountFactory::active();

    $this->assertTrue($account->isActive());
}
```

**Incorrect example:**
```php
public function testIsActive(): void
{
    $user = UserFactory::complete();
    $account = AccountFactory::completeWithUser($user);
    $order1 = OrderFactory::pending(['accountId' => $account->id()]);
    $order2 = OrderFactory::confirmed(['accountId' => $account->id()]);
    // ... just to test if the account is active
}
```

### TST-014 — No loose duplicate values between setup and assertion [ERROR]

**Rule:** Never repeat literals between object construction and verification. Read the value from the object, not from duplicated strings or numbers.

**Checks:** Compare literals in Arrange with literals in Assert. If the same value appears in both blocks, the assert should read from the object, not repeat the literal.

**Why:** Duplicate values create tests that pass by coincidence. When the value changes in setup, the test continues passing with the old literal in the assertion. Real bugs escape.

**Correct example:**
```php
public function testCreateOrderPersists(): void
{
    $order = OrderFactory::pending(['totalCents' => 5000]);

    $id = $this->repository->create($order);
    $saved = $this->repository->findById($id);

    $this->assertSame($order->totalCents(), $saved->totalCents());
}
```

**Incorrect example:**
```php
public function testCreateOrderPersists(): void
{
    $order = OrderFactory::pending(['totalCents' => 5000]);

    $id = $this->repository->create($order);
    $saved = $this->repository->findById($id);

    $this->assertSame(5000, $saved->totalCents()); // 5000 repeated
}
```

---

## 6. Isolation by layer

### TST-015 — Unit tests: no external dependency [ERROR]

**Rule:** Unit tests work with in-memory objects. No database, no network, no filesystem, no framework. They test pure entities and Value Objects.

**Checks:** In `unit/`, search for `$wpdb`, `$this->repository`, `file_get_contents`, `curl`, `$this->db`. Any occurrence is a violation.

**Why:** Unit tests must run in milliseconds. They are executed on every commit by the autonomous agent. Any external dependency makes the suite slow and fragile, compromising the rapid feedback cycle that 24/7 operation requires.

**Correct example:**
```php
// pure unit test — no external dependency
public function testConfirmWhenPendingTransitions(): void
{
    $order = OrderFactory::pending();

    $order->confirm();

    $this->assertSame('confirmed', $order->status());
}
```

**Incorrect example:**
```php
// "unit test" that accesses database — not a unit test
public function testConfirmOrder(): void
{
    $order = $this->repository->findById(1); // accesses database
    $order->confirm();
    $this->repository->update($order);       // accesses database again
}
```

### TST-016 — Component tests: mock dependencies [ERROR]

**Rule:** Component tests isolate the subject by mocking its dependencies (repositories, external services). They test orchestration without touching infrastructure.

**Checks:** In `components/`, confirm that dependencies are `createMock()` and that no real database/network access exists.

**Why:** Components validate that orchestration logic works — that the right methods are called in the right order. Without mocks, the test becomes a disguised integration test, slower and more fragile.

**Correct example:**
```php
public function testConfirmOrderUpdatesRepository(): void
{
    $repository = $this->createMock(OrderRepository::class);
    $repository->expects($this->once())
        ->method('findById')
        ->willReturn(OrderFactory::pending());
    $repository->expects($this->once())
        ->method('update');

    $service = new OrderService($repository);

    $service->confirmOrder(1);
}
```

**Incorrect example:**
```php
// "component test" that accesses real database — should be integration
public function testConfirmOrder(): void
{
    $service = new OrderService($this->realRepository);
    $service->confirmOrder(1);
}
```

### TST-017 — Integration tests: real infrastructure, no mocks [ERROR]

**Rule:** Integration tests use real infrastructure (database, external services). They test repositories, persistence, and end-to-end integrations. No mocks of the data layer.

**Checks:** In `integration/`, search for `createMock` of repositories or database classes. Any mock of persistence is a violation.

**Why:** The only way to guarantee persistence works is to test it against a real database. Database mocks hide SQL, mapping, and encryption bugs that only appear in production — when it's already too late.

**Correct example:**
```php
public function testCreateOrderPersists(): void
{
    $order = OrderFactory::pending(['totalCents' => 5000]);

    $id = $this->repository->create($order);
    $saved = $this->repository->findById($id);

    $this->assertSame($order->totalCents(), $saved->totalCents());
}
```

**Incorrect example:**
```php
// "integration test" that mocks the database — tests nothing real
public function testCreateOrder(): void
{
    $db = $this->createMock(Database::class);
    $db->method('insert')->willReturn(1);
    // mock doesn't validate SQL, doesn't validate schema, doesn't validate anything
}
```

### TST-018 — API tests: complete request/response [ERROR]

**Rule:** API tests simulate complete HTTP requests, including authentication, authorization, and payload. They test endpoints as a black box: complete input, verified output.

**Checks:** In `api/`, confirm that each test builds a complete HTTP request (method, path, headers) and verifies status code + body.

**Why:** Endpoints are the system boundary — where external data enters. In autonomous operation, the agent generates endpoints that must reject invalid requests without human supervision. API tests validate that contract.

**Correct example:**
```php
public function testConfirmOrderWithoutAuthenticationReturns401(): void
{
    // Arrange — request without token/nonce
    $request = new Request('POST', '/orders/1/confirm');

    // Act
    $response = $this->app->handle($request);

    // Assert
    $this->assertSame(401, $response->getStatusCode());
}

public function testConfirmOrderWithValidDataReturnsSuccess(): void
{
    // Arrange — authenticated request
    $request = new Request('POST', '/orders/1/confirm', [
        'Authorization' => 'Bearer ' . $this->validToken,
    ]);

    // Act
    $response = $this->app->handle($request);

    // Assert
    $this->assertSame(200, $response->getStatusCode());
}
```

**Incorrect example:**
```php
// Tests endpoint without authentication — doesn't validate security
public function testConfirmOrder(): void
{
    $response = $this->endpoint->confirm(1);
    $this->assertTrue($response['success']);
}
```

### TST-019 — Functional tests: loaded application, end-to-end flow [ERROR]

**Rule:** Functional tests load the complete application and verify that pages render, assets are loaded, and end-to-end flows work as expected.

**Checks:** In `functional/`, confirm that the application is loaded via a real HTTP client and that asserts verify status + rendered content.

**Why:** Functional tests are the last line of defense. They validate that all layers work together. In the project, with frequent deploys and autonomous operation, these tests guarantee that no integration between layers broke silently.

**Correct example:**
```php
public function testHomepageRendersWithCorrectAssets(): void
{
    $response = $this->client->get('/');

    $this->assertSame(200, $response->getStatusCode());
    $this->assertStringContainsString('<link', $response->getBody());
    $this->assertStringContainsString('<script', $response->getBody());
}

public function testCompleteRegistrationFlow(): void
{
    // register
    $response = $this->client->post('/register', $validData);
    $this->assertSame(302, $response->getStatusCode());

    // login
    $response = $this->client->post('/login', $credentials);
    $this->assertSame(200, $response->getStatusCode());
}
```

**Incorrect example:**
```php
// "functional" that doesn't load the application — it's a disguised unit test
public function testHomepage(): void
{
    $html = file_get_contents('templates/index.html');
    $this->assertStringContainsString('title', $html);
}
```

### TST-020 — Mock dependencies, never the subject [ERROR]

**Rule:** Mocks must only be used for dependencies that are not the test's responsibility. Never mock the object being tested.

**Checks:** In each test with `createMock`, verify that the mocked class is never the same as the subject under test (the one instantiated with `new`).

**Why:** Mocking the subject is self-deception — the test doesn't validate real behavior, it only confirms the mock returns what it was programmed to return. In autonomous operation, this generates false confidence: CI passes green, but the real code is broken.

**Correct example:**
```php
// mock of the dependency (repository)
public function testConfirmOrderUpdatesRepository(): void
{
    $repository = $this->createMock(OrderRepository::class);
    $repository->expects($this->once())->method('update');

    $service = new OrderService($repository);
    $service->confirmOrder(1);
}
```

**Incorrect example:**
```php
// mock of the subject — tests nothing real
public function testOrder(): void
{
    $order = $this->createMock(Order::class);
    $order->method('isConfirmed')->willReturn(true);
    $this->assertTrue($order->isConfirmed()); // tested the mock, not the Order
}
```

### TST-021 — No dependency on external state [ERROR]

**Rule:** Tests never depend on environment variables, system time, files on disk, or state from other tests. Each test is self-sufficient.

**Checks:** Search for `getenv`, `$_ENV`, `$_SERVER`, `file_get_contents` without mock, `new DateTimeImmutable()` without argument in tests. Any direct use is a violation.

**Why:** The autonomous agent runs tests at different times, in different environments, in random order. Tests that depend on external state fail intermittently, generating noise that prevents the agent from distinguishing real failure from environmental failure.

**Correct example:**
```php
// controlled time — explicitly injected
public function testOrderExpiredWhenDatePassed(): void
{
    $pastDate = new DateTimeImmutable('2025-01-01');
    $order = OrderFactory::pending(['dueDate' => $pastDate]);

    $this->assertTrue($order->isExpired(new DateTimeImmutable('2026-04-08')));
}
```

**Incorrect example:**
```php
// depends on the real clock — breaks depending on the day
public function testOrderExpired(): void
{
    $order = OrderFactory::pending(['dueDate' => new DateTimeImmutable('yesterday')]);
    $this->assertTrue($order->isExpired()); // flaky
}
```

---

## 7. Determinism

### TST-022 — Tests are deterministic [ERROR]

**Rule:** The same test running 100 times must produce the same result. Using non-deterministic functions without control is prohibited: `time()`, `rand()`, `uniqid()`, `new DateTimeImmutable()` without argument, `Date.now()`, `Math.random()`.

**Checks:** Search for `time()`, `rand(`, `random_int(`, `uniqid(`, `Date.now()`, `Math.random()`, `new DateTimeImmutable()` (without argument) in test files.

**Why:** Flaky tests are worse than absent tests. In 24/7 operation, an intermittent test paralyzes the pipeline — the agent doesn't know if it's a real bug or a spurious failure and can't make autonomous decisions.

**Correct example:**
```php
$now = new DateTimeImmutable('2026-04-08 10:00:00');
$id = 42;
```

**Incorrect example:**
```php
$now = new DateTimeImmutable(); // changes every execution
$id = random_int(1, 1000);     // non-deterministic
```

### TST-023 — Execution order doesn't matter [ERROR]

**Rule:** No test depends on another test having run before it. Each test prepares its own state and cleans up afterward if necessary.

**Checks:** Search for references to fixed IDs or data created in other test methods. Each test must create its own data in Arrange.

**Why:** Test frameworks can execute in random order (PHPUnit `--random-order`, pytest `--randomly`, Jest `--randomize`). Order dependency generates phantom failures that consume hours of investigation.

**Correct example:**
```php
public function testCreateOrder(): void
{
    // creates its own state
    $order = OrderFactory::pending();
    $id = $this->repository->create($order);
    $this->assertNotNull($id);
}

public function testFindOrder(): void
{
    // creates its own state — doesn't depend on testCreateOrder
    $order = OrderFactory::pending();
    $id = $this->repository->create($order);

    $saved = $this->repository->findById($id);
    $this->assertNotNull($saved);
}
```

**Incorrect example:**
```php
// testFindOrder assumes testCreateOrder already ran and created ID 1
public function testFindOrder(): void
{
    $saved = $this->repository->findById(1); // depends on the previous test
    $this->assertNotNull($saved);
}
```

---

## 8. Coverage by layer

### TST-024 — Unit tests: entities cover complete FSM [ERROR]

**Rule:** Every entity with a state machine must have unit tests for: each valid transition, each invalid transition (throws exception), each state predicate, construction with valid and invalid parameters, and serialization/hydration methods.

**Checks:** For each entity with FSM, list transitions from the state diagram and confirm that tests exist for each valid transition + each invalid transition + predicates.

**Why:** Entities are the heart of the domain. In the project, AI generates code that manipulates entities — if the FSM isn't 100% covered, an invalid transition can corrupt data without anyone noticing until the customer complains.

**Correct example:**
```php
// Minimum coverage for entity with FSM
public function testCreatePendingOrder(): void {}
public function testConfirmWhenPendingTransitions(): void {}
public function testConfirmWhenCancelledThrowsException(): void {}
public function testCancelWhenPendingTransitions(): void {}
public function testCancelWhenAlreadyCancelledThrowsException(): void {}
public function testIsConfirmedReturnsTrueWhenConfirmed(): void {}
public function testIsPendingReturnsTrueWhenPending(): void {}
public function testCanTransitionToConfirmedWhenPending(): void {}
public function testCannotTransitionToConfirmedWhenCancelled(): void {}
public function testFromRowWithCleanDataHydratesCorrectly(): void {}
public function testFromRowWithDirtyDataDoesNotExplode(): void {}
public function testToArrayReturnsAllFields(): void {}
```

**Incorrect example:**
```php
// Only happy path — FSM partially covered
public function testConfirm(): void {}
public function testCancel(): void {}
// missing: invalid transitions, predicates, from_row, to_array
```

### TST-025 — Components: services cover orchestration [ERROR]

**Rule:** Services/managers must have component tests with mocked repositories, verifying: correct calls to repository methods, exception when entity not found, and delegation of domain logic to the entity.

**Checks:** For each service, confirm tests with `expects($this->once())->method(...)` on the mocked repo + test for `EntityNotFoundException` when `findById` returns null.

**Why:** Services are the glue between domain and infrastructure. If orchestration fails, correct data isn't persisted or exceptions aren't handled. In autonomous operation, silent orchestration failure is the hardest category of bug to diagnose.

**Correct example:**
```php
public function testConfirmOrderCallsUpdateOnRepository(): void
{
    $repository = $this->createMock(OrderRepository::class);
    $repository->method('findById')->willReturn(OrderFactory::pending());
    $repository->expects($this->once())->method('update');

    $service = new OrderService($repository);
    $service->confirmOrder(1);
}

public function testConfirmNonexistentOrderThrowsException(): void
{
    $repository = $this->createMock(OrderRepository::class);
    $repository->method('findById')->willReturn(null);

    $service = new OrderService($repository);

    $this->expectException(EntityNotFoundException::class);
    $service->confirmOrder(999);
}
```

**Incorrect example:**
```php
// Tests service without verifying interaction with repository
public function testConfirmOrder(): void
{
    $service = new OrderService($this->realRepository);
    $service->confirmOrder(1);
    // no assertion about what the repository received
}
```

### TST-026 — Integration: repositories cover complete CRUD [ERROR]

**Rule:** Every repository must have integration tests for: `create()` persists and returns ID, `findById()` returns the correct entity, `findById()` returns null when nonexistent, `update()` persists changes, `delete()` removes the record.

**Checks:** For each repository, confirm tests for the 5 CRUD methods (create, findById success, findById null, update, delete).

**Why:** Repositories are the boundary with the database. SQL errors, mapping, or encoding only appear with a real database. In the project, financial and personal data passes through repositories — any persistence failure can corrupt critical data.

**Correct example:**
```php
public function testCreatePersistsAndReturnsId(): void
{
    $order = OrderFactory::pending();
    $id = $this->repository->create($order);
    $this->assertIsInt($id);
    $this->assertGreaterThan(0, $id);
}

public function testFindByIdReturnsNullWhenNotExists(): void
{
    $result = $this->repository->findById(999999);
    $this->assertNull($result);
}
```

**Incorrect example:**
```php
// Only tests create, ignores find/update/delete
public function testCreate(): void
{
    $id = $this->repository->create(OrderFactory::pending());
    $this->assertNotNull($id);
}
```

### TST-027 — API: endpoints cover security and contract [ERROR]

**Rule:** Every endpoint must have API tests for: unauthenticated request is rejected, request with invalid permission is rejected, request with missing data returns error, valid request returns success, service exceptions are caught and returned as error.

**Checks:** For each endpoint, confirm 5 minimum tests: no auth (401/403), invalid role (403), missing data (400/422), success (200/201), service exception (500/error).

**Why:** Endpoints are the system's front door. In autonomous operation, the agent generates endpoints that must be secure by default. If API tests don't cover authentication and authorization, security failures go unnoticed.

**Correct example:**
```php
public function testEndpointWithoutAuthenticationReturnsError(): void {}
public function testEndpointWithInvalidRoleReturnsForbidden(): void {}
public function testEndpointWithMissingDataReturnsValidationError(): void {}
public function testEndpointWithValidDataReturnsSuccess(): void {}
public function testEndpointWhenServiceThrowsExceptionReturnsError(): void {}
```

**Incorrect example:**
```php
// Only happy path — security not tested
public function testEndpointReturnsSuccess(): void
{
    $response = $this->endpoint->handle($validData);
    $this->assertTrue($response['success']);
}
```

### TST-028 — Functional: critical flows and rendering [WARNING]

**Rule:** Functional tests must cover: page loads without error (HTTP 200), essential assets are loaded, mandatory sections render, critical end-to-end flows.

**Checks:** In `functional/`, confirm at least: test for home page status 200, test for `<link>`/`<script>` presence, test for critical business flow (if applicable).

**Why:** Functional tests are expensive and should be selective — they cover critical paths, not every variation. In the project, they validate that the system works end-to-end after automated deploys.

**Correct example:**
```php
public function testHomepageLoads(): void
{
    $response = $this->client->get('/');
    $this->assertSame(200, $response->getStatusCode());
}

public function testCriticalPurchaseFlow(): void
{
    // register → login → add to cart → checkout
    // selective test of revenue-generating flow
}
```

**Incorrect example:**
```php
// 50 functional tests testing every form variation
// — should be unit/component, not functional
```

---

## 9. Anti-patterns

### TST-029 — No complex hooks or shared state [WARNING]

**Rule:** Avoid complex `setUp()` / `beforeEach()` that builds shared state between tests. If the setup has more than 5 lines, the test probably needs a factory.

**Checks:** Count lines of `setUp()` / `beforeEach()` in each test class. More than 5 lines is a violation.

**Why:** Shared state between tests creates invisible coupling. When the autonomous agent modifies one test, shared setup can break other unrelated tests — generating failure cascades that paralyze the pipeline.

**Correct example:**
```php
public function testConfirmOrder(): void
{
    $order = OrderFactory::pending(); // factory in the test

    $order->confirm();

    $this->assertSame('confirmed', $order->status());
}
```

**Incorrect example:**
```php
// setUp with 15 lines building global state
protected function setUp(): void
{
    $this->user = UserFactory::admin();
    $this->account = AccountFactory::active(['userId' => $this->user->id()]);
    $this->order = OrderFactory::pending(['accountId' => $this->account->id()]);
    $this->repository = new OrderRepository($this->db);
    $this->service = new OrderService($this->repository);
    $this->id = $this->repository->create($this->order);
    // ... each test uses part of this state, none uses all of it
}
```

### TST-030 — No tests that test the framework [ERROR]

**Rule:** Never test whether native language or framework functions work. Test exclusively the project's code.

**Checks:** Inspect asserts — if the assert subject is a native function (`json_encode`, `array_map`, ORM method) without project logic involved, it's a violation.

**Why:** Testing the framework is a waste of CI. In 24/7 operation, every CI second counts. Tests that validate `json_encode()`, `array_map()`, or native ORM methods consume resources without adding protection to the project's code.

**Correct example:**
```php
// Tests project logic
public function testCalculateDiscountAppliesPercentage(): void
{
    $order = OrderFactory::pending(['totalCents' => 10000]);

    $order->applyDiscount(10); // 10%

    $this->assertSame(9000, $order->totalCents());
}
```

**Incorrect example:**
```php
// Tests PHP, not our code
public function testJsonEncodeReturnsString(): void
{
    $this->assertIsString(json_encode(['a' => 1]));
}
```

### TST-031 — No fantasy tests [ERROR]

**Rule:** Never test impossible or extremely unlikely scenarios that never happen in real use. Tests exist to validate production behavior.

**Checks:** For each test, confirm that the scenario described in the name is plausible in real use. Absurd values (billions, negative IDs) without business justification are a violation.

**Why:** Fantasy tests consume writing time, CI time, and review attention — without protecting against any real scenario. In autonomous operation, the agent may generate unnecessary tests if it doesn't have this explicit restriction.

**Correct example:**
```php
// real scenario — maximum value supported by the system
public function testOrderWithMaxAllowedValue(): void
{
    $order = OrderFactory::pending(['totalCents' => 99999999]); // $999,999.99
    $this->assertSame(99999999, $order->totalCents());
}
```

**Incorrect example:**
```php
// fantasy scenario — will never happen
public function testOrderWithBillionDollars(): void
{
    $order = OrderFactory::pending(['totalCents' => 100000000000000]);
    // ... will never happen in the system
}
```

---

## 10. Documentation and versioning

### TST-032 — Comments in tests explain the why, not the what [WARNING]

**Rule:** Comments in tests are allowed only to explain why a specific scenario is tested (e.g., bug regression). The test name should be sufficient to explain the what.

**Checks:** Inspect comments in tests. Comments that describe what the code does (instead of why) are a violation. Regression comments with bug/PR references are accepted.

**Why:** Well-named tests (TST-007) are self-documented. Comments that repeat what the code does are noise. Comments that explain the motivation (e.g., "Bug #142 — negative discount passed validation") add context that the name can't accommodate.

**Correct example:**
```php
// Regression: Bug #142 — negative discount was applied without validation
public function testApplyNegativeDiscountThrowsException(): void
{
    $order = OrderFactory::confirmed();

    $this->expectException(DomainException::class);
    $order->applyDiscount(-500);
}
```

**Incorrect example:**
```php
// Tests if negative discount throws exception  ← repeats the test name
public function testApplyNegativeDiscountThrowsException(): void
{
    // creates a confirmed order  ← describes the obvious
    $order = OrderFactory::confirmed();
    // expects exception  ← describes the obvious
    $this->expectException(DomainException::class);
    $order->applyDiscount(-500);
}
```

### TST-033 — Hydration test proves real column name [ERROR]

**Rule:** Every entity with a hydration method (`from_row()`, `fromArray()`, `from_db()`, etc.) must have a test that proves **each field read matches the real column name in the schema**. The hydration test seeds the source array/object using **literally** the canonical column name and verifies the entity getter returns the seeded value. When the internal PHP name differs from the SQL column name (e.g., `$score100` property vs `score_100` column), add a **sentinel** test that seeds the WRONG name and expects the default value — if someone regresses to the wrong name, the test fails.

**Checks:** For each entity with `from_row`/`fromArray`, confirm: (1) test with seed using canonical SQL column name, (2) sentinel test seeding the wrong PHP name and expecting default, for each field where camelCase != snake_case.

**Why:** Mismatch bugs between PHP property names and SQL column names pass silently when bug and test share the same error. A real incident showed this in practice: a `from_row()` method read `$row->score100` instead of `$row->score_100`, and the test seeded `'score100'` (wrong key) — both the bug and the test had the same defect, so CI was green while production returned `score_100 = 0` for all competencies for 2 days. Origin: a PR with an automatic batch adding `from_row()` to 33 entities without cross-referencing names with the schema. This rule exists to close that hole.

**Correct example:**
```php
#[Test]
public function from_row_reads_score_100_with_underscore_from_real_column(): void
{
    // Seed uses LITERALLY the schema column name (snake_case)
    $row = (object) [
        'id'        => 1,
        'score_100' => 75.5,  // ← canonical column name
        // ...
    ];

    $entity = ResultCompetency::from_row($row);

    self::assertSame(75.5, $entity->score_100());
}

#[Test]
public function from_row_ignores_score100_property_without_underscore(): void
{
    // Anti-regression sentinel: seeds the WRONG name (camelCase),
    // expects default. If someone reverts to `$row->score100`, it fails.
    $row = (object) [
        'id'       => 1,
        'score100' => 99.9,  // ← wrong key, must be ignored
        // ...
    ];

    $entity = ResultCompetency::from_row($row);

    self::assertSame(0.0, $entity->score_100());  // default, not 99.9
}
```

**Incorrect example:**
```php
#[Test]
public function from_row_hydrates_correctly(): void
{
    // seed uses internal PHP property name (camelCase),
    //    same string that `from_row` reads — bug and test match
    //    by coincidence without ever exercising the real path
    $row = (object) [
        'id'       => 1,
        'score100' => 75.5,
    ];

    $entity = ResultCompetency::from_row($row);
    self::assertSame(75.5, $entity->score_100());
    // CI green, but production returns 0.0 because the real column is `score_100`
}
```

**Minimum coverage per entity with hydration:**
1. **Happy path** — seed with canonical name of each field, assertion on each getter (at least the critical fields: identity, numeric values, status)
2. **Anti-regression sentinel** — for each field where PHP camelCase name != SQL snake_case column, a test that seeds the wrong name and expects default
3. **Dirty data tolerance** (TST-024 + Lesson #7) — `from_row_with_dirty_data_does_not_explode` seeding string in numeric field, invalid value in enum, etc.

Complementary automated mitigation: a static test that scans all `from_row()` in the project and cross-references `$row->XYZ` with the canonical SQL migration schema — if the column doesn't exist in the target table, it fails. This test is a follow-up PR tracked in incident 0008.

**Warning sign:** PR that adds/modifies `from_row()` in batch (>5 entities) without a test exercising the real path of each column; hydration test whose seed uses the internal PHP property name instead of the SQL column.

---

## Definition of Done — Delivery Checklist

> PRs that don't meet the DoD don't enter review. They are returned.

| # | Item | Rules | Verification |
|---|------|-------|--------------|
| 1 | Tests are in the correct pyramid layer | TST-001, TST-002 | Inspect directory of each test |
| 2 | Names describe behavior with context | TST-007, TST-008 | Inspect test method names |
| 3 | AAA pattern respected in all tests | TST-009 | Inspect structure of each test |
| 4 | Three paths covered: happy, invalid, boundary | TST-011 | Verify existence of all three types per behavior |
| 5 | Factories used, no fixtures | TST-012 | Search for `fixture`, `json`, `yaml` in tests |
| 6 | No loose duplicate values | TST-014 | Compare setup vs. assertion in each test |
| 7 | Unit tests without external dependency | TST-015 | Search for database, network, or filesystem access in `unit/` |
| 8 | Mocks only on dependencies, never on the subject | TST-020 | Inspect `createMock` — subject is never mocked |
| 9 | Deterministic tests | TST-022, TST-023 | Search for `time()`, `rand()`, `Date.now()`, `DateTimeImmutable()` without argument |
| 10 | Entities with FSM cover all states | TST-024 | Verify coverage of valid + invalid transitions |
| 11 | Endpoints cover security | TST-027 | Verify tests for authentication and authorization |
| 12 | All new code has tests | TST-005 | Compare code files vs. test files in the PR |
| 13 | Fixed bug has regression test | TST-004 | Verify that fix PR includes a test that reproduces the bug |
| 14 | No tests that test the framework | TST-030 | Inspect assertions — must test project code |
| 15 | No fantasy tests | TST-031 | Inspect scenarios — must reflect real use |
| 16 | Hydration proves real column name | TST-033 | Inspect `from_row()` tests — seed uses canonical SQL column + anti-regression sentinel for camelCase fields |
