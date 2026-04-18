---
document: rest-api-standards
version: 2.1.0
created: 2026-04-13
updated: 2026-04-16
total_rules: 14
severities:
  error: 10
  warning: 4
scope: Standardization of REST API endpoints across all projects
applies_to: ["all"]
requires: ["security-standards", "php-standards"]
replaces: []
---

# REST API Standards — your organization

> Constitutional document. Delivery contract for every
> developer who touches REST endpoints in our projects.
> Code that violates ERROR rules is not discussed — it is returned.

---

## How to use this document

### For the developer

1. Read this entire document before creating or modifying REST endpoints.
2. Use the rule IDs (API-001 to API-008) to reference in PRs and code reviews.
3. Check the DoD at the end before opening any Pull Request.

### For the auditor (human or AI)

1. Read the frontmatter to understand scope and dependencies.
2. Audit the code against each rule by ID.
3. Classify violations by the severity defined in this document.
4. Reference violations by rule ID (e.g., "violates API-003").

### For Claude Code

1. Read the frontmatter to determine if this document applies to the project in question.
2. In code review, check every ERROR rule as blocking — no merge while any violation exists.
3. WARNING rules should be reported, but accept a written justification in the PR.
4. Always reference by ID (e.g., "violates API-001") for traceability.

---

## Severities

| Level | Meaning | Action |
|-------|---------|--------|
| **ERROR** | Non-negotiable violation | Blocks merge. Fix before review. |
| **WARNING** | Strong recommendation | Must be justified in writing if ignored. |

---

## 1. Namespace and Organization

### API-001 — Namespace = authentication contract [ERROR]

**Rule:** Each REST namespace represents an **authentication domain** with its own contract. Endpoints with different auth mechanisms NEVER share a namespace. Endpoints with the same auth mechanism MUST be in the same namespace.

**Checks:** `grep -rn "register_rest_route" inc/` — group by namespace and confirm that all endpoints in a namespace use the same `permission_callback`.

**Valid namespaces in the project:**

| Namespace | Auth | Who calls | Example |
|-----------|------|-----------|---------|
| `app/v1` | WP nonce/session | Authenticated frontend | `/profile`, `/dashboard` |
| `auth/v1` | OAuth state token + redirect | Identity providers (Google) | `/google/connect` |
| `store/v1` | OAuth state token + redirect | Payment providers (MP) | `/mercadopago/oauth/*` |
| `map/v1` | Session / HMAC-SHA256 | Browser + external webhooks | `/pdf/generate`, `/webhook/mercadopago` |
| `game/v1` | API key (header) | External game clients | `/result`, `/ranking/{slug}` |

**Why:** A namespace is a public contract. Anyone consuming `game/v1` knows they need `X-Play-API-Key`. Anyone consuming `app/v1` knows they need a WP nonce. Mixing API key auth with WP nonce in the same namespace confuses the consumer and makes auditing harder — the auditor doesn't know which `permission_callback` to expect.

**Correct example:**
```php
// play/v1 — every endpoint uses API key
register_rest_route('game/v1', '/resultado', [
    'methods'             => 'POST',
    'callback'            => [$this, 'handle_resultado'],
    'permission_callback' => [$this, 'check_api_key'],
]);
```

**Incorrect example:**
```php
// VIOLATION: API key endpoint mixed with WP nonce endpoints
register_rest_route('app/v1', '/play/resultado', [
    'methods'             => 'POST',
    'callback'            => [$this, 'handle_resultado'],
    'permission_callback' => [$this, 'check_api_key'], // different auth from the rest of the namespace
]);
```

**Creating a new namespace requires:** justification that the auth mechanism is incompatible with existing namespaces + PR approval.

---

## 2. Rate Limiting

### API-002 — Every endpoint with mutation MUST have rate limiting [ERROR]

**Rule:** POST, PUT, PATCH, and DELETE endpoints MUST have rate limiting. Recommended limits by type:

**Checks:** `grep -rn "rate_limiter\|RateLimiter" inc/` — every mutation handler must call `rate_limiter->allow()` before processing.

| Type | Limit |
|------|-------|
| Login/Auth | 5 req/min per IP |
| Authenticated mutation | 30 req/min per user |
| External webhook | 60 req/min per IP |
| Upload | 10 req/min per user |

**Why:** Without rate limiting, an automated script can create 10,000 orders, send 50,000 emails, or crash the database with mass INSERTs. Rate limiting is the first layer of defense against abuse.

**Correct example:**
```php
public function handle_transfer_license(\WP_REST_Request $request): \WP_REST_Response
{
    if (!$this->rate_limiter->allow('license_transfer', get_current_user_id(), 10, 60)) {
        return new \WP_REST_Response(
            ['error' => 'Too many requests. Wait 1 minute.', 'code' => 'RATE_LIMITED'],
            429
        );
    }
    // ...
}
```

### API-004 — Public endpoints MUST have rate limiting by IP [WARNING]

**Rule:** Endpoints accessible without authentication MUST have rate limiting by IP. Recommended limits: 30 req/min for reads, 5 req/min for writes.

**Checks:** Endpoints with `permission_callback => '__return_true'` must have `rate_limiter->allow()` by IP.

**Why:** Public endpoints are accessible by any bot, crawler, or attacker. Without rate limiting by IP, a single actor can consume 100% of the server's resources.

---

## 3. Tenant Isolation

### API-003 — Every endpoint MUST filter by the authenticated user's tenant_id [ERROR]

**Rule:** Every authenticated REST endpoint MUST filter data by the user's `tenant_id`. Endpoints that return lists MUST filter by tenant. Endpoints that receive IDs MUST validate that the resource belongs to the user's tenant.

**Checks:** Inspect REST callbacks — every query must include `tenant_id` and every received ID must have an ownership check.

**Why:** REST API is the system boundary — where IDOR attacks happen. If an endpoint returns data without a tenant filter, any authenticated user sees data from all tenants.

**Correct example:**
```php
public function handle_list_orders(\WP_REST_Request $request): \WP_REST_Response
{
    $tenant_id = current_tenant_id();
    $orders = $this->orderRepo->find_by_tenant($tenant_id);
    // ...
}
```

---

## 4. Response Format

### API-005 — Error responses MUST follow a standardized format [ERROR]

**Rule:** Every error response (4xx, 5xx) MUST follow this format:

**Checks:** `grep -rn "WP_REST_Response\|wp_send_json_error" inc/` — every error response must have `error`, `code`, and `status` fields.

```json
{
    "error": "Human-readable error description",
    "code": "MACHINE_CODE",
    "status": 422
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `error` | `string` | Yes | Human-readable message for the frontend |
| `code` | `string` | Yes | Machine code for switch/case in the client |
| `status` | `int` | Yes | HTTP status code mirrored in the body |

**Why:** A consistent format allows the frontend to handle errors uniformly. Without a standard, each endpoint invents its own format and the frontend needs N parsers.

**Standardized codes:**

| Code | Status | Meaning |
|------|--------|---------|
| `VALIDATION_ERROR` | 422 | Invalid data |
| `NOT_FOUND` | 404 | Resource not found |
| `UNAUTHORIZED` | 401 | Not authenticated |
| `FORBIDDEN` | 403 | No permission |
| `RATE_LIMITED` | 429 | Too many requests |
| `CONFLICT` | 409 | Conflicting state |
| `INTERNAL_ERROR` | 500 | Internal error |

### API-006 — Deprecated endpoints MUST return 410 Gone [WARNING]

**Rule:** Endpoints being removed MUST go through a deprecation cycle:
1. `Deprecation: true` + `Sunset: <date>` headers for 90 days
2. After the sunset date: return `410 Gone` with a body indicating the replacement endpoint

**Checks:** `grep -rn "Deprecation\|Sunset\|410" inc/` — endpoints marked for removal must have deprecation headers or status 410.

**Why:** Abrupt endpoint removal breaks integrations. 410 is explicit — the client knows the endpoint is dead and where to go.

---

## 5. Security

### API-007 — Webhooks MUST validate signatures before processing [ERROR]

**Rule:** Every webhook endpoint that receives payloads from external services (Mercado Pago, Brevo, etc.) MUST validate signature/authenticity before processing. Minimum: verification via the service's API (anti-spoofing). Ideal: HMAC signature validation.

**Checks:** `grep -rn "webhook\|handle_webhook" inc/` — every webhook handler must validate a signature or query the origin API before processing the payload.

**Why:** A webhook without validation accepts any payload. An attacker can forge an approved payment notification and grant unauthorized access. The Mercado Pago webhook already does anti-spoofing via API query — maintain that pattern.

**Correct example (anti-spoofing):**
```php
public function handle_webhook(\WP_REST_Request $request): \WP_REST_Response
{
    $payment_id = $request->get_param('data')['id'] ?? null;
    if (!$payment_id) {
        return new \WP_REST_Response(['error' => 'Invalid payload'], 400);
    }

    // Anti-spoofing: query the MP API before processing
    $payment = $this->mp_client->get_payment($payment_id);
    if (!$payment) {
        return new \WP_REST_Response(['error' => 'Payment not found in API'], 404);
    }
    // ... process with data from the API, not from the webhook
}
```

### API-008 — Input validation with sanitization and limits [ERROR]

**Rule:** Every field received via REST MUST be sanitized by type and have a defined length limit. Fields without a limit are a DoS vector via giant payload. No exceptions — an endpoint that accepts strings without sanitization does not merge.

**Checks:** Inspect every `$request->get_param()` — must have `sanitize_text_field()`/`absint()`/`sanitize_email()` and `strlen()` check immediately after.

**Why:** `POST /api/endpoint` with a 10MB body without size validation can stall the PHP-FPM worker. Sanitization prevents XSS and injection. Limits prevent storage and memory abuse.

**Sanitization by type (mandatory):**

| Field type | Sanitizer | Limit |
|------------|-----------|-------|
| Name / title | `sanitize_text_field()` | 255 chars |
| Slug | `sanitize_text_field()` | 100 chars |
| Short description | `sanitize_text_field()` | 500 chars |
| Long text / HTML | `wp_kses_post()` | 5000 chars |
| Email | `sanitize_email()` + `is_email()` | 320 chars |
| URL | `esc_url()` | 2048 chars |
| Integer | `(int)` cast + `min()`/`max()` bounds | Explicit range |
| JSON payload | `json_decode()` + structure validation | 64 KB |

**Correct example:**
```php
$score     = min(max((int) ($params['score'] ?? 0), 0), $score_max);  // clamped
$name      = sanitize_text_field($params['name'] ?? '');
$email     = sanitize_email($params['email'] ?? '');
if (empty($name) || strlen($name) < 3) { /* reject */ }
if (!is_email($email)) { /* reject */ }
```

---

## 6. Endpoint Protection

### API-009 — Every endpoint MUST have an explicit permission_callback [ERROR]

**Rule:** Every `register_rest_route()` MUST declare a `permission_callback`. Use `'__return_true'` only for genuinely public endpoints. NEVER omit the field — WordPress accepts omission but logs a warning and exposes the endpoint without protection.

**Checks:** `grep -A5 "register_rest_route" inc/` — every registration must contain `permission_callback`. Absence is a violation.

**Why:** Omitting `permission_callback` creates an open endpoint that doesn't appear in automated audits. Forcing `'__return_true'` makes the decision explicit and auditable.

**Correct example:**
```php
register_rest_route('game/v1', '/ranking/(?P<slug>[a-z0-9-]+)', [
    'methods'             => 'GET',
    'callback'            => [$this, 'handle_ranking'],
    'permission_callback' => [$this, 'check_api_key'],  // explicit
]);
```

**Incorrect example:**
```php
// VIOLATION: permission_callback omitted — silently open endpoint
register_rest_route('mapa/v1', '/dados', [
    'methods'  => 'GET',
    'callback' => [$this, 'handle_dados'],
]);
```

### API-010 — Numeric values MUST be clamped with an explicit range [ERROR]

**Rule:** Every integer or float received from the client MUST be clamped with `min()`/`max()` to a valid range defined by business rules. Cast without clamp is not validation — it transforms garbage into a number, but doesn't guarantee sanity.

**Checks:** `grep -rn "(int)" inc/` in REST handlers — every integer cast must have `min(max(...))` on the same or nearby line.

**Why:** `score = (int) $params['score']` accepts `-2147483648` or `999999999` without complaining. Without clamping, the database stores absurd values and derived calculations (ranking, average, prize) break silently.

**Correct example:**
```php
$score     = (int) ($params['score'] ?? 0);
$score_max = (int) ($params['score_max'] ?? 0);
if ($score_max <= 0) { /* reject */ }
$score = min(max($score, 0), $score_max);  // 0 <= score <= score_max
```

**Incorrect example:**
```php
// VIOLATION: cast without clamp — accepts any integer
$score = (int) $params['score'];
$limit = (int) $request->get_param('limit');  // could be 999999
```

### API-011 — Validation MUST happen before any side effect [ERROR]

**Rule:** Every endpoint MUST validate all input fields BEFORE touching the database, filesystem, external API, or any resource with side effects. Pattern: validation block -> accumulate errors -> return 400/422 with all errors at once. NEVER validate field by field with early returns that hide subsequent errors.

**Checks:** Inspect handlers — the validation block must come before any `$this->wpdb->` or `$repo->`. No INSERT/UPDATE before complete validation.

**Why:** If field 3 validation does an INSERT before checking field 5, a partially valid input leaves garbage in the database. Also, returning errors field by field forces the client to make N requests to get it right — returning everything at once shows respect for the consumer.

**Correct example:**
```php
$errors = [];
if (empty($game_slug)) { $errors[] = 'game_slug is required.'; }
if (empty($name) || strlen($name) < 3) { $errors[] = 'name must be at least 3 characters.'; }
if (!is_email($email)) { $errors[] = 'invalid email.'; }
if ($score_max <= 0) { $errors[] = 'score_max must be > 0.'; }

if (!empty($errors)) {
    return new \WP_REST_Response([
        'error'  => implode(' ', $errors),
        'code'   => 'VALIDATION_ERROR',
        'status' => 422
    ], 422);
}
// Now: touch the database
```

### API-012 — Optional JSON MUST be validated in structure before persisting [ERROR]

**Rule:** Fields that accept JSON from the client (arrays, objects, metadata) MUST: (1) verify it's an `array` after decode, (2) sanitize each internal value, (3) re-encode with `wp_json_encode()`. NEVER persist raw client JSON without inspection.

**Checks:** `grep -rn "json_encode\|wp_json_encode" inc/` — all persisted JSON must come from `wp_json_encode()` with data previously validated with `is_array()` and sanitized.

**Why:** JSON is a free-form payload — the client can send arbitrary structure, including HTML, scripts, or gigabytes of nesting. Without structure validation, the database becomes a garbage dump and the frontend rendering the JSON inherits XSS.

**Correct example:**
```php
$data_json = '{}';
if (isset($params['data']) && is_array($params['data'])) {
    $data_json = wp_json_encode($params['data']);
}

$device_json = '{}';
if (isset($params['device']) && is_array($params['device'])) {
    $device_json = wp_json_encode(array_map('sanitize_text_field', $params['device']));
}
```

**Incorrect example:**
```php
// VIOLATION: Client JSON straight to the database without inspection
$this->wpdb->insert($table, [
    'data_json' => json_encode($params['data']),
]);
```

### API-013 — Success responses MUST follow a standardized format [WARNING]

**Rule:** Success responses (2xx) MUST include a `success: true` field at the payload root. Returned data lives in named fields (not in a generic root `data`). IDs of created resources MUST be returned.

**Checks:** `grep -rn "WP_REST_Response" inc/` — 2xx responses must contain `'success' => true` and named fields.

**Why:** A frontend consuming N different endpoints needs a predictable contract. `success: true` + named fields allows uniform handling without inspecting HTTP status.

**Correct example:**
```php
return new \WP_REST_Response([
    'success'    => true,
    'session_id' => $session_id,
    'prize'      => [
        'type'        => 'coins',
        'description' => '10 silver coins!',
        'message'     => 'Congratulations! Your prize has been credited.',
    ],
], 200);
```

### API-014 — External endpoints MUST document integration contracts [WARNING]

**Rule:** Every endpoint consumed by an external client (game, mobile app, third-party integration) MUST have a documented contract in `docs/modules/rest-api.md` including: URL, method, mandatory headers, body schema (fields, types, required, limits), response schema (success + error), and example request/response.

**Checks:** List endpoints with API key or public `permission_callback` — each must have a corresponding entry in `docs/modules/rest-api.md`.

**Why:** An internal endpoint can be discovered by reading the code. An external endpoint is consumed by someone who does NOT have code access — without documentation, integration becomes trial and error.

---

## DoD — Definition of Done (REST API)

Before opening a PR that creates or modifies REST endpoints:

- [ ] Correct namespace for the auth domain (API-001)
- [ ] Mutation endpoints have rate limiting (API-002)
- [ ] Endpoints filter by tenant_id (API-003)
- [ ] Public endpoints have rate limiting by IP (API-004)
- [ ] Error responses follow standardized format (API-005)
- [ ] Deprecated endpoints return 410 (API-006)
- [ ] Webhooks validate signatures (API-007)
- [ ] Inputs sanitized by type with length limits (API-008)
- [ ] Explicit `permission_callback` in every `register_rest_route` (API-009)
- [ ] Numeric values clamped with min/max (API-010)
- [ ] Complete validation before any side effect (API-011)
- [ ] Client JSON validated in structure and sanitized before persisting (API-012)
- [ ] Success response with `success: true` + named fields (API-013)
- [ ] External endpoints with documented contract (API-014)

---

## Versioning

| Version | Date | Author | Change |
|---------|------|--------|--------|
| 1.0.0 | 2026-04-13 | Team | Creation — 8 rules (5 ERROR, 3 WARNING) |
| 2.0.0 | 2026-04-13 | Team | API-001 rewritten (namespace = auth contract, not cosmetic). API-008 promoted from WARNING to ERROR. 6 new rules: API-009 explicit permission_callback, API-010 numeric clamping, API-011 validation before side effects, API-012 sanitized JSON, API-013 standardized success response, API-014 documented integration contract. Total: 14 rules (10 ERROR, 4 WARNING) |
| 2.1.0 | 2026-04-16 | Team | Added **Checks** field to all 14 rules |

---
