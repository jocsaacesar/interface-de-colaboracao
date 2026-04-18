---
name: audit-crypto
description: Audits the cryptography implementation in the open PR against the rules defined in docs/crypto-standards.md. Covers algorithm, AEAD, KDF, key validation, versioning, rotation, memory, envelope encryption, and repository usage. Manual trigger only.
---

# /audit-crypto — Cryptography Auditor

Reads the rules from `docs/crypto-standards.md`, identifies relevant PHP files in the open (unmerged) PR, and compares each file against every applicable cryptography rule. Focuses on: algorithm and library, authenticated encryption (AEAD), key derivation (KDF), key validation, ciphertext versioning, rotation, memory management, envelope encryption, and correct usage in repositories.

Complements `/audit-security` (general security) and `/audit-php` (syntax).

## When to use

- **ONLY** when the user explicitly types `/audit-crypto`.
- Run before merging a PR that changes encryption classes, repositories, or key configuration.
- **Never** trigger automatically, nor as part of another skill.

## Minimum required standards

> This section contains the complete standards used by the audit. Edit to customize for your project.

# Cryptography standards

## Description

Reference document for cryptography auditing in the project. Defines mandatory rules to protect sensitive data at rest using modern authenticated encryption. The `/audit-crypto` skill reads this document and compares it against the target code.

## Scope

- The project's encryption class
- Every repository that injects the encryption interface
- Key configuration (`.env`, `.env.example`)
- Context: sensitive data at rest in the database

## References

- [Libsodium — XChaCha20-Poly1305](https://doc.libsodium.org/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction)
- [Latacora — Cryptographic Right Answers](https://latacora.micro.blog/2018/04/03/cryptographic-right-answers.html)
- [OWASP Cryptographic Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)
- [PHP Sodium Extension](https://www.php.net/manual/en/book.sodium.php)

## Severity

- **ERROR** — Violation blocks approval. Must be fixed before merge.
- **WARNING** — Strong recommendation. Must be justified if ignored.

---

## 1. Algorithm and library

### CRYPTO-001 — Use PHP's native Libsodium [ERROR]

Data-at-rest encryption must use the native Sodium extension (available since PHP 7.2). Using `openssl_encrypt` / `openssl_decrypt` for new data is prohibited. The target algorithm is **XChaCha20-Poly1305** via `sodium_crypto_aead_xchacha20poly1305_ietf_encrypt`.

```php
// correct — Libsodium AEAD
$nonce = random_bytes(SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_NPUBBYTES); // 24 bytes
$ciphertext = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
    $plaintext,
    '',           // additional data (context, e.g., table + field)
    $nonce,
    $derivedKey
);

// incorrect — manual OpenSSL
$ciphertext = openssl_encrypt($plaintext, 'aes-256-cbc', $key, OPENSSL_RAW_DATA, $iv);
```

**Exception:** Reading legacy data encrypted with OpenSSL is permitted during the migration period.

### CRYPTO-002 — Obsolete or homegrown algorithms prohibited [ERROR]

Prohibited: DES, 3DES, RC4, Blowfish, MD5 for encryption, SHA1 for integrity, `mcrypt_*`, ECB mode, CBC without authentication. Implementing homegrown algorithms is prohibited.

---

## 2. Authenticated encryption (AEAD)

### CRYPTO-003 — All ciphertext must be authenticated [ERROR]

Encryption without authentication is vulnerable to manipulation attacks. The mode of operation must be **AEAD** (Authenticated Encryption with Associated Data).

With Libsodium, `sodium_crypto_aead_xchacha20poly1305_ietf_encrypt` is natively AEAD.

### CRYPTO-004 — Failed decryption must throw a typed exception [ERROR]

If `sodium_crypto_aead_*_decrypt` returns `false`, the class must throw a typed exception immediately. Never return an empty string, null, or partial data.

---

## 3. Key derivation (KDF)

### CRYPTO-005 — Never use the master key directly on data [ERROR]

The `APP_ENCRYPTION_KEY` string from `.env` is the master key (KEK). It must never be passed directly to encryption functions. Derive specific sub-keys via **HKDF** using `sodium_crypto_kdf_derive_from_key`.

```php
// correct — sub-key derivation
$subkey = sodium_crypto_kdf_derive_from_key(
    SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_KEYBYTES,
    $subkeyId,     // integer — identifies the context
    'MyApp___',    // 8-byte context, identifies the application
    $masterKey
);

// incorrect — master key directly on data
$ciphertext = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt($plaintext, '', $nonce, $masterKey);
```

### CRYPTO-006 — Distinct derivation contexts for each purpose [WARNING]

Each cryptographic use (sensitive data, TOTP secrets, tokens) must use a different `subkey_id` in derivation.

---

## 4. Key validation

### CRYPTO-007 — Master key must be exactly 32 bytes [ERROR]

The encryption class constructor must validate that `APP_ENCRYPTION_KEY` is exactly 32 bytes. Otherwise, throw a fatal exception immediately. Don't try to fix it (padding, hashing).

```php
// correct
$key = getenv('APP_ENCRYPTION_KEY');

if ($key === false || $key === '') {
    throw new MissingEncryptionKeyException('APP_ENCRYPTION_KEY not defined.');
}

if (mb_strlen($key, '8bit') !== SODIUM_CRYPTO_KDF_KEYBYTES) {
    throw new MissingEncryptionKeyException(
        'APP_ENCRYPTION_KEY must be exactly 32 bytes.'
    );
}
```

### CRYPTO-008 — Missing key stops bootstrap [ERROR]

If `APP_ENCRYPTION_KEY` is not defined or is empty, the system must not initialize.

---

## 5. Ciphertext versioning

### CRYPTO-009 — All ciphertext must have a version prefix [ERROR]

To allow key rotation and algorithm migration without breaking existing data, all encrypted data must start with a version prefix.

```
v1|nonce(24 bytes base64)|ciphertext(base64)   -> Libsodium XChaCha20-Poly1305
```

### CRYPTO-010 — Gradual migration of legacy data [WARNING]

Data encrypted with a legacy algorithm should be re-encrypted with the current algorithm when read and rewritten.

---

## 6. Key rotation

### CRYPTO-011 — Support multiple key versions simultaneously [WARNING]

The system should support at least two active key versions at the same time.

### CRYPTO-012 — Rotation doesn't require mass re-encryption [WARNING]

When rotating the master key, only new data and rewritten data use the new key.

---

## 7. Memory management

### CRYPTO-013 — Clear keys from memory after use [WARNING]

Keys and sub-keys should be zeroed from RAM with `sodium_memzero()` after each operation.

```php
// correct
$subkey = sodium_crypto_kdf_derive_from_key(/* ... */);
$ciphertext = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt($plaintext, '', $nonce, $subkey);
sodium_memzero($subkey);
```

### CRYPTO-014 — Never log keys, sub-keys, or nonces [ERROR]

Prohibited: including cryptographic material in logs, error_log, var_dump, debug_backtrace, or any diagnostic output.

---

## 8. Envelope encryption (future)

### CRYPTO-015 — Data encrypted with DEK, DEK protected by KEK [WARNING]

For future scale, each record should be encrypted with a unique **Data Encryption Key (DEK)**, and the DEK should be encrypted by the **Key Encryption Key (KEK)** master key.

### CRYPTO-016 — DEK should be unique per record or per batch [WARNING]

---

## 9. Repositories and interface usage

### CRYPTO-017 — Every sensitive field must be encrypted [ERROR]

Fields containing sensitive data must be stored encrypted in the database. The column type must be `TEXT` (ciphertext has variable length).

### CRYPTO-018 — Encryption/decryption only in the repository [ERROR]

Field encryption and decryption happens exclusively in the repository layer. Entities, managers, and handlers never manipulate encrypted data directly.

### CRYPTO-019 — Segregated interface for testability [ERROR]

The encryption class must implement an interface. Repositories depend on the interface, never the concrete implementation. Tests use a mock of the interface.

```php
// correct
public function __construct(
    private readonly Database $db,
    private readonly EncryptionInterface $crypto,
) {}

// incorrect — concrete dependency
public function __construct(
    private readonly Database $db,
    private readonly Encryption $crypto,
) {}
```

---

## 10. Nonce and randomness

### CRYPTO-020 — Nonce generated with CSPRNG [ERROR]

The nonce must be generated exclusively with PHP's `random_bytes()`. Prohibited: `rand()`, `mt_rand()`, `uniqid()`, timestamp, predictable counter.

### CRYPTO-021 — Nonce never reused with the same key [ERROR]

The nonce must be randomly generated for each operation — never stored and reused.

---

## Rules summary

| ID | Rule | Severity |
|----|------|----------|
| CRYPTO-001 | Use PHP's native Libsodium | ERROR |
| CRYPTO-002 | Obsolete or homegrown algorithms prohibited | ERROR |
| CRYPTO-003 | All ciphertext must be authenticated (AEAD) | ERROR |
| CRYPTO-004 | Failed decryption -> typed exception | ERROR |
| CRYPTO-005 | Never use master key directly on data (KDF) | ERROR |
| CRYPTO-006 | Distinct derivation contexts per purpose | WARNING |
| CRYPTO-007 | Master key must be exactly 32 bytes | ERROR |
| CRYPTO-008 | Missing key stops bootstrap | ERROR |
| CRYPTO-009 | All ciphertext with version prefix | ERROR |
| CRYPTO-010 | Gradual migration of legacy data | WARNING |
| CRYPTO-011 | Support multiple key versions | WARNING |
| CRYPTO-012 | Rotation without mass re-encryption | WARNING |
| CRYPTO-013 | Clear keys from memory after use | WARNING |
| CRYPTO-014 | Never log cryptographic material | ERROR |
| CRYPTO-015 | Envelope encryption: DEK/KEK | WARNING |
| CRYPTO-016 | DEK unique per record or batch | WARNING |
| CRYPTO-017 | Every sensitive field encrypted | ERROR |
| CRYPTO-018 | Encryption only in the repository | ERROR |
| CRYPTO-019 | Segregated interface for testability | ERROR |
| CRYPTO-020 | Nonce generated with CSPRNG | ERROR |
| CRYPTO-021 | Nonce never reused with same key | ERROR |

**Total: 21 rules (13 ERRORs, 8 WARNINGs)**

## Process

### Phase 1 — Load the ruleset

1. Read the **Minimum required standards** section of this document.
2. Internalize all 21 rules with their IDs (CRYPTO-001 to CRYPTO-021), descriptions, examples, and severities (ERROR/WARNING).
3. Do not summarize or recite the document back.

### Phase 2 — Identify the open PR

1. Run `gh pr list --state open --base main --json number,title,headBranch --limit 1` to find the most recent open PR.
2. If none found against `main`, try `--base develop`.
3. If there are multiple open PRs, list all and ask the user which one to audit.
4. If there are no open PRs, inform the user and stop.
5. Run `gh pr diff <number>` to get the full PR diff.

### Phase 3 — Identify target files

Filter the diff files and add the core encryption files (always audited):

**Always audited:**
- Encryption class
- Encryption interface
- Encryption exceptions

**Audited if changed in the PR:**
- Every repository that injects the encryption interface
- `.env.example` (key configuration)
- Bootstrap/instantiation file

### Phase 4 — Audit file by file

For each identified file:

1. Read the complete file (not just the diff — context matters).
2. Compare against **every rule** from `docs/crypto-standards.md`, one by one, in document order.
3. For each violation found, record:
   - **File** and **line(s)** where it occurs
   - **Rule ID** violated (e.g., crypto-standards.md, CRYPTO-003)
   - **Severity** (ERROR or WARNING)
   - **Category** (Algorithm, AEAD, KDF, Validation, Versioning, Rotation, Memory, Envelope, Repository, Nonce)
   - **What's wrong** — concise description
   - **How to fix** — specific correction with Libsodium code example
4. If the file violates no rules, record as approved.

### Phase 5 — Report

Present the report to the user with current state vs. target table and violations table.

### Phase 6 — Migration plan

If there are ERROR violations:

1. Classify corrections into **migration phases**:
   - **Phase 1 (immediate):** Key validation (CRYPTO-007, CRYPTO-008).
   - **Phase 2 (new class):** Create new implementation with Libsodium + KDF + versioning.
   - **Phase 3 (migration):** Update interface to support legacy fallback.
   - **Phase 4 (cleanup):** Remove legacy code. Memory zeroing.
   - **Phase 5 (future):** Envelope encryption.

2. For each phase, indicate exactly which files change and what changes.
3. Ask the user: "Would you like me to execute Phase 1 now?"

## Rules

- **Never change code during the audit.** The skill is read-only until the user explicitly requests correction.
- **Always audit the core encryption files**, even if not changed in the PR.
- **Always reference the violated rule ID.** The report must be traceable to the standards document.
- **Never invent rules.** The ruleset is exclusively `docs/crypto-standards.md`.
- **Be methodical and procedural.** Each file is compared against each rule, in document order, without skipping.
- **Fidelity to the document.** If the code violates a rule in the document, report it. If the document doesn't cover the case, don't report it.
- **Prioritize by data risk.** AEAD and KDF come before memory zeroing and envelope encryption.
- **Show the complete report before any action.** Never apply corrections without explicit approval.
- **The migration plan is mandatory.** Cryptography requires gradual migration to avoid breaking existing data.
