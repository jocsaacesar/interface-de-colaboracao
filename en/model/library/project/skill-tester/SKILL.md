---
name: skill-tester
description: Test creation skill for projects. Analyzes implemented code, identifies coverage gaps, and creates tests following the 5-layer pyramid. Manual trigger only.
---

# /skill-tester — Test Creator

Analyzes the implemented code in the project, identifies coverage gaps, and creates tests following the 5-layer pyramid (unit, component, integration, API, functional). Ensures complete coverage of FSM, CRUD, security, and critical flows.

## When to use

- After implementation of new code (complements `skill-executor`).
- When the user asks to create tests for a specific module.
- When a test audit (`/audit-tests`) finds gaps.
- **Never** trigger automatically.

## Process

### Phase 1 — Analyze the target code

1. Read the code that needs tests.
2. Identify the correct layer in the pyramid:
   - **Entity/Value Object** -> unit tests
   - **Manager** -> component tests (with mocks)
   - **Repository** -> integration tests (with real database)
   - **Handler** -> API tests (request/response)
   - **Page/template** -> functional tests
3. Consult `docs/test-standards.md` for the rules of each layer.

### Phase 2 — Plan coverage

For each class/module, list the necessary tests:

**Entities with FSM:**
- [ ] Each valid transition
- [ ] Each invalid transition (throws exception)
- [ ] Each state predicate
- [ ] Construction with valid parameters
- [ ] Construction with invalid parameters
- [ ] `fromRow()` with clean data
- [ ] `fromRow()` with dirty data (doesn't explode)
- [ ] `toArray()` returns all fields

**Managers:**
- [ ] Calls correct repository methods
- [ ] Throws exception when entity not found
- [ ] Delegates domain logic to the entity

**Repositories:**
- [ ] `create()` persists and returns ID
- [ ] `findById()` returns correct entity
- [ ] `findById()` returns null when not found
- [ ] `update()` persists changes
- [ ] `delete()` removes record
- [ ] Encrypted data is decrypted on read

**Handlers:**
- [ ] Request without authentication is rejected
- [ ] Request with invalid role is rejected
- [ ] Request with missing data returns error
- [ ] Valid request returns success
- [ ] Manager exceptions are caught

### Phase 3 — Implement tests

1. Create factories when necessary.
2. Implement each test following the AAA pattern (Arrange, Act, Assert).
3. Name tests following the pattern: `test` + action + context + result.
4. Ensure each test is deterministic and isolated.
5. One assertion per unit/component test. Up to 3 in integration/API/functional.

### Phase 4 — Validate

1. Run the test suite:
   ```bash
   composer test
   ```
2. Verify that all pass.
3. Verify that no test is SKIPPED (skipped is not green).
4. Present results to the user.

## Rules

- **Three paths required.** Every tested behavior covers: happy, invalid, boundary.
- **Factories, never fixtures.** Use factories to create test objects.
- **Minimal data.** Each test builds strictly the minimum needed.
- **No duplicate values.** Never repeat literals between setup and assertion. Read from the object.
- **Tests simulate real conditions.** Don't test invented scenarios.
- **No fantasy tests.** Don't test impossible scenarios.
- **No tests that test the framework.** Test our code, not PHP's.
- **Deterministic.** No time(), rand(), DateTimeImmutable without argument.
- **Isolated.** No dependency on external state or other tests.
- **Correct layer.** A test that accesses the database is not a unit test. A test that mocks everything is not an integration test.
