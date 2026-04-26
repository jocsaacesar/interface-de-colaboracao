---
name: auditar-cripto
description: Audita implementação de criptografia do PR aberto contra as regras definidas em docs/padroes-criptografia.md. Cobre algoritmo, AEAD, KDF, validação de chave, versionamento, rotação, memória, envelope encryption e uso nos repositórios. Trigger manual apenas.
---

# /auditar-cripto — Auditora de criptografia

Lê as regras de `docs/padroes-criptografia.md`, identifica os arquivos PHP relevantes no PR aberto (não mergeado) e compara cada arquivo contra cada regra de criptografia aplicável. Foco em: algoritmo e biblioteca, criptografia autenticada (AEAD), derivação de chave (KDF), validação de chave, versionamento de ciphertext, rotação, gestão de memória, envelope encryption e uso correto nos repositórios.

Complementa `/auditar-seguranca` (segurança geral) e `/auditar-php` (sintaxe).

## Quando usar

- **APENAS** quando o usuário digitar `/auditar-cripto` explicitamente.
- Rodar antes de mergear um PR que altere classes de criptografia, repositórios ou configuração de chaves.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Padrões mínimos exigidos

> Esta seção contém os padrões completos usados pela auditoria. Edite para personalizar ao seu projeto.

# Padrão de criptografia

## Descrição

Documento de referência para auditoria de criptografia no projeto Acertando os Pontos. Define regras obrigatórias para proteger dados financeiros em repouso usando criptografia autenticada moderna. A skill `/auditar-cripto` lê este documento e compara contra o código-alvo.

Complementa `docs/padroes-seguranca.md` (segurança geral) e `docs/padroes-php.md` (sintaxe).

## Escopo

- Classe de criptografia (`inc/Criptografia.php`, `inc/CriptografiaInterface.php`)
- Todo repositório que injeta `CriptografiaInterface`
- Configuração de chaves (`.env`, `.env.example`, `.env.docker.example`)
- Contexto: dados financeiros pessoais e de pequenas empresas em repouso no banco de dados

## Referências

- [Libsodium — XChaCha20-Poly1305](https://doc.libsodium.org/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction)
- [Latacora — Cryptographic Right Answers](https://latacora.micro.blog/2018/04/03/cryptographic-right-answers.html)
- [OWASP Cryptographic Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)
- [OWASP ASVS v4.0 Section 6 — Stored Cryptography](https://owasp.org/www-project-application-security-verification-standard/)
- [NIST SP 800-38D — GCM](https://csrc.nist.gov/publications/detail/sp/800-38d/final)
- [PHP Sodium Extension](https://www.php.net/manual/en/book.sodium.php)

## Severidade

- **ERRO** — Violação bloqueia aprovação. Deve ser corrigida antes de merge.
- **AVISO** — Recomendação forte. Deve ser justificada se ignorada.

---

## 1. Algoritmo e biblioteca

### CRIPTO-001 — Usar Libsodium nativo do PHP [ERRO]

A criptografia de dados em repouso deve usar a extensão Sodium nativa do PHP (disponível desde PHP 7.2, estável no PHP 8.4). Proibido usar `openssl_encrypt` / `openssl_decrypt` para novos dados. O algoritmo alvo é **XChaCha20-Poly1305** via `sodium_crypto_aead_xchacha20poly1305_ietf_encrypt`.

```php
// correto — Libsodium AEAD
$nonce = random_bytes(SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_NPUBBYTES); // 24 bytes
$cifrado = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
    $texto,
    '',           // additional data (contexto, ex: tabela + campo)
    $nonce,
    $chaveDerivada
);

// incorreto — OpenSSL manual
$cifrado = openssl_encrypt($texto, 'aes-256-cbc', $chave, OPENSSL_RAW_DATA, $iv);
```

**Exceção:** Leitura de dados legados criptografados com OpenSSL é permitida durante o período de migração, desde que novas gravações usem Libsodium.

### CRIPTO-002 — Proibido algoritmos obsoletos ou caseiros [ERRO]

Proibido: DES, 3DES, RC4, Blowfish, MD5 para criptografia, SHA1 para integridade, `mcrypt_*`, modos ECB, CBC sem autenticação. Proibido implementar algoritmos caseiros — sempre usar primitivos de biblioteca.

---

## 2. Criptografia autenticada (AEAD)

### CRIPTO-003 — Todo ciphertext deve ser autenticado [ERRO]

Criptografia sem autenticação (AES-CBC puro, XOR, etc.) é vulnerável a ataques de manipulação (padding oracle, bit flipping). O modo de operação deve ser **AEAD** (Authenticated Encryption with Associated Data), que garante confidencialidade e integridade em uma única operação atômica.

Com Libsodium, `sodium_crypto_aead_xchacha20poly1305_ietf_encrypt` já é AEAD nativo — a tag de autenticação (Poly1305, 16 bytes) é gerada e verificada automaticamente.

```php
// correto — AEAD nativo, verificação automática na descriptografia
$texto = sodium_crypto_aead_xchacha20poly1305_ietf_decrypt(
    $cifrado,
    '',
    $nonce,
    $chaveDerivada
);

if ($texto === false) {
    throw new CriptografiaException('Dado adulterado ou chave incorreta.');
}

// incorreto — CBC sem HMAC, não detecta adulteração
$texto = openssl_decrypt($cifrado, 'aes-256-cbc', $chave, OPENSSL_RAW_DATA, $iv);
// openssl_decrypt pode retornar lixo silenciosamente se o ciphertext foi manipulado
```

### CRIPTO-004 — Descriptografia que falha deve lançar exceção tipada [ERRO]

Se `sodium_crypto_aead_*_decrypt` retornar `false`, a classe deve lançar `CriptografiaException` imediatamente. Nunca retornar string vazia, null ou dado parcial.

---

## 3. Derivação de chave (KDF)

### CRIPTO-005 — Nunca usar a chave mestra diretamente nos dados [ERRO]

A string `APP_ENCRYPTION_KEY` do `.env` é a chave mestra (KEK). Ela nunca deve ser passada diretamente para funções de criptografia. Deve-se derivar sub-chaves específicas via **HKDF** usando `sodium_crypto_kdf_derive_from_key`.

```php
// correto — derivação de sub-chave
$subchave = sodium_crypto_kdf_derive_from_key(
    SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_KEYBYTES, // 32 bytes
    $subchaveId,    // inteiro — identifica o contexto (ex: 1 = dados financeiros, 2 = TOTP)
    'AcPontos',     // contexto de 8 bytes, identifica a aplicação
    $chaveMestra    // APP_ENCRYPTION_KEY (exatamente 32 bytes)
);

// incorreto — chave mestra direto nos dados
$cifrado = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt($texto, '', $nonce, $chaveMestra);
```

### CRIPTO-006 — Contextos de derivação distintos para cada finalidade [AVISO]

Cada uso criptográfico (dados financeiros, TOTP secrets, tokens) deve usar um `subkey_id` diferente na derivação, garantindo que a mesma chave mestra gere sub-chaves distintas e independentes.

---

## 4. Validação de chave

### CRIPTO-007 — Chave mestra deve ter exatamente 32 bytes [ERRO]

O construtor da classe de criptografia deve validar que `APP_ENCRYPTION_KEY` tem exatamente 32 bytes (`SODIUM_CRYPTO_KDF_KEYBYTES`). Caso contrário, lançar exceção fatal imediatamente. Não tentar corrigir (padding, hash).

```php
// correto
$chave = getenv('APP_ENCRYPTION_KEY');

if ($chave === false || $chave === '') {
    throw new ChaveCriptografiaAusenteException('APP_ENCRYPTION_KEY não definida.');
}

if (mb_strlen($chave, '8bit') !== SODIUM_CRYPTO_KDF_KEYBYTES) {
    throw new ChaveCriptografiaAusenteException(
        'APP_ENCRYPTION_KEY deve ter exatamente 32 bytes.'
    );
}

// incorreto — aceita qualquer tamanho
$this->chave = $chave; // sem validação de tamanho
```

### CRIPTO-008 — Chave ausente interrompe o bootstrap [ERRO]

Se `APP_ENCRYPTION_KEY` não estiver definida ou for vazia, o sistema não deve inicializar. A exceção deve ser capturada o mais cedo possível (construtor da classe de criptografia).

---

## 5. Versionamento de ciphertext

### CRIPTO-009 — Todo ciphertext deve ter prefixo de versão [ERRO]

Para permitir rotação de chave e migração de algoritmo sem quebrar dados existentes, todo dado criptografado deve começar com um prefixo de versão seguido de separador.

```
v1|nonce(24 bytes base64)|ciphertext(base64)   → Libsodium XChaCha20-Poly1305
```

Dados sem prefixo de versão são tratados como legado (OpenSSL AES-256-CBC) durante o período de migração.

```php
// correto — gravar com versão
$encoded = 'v1|' . base64_encode($nonce) . '|' . base64_encode($cifrado);

// correto — ler com detecção
if (str_starts_with($textoCifrado, 'v1|')) {
    // descriptografar com Libsodium
} else {
    // fallback: descriptografar com OpenSSL legado
}
```

### CRIPTO-010 — Migração gradual de dados legados [AVISO]

Dados criptografados com algoritmo legado devem ser re-criptografados com o algoritmo atual quando lidos e regravados. Isso permite migração orgânica sem script de migração em massa. A leitura legada deve emitir log de aviso em ambiente de desenvolvimento.

---

## 6. Rotação de chave

### CRIPTO-011 — Suporte a múltiplas versões de chave simultâneas [AVISO]

O sistema deve suportar pelo menos duas versões de chave ativas ao mesmo tempo (atual + anterior), permitindo rotação sem downtime. O prefixo de versão (CRIPTO-009) identifica qual chave usar na descriptografia.

### CRIPTO-012 — Rotação não requer re-encrypt em massa [AVISO]

Ao rotacionar a chave mestra, apenas novos dados e dados regravados usam a nova chave. Dados antigos permanecem legíveis pela chave anterior até serem organicamente regravados.

---

## 7. Gestão de memória

### CRIPTO-013 — Limpar chaves da memória após uso [AVISO]

Chaves e sub-chaves devem ser zeradas da memória RAM com `sodium_memzero()` após cada operação de criptografia/descriptografia. Isso reduz a janela de exposição em caso de dump de memória.

```php
// correto
$subchave = sodium_crypto_kdf_derive_from_key(/* ... */);
$cifrado = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt($texto, '', $nonce, $subchave);
sodium_memzero($subchave);

// incorreto — chave permanece na memória até o garbage collector
```

### CRIPTO-014 — Nunca logar chaves, sub-chaves ou nonces [ERRO]

Proibido incluir material criptográfico em logs, error_log, var_dump, debug_backtrace ou qualquer saída de diagnóstico.

---

## 8. Envelope encryption (futuro)

### CRIPTO-015 — Dados criptografados com DEK, DEK protegida por KEK [AVISO]

Para escala futura, cada registro (ou grupo de registros) deve ser criptografado com uma **Data Encryption Key (DEK)** única, e a DEK deve ser criptografada pela **Key Encryption Key (KEK)** mestra. Isso permite rotação de KEK sem re-encrypt de todos os dados.

```
┌─────────────────────────────────────────────┐
│ Registro no banco                           │
├────────────┬────────────────────────────────┤
│ dek_cifrada│ dados_cifrados_com_dek         │
└────────────┴────────────────────────────────┘
         │                    │
    KEK descriptografa   DEK descriptografa
```

**Nota:** Este controle é AVISO porque a implementação atual (chave mestra direto nos dados) é aceitável para a escala atual do projeto. Deve ser implementado quando o volume de dados justificar.

### CRIPTO-016 — DEK deve ser única por registro ou por lote [AVISO]

Se envelope encryption for implementada, cada DEK deve ser gerada com `random_bytes(32)` e nunca reutilizada entre registros ou tabelas diferentes.

---

## 9. Repositórios e uso da interface

### CRIPTO-017 — Todo campo financeiro sensível deve ser criptografado [ERRO]

Campos que contêm dados financeiros pessoais (valor, descrição de lançamento, nome do cartão, banco, dia de vencimento, faixa de renda, objetivo financeiro, etc.) devem ser armazenados criptografados no banco. O tipo da coluna no banco deve ser `TEXT`, nunca `VARCHAR` (ciphertext tem tamanho variável).

### CRIPTO-018 — Criptografia/descriptografia apenas no repositório [ERRO]

A criptografia e descriptografia de campos acontece exclusivamente na camada de repositório, nos métodos de persistência (`create`, `update`) e hidratação (`hydrate`, `fromRow`). Entidades, gerenciadores e handlers nunca manipulam dados criptografados diretamente.

```php
// correto — repositório criptografa antes de gravar
private function criptografarDados(Lancamento $lancamento): array
{
    return [
        'descricao' => $this->cripto->criptografar($lancamento->descricao()),
        'valor' => $this->cripto->criptografar($lancamento->valor()),
    ];
}

// incorreto — handler manipula criptografia
public function handleCriar(): void
{
    $valor = $this->cripto->criptografar($_POST['valor']); // ERRADO
}
```

### CRIPTO-019 — Interface segregada para testabilidade [ERRO]

A classe de criptografia deve implementar `CriptografiaInterface`. Repositórios dependem da interface, nunca da implementação concreta. Testes usam mock da interface.

```php
// correto
public function __construct(
    private readonly \wpdb $wpdb,
    private readonly CriptografiaInterface $cripto,
) {}

// incorreto — dependência concreta
public function __construct(
    private readonly \wpdb $wpdb,
    private readonly Criptografia $cripto, // classe concreta
) {}
```

---

## 10. Nonce e aleatoriedade

### CRIPTO-020 — Nonce gerado com CSPRNG [ERRO]

O nonce (número usado uma vez) deve ser gerado exclusivamente com `random_bytes()` do PHP (que usa o CSPRNG do sistema operacional). Proibido: `rand()`, `mt_rand()`, `uniqid()`, timestamp, contador previsível.

```php
// correto — 24 bytes para XChaCha20
$nonce = random_bytes(SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_NPUBBYTES);

// incorreto
$nonce = md5(uniqid()); // previsível
$nonce = random_bytes(16); // tamanho errado para XChaCha20 (precisa 24)
```

### CRIPTO-021 — Nonce nunca reutilizado com a mesma chave [ERRO]

Com XChaCha20 e nonce de 24 bytes, a probabilidade de colisão é negligível para volumes normais. Mas o nonce deve ser gerado aleatoriamente a cada operação — nunca armazenado e reutilizado, nunca derivado de dados previsíveis.

---

## Resumo de regras

| ID | Regra | Severidade |
|----|-------|-----------|
| CRIPTO-001 | Usar Libsodium nativo do PHP | ERRO |
| CRIPTO-002 | Proibido algoritmos obsoletos ou caseiros | ERRO |
| CRIPTO-003 | Todo ciphertext deve ser autenticado (AEAD) | ERRO |
| CRIPTO-004 | Descriptografia falha → exceção tipada | ERRO |
| CRIPTO-005 | Nunca usar chave mestra diretamente nos dados (KDF) | ERRO |
| CRIPTO-006 | Contextos de derivação distintos por finalidade | AVISO |
| CRIPTO-007 | Chave mestra deve ter exatamente 32 bytes | ERRO |
| CRIPTO-008 | Chave ausente interrompe o bootstrap | ERRO |
| CRIPTO-009 | Todo ciphertext com prefixo de versão | ERRO |
| CRIPTO-010 | Migração gradual de dados legados | AVISO |
| CRIPTO-011 | Suporte a múltiplas versões de chave | AVISO |
| CRIPTO-012 | Rotação sem re-encrypt em massa | AVISO |
| CRIPTO-013 | Limpar chaves da memória após uso | AVISO |
| CRIPTO-014 | Nunca logar material criptográfico | ERRO |
| CRIPTO-015 | Envelope encryption: DEK/KEK | AVISO |
| CRIPTO-016 | DEK única por registro ou lote | AVISO |
| CRIPTO-017 | Todo campo financeiro sensível criptografado | ERRO |
| CRIPTO-018 | Criptografia apenas no repositório | ERRO |
| CRIPTO-019 | Interface segregada para testabilidade | ERRO |
| CRIPTO-020 | Nonce gerado com CSPRNG | ERRO |
| CRIPTO-021 | Nonce nunca reutilizado com mesma chave | ERRO |

**Total: 21 regras (13 ERROs, 8 AVISOs)**

## Processo

### Fase 1 — Carregar a régua

1. Ler a seção **Padrões mínimos exigidos** deste documento.
2. Internalizar todas as 21 regras com seus IDs (CRIPTO-001 a CRIPTO-021), descrições, exemplos e severidades (ERRO/AVISO).
3. Não resumir nem recitar o documento de volta.

### Fase 2 — Identificar o PR aberto

1. Executar `gh pr list --state open --base main --json number,title,headBranch --limit 1` para encontrar o PR aberto mais recente.
2. Se não encontrar contra `main`, tentar `--base develop`.
3. Se houver mais de um PR aberto, listar todos e perguntar ao usuário qual auditar.
4. Se não houver PR aberto, informar o usuário e encerrar.
5. Executar `gh pr diff <numero>` para obter o diff completo do PR.

### Fase 3 — Identificar arquivos alvo

Filtrar os arquivos do diff e adicionar os arquivos core de criptografia (sempre auditados, mesmo que não alterados no PR):

**Sempre auditados:**
- `inc/Criptografia.php`
- `inc/CriptografiaInterface.php`
- `inc/entidades/ChaveCriptografiaAusenteException.php`
- `inc/entidades/CriptografiaException.php`

**Auditados se alterados no PR:**
- Todo arquivo em `inc/repositorios/` que injeta `CriptografiaInterface`
- `.env.example`, `.env.docker.example` (configuração de chave)
- `inc/handlers/handlers.php` (instanciação da classe de criptografia)

### Fase 4 — Auditar arquivo por arquivo

Para cada arquivo identificado:

1. Ler o arquivo completo (não apenas o diff — contexto importa).
2. Comparar contra **cada regra** de `docs/padroes-criptografia.md`, uma por uma, na ordem do documento.
3. Para cada violação encontrada, registrar:
   - **Arquivo** e **linha(s)** onde ocorre
   - **ID da regra** violada (ex.: CRIPTO-003)
   - **Severidade** (ERRO ou AVISO)
   - **Categoria** (Algoritmo, AEAD, KDF, Validação, Versionamento, Rotação, Memória, Envelope, Repositório, Nonce)
   - **O que está errado** — descrição concisa
   - **Como corrigir** — correção específica com código de exemplo usando Libsodium
4. Se o arquivo não viola nenhuma regra, registrar como aprovado.

### Fase 5 — Relatório

Apresentar o relatório ao usuário no seguinte formato:

```
## Relatório de auditoria de criptografia

**PR:** #<numero> — <titulo>
**Branch:** <branch>
**Arquivos auditados:** <quantidade>
**Régua:** docs/padroes-criptografia.md

### Resumo

- Erros: <quantidade> (de 13 regras ERRO)
- Avisos: <quantidade> (de 8 regras AVISO)
- Arquivos aprovados: <quantidade>

### Estado atual vs. Target

| Aspecto | Estado atual | Target | Gap |
|---------|-------------|--------|-----|
| Algoritmo | OpenSSL AES-256-CBC | Libsodium XChaCha20-Poly1305 | CRIPTO-001 |
| Autenticação | Nenhuma | AEAD nativo | CRIPTO-003 |
| KDF | Chave direta | HKDF via sodium_crypto_kdf | CRIPTO-005 |
| Validação | Sem check de tamanho | 32 bytes strict | CRIPTO-007 |
| Versionamento | Sem prefixo | v1|nonce|ciphertext | CRIPTO-009 |
| Memória | Sem zeroing | sodium_memzero() | CRIPTO-013 |

### Violações

#### <arquivo.php>

| Linha | Regra | Severidade | Categoria | Descrição | Correção |
|-------|-------|------------|-----------|-----------|----------|
| 30 | CRIPTO-001 | ERRO | Algoritmo | Usa openssl_encrypt | Migrar para sodium_crypto_aead_xchacha20poly1305_ietf_encrypt |

#### <outro-arquivo.php>
Aprovado — nenhuma violação encontrada.
```

### Fase 6 — Plano de migração

Se houver violações do tipo ERRO:

1. Classificar as correções em **fases de migração**:
   - **Fase 1 (imediata):** Validação de chave (CRIPTO-007, CRIPTO-008) — não quebra dados existentes.
   - **Fase 2 (nova classe):** Criar `CriptografiaV2` com Libsodium + KDF + versionamento (CRIPTO-001, CRIPTO-003, CRIPTO-005, CRIPTO-009).
   - **Fase 3 (migração):** Atualizar `CriptografiaInterface` para suportar fallback legado. Dados migram organicamente (CRIPTO-010).
   - **Fase 4 (limpeza):** Remover código OpenSSL quando todos os dados estiverem em v1. Memory zeroing (CRIPTO-013).
   - **Fase 5 (futuro):** Envelope encryption (CRIPTO-015, CRIPTO-016).

2. Para cada fase, indicar exatamente quais arquivos mudam e o que muda.
3. Perguntar ao usuário: "Quer que eu execute a Fase 1 agora?"

Se houver apenas AVISOs ou nenhuma violação:

> "Implementação de criptografia em conformidade com o target state. Os avisos são recomendações de hardening — quer que eu implemente algum?"

## Regras

- **Nunca alterar código durante a auditoria.** A skill é read-only até o usuário pedir correção explicitamente.
- **Sempre auditar os arquivos core de criptografia**, mesmo que não alterados no PR. A segurança criptográfica é sistêmica.
- **Sempre referenciar o ID da regra violada.** O relatório deve ser rastreável ao documento de padrões.
- **Nunca inventar regras.** A régua é exclusivamente o `docs/padroes-criptografia.md` — sem opinião, sem sugestões extras.
- **Ser metódica e processual.** Cada arquivo é comparado contra cada regra, na ordem do documento, sem pular.
- **Fidelidade ao documento.** Se o código viola uma regra do documento, reportar. Se o documento não cobre o caso, não reportar.
- **Priorizar por risco de dados.** AEAD e KDF vêm antes de memory zeroing e envelope encryption.
- **Mostrar o relatório completo antes de qualquer ação.** Nunca executar correções sem aprovação explícita.
- **O plano de migração é obrigatório.** Diferente das outras auditorias que corrigem pontualmente, criptografia exige migração gradual para não quebrar dados existentes.
