---
document: security-standards
version: 2.1.0
created: 2025-06-01
updated: 2026-04-16
total_rules: 25
severities:
  error: 19
  warning: 6
stack: php
scope: Application and infrastructure security across all projects
applies_to: ["all"]
requires: []
replaces: ["security-standards v1 (previous version)"]
---

# Security Standards — your organization

> Constitutional document. Delivery contract for every
> developer who touches security in our projects.
> Code that violates ERROR rules is not discussed — it is returned.

---

## How to use this document

### For the developer

1. Read this entire document before opening your first PR involving data input, authentication, encryption, or infrastructure.
2. Use the rule IDs (SEG-001 to SEG-025) to reference in PRs and code reviews.
3. Check the DoD at the end before opening any Pull Request.

### For the auditor (human or AI)

1. Read the frontmatter to understand scope and dependencies.
2. Audit the code against each rule by ID.
3. Classify violations by the severity defined in this document.
4. Reference violations by rule ID (e.g., "violates SEG-011").

### For Claude Code

1. Read the frontmatter to determine if this document applies to the project in question.
2. In code review, check every ERROR rule as blocking — no merge while any violation exists.
3. WARNING rules should be reported, but accept a written justification in the PR.
4. Always reference by ID (e.g., "violates SEG-003") for traceability.

---

## Severities

| Level | Meaning | Action |
|-------|---------|--------|
| **ERROR** | Non-negotiable violation | Blocks merge. Fix before review. |
| **WARNING** | Strong recommendation | Must be justified in writing if ignored. |

---

## 1. SQL Injection

### SEG-001 — Parameterized queries are mandatory [ERROR]

**Rule:** Every query that receives variable data must use prepared statements with typed placeholders. No exceptions, regardless of language or framework.

**Checks:** `grep -rn` for direct interpolation in SQL strings (`"SELECT.*\$`, `"INSERT.*\$`, `"UPDATE.*\$`, `"DELETE.*\$`). Zero occurrences = pass.

**Why:** The project works with sensitive data across multiple projects — financial, personal, health. A single unparameterized query is a vector for catastrophic data leaks. A small team means there's no separate incident response team; whoever caused the problem is the one who'll be fixing it at 3 AM.

**Correct example:**
```php
// WordPress/PHP — using $wpdb->prepare()
$wpdb->get_results($wpdb->prepare(
    "SELECT * FROM {$this->tableName()} WHERE user_id = %d AND status = %s",
    $userId,
    $status
));
```

```python
# Python — using native parameterization
cursor.execute(
    "SELECT * FROM users WHERE id = %s AND status = %s",
    (user_id, status)
)
```

**Incorrect example:**
```php
// Direct injection — PROHIBITED in any language
$wpdb->get_results("SELECT * FROM {$table} WHERE user_id = {$userId}");
```

```python
# Direct interpolation — PROHIBITED
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")
```

**References:** SEG-002

---

### SEG-002 — No variable concatenation in SQL [ERROR]

**Rule:** Even if the variable seems safe (comes from another query, is an integer, was validated before), always use prepared statements. The rule is mechanical, not contextual.

**Checks:** `grep -rn` for variable concatenation in SQL (`$wpdb->query(".*{$`, `$wpdb->get_`). Any occurrence without `prepare()` = ERROR.

**Why:** Autonomous development with AI means code is generated and reviewed at high speed. Mechanical rules ("always prepare, don't think about it") eliminate the entire class of error. Relying on context requires human judgment that isn't always present during review.

**Correct example:**
```php
// Even for internal IDs — always prepare
$wpdb->get_row($wpdb->prepare(
    "SELECT * FROM {$this->tableName()} WHERE id = %d",
    $id
));
```

```javascript
// Node.js — always parameterized
const result = await db.query(
    "SELECT * FROM users WHERE id = $1",
    [id]
);
```

**Incorrect example:**
```php
// "Trusts" that the ID is safe — PROHIBITED
$wpdb->get_row("SELECT * FROM {$this->tableName()} WHERE id = {$id}");
```

**References:** SEG-001

---

## 2. Cross-Site Scripting (XSS)

### SEG-003 — Sanitize all user input [ERROR]

**Rule:** All data from external input (forms, query strings, request body, headers) must be sanitized before any use. Never use raw request data.

**Checks:** `grep -rn '\$_POST\|\$_GET\|\$_REQUEST\|\$_SERVER'` in handlers. Any occurrence without `sanitize_*`/`absint`/`esc_*` wrapper = ERROR.

**Why:** In the project, Claude Code generates code in volume. If sanitization isn't an absolute rule at the boundary, one forgotten handler is all it takes to open persistent XSS. Sensitive client data must not leak due to negligence in a single endpoint.

**Correct example:**
```php
// WordPress — sanitization functions at the boundary
$description = sanitize_text_field($_POST['description'] ?? '');
$amount = absint($_POST['amount'] ?? 0);
$url = esc_url_raw($_POST['url'] ?? '');
```

```python
# Python/Django — sanitization at the boundary
description = bleach.clean(request.POST.get('description', ''))
amount = int(request.POST.get('amount', 0))
```

**Incorrect example:**
```php
// Direct use without sanitization — PROHIBITED
$description = $_POST['description'];
$amount = $_POST['amount'];
```

---

### SEG-004 — Escape all output to the browser [ERROR]

**Rule:** All data displayed in HTML, attributes, or JavaScript must be escaped with the appropriate function for the rendering context. Never emit raw data to the browser.

**Checks:** `grep -rn 'echo \$'` in templates/views. Any output without `esc_html`/`esc_attr`/`esc_url`/`wp_json_encode` = ERROR.

**Why:** Projects handle financial and personal data displayed in dashboards. Reflected or persistent XSS on a balance or transaction screen is devastating for client trust. Escaping by context is a mechanical obligation.

**Correct example:**
```php
// WordPress — context-appropriate escaping
echo esc_html($entity->description());       // inside HTML tags
echo esc_attr($entity->name());              // inside attributes
echo esc_url($link);                         // in href/src
echo wp_json_encode($data);                  // in JavaScript context
```

```javascript
// JavaScript — use textContent, never innerHTML with variable data
element.textContent = userData.name;
```

**Incorrect example:**
```php
// Output without escaping — PROHIBITED
echo $entity->description();
echo "<a href='{$link}'>";
```

---

### SEG-005 — Allowlist, never blocklist [WARNING]

**Rule:** Validate against what is allowed, never against what is forbidden. An allowlist is finite and predictable; a blocklist is infinite and always incomplete.

**Checks:** Inspect input validations. Presence of an array of forbidden values without an array of allowed values = WARNING.

**Why:** A small team doesn't have the capacity to maintain blocklists updated against new attack vectors. Allowlist is "define once, protect forever". Blocklist is "forget one case, lose everything".

**Correct example:**
```php
// Allowlist — finite list of accepted values
$allowedTypes = ['income', 'expense', 'transfer'];
if (!in_array($type, $allowedTypes, true)) {
    throw new InvalidArgumentException('Invalid type.');
}
```

**Incorrect example:**
```php
// Blocklist — infinite list of forbidden values
$forbiddenTypes = ['hack', 'admin', 'drop'];
if (in_array($type, $forbiddenTypes, true)) {
    throw new InvalidArgumentException('Forbidden type.');
}
```

**Exceptions:** Spam or offensive content filters, where the nature of the problem requires a blocklist. Even then, combine with an allowlist when possible.

---

## 3. Cross-Site Request Forgery (CSRF)

### SEG-006 — CSRF token mandatory in every mutation handler [ERROR]

**Rule:** Every endpoint that receives a mutation request (POST, PUT, DELETE) from the frontend must validate a CSRF token before any processing.

**Checks:** `grep -rn 'function handle'` in mutation handlers. Each must contain `check_ajax_referer`/`wp_verify_nonce` or equivalent. Absence = ERROR.

**Why:** Projects operate with financial and personal data. A CSRF attack can transfer money, alter records, or delete data without the user knowing. A CSRF token is the minimum barrier against forged actions.

**Correct example:**
```php
// WordPress — nonce verification (WP's CSRF implementation)
public function handleCreateRecord(): void
{
    check_ajax_referer('app_nonce', 'nonce');
    // ... processing
}
```

```python
# Django — @csrf_protect or global middleware
@csrf_protect
def create_record(request):
    # ... processing
```

**Incorrect example:**
```php
// No CSRF verification — PROHIBITED
public function handleCreateRecord(): void
{
    $description = sanitize_text_field($_POST['description']);
    // processes directly, without verifying the request is legitimate
}
```

---

### SEG-007 — CSRF token is the first handler verification [ERROR]

**Rule:** CSRF verification comes before any other operation. Before sanitizing, before querying the database, before everything.

**Checks:** In each mutation handler, `check_ajax_referer` must be the first call of the method. Any operation before it = ERROR.

**Why:** If the request is forged, no processing should happen. Sanitizing input from an illegitimate request is waste and increases the attack surface. In the project, the verification order is law: authenticity first, permission second, data third.

**Correct example:**
```php
public function handleUpdate(): void
{
    // 1. CSRF
    check_ajax_referer('app_nonce', 'nonce');

    // 2. Permission (role/authorization)
    $this->checkPermission();

    // 3. Input sanitization
    $id = absint($_POST['id'] ?? 0);

    // 4. Business logic
    $this->manager->update($id);
}
```

**Incorrect example:**
```php
public function handleUpdate(): void
{
    // Sanitizes BEFORE verifying CSRF — wrong order
    $id = absint($_POST['id'] ?? 0);
    $this->manager->update($id);
    check_ajax_referer('app_nonce', 'nonce'); // too late
}
```

---

## 4. IDOR and access control

### SEG-008 — Verify resource ownership [ERROR]

**Rule:** Before reading, modifying, or deleting any resource, verify that the authenticated user is the owner or has explicit permission over that resource. Never trust an ID coming from the frontend.

**Checks:** In handlers that receive IDs from the frontend, look for `userId()` / `user_id` comparison with the authenticated user before the operation. Absence = ERROR.

**Why:** Projects store sensitive data from multiple users in the same database. An IDOR allows user A to access user B's data by swapping an ID in the request. In financial projects, this means seeing someone else's balances, transactions, and bank details.

**Correct example:**
```php
public function handleDelete(): void
{
    check_ajax_referer('app_nonce', 'nonce');
    $this->checkPermission();

    $recordId = absint($_POST['id'] ?? 0);
    $record = $this->repository->findById($recordId);

    if (!$record || $record->userId() !== $this->getCurrentUserId()) {
        throw new ForbiddenException('No permission.');
    }

    $this->manager->delete($recordId);
}
```

**Incorrect example:**
```php
public function handleDelete(): void
{
    $recordId = absint($_POST['id'] ?? 0);
    $this->manager->delete($recordId); // anyone can delete any record
}
```

---

### SEG-009 — Roles verified in every handler [ERROR]

**Rule:** Every handler that processes requests must define which roles have access and verify before processing. Without role verification, the endpoint is open to any authenticated user.

**Checks:** `grep -rn 'ALLOWED_ROLES\|checkPermission\|current_user_can\|permission_required'` in handlers. Handler without any role verification = ERROR.

**Why:** The project builds multi-role systems (admin, regular user, auditor). An endpoint without a role check is an open door for horizontal privilege escalation. A small team can't manually audit every endpoint — the mechanical rule of "every handler checks roles" eliminates the class of error.

**Correct example:**
```php
class RecordHandler
{
    private const ALLOWED_ROLES = ['admin', 'user'];

    private function checkPermission(): void
    {
        $user = $this->getCurrentUser();
        $hasRole = array_intersect(self::ALLOWED_ROLES, $user->roles);

        if (empty($hasRole)) {
            throw new ForbiddenException('No permission.');
        }
    }
}
```

```python
# Django — permission decorator
@permission_required('app.can_create_record')
def create_record(request):
    # ...
```

**Incorrect example:**
```php
// Handler without any role verification
class RecordHandler
{
    public function handle(): void
    {
        // any authenticated user executes
    }
}
```

---

### SEG-010 — No privilege escalation [ERROR]

**Rule:** Administrative actions (creating roles, changing permissions, accessing other users' data) must be restricted to specific roles. A regular user must never perform admin actions.

**Checks:** Endpoints that alter roles/permissions must require `admin` role or equivalent. `grep -rn 'setRole\|add_role\|promote'` — each occurrence must have an admin guard before it.

**Why:** In the project, each project defines roles with clear responsibilities. Privilege escalation means a regular user can become admin, alter others' data, or manipulate system settings. In projects with sensitive data, this is catastrophic.

**Correct example:**
```php
public function handleChangeRole(): void
{
    check_ajax_referer('app_nonce', 'nonce');

    if (!$this->isAdmin()) {
        throw new ForbiddenException('Only administrators can change roles.');
    }

    // ... change role
}
```

**Incorrect example:**
```php
public function handleChangeRole(): void
{
    // Any logged-in user can change roles
    $newRole = sanitize_text_field($_POST['role']);
    $this->userManager->setRole($userId, $newRole);
}
```

---

## 5. Sensitive data encryption

### SEG-011 — Sensitive data encrypted at rest [ERROR]

**Rule:** All sensitive data (monetary values, transaction descriptions, personal data, banking data, health data) must be encrypted before persisting to the database and decrypted after reading.

**Checks:** In repositories that persist sensitive fields, verify calls to `encrypt()` on `insert`/`update` and `decrypt()` on `hydrate`/`from_row`. Absence = ERROR.

**Why:** The project builds systems that store financial, personal, and health data. A database leak (SQL dump, exposed backup) without encryption at rest exposes all data in cleartext. Encryption at rest is the last line of defense.

**Correct example:**
```php
// Encryption in the repository — project standard
public function create(Entity $entity): int
{
    $this->db->insert($this->tableName(), [
        'amount_cents' => $this->crypto->encrypt((string) $entity->amountCents()),
        'description' => $this->crypto->encrypt($entity->description()),
    ]);

    return (int) $this->db->lastInsertId();
}

private function hydrate(object $row): Entity
{
    $row->amount_cents = (int) $this->crypto->decrypt($row->amount_cents);
    $row->description = $this->crypto->decrypt($row->description);
    return Entity::fromRow($row);
}
```

**Incorrect example:**
```php
// Sensitive data in cleartext in the database — PROHIBITED
$this->db->insert($this->tableName(), [
    'amount_cents' => $entity->amountCents(),
    'description' => $entity->description(),
]);
```

---

### SEG-012 — Robust and standardized encryption algorithm [WARNING]

**Rule:** The encryption implementation must use AES-256-CBC (or superior) with a random IV per operation. Never implement custom encryption.

**Checks:** `grep -rn 'openssl_encrypt\|Cipher\|aes'` — confirm use of `aes-256-cbc` or superior. `grep -rn 'base64_encode\|rot13\|md5\|sha1'` in an "encryption" context = WARNING.

**Why:** The project needs a consistent encryption standard across projects to facilitate auditing and maintenance. AES-256-CBC is widely supported, audited, and meets compliance requirements. Homegrown encryption is the fastest way to have illusory security.

**Correct example:**
```php
// PHP — openssl with random IV per operation
$iv = openssl_random_pseudo_bytes(openssl_cipher_iv_length('aes-256-cbc'));
$encrypted = openssl_encrypt($data, 'aes-256-cbc', $key, 0, $iv);
$result = base64_encode($iv . $encrypted);
```

```python
# Python — using cryptography (Fernet uses AES-128-CBC, for AES-256 use primitives)
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
import os
iv = os.urandom(16)
cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
```

**Incorrect example:**
```php
// ROT13, Base64 or homegrown "encryption" — PROHIBITED
$encrypted = base64_encode($data); // this is encoding, not encryption
$encrypted = str_rot13($data);     // this is a joke, not encryption
```

---

### SEG-013 — Encryption key in environment variable [ERROR]

**Rule:** The encryption key must exist exclusively in an environment variable (.env or equivalent). Never hardcoded, never as a constant in code, never in a versioned configuration file.

**Checks:** `grep -rn 'ENCRYPTION_KEY\|encryption_key'` in source code. Any occurrence that isn't `getenv`/`os.environ`/`process.env` = ERROR.

**Why:** Project repositories are accessed by developers and AI agents. A hardcoded key in the code means anyone with repo access has access to all encrypted data. Environment variables isolate the secret from the code.

**Correct example:**
```php
$key = getenv('APP_ENCRYPTION_KEY');
```

```python
import os
key = os.environ['APP_ENCRYPTION_KEY']
```

**Incorrect example:**
```php
// Key in source code — PROHIBITED
private const ENCRYPTION_KEY = 'my-secret-key';
define('APP_ENCRYPTION_KEY', 'key-in-code');
```

---

### SEG-014 — No secrets in source code [ERROR]

**Rule:** No API key, password, token, or secret must appear in source code or versioned files. Everything must be in environment variables (.env or equivalent).

**Checks:** `grep -rn 'sk_live\|sk_test\|password.*=.*["\x27]\|api_key.*=.*["\x27]\|secret.*=.*["\x27]'` in versioned files. Any match with a hardcoded literal value = ERROR.

**Why:** The project uses Git as the source of truth. A committed secret is a secret exposed forever (even after removal, it stays in history). With AI-assisted development, the risk increases — models can reproduce secrets seen in code in other contexts.

**Correct example:**
```php
$apiKey = getenv('PAYMENT_GATEWAY_KEY');
$dbPassword = getenv('DB_PASSWORD');
```

```javascript
const apiKey = process.env.PAYMENT_GATEWAY_KEY;
```

**Incorrect example:**
```php
$apiKey = 'sk_live_abc123def456';
define('DB_PASSWORD', 'super-secret-password');
```

```javascript
const apiKey = 'sk_live_abc123def456';
```

---

## 6. Boundary validation

### SEG-015 — Handler is the sole validation boundary [ERROR]

**Rule:** All input validation and sanitization must happen in the handler (controller, endpoint, action). Inner layers (services, repositories, entities) trust that data arrives clean. The responsibility to validate belongs exclusively to the boundary.

**Checks:** `grep -rn 'sanitize_\|absint\|esc_'` in services/repositories. Presence of sanitization outside the handler = ERROR (responsibility leaked from the boundary).

**Why:** In the project's architecture, separation of responsibilities is law. If validation is scattered across multiple layers, nobody knows where data is validated, and changes in one layer break assumptions in another. Single boundary = simple audit.

**Correct example:**
```
Request → Handler (validates, sanitizes) → Service → Repository → Database
                                                                      ↓
Response ← Handler (escapes output) ← Service ← Repository ← Database
```

**Incorrect example:**
```
Request → Handler (doesn't validate) → Service (partial validation) → Repository (validates again) → Database
// Nobody knows where validation actually happens
```

---

### SEG-016 — Validate type, format, and domain [ERROR]

**Rule:** Every input must be validated at three levels: type (int, string, array), format (date, email, currency), and domain (within allowed values).

**Checks:** Inspect each input in the handler. Must have: (1) type cast/sanitize, (2) format validation, (3) check against allowed values. Missing a level = ERROR.

**Why:** Incomplete validation is useless validation. Checking only type lets invalid formats through. Checking only format lets out-of-domain values through. In the project, corrupted data in the database is more expensive to fix than to prevent — a small team doesn't have the luxury of "fixing it later".

**Correct example:**
```php
$type = sanitize_text_field($_POST['type'] ?? '');

// Type: it's a string (sanitize_text_field ensures this)
// Format: not empty
if (empty($type)) {
    throw new ValidationException('Type is required.');
}

// Domain: is it in the allowed values
$allowedTypes = ['income', 'expense', 'transfer'];
if (!in_array($type, $allowedTypes, true)) {
    throw new ValidationException('Invalid type.');
}
```

**Incorrect example:**
```php
// Validates only the type, ignores format and domain
$type = sanitize_text_field($_POST['type'] ?? '');
// uses $type directly without checking if it's a valid value
```

---

### SEG-017 — Never trust frontend data [ERROR]

**Rule:** IDs, values, statuses — everything from the frontend is potentially manipulated. Always revalidate on the backend.

**Checks:** Request data used in business logic must go through backend validation. Input used without cast/validation = ERROR.

**Why:** Browser DevTools allow altering any value before sending. The frontend is convenience for the user, never a guarantee for the system. In the project, financial and personal data require the backend to be the absolute authority on validation.

**Correct example:**
```php
$amountCents = absint($_POST['amount_cents'] ?? 0);
if ($amountCents <= 0 || $amountCents > 99999999) {
    throw new ValidationException('Invalid amount.');
}
```

```python
amount_cents = int(request.POST.get('amount_cents', 0))
if amount_cents <= 0 or amount_cents > 99999999:
    raise ValidationError('Invalid amount.')
```

**Incorrect example:**
```php
// Trusts the frontend — PROHIBITED
$amountCents = $_POST['amount_cents']; // could be negative, string, SQL injection
```

---

## 7. File uploads

### SEG-018 — MIME type allowlist for uploads [ERROR]

**Rule:** Uploads must accept only explicitly allowed MIME types. Verification must be done on the actual file content, never just the extension.

**Checks:** In upload handlers, look for real MIME verification (`wp_check_filetype_and_ext`, `finfo_file`, `python-magic`). Verification only by extension or absent = ERROR.

**Why:** Upload verification only by extension allows a PHP file to be renamed to .jpg and executed on the server. In the project, where projects run on shared servers, a shell upload compromises all projects on the server.

**Correct example:**
```php
// WordPress — real MIME verification
$allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
$fileInfo = wp_check_filetype_and_ext($file['tmp_name'], $file['name']);

if (!in_array($fileInfo['type'], $allowedTypes, true)) {
    throw new ValidationException('File type not allowed.');
}
```

```python
# Python — real MIME verification with python-magic
import magic
mime = magic.from_file(file.temporary_file_path(), mime=True)
allowed_types = ['image/jpeg', 'image/png', 'image/webp']
if mime not in allowed_types:
    raise ValidationError('File type not allowed.')
```

**Incorrect example:**
```php
// Checks only the extension — PROHIBITED
$ext = pathinfo($file['name'], PATHINFO_EXTENSION);
if ($ext === 'jpg') { /* accepts */ }
// A malicious.php file renamed to malicious.jpg passes
```

---

### SEG-019 — Size limit per upload [ERROR]

**Rule:** Every upload must have a size limit defined and checked on the backend. Each project defines its limits as needed.

**Checks:** In upload handlers, look for `$file['size']` / `file.size` comparison against a limit constant. Absence of size verification on the backend = ERROR.

**Why:** Project servers have limited resources. Upload without a limit allows DoS by disk or memory exhaustion. A defined and backend-verified limit is mandatory — a frontend-only limit is bypassable via curl.

**Correct example:**
```php
$maxBytes = 2 * 1024 * 1024; // 2MB
if ($file['size'] > $maxBytes) {
    throw new ValidationException('File exceeds the 2MB limit.');
}
```

```python
if file.size > 2 * 1024 * 1024:
    raise ValidationError('File exceeds the 2MB limit.')
```

**Incorrect example:**
```php
// No limit — accepts upload of any size
move_uploaded_file($file['tmp_name'], $destination);
```

---

## 8. Infrastructure protection

### SEG-020 — Rate limiting on sensitive endpoints [WARNING]

**Rule:** Authentication, resource creation, and sensitive operation endpoints must have request limits per IP and/or per user.

**Checks:** `grep -rn 'limit_req\|RateLimiter\|throttle'` in server config and sensitive handlers. Login/creation endpoint without rate limiting = WARNING.

**Why:** A small team doesn't monitor logs 24/7. Rate limiting is automated defense against brute force and abuse. Without rate limiting, a bot can try thousands of passwords per minute or create thousands of fake records without anyone noticing in time.

**Correct example:**
```nginx
# Nginx — rate limiting by zone
limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;

location /api/login {
    limit_req zone=login burst=3 nodelay;
    # ...
}
```

**Incorrect example:**
```nginx
# Login endpoint without any rate limiting
location /api/login {
    proxy_pass http://backend;
    # any IP can make 1000 attempts per second
}
```

---

### SEG-021 — Security headers configured [WARNING]

**Rule:** The server must send the following security headers in every response:
- `Strict-Transport-Security` (HSTS)
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy` (restrictive)

**Checks:** `curl -sI https://domain | grep -iE 'strict-transport|x-content-type|x-frame|referrer-policy|permissions-policy'`. Each listed header absent = WARNING.

**Why:** Security headers are low-cost, high-impact defense. Configure once on the server and it protects all responses. In the project, where projects share infrastructure, standardized headers guarantee a consistent security baseline across projects.

**Correct example:**
```nginx
# Nginx — security headers
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
```

**Incorrect example:**
```nginx
# Server without any security headers
server {
    listen 443 ssl;
    # ... no security add_header
}
```

---

### SEG-022 — HTTPS mandatory [ERROR]

**Rule:** All production traffic must use HTTPS with TLS 1.2 or higher. HTTP must redirect 301 to HTTPS.

**Checks:** `curl -sI http://domain` must return `301` with `Location: https://`. `curl -sI https://domain` must connect with TLS 1.2+. Failure in either = ERROR.

**Why:** Financial and personal data travels between browser and server. HTTP in cleartext allows trivial interception (man-in-the-middle). In the project, HTTPS is not a differentiator — it's a minimum operational requirement.

**Correct example:**
```nginx
server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    ssl_protocols TLSv1.2 TLSv1.3;
    # ...
}
```

**Incorrect example:**
```nginx
# Serves content over HTTP without redirect
server {
    listen 80;
    server_name example.com;
    root /var/www/html;
    # sensitive data travels in cleartext
}
```

---

### SEG-023 — Sensitive files blocked on the server [WARNING]

**Rule:** The server must block direct access to sensitive files: `.env`, `.git`, `.htaccess`, `.sql`, `.bak`, `composer.json`, `composer.lock`, `package.json`, `package-lock.json`.

**Checks:** `curl -sI https://domain/.env` and `curl -sI https://domain/.git/config` must return 403 or 404. Any 200 = WARNING.

**Why:** An accessible `.env` via browser exposes all project keys. An exposed `.git` allows downloading the entire repository history. In the project, where multiple projects coexist on the same server, one exposed project compromises the credibility of all.

**Correct example:**
```nginx
# Nginx — block sensitive files
location ~ /\.(env|git|htaccess) {
    deny all;
    return 404;
}

location ~ \.(sql|bak)$ {
    deny all;
    return 404;
}
```

**Incorrect example:**
```nginx
# No blocking rules — .env accessible via browser
server {
    root /var/www/project;
    # https://project.com/.env returns the file contents
}
```

---

## 9. Webhooks and external APIs

### SEG-024 — Anti-spoofing validation in webhooks [ERROR]

**Rule:** Webhooks from external services (payment gateways, third-party APIs) must validate request authenticity before processing. Always query the originating service to confirm the received data.

**Checks:** In webhook handlers, look for a call to the origin API (e.g., `getPayment`, `verify_signature`) before processing data. Direct payload processing without verification = ERROR.

**Why:** A webhook is an open door to the world. Anyone who knows the URL can send forged data. In the project, where projects process payments and financial data, a fake webhook can register nonexistent payments or alter balances.

**Correct example:**
```php
// Validates with the origin API before processing
public function handleWebhook(): void
{
    $paymentId = sanitize_text_field($_POST['payment_id'] ?? '');

    // Queries the origin API to confirm
    $payment = $this->gateway->getPayment($paymentId);

    if (!$payment) {
        throw new SecurityException('Payment not found at the origin.');
    }

    // Processes with API data, not webhook data
    $this->manager->processPayment($payment);
}
```

**Incorrect example:**
```php
// Trusts webhook data without validating — PROHIBITED
public function handleWebhook(): void
{
    $data = json_decode(file_get_contents('php://input'), true);
    $this->manager->processPayment($data); // data could be forged
}
```

---

### SEG-025 — Replay attack protection [WARNING]

**Rule:** Webhooks must verify the request timestamp. Requests more than 5 minutes old must be rejected.

**Checks:** In webhook handlers, look for timestamp comparison (`abs(time() - $timestamp) > 300` or equivalent). Absence of temporal verification = WARNING.

**Why:** Replay attacks reuse a legitimate captured request. In financial projects, this could mean processing the same payment twice. Timestamp verification is a simple and effective defense against replay.

**Correct example:**
```php
$timestamp = (int) ($_POST['timestamp'] ?? 0);
$now = time();

if (abs($now - $timestamp) > 300) { // 5 minutes
    throw new SecurityException('Request expired.');
}
```

```python
import time
timestamp = int(request.POST.get('timestamp', 0))
if abs(time.time() - timestamp) > 300:
    raise SecurityError('Request expired.')
```

**Incorrect example:**
```php
// No timestamp verification — accepts requests from any time
public function handleWebhook(): void
{
    // processes without checking when the request was generated
    $this->process($_POST);
}
```

**Exceptions:** Webhooks from services that don't send timestamps. In that case, use an idempotency key to prevent duplicate processing.

---

## Definition of Done — Delivery Checklist

> PRs that don't meet the DoD don't enter review. They are returned.

| # | Item | Rules | Verification |
|---|------|-------|--------------|
| 1 | Parameterized queries in every database operation | SEG-001, SEG-002 | Search for variable concatenation in SQL in the diff |
| 2 | All input sanitized at the boundary | SEG-003, SEG-015 | Verify that handlers sanitize all request input |
| 3 | All output escaped by context | SEG-004 | Verify that data displayed in HTML/attributes/JS uses escaping |
| 4 | CSRF token validated as the first operation in mutation handlers | SEG-006, SEG-007 | Verify presence and position of CSRF validation |
| 5 | Ownership verified before reading/modifying/deleting a resource | SEG-008 | Verify that handlers compare resource userId with authenticated user |
| 6 | Roles defined and verified in every handler | SEG-009, SEG-010 | Verify presence of ALLOWED_ROLES and checkPermission |
| 7 | Sensitive data encrypted before persisting | SEG-011, SEG-012 | Verify that repositories encrypt sensitive fields |
| 8 | No hardcoded secrets in the code | SEG-013, SEG-014 | `grep -rn "password\|secret\|api_key\|token" src/` with no suspicious results |
| 9 | Three-level validation (type, format, domain) | SEG-016, SEG-017 | Verify that handlers validate type + format + domain for each input |
| 10 | Uploads with MIME allowlist and size limit | SEG-018, SEG-019 | Verify real MIME verification and byte limit |
| 11 | HTTPS mandatory with TLS 1.2+ | SEG-022 | Verify server configuration and HTTP→HTTPS redirect |
| 12 | Security headers configured | SEG-021 | `curl -I https://domain` and verify mandatory headers |
| 13 | Sensitive files blocked | SEG-023 | `curl https://domain/.env` returns 404 |
| 14 | Webhooks with anti-spoofing validation | SEG-024 | Verify that handler queries the origin API before processing |
| 15 | Allowlist preferred over blocklist in validations | SEG-005, SEG-025 | Verify that validations use a list of allowed values |
