---
name: audit-security
description: Audits PHP code security in the open PR against the rules defined in docs/security-standards.md. Covers SQL injection, XSS, CSRF, IDOR, encryption, and validation. Manual trigger only.
---

# /audit-security — Security Auditor

Reads the rules from `docs/security-standards.md`, identifies PHP files changed in the open (unmerged) PR, and compares each file against every applicable security rule. Focuses on: SQL injection, XSS, CSRF, IDOR, sensitive data encryption, boundary validation, uploads, and webhooks.

Complements `/audit-php` (syntax), `/audit-oop` (architecture), and `/audit-tests` (tests).

## When to use

- **ONLY** when the user explicitly types `/audit-security`.
- Run before merging a PR — acts as a security gate.
- **Never** trigger automatically, nor as part of another skill.

## Minimum required standards

> This section contains the complete standards used by the audit. Edit to customize for your project.

# Security standards

## Description

Reference document for security auditing in the project. Defines mandatory rules to protect sensitive data, prevent attacks, and ensure system integrity. The `/audit-security` skill reads this document and compares it against the target code.

## Scope

- All PHP code in the project
- HTTP/AJAX/REST handlers, repositories, page templates
- Infrastructure configurations when applicable

## References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- `docs/php-standards.md` — Complementary PHP security rules

## Severity

- **ERROR** — Violation blocks approval. Must be fixed before merge.
- **WARNING** — Strong recommendation. Must be justified if ignored.

---

## 1. SQL Injection

### SEG-001 — Parameterized queries required [ERROR]

Every query that receives variable data uses prepared statements with typed placeholders. No exceptions.

```php
// correct
$db->prepare("SELECT * FROM {$table} WHERE user_id = ? AND status = ?", [$userId, $status]);

// incorrect — direct injection
$db->query("SELECT * FROM {$table} WHERE user_id = {$userId}");
```

### SEG-002 — No variable concatenation in SQL [ERROR]

Even if the variable seems safe, always use prepared statements. The rule is mechanical, not contextual.

---

## 2. Cross-Site Scripting (XSS)

### SEG-003 — Sanitize all user input [ERROR]

All data from `$_POST`, `$_GET`, `$_REQUEST`, or request body is sanitized before any use.

```php
// correct — sanitization at the boundary
$description = filter_var($_POST['description'] ?? '', FILTER_SANITIZE_SPECIAL_CHARS);
$value = filter_var($_POST['value'] ?? 0, FILTER_VALIDATE_INT);
```

### SEG-004 — Escape all output to the browser [ERROR]

All data displayed in HTML, attributes, or JavaScript is escaped with the appropriate function.

```php
// correct — context-appropriate escaping
echo htmlspecialchars($order->description(), ENT_QUOTES, 'UTF-8');   // inside HTML tags
echo htmlspecialchars($account->name(), ENT_QUOTES, 'UTF-8');         // inside attributes
echo json_encode($data, JSON_HEX_TAG | JSON_HEX_AMP);                // in JavaScript context
```

### SEG-005 — Allowlist, never blocklist [WARNING]

Validate against what is permitted, not against what is forbidden.

```php
// correct — allowlist
$allowedTypes = ['sale', 'exchange', 'return'];
if (!in_array($type, $allowedTypes, true)) {
    throw new InvalidTypeException();
}
```

---

## 3. Cross-Site Request Forgery (CSRF)

### SEG-006 — CSRF token required in every handler [ERROR]

Every endpoint that receives a frontend request validates a CSRF token before any processing.

### SEG-007 — CSRF token is the first verification in the handler [ERROR]

Token verification comes before any other operation. Before sanitizing, before querying the database, before anything.

```php
// correct — verification order
public function handleUpdateAccount(): void
{
    // 1. CSRF token
    $this->verifyToken($_POST['csrf_token'] ?? '');

    // 2. Permission
    $this->verifyPermission();

    // 3. Input sanitization
    $accountId = (int) ($_POST['account_id'] ?? 0);

    // 4. Logic
    $this->manager->updateAccount($accountId);
}
```

---

## 4. IDOR and access control

### SEG-008 — Verify resource ownership [ERROR]

Before reading, modifying, or deleting any resource, verify that the logged-in user owns that resource. Never trust IDs from the frontend.

```php
// correct — verifies ownership
$order = $this->repository->findById($orderId);

if (!$order || $order->userId() !== $this->currentUser()->id()) {
    throw new UnauthorizedException();
}
```

### SEG-009 — Roles verified in every handler [ERROR]

Every handler defines allowed roles and verifies them before processing.

### SEG-010 — No privilege escalation [ERROR]

Administrative actions are restricted to specific roles. A regular user never executes an administrator action.

---

## 5. Sensitive data encryption

### SEG-011 — Sensitive data encrypted at rest [ERROR]

All sensitive data is encrypted before persisting to the database and decrypted after reading.

### SEG-012 — Modern encryption algorithm [WARNING]

The encryption class uses modern, audited algorithms (e.g., AES-256-GCM, XChaCha20-Poly1305).

### SEG-013 — Encryption key in .env [ERROR]

The encryption key lives exclusively in `.env`. Never hardcoded, never in a PHP constant, never in a versioned configuration file.

### SEG-014 — No secrets in source code [ERROR]

No API key, password, token, or secret appears in PHP, JavaScript, CSS, or any versioned file. Everything lives in `.env`.

---

## 6. Boundary validation

### SEG-015 — Handler is the only boundary [ERROR]

All input validation and sanitization happens in the handler. Managers, repositories, and entities trust that data arrives clean.

### SEG-016 — Validate type, format, and domain [ERROR]

Every input is validated at three levels:
1. **Type** — is it int, string, array?
2. **Format** — is it in the expected format?
3. **Domain** — is it within the allowed values?

### SEG-017 — Never trust frontend data [ERROR]

IDs, values, statuses — everything from the frontend is potentially manipulated. Revalidate on the backend.

---

## 7. File uploads

### SEG-018 — MIME type allowlist [ERROR]

Uploads accept only explicitly allowed MIME types. Real content verification, not just extension checking.

### SEG-019 — Size limit per upload [ERROR]

Every upload has a defined size limit.

---

## 8. Infrastructure protection

### SEG-020 — Rate limiting on sensitive endpoints [WARNING]

Authentication endpoints, resource creation, and critical operations have request limits per IP/user.

### SEG-021 — Security headers [WARNING]

The server must send the following headers:
- `Strict-Transport-Security` (HSTS)
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Referrer-Policy: strict-origin-when-cross-origin`

### SEG-022 — HTTPS required [ERROR]

All production traffic uses HTTPS with TLS 1.2+.

### SEG-023 — Sensitive files blocked on the server [WARNING]

The server blocks direct access to: `.env`, `.git`, `.sql`, `.bak`, `composer.json`, `composer.lock`.

---

## 9. Webhooks and external APIs

### SEG-024 — Anti-spoofing validation on webhooks [ERROR]

Webhooks from external services validate request authenticity before processing.

### SEG-025 — Replay attack protection [WARNING]

Webhooks verify request timestamp. Requests delayed by more than 5 minutes are rejected.

---

## Audit checklist

The `/audit-security` skill must verify, for each file:

**SQL Injection:**
- [ ] Parameterized queries in every query with variable data
- [ ] No variable concatenation in SQL

**XSS:**
- [ ] All input sanitized
- [ ] All output escaped

**CSRF:**
- [ ] CSRF token verified in every handler
- [ ] CSRF token is the first verification in the handler

**IDOR and access:**
- [ ] Resource ownership verified before read/modify/delete
- [ ] Roles defined and verified in every handler
- [ ] No privilege escalation

**Encryption:**
- [ ] Sensitive data encrypted at rest
- [ ] Encryption key in .env, never in code
- [ ] No hardcoded secrets in any versioned file

**Validation:**
- [ ] Handler is the only validation boundary
- [ ] Type, format, and domain validated
- [ ] No frontend data used without revalidation

**Upload:**
- [ ] MIME type allowlist with real verification
- [ ] Size limit defined

**Infrastructure:**
- [ ] HTTPS required
- [ ] Security headers configured

**Webhooks:**
- [ ] Anti-spoofing validation
- [ ] Replay attack protection

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
5. Filter only `.php` files from the project.

### Phase 3 — Audit file by file

For each PHP file changed in the PR:

1. Read the complete file (not just the diff — context matters).
2. Compare against **every rule** from `docs/security-standards.md`, one by one, in document order.
3. For each violation found, record:
   - **File** and **line(s)** where it occurs
   - **Rule ID** violated (e.g., security-standards.md, SEG-008)
   - **Severity** (ERROR or WARNING)
   - **Vulnerability type** (SQL injection, XSS, CSRF, IDOR, encryption, validation)
   - **What's wrong** — concise description
   - **How to fix** — specific correction for that snippet
4. If the file violates no rules, record as approved.

### Phase 4 — Report

Present the report to the user in the standard format with violations table (Line, Rule, Severity, Type, Description, Fix).

### Phase 5 — Correction plan

If there are ERROR violations:

1. List the necessary corrections grouped by vulnerability type.
2. Order by risk (SQL injection and IDOR first, headers last).
3. Ask the user: "Would you like me to apply the corrections now?"

## Rules

- **Never change code during the audit.** The skill is read-only until the user explicitly requests correction.
- **Never audit files outside the PR.** Only PHP files changed in the open PR.
- **Always reference the violated rule ID.** The report must be traceable to the standards document.
- **Never invent rules.** The ruleset is exclusively `docs/security-standards.md`.
- **Be methodical and procedural.** Each file is compared against each rule, in document order, without skipping.
- **Fidelity to the document.** If the code violates a rule in the document, report it. If the document doesn't cover the case, don't report it.
- **Prioritize by risk.** In the report, SQL injection and IDOR come before headers and rate limiting.
- **Show the complete report before any action.** Never apply corrections without explicit approval.
