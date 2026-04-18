---
document: crypto-standards
version: 2.1.0
created: 2025-01-01
updated: 2026-04-16
total_rules: 21
severities:
  error: 14
  warning: 7
scope: Encryption of data at rest and in transit across all projects
applies_to: ["all"]
requires: ["security-standards"]
replaces: ["crypto-standards v1.0.0"]
---

# Cryptography Standards — your organization

> Constitutional document. Delivery contract for every
> developer who touches cryptography in our projects.
> Code that violates ERROR rules is not discussed — it is returned.

---

## How to use this document

### For the developer

1. Read the rules before implementing any cryptographic operation.
2. Use the IDs (CRIPTO-001 to CRIPTO-021) to reference in PRs and code reviews.
3. Check the DoD at the end before opening any Pull Request involving cryptography.

### For the auditor (human or AI)

1. Read the frontmatter to understand scope and dependencies.
2. Audit the code against each rule by ID.
3. Classify violations by the severity defined in this document.
4. Reference violations by rule ID (e.g., "violates CRIPTO-005").

### For Claude Code

1. Read the frontmatter to identify scope and related documents.
2. When reviewing code, check every ERROR rule as mandatory.
3. When generating code, apply all rules automatically.
4. Reference violations always by ID (e.g., "violates CRIPTO-014").

---

## Severities

| Level | Meaning | Action |
|-------|---------|--------|
| **ERROR** | Non-negotiable violation | Blocks merge. Fix before review. |
| **WARNING** | Strong recommendation | Must be justified in writing if ignored. |

---

## 1. Algorithm and library

### CRIPTO-001 — Use modern authenticated encryption via standard library [ERROR]

**Rule:** Data encryption must use native, audited cryptographic libraries of the language/platform. In PHP, use the native Sodium extension (available since PHP 7.2). The default algorithm is **XChaCha20-Poly1305** via `sodium_crypto_aead_xchacha20poly1305_ietf_encrypt`. In other languages, use the recommended equivalent library (libsodium bindings, Web Crypto API, NaCl). Using low-level cryptographic APIs that require manual assembly (e.g., `openssl_encrypt` / `openssl_decrypt` in PHP) is prohibited.

**Checks:** Search for `openssl_encrypt`, `openssl_decrypt`, `mcrypt_*` in the code. Every encryption call must use `sodium_crypto_*`.

**Why:** The project handles sensitive data (financial, health, educational). The team is small and development is AI-assisted — there's no room for manually assembling cryptographic primitives. Libsodium offers a high-level API that makes it hard to get wrong: automatically generated nonce with correct size, built-in authentication, no choice of operation mode. Fewer manual decisions = fewer cryptographic failures.

**Correct example:**
```php
// PHP — Native Libsodium AEAD
$nonce = random_bytes(SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_NPUBBYTES); // 24 bytes
$ciphertext = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
    $plaintext,
    '',           // additional data (context, e.g.: table + field)
    $nonce,
    $derivedKey
);
```

**Incorrect example:**
```php
// Manual OpenSSL — requires mode selection, manual IV, no built-in authentication
$ciphertext = openssl_encrypt($plaintext, 'aes-256-cbc', $key, OPENSSL_RAW_DATA, $iv);
```

**Exceptions:** Reading legacy data encrypted with another library is allowed during migration periods, as long as new writes use the standard library.

**References:** CRIPTO-003

### CRIPTO-002 — Obsolete or homegrown algorithms are prohibited [ERROR]

**Rule:** Using DES, 3DES, RC4, Blowfish, MD5 for encryption, SHA1 for integrity, `mcrypt_*`, ECB modes, or CBC without authentication is prohibited. Implementing homegrown algorithms is prohibited — always use audited library primitives.

**Checks:** Search for `des`, `3des`, `rc4`, `blowfish`, `md5(`, `sha1(`, `mcrypt_`, `ecb`, `cbc` in the code. Search for manual XOR functions on strings.

**Why:** A small team doesn't have the capacity to review custom cryptographic implementations. Obsolete algorithms have documented vulnerabilities and public exploits. With AI-assisted development, the risk of an automated suggestion using an obsolete algorithm is real — this rule serves as an explicit barrier.

**Correct example:**
```php
// Modern algorithm via audited library
$ciphertext = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
    $plaintext, '', $nonce, $derivedKey
);
```

**Incorrect example:**
```php
// DES — obsolete since 1999
$ciphertext = openssl_encrypt($plaintext, 'des-ecb', $key);

// Homegrown algorithm — never
function myEncryption(string $plaintext, string $key): string {
    $result = '';
    for ($i = 0; $i < strlen($plaintext); $i++) {
        $result .= chr(ord($plaintext[$i]) ^ ord($key[$i % strlen($key)]));
    }
    return $result;
}
```

---

## 2. Authenticated encryption (AEAD)

### CRIPTO-003 — All ciphertext must be authenticated [ERROR]

**Rule:** Encryption without authentication (plain AES-CBC, XOR, etc.) is prohibited. The operation mode must be **AEAD** (Authenticated Encryption with Associated Data), which guarantees confidentiality and integrity in a single atomic operation. With Libsodium, `sodium_crypto_aead_xchacha20poly1305_ietf_encrypt` is natively AEAD — the authentication tag (Poly1305, 16 bytes) is generated and verified automatically.

**Checks:** Confirm that every encryption call uses Sodium `_aead_` functions. No `openssl_encrypt` with CBC/CTR mode without a separate HMAC.

**Why:** Silently tampered financial and health data is worse than lost data. Encryption without authentication allows an attacker to modify the ciphertext without detection (padding oracle, bit flipping). In the project, where encrypted data feeds financial calculations and business decisions, integrity is as critical as confidentiality.

**Correct example:**
```php
// Native AEAD — automatic verification on decryption
$plaintext = sodium_crypto_aead_xchacha20poly1305_ietf_decrypt(
    $ciphertext,
    '',
    $nonce,
    $derivedKey
);

if ($plaintext === false) {
    throw new CryptoException('Data tampered or incorrect key.');
}
```

**Incorrect example:**
```php
// CBC without HMAC — does not detect tampering
$plaintext = openssl_decrypt($ciphertext, 'aes-256-cbc', $key, OPENSSL_RAW_DATA, $iv);
// openssl_decrypt may silently return garbage if the ciphertext was manipulated
```

### CRIPTO-004 — Failed decryption must throw a typed exception [ERROR]

**Rule:** If the decryption function returns failure (e.g., `false` in Libsodium), the code must throw a typed exception immediately. Never return an empty string, null, or partial data.

**Checks:** Search for `_decrypt(` and confirm that a `false` return throws a typed exception. No `?: ''` or `?? null` after decryption.

**Why:** Incorrectly decrypted financial data that passes silently can generate wrong calculations, incorrect reports, and business decisions based on garbage. A typed exception allows specific handling (retry with previous key, audit log, alert) instead of silent failure.

**Correct example:**
```php
$plaintext = sodium_crypto_aead_xchacha20poly1305_ietf_decrypt(
    $ciphertext, '', $nonce, $derivedKey
);

if ($plaintext === false) {
    throw new CryptoException('Decryption failed: data tampered or incorrect key.');
}

return $plaintext;
```

**Incorrect example:**
```php
$plaintext = sodium_crypto_aead_xchacha20poly1305_ietf_decrypt(
    $ciphertext, '', $nonce, $derivedKey
);

return $plaintext ?: ''; // returns empty string instead of reporting failure
```

---

## 3. Key derivation (KDF)

### CRIPTO-005 — Never use the master key directly on data [ERROR]

**Rule:** The master key (KEK) stored in an environment variable must never be passed directly to encryption functions. Derive purpose-specific sub-keys via **HKDF** (e.g., `sodium_crypto_kdf_derive_from_key` in PHP). Each sub-key is bound to a context (application + purpose).

**Checks:** Search for the master key variable (`$masterKey`, `APP_ENCRYPTION_KEY`) as a direct argument to `_encrypt`/`_decrypt` functions. It should only pass through `_kdf_derive_from_key`.

**Why:** If the master key leaks through direct use in multiple contexts, all data across all projects is compromised simultaneously. Sub-key derivation isolates the impact: compromising one sub-key doesn't compromise the others. With a small team and multiple projects, this isolation is critical.

**Correct example:**
```php
// Sub-key derivation with context
$subkey = sodium_crypto_kdf_derive_from_key(
    SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_KEYBYTES, // 32 bytes
    $subkeyId,      // integer — identifies the purpose (e.g.: 1 = financial, 2 = TOTP)
    'MyApp___',     // 8-byte context, identifies the application
    $masterKey      // master key from the environment (exactly 32 bytes)
);

$ciphertext = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt($plaintext, '', $nonce, $subkey);
```

**Incorrect example:**
```php
// Master key used directly — total compromise if leaked
$ciphertext = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt($plaintext, '', $nonce, $masterKey);
```

### CRIPTO-006 — Distinct derivation contexts for each purpose [WARNING]

**Rule:** Each cryptographic use (financial data, TOTP secrets, session tokens, health data) must use a different `subkey_id` in derivation, ensuring that the same master key generates distinct and independent sub-keys.

**Checks:** List all `_kdf_derive_from_key` calls and confirm that each purpose uses a distinct `subkey_id`. No repeated ID between different contexts.

**Why:** The project works with data of different natures (financial, educational, health) across distinct projects. Reusing the same sub-key for different purposes means that a leak in one context compromises all others. Separate contexts guarantee cryptographic isolation between business domains.

**Correct example:**
```php
// Distinct sub-keys by purpose
$financialSubkey = sodium_crypto_kdf_derive_from_key(
    32, 1, 'MyApp___', $masterKey  // subkey_id = 1 for financial data
);
$healthSubkey = sodium_crypto_kdf_derive_from_key(
    32, 2, 'MyApp___', $masterKey  // subkey_id = 2 for health data
);
```

**Incorrect example:**
```php
// Same sub-key for everything — no isolation
$subkey = sodium_crypto_kdf_derive_from_key(32, 1, 'MyApp___', $masterKey);
// uses $subkey for financial data AND health data
```

---

## 4. Key validation

### CRIPTO-007 — Master key must have the exact size required by the algorithm [ERROR]

**Rule:** The encryption class constructor must validate that the master key has exactly the size required by the algorithm (32 bytes for Libsodium KDF). Otherwise, throw a fatal exception immediately. Never try to fix it (padding, hash, truncation).

**Checks:** Inspect the encryption class constructor. It must contain `mb_strlen($key, '8bit') !== SODIUM_CRYPTO_KDF_KEYBYTES` with throw. No corrective `str_pad` or `hash()`.

**Why:** A key with the wrong size indicates a configuration error in the deploy. Automatically fixing it (padding, hash) masks the problem and weakens the encryption. In the project, where deploys are done by a small team and frequently AI-assisted, failing loudly at bootstrap is better than silently encrypting with a malformed key.

**Correct example:**
```php
$key = getenv('APP_ENCRYPTION_KEY');

if ($key === false || $key === '') {
    throw new MissingEncryptionKeyException('APP_ENCRYPTION_KEY is not set.');
}

if (mb_strlen($key, '8bit') !== SODIUM_CRYPTO_KDF_KEYBYTES) {
    throw new MissingEncryptionKeyException(
        'APP_ENCRYPTION_KEY must be exactly ' . SODIUM_CRYPTO_KDF_KEYBYTES . ' bytes.'
    );
}
```

**Incorrect example:**
```php
$this->key = getenv('APP_ENCRYPTION_KEY');
// no size validation — accepts anything

// or worse — silently "fixes"
$this->key = str_pad($key, 32, "\0"); // padding with null bytes
$this->key = hash('sha256', $key, true); // hash to force 32 bytes
```

### CRIPTO-008 — Missing key must halt bootstrap [ERROR]

**Rule:** If the encryption key is not set or is empty, the system must not initialize. The exception must be caught as early as possible (encryption class constructor or application bootstrap).

**Checks:** Confirm that the bootstrap or constructor tests `getenv('APP_ENCRYPTION_KEY') === false || === ''` and throws an exception. No silent fallback.

**Why:** A system that initializes without an encryption key may write plaintext data to the database, creating a silent exposure window. In the project, sensitive data (financial, health) is encrypted at the repository layer — if the repository works without encryption, data is exposed without anyone noticing until the next audit.

**Correct example:**
```php
// In the application bootstrap
$key = getenv('APP_ENCRYPTION_KEY');
if ($key === false || $key === '') {
    throw new MissingEncryptionKeyException(
        'APP_ENCRYPTION_KEY is not set. System cannot initialize without an encryption key.'
    );
}
```

**Incorrect example:**
```php
// System initializes normally without key — data written in plaintext
$key = getenv('APP_ENCRYPTION_KEY');
if (empty($key)) {
    error_log('Warning: encryption key not configured');
    // continues running without encryption...
}
```

---

## 5. Ciphertext versioning

### CRIPTO-009 — All ciphertext must have a version prefix [ERROR]

**Rule:** To allow key rotation and algorithm migration without breaking existing data, all encrypted data must start with a version prefix followed by a separator. The prefix format is flexible (e.g., `v1|`, `v2|`), but must be consistent within the project.

**Checks:** Inspect the output of the `encrypt()` function. It must start with a version prefix (e.g., `v1|`). Search for `str_starts_with` or equivalent in the `decrypt()` function.

**Why:** The project has long-running projects where algorithms and keys will change over time. Without a version prefix, it's impossible to know which key or algorithm to use to decrypt old data. This would deadlock migrations and make key rotation an operational nightmare for a small team.

**Correct example:**
```php
// Write with version
$encoded = 'v1|' . base64_encode($nonce) . '|' . base64_encode($ciphertext);

// Read with version detection
if (str_starts_with($encryptedText, 'v1|')) {
    // decrypt with v1 algorithm
} elseif (str_starts_with($encryptedText, 'v2|')) {
    // decrypt with v2 algorithm
} else {
    throw new CryptoException('Unknown ciphertext version.');
}
```

**Incorrect example:**
```php
// No prefix — impossible to know which algorithm/key to use
$encoded = base64_encode($nonce) . base64_encode($ciphertext);
```

### CRIPTO-010 — Gradual migration of legacy data [WARNING]

**Rule:** Data encrypted with a previous algorithm or key must be re-encrypted with the current algorithm/key when read and rewritten. This allows organic migration without a mass migration script. Reading with the legacy algorithm should emit a warning log in the development environment.

**Checks:** Confirm that the repository, when reading data with a previous version, re-encrypts and rewrites with the current version. A `wasLegacy()` method or equivalent must exist.

**Why:** Mass migration scripts in projects with sensitive data are risky — they require a maintenance window, complex rollback, and extensive testing. In the project, with a small team, organic migration (re-encrypt on read/rewrite) distributes risk over time and requires no special operational coordination.

**Correct example:**
```php
public function findById(int $id): ?Entity
{
    $row = $this->db->get($id);
    $data = $this->crypto->decrypt($row->encrypted_data);

    // If it was legacy, rewrite with current algorithm
    if ($this->crypto->wasLegacy()) {
        $row->encrypted_data = $this->crypto->encrypt($data);
        $this->db->update($id, $row);
    }

    return Entity::fromRow($row, $data);
}
```

**Incorrect example:**
```php
// Mass migration script — risky, requires downtime
foreach ($this->db->all() as $row) {
    $data = $this->oldCrypto->decrypt($row->encrypted_data);
    $row->encrypted_data = $this->newCrypto->encrypt($data);
    $this->db->update($row->id, $row);
}
```

---

## 6. Key rotation

### CRIPTO-011 — Support for multiple simultaneous key versions [WARNING]

**Rule:** The system must support at least two active key versions at the same time (current + previous), allowing rotation without downtime. The version prefix (CRIPTO-009) identifies which key to use for decryption.

**Checks:** Confirm that the encryption class accepts at least 2 keys (current + previous). The decryption method must select the key by version prefix.

**Why:** The project has no dedicated operations team. Key rotation that requires downtime or coordinated migration is unfeasible for a small team. Supporting two simultaneous keys allows transparent rotation: new data uses the new key, old data remains readable via the previous key.

**Correct example:**
```php
class KeyManager
{
    public function keyForDecryption(string $version): string
    {
        return match ($version) {
            'v2' => $this->currentKey,
            'v1' => $this->previousKey,
            default => throw new CryptoException("Unknown key version: {$version}"),
        };
    }

    public function keyForEncryption(): string
    {
        return $this->currentKey; // always encrypt with the latest
    }
}
```

**Incorrect example:**
```php
// Only one key — rotation breaks all old data
class Crypto
{
    public function __construct(private string $key) {}
    // when the key changes, old data becomes unreadable
}
```

### CRIPTO-012 — Rotation does not require mass re-encryption [WARNING]

**Rule:** When rotating the master key, only new data and rewritten data use the new key. Old data remains readable via the previous key until organically rewritten (see CRIPTO-010).

**Checks:** Confirm that no mass re-encryption script exists. Encryption always uses the current key; decryption accepts the previous key via prefix.

**Why:** Mass re-encryption of sensitive data requires a maintenance window, rollback plan, and extensive testing — resources a small team can't mobilize frequently. Organic rotation distributes cost over time and eliminates the risk of mass corruption.

**Correct example:**
```php
// Rotation: add new key, keep the previous one
// .env
// APP_ENCRYPTION_KEY=new_key_32_bytes_here____________
// APP_ENCRYPTION_KEY_PREVIOUS=previous_key_32_bytes_here____

// New data: encrypted with APP_ENCRYPTION_KEY (v2)
// Old data: decrypted with APP_ENCRYPTION_KEY_PREVIOUS (v1)
// Rewritten data: re-encrypted with APP_ENCRYPTION_KEY (v2)
```

**Incorrect example:**
```php
// Rotation with forced migration — operational risk
// 1. Stop the system
// 2. Run re-encryption script on all records
// 3. Swap the key
// 4. Restart and hope it works
```

---

## 7. Memory management

### CRIPTO-013 — Clear keys from memory after use [WARNING]

**Rule:** Keys and sub-keys must be zeroed from memory after each encryption/decryption operation. In PHP, use `sodium_memzero()`. In other languages, use the cryptographic library's equivalent.

**Checks:** Search for `sodium_memzero` after each sub-key usage. Every `$subkey`/`$dek` variable must be zeroed before return.

**Why:** In shared environments (hosting, containers), a memory dump can expose keys that remained after use. In the project, where projects run on varied infrastructure (own servers, cloud, containers), clearing keys from memory reduces the exposure window regardless of the environment.

**Correct example:**
```php
$subkey = sodium_crypto_kdf_derive_from_key(
    SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_KEYBYTES,
    $subkeyId, 'MyApp___', $masterKey
);
$ciphertext = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt($plaintext, '', $nonce, $subkey);
sodium_memzero($subkey); // sub-key zeroed immediately after use
```

**Incorrect example:**
```php
$subkey = sodium_crypto_kdf_derive_from_key(/* ... */);
$ciphertext = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt($plaintext, '', $nonce, $subkey);
// $subkey remains in memory until garbage collector — exposure window
```

### CRIPTO-014 — Never log keys, sub-keys, or nonces [ERROR]

**Rule:** Including cryptographic material (keys, sub-keys, nonces, partial ciphertexts) in logs, error_log, var_dump, debug_backtrace, print_r, console output, or any diagnostic mechanism is prohibited.

**Checks:** Search for `error_log`, `var_dump`, `print_r`, `console.log`, `debug_backtrace` near variables `$key`, `$subkey`, `$nonce`, `$dek`, `$kek`, `$ciphertext`.

**Why:** Logs are frequently stored in plaintext, replicated to monitoring services, and retained for long periods. With AI-assisted development, it's common for debug suggestions to include `var_dump($key)` or `console.log(key)` — this rule serves as an explicit barrier against such accidental leaks.

**Correct example:**
```php
// Log without cryptographic material
error_log('Crypto: decryption failed for record ID=' . $id);
error_log('Crypto: invalid key size');
```

**Incorrect example:**
```php
// LEAK — key in log
error_log('Key used: ' . bin2hex($key));
var_dump($subkey);
error_log('Nonce: ' . base64_encode($nonce) . ' | Ciphertext: ' . base64_encode($ciphertext));
```

---

## 8. Envelope encryption (future evolution)

### CRIPTO-015 — Data encrypted with DEK, DEK protected by KEK [WARNING]

**Rule:** For future scale, each record (or group of records) should be encrypted with a unique **Data Encryption Key (DEK)**, and the DEK should be encrypted by the **Key Encryption Key (KEK)** master. This allows KEK rotation without re-encrypting all data.

**Checks:** If envelope encryption is implemented: confirm that each record has its own DEK encrypted by the KEK. An `encrypted_dek` column must exist alongside `encrypted_data`.

**Why:** As the project's projects grow and accumulate more sensitive data, rotating the master key becomes progressively more expensive if each record uses the same key. Envelope encryption isolates the rotation cost: swapping the KEK only requires re-encrypting the DEKs (small), not the data (large).

**Correct example:**
```php
// Encrypt with envelope encryption
$dek = random_bytes(32); // unique DEK for this record
$encryptedData = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
    $data, '', $dataNonce, $dek
);
$encryptedDek = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
    $dek, '', $dekNonce, $kek
);
sodium_memzero($dek);

// Store: encrypted_dek + encrypted_data
```

**Incorrect example:**
```php
// All records encrypted with the same key directly
// Key rotation requires re-encrypting ALL records
$ciphertext = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
    $data, '', $nonce, $masterKey
);
```

**Exceptions:** The current implementation with master key + KDF (CRIPTO-005) is acceptable for moderate data volumes. Envelope encryption should be implemented when the volume justifies it.

### CRIPTO-016 — DEK must be unique per record or per batch [WARNING]

**Rule:** If envelope encryption is implemented, each DEK must be generated with the language's CSPRNG (e.g., `random_bytes(32)` in PHP) and never reused between records or different tables.

**Checks:** Confirm that `random_bytes(32)` is called inside the write loop (new DEK per record). No `$dek` variable defined outside the loop.

**Why:** Reusing DEKs between records nullifies the benefit of envelope encryption: compromising one DEK exposes multiple records. In the project, data of different natures (financial, health, educational) must have total cryptographic isolation — one DEK per record guarantees that compromising one record doesn't affect the others.

**Correct example:**
```php
// Unique DEK for each record
foreach ($records as $record) {
    $dek = random_bytes(32); // new DEK for each record
    $ciphertext = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
        $record->data(), '', random_bytes(24), $dek
    );
    $encryptedDek = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
        $dek, '', random_bytes(24), $kek
    );
    sodium_memzero($dek);
    $this->save($record->id(), $encryptedDek, $ciphertext);
}
```

**Incorrect example:**
```php
// Same DEK for all records — no isolation
$dek = random_bytes(32);
foreach ($records as $record) {
    $ciphertext = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
        $record->data(), '', random_bytes(24), $dek
    );
    // same $dek reused — compromising one exposes all
}
```

---

## 9. Encryption layer and interface

### CRIPTO-017 — Every sensitive field must be encrypted at rest [ERROR]

**Rule:** Fields containing sensitive data (financial, health, educational, personally identifiable) must be stored encrypted in the database. The column type must accommodate variable-length ciphertext (e.g., `TEXT` in SQL, never `VARCHAR` with a fixed limit).

**Checks:** List sensitive columns in the schema. Type must be `TEXT` (not `VARCHAR`). Written data must have a version prefix (indicating ciphertext).

**Why:** The project works with personal financial data, health data, and educational data — all subject to data protection regulations. In case of database leaks (SQL injection, exposed backup, unauthorized access), data encrypted at rest is unreadable without the key. This is the last line of defense.

**Correct example:**
```php
// Repository encrypts before writing
private function encryptData(Entity $entity): array
{
    return [
        'description' => $this->crypto->encrypt($entity->description()),
        'amount'      => $this->crypto->encrypt((string) $entity->amount()),
    ];
}

// Database column: TEXT (accommodates ciphertext of any length)
```

**Incorrect example:**
```php
// Sensitive data written in plaintext
$this->db->insert('records', [
    'description' => $entity->description(),  // plaintext in the database
    'amount'      => $entity->amount(),        // plaintext in the database
]);

// Or VARCHAR(255) column — may truncate ciphertext
```

### CRIPTO-018 — Encryption/decryption only in the persistence layer [ERROR]

**Rule:** Field encryption and decryption happens exclusively in the persistence layer (repository, DAO), in write and hydration methods. Upper layers (entities, services, controllers, handlers) never manipulate encrypted data directly.

**Checks:** Search for `->encrypt(` and `->decrypt(` outside `*Repository*`/`*Repo*`/`*DAO*` files. No handler, service, or entity should call these functions.

**Why:** Concentrating encryption in the repository creates a single audit point. If encryption is scattered across handlers, services, and entities, it's impossible to guarantee that all paths are correct — especially with AI-assisted development, where each code suggestion can introduce a path without encryption. One point = one audit.

**Correct example:**
```php
// Repository encrypts on write
public function save(Entity $entity): void
{
    $this->db->insert('table', [
        'description' => $this->crypto->encrypt($entity->description()),
        'amount'      => $this->crypto->encrypt((string) $entity->amount()),
    ]);
}

// Repository decrypts on read
public function findById(int $id): ?Entity
{
    $row = $this->db->get($id);
    return Entity::fromRow(
        $this->crypto->decrypt($row->description),
        $this->crypto->decrypt($row->amount),
    );
}
```

**Incorrect example:**
```php
// Handler manipulates encryption — wrong layer
public function handleCreate(): void
{
    $amount = $this->crypto->encrypt($_POST['amount']); // WRONG
    $this->service->create($amount);
}
```

### CRIPTO-019 — Segregated interface for testability [ERROR]

**Rule:** The encryption class must implement an interface. All dependencies point to the interface, never to the concrete implementation. Tests use a mock or fake implementation of the interface.

**Checks:** Confirm that a `CryptoInterface` (or equivalent) exists. Type hints in constructors must point to the interface, not to the concrete class.

**Why:** Repositories that depend on a concrete encryption class cannot be unit tested without a real key and the Sodium extension installed. In the project, tests must run fast and without infrastructure dependencies. A segregated interface allows a mock that returns data without encryption, isolating the repository behavior.

**Correct example:**
```php
// Interface
interface CryptoInterface
{
    public function encrypt(string $plaintext): string;
    public function decrypt(string $ciphertext): string;
}

// Repository depends on the interface
public function __construct(
    private readonly PDO $db,
    private readonly CryptoInterface $crypto,
) {}
```

**Incorrect example:**
```php
// Concrete dependency — impossible to mock without the real extension
public function __construct(
    private readonly PDO $db,
    private readonly Crypto $crypto, // concrete class
) {}
```

---

## 10. Nonce and randomness

### CRIPTO-020 — Nonce generated with CSPRNG [ERROR]

**Rule:** The nonce (number used once) must be generated exclusively with the language's CSPRNG (Cryptographically Secure Pseudo-Random Number Generator). In PHP, use `random_bytes()`. Prohibited: `rand()`, `mt_rand()`, `uniqid()`, timestamp, predictable counter, or any non-cryptographically secure source.

**Checks:** Search for `$nonce` assignment. Must be `random_bytes(SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_NPUBBYTES)`. No `rand()`, `mt_rand()`, `uniqid()`, `time()`.

**Why:** A predictable nonce combined with a fixed key enables plaintext recovery attacks. With AI-assisted development, it's common for suggestions to use `uniqid()` or `mt_rand()` to generate "something random" — these functions are not cryptographically secure. This rule is an explicit barrier against dangerous automated suggestions.

**Correct example:**
```php
// CSPRNG — 24 bytes for XChaCha20
$nonce = random_bytes(SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_NPUBBYTES);
```

**Incorrect example:**
```php
// Predictable — NOT CSPRNG
$nonce = md5(uniqid());           // predictable, only 16 bytes
$nonce = random_bytes(16);         // wrong size for XChaCha20 (needs 24)
$nonce = pack('P', time());        // timestamp — completely predictable
$nonce = str_pad((string)$id, 24); // derived from predictable data
```

### CRIPTO-021 — Nonce never reused with the same key [ERROR]

**Rule:** The nonce must be randomly generated for each encryption operation. Never store and reuse a nonce, never derive it from predictable data. With XChaCha20 and a 24-byte nonce, collision probability is negligible for normal volumes if generated via CSPRNG.

**Checks:** Confirm that `random_bytes()` is called inside the `encrypt()` method, not in the constructor or as a class property. No reused `$this->nonce`.

**Why:** Nonce reuse with the same key in XChaCha20-Poly1305 enables keystream recovery via XOR of ciphertexts. In the project, where financial and health data is encrypted, this vulnerability would allow an attacker with database access to recover sensitive data without the key.

**Correct example:**
```php
// New nonce for each operation
public function encrypt(string $plaintext): string
{
    $nonce = random_bytes(SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_NPUBBYTES);
    $ciphertext = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
        $plaintext, '', $nonce, $this->subkey
    );
    return 'v1|' . base64_encode($nonce) . '|' . base64_encode($ciphertext);
}
```

**Incorrect example:**
```php
// Fixed nonce reused — critical vulnerability
private string $nonce;

public function __construct()
{
    $this->nonce = random_bytes(24); // generated once, reused always
}

public function encrypt(string $plaintext): string
{
    // same nonce + same key for all plaintexts = keystream recovery
    return sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
        $plaintext, '', $this->nonce, $this->subkey
    );
}
```

---

## 11. Documentation and versioning

> **Note:** The principles expressed in the PHP examples in this document apply universally. In other languages, use the equivalent cryptographic library (libsodium bindings, NaCl, Web Crypto API) following the same principles: modern algorithms, AEAD, KDF, nonce via CSPRNG, segregated interface.

---

## Definition of Done — Delivery Checklist

> PRs that don't meet the DoD don't enter review. They are returned.

| # | Item | Rules | Verification |
|---|------|-------|--------------|
| 1 | No obsolete or homegrown algorithm in the code | CRIPTO-001, CRIPTO-002 | Search for `openssl_encrypt`, `mcrypt_*`, `des`, `rc4`, `md5` in the code |
| 2 | All encryption uses AEAD | CRIPTO-003 | Verify that every encryption call uses AEAD functions |
| 3 | Decryption failure throws typed exception | CRIPTO-004 | Verify that `false` return is never ignored |
| 4 | Master key never used directly | CRIPTO-005 | Search for direct uses of the master key variable in encryption functions |
| 5 | Key validated at bootstrap | CRIPTO-007, CRIPTO-008 | Verify size and presence validation in the constructor |
| 6 | Ciphertext has version prefix | CRIPTO-009 | Inspect the encryption function output format |
| 7 | Cryptographic material absent from logs | CRIPTO-014 | Search for `error_log`, `var_dump`, `print_r`, `console.log` near key variables |
| 8 | Sensitive fields encrypted in the database | CRIPTO-017 | Verify that sensitive columns are TEXT type and data is encrypted |
| 9 | Encryption only in the repository | CRIPTO-018 | Verify that handlers, services, and entities don't call encryption functions |
| 10 | Dependency via interface, not concrete class | CRIPTO-019 | Verify type hints in constructors |
| 11 | Nonce generated with CSPRNG and correct size | CRIPTO-020 | Verify use of `random_bytes()` with size constant |
| 12 | Nonce never reused | CRIPTO-021 | Verify that nonce is generated inside the encryption method, not stored |
| 13 | Sub-keys cleared from memory | CRIPTO-013 | Verify calls to `sodium_memzero()` after use |
| 14 | Distinct derivation contexts per purpose | CRIPTO-006 | Verify that each use has a different subkey_id |
| 15 | Tests use mock of the crypto interface | CRIPTO-019 | Verify that tests don't depend on a real key or Sodium extension |
