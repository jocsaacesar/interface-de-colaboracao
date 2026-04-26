---
documento: padroes-multi-tenant
versao: 1.1.0
criado: 2026-04-13
atualizado: 2026-04-16
total_regras: 10
severidades:
  erro: 7
  aviso: 3
escopo: Isolamento de dados e segurança em arquitetura multi-tenant da BGR Software House
aplica_a: ["unibgr-campusdigital"]
requer: ["padroes-seguranca", "padroes-php", "padroes-poo"]
substitui: []
---

# Padrões Multi-Tenant — BGR Software House

> Documento constitucional. Contrato de entrega entre a BGR e todo
> desenvolvedor que toca isolamento de dados, queries ou catálogo
> em projetos multi-tenant.
> Código que viola regras ERRO não é discutido — é devolvido.

---

## Como usar este documento

### Para o desenvolvedor

1. Leia este documento inteiro antes de tocar em qualquer query que acesse tabelas com `tenant_id`.
2. Use os IDs das regras (MT-001 a MT-010) para referenciar em PRs e code reviews.
3. Consulte o DoD no final antes de abrir qualquer Pull Request.

### Para o auditor (humano ou IA)

1. Leia o frontmatter para entender escopo e dependências.
2. Audite o código contra cada regra por ID.
3. Classifique violações pela severidade definida neste documento.
4. Referencie violações pelo ID da regra (ex.: "viola MT-003").

### Para o Claude Code

1. Leia o frontmatter para determinar se este documento se aplica ao projeto em questão.
2. Em code review, verifique cada regra ERRO como bloqueante — nenhum merge enquanto houver violação.
3. Regras AVISO devem ser reportadas, mas aceitam justificativa por escrito no PR.
4. Referencie sempre pelo ID (ex.: "viola MT-001") para rastreabilidade.

---

## Severidades

| Nível | Significado | Ação |
|-------|-------------|------|
| **ERRO** | Violação inegociável | Bloqueia merge. Corrigir antes de review. |
| **AVISO** | Recomendação forte | Deve ser justificada por escrito se ignorada. |

---

## 1. Isolamento de Dados

### MT-001 — Toda query em tabela com tenant_id DEVE filtrar por tenant [ERRO]

**Regra:** Toda query SELECT, UPDATE ou DELETE em tabela que possua coluna `tenant_id` DEVE incluir `WHERE tenant_id = ?` (ou equivalente via trait). Sem exceção. Query sem filtro de tenant é leak de dados cross-tenant.

**Verifica:** `grep -rn "SELECT\|UPDATE\|DELETE" inc/ | grep -v tenant_id` — toda query em tabela com `tenant_id` deve filtrar.

**Por quê na BGR:** Multi-tenant com dados sensíveis (financeiros, educacionais, de saúde) — um SELECT sem filtro expõe dados de empresa A pra empresa B. Não existe "vou filtrar depois no PHP". O filtro é no SQL ou não existe.

**Exemplo correto:**
```php
$this->wpdb->get_results($this->wpdb->prepare(
    "SELECT * FROM {$this->table_name()}
     WHERE user_id = %d AND tenant_id = %d",
    $user_id,
    $this->tenant_id()
));
```

**Exemplo incorreto:**
```php
// VIOLAÇÃO: sem filtro de tenant
$this->wpdb->get_results($this->wpdb->prepare(
    "SELECT * FROM {$this->table_name()} WHERE user_id = %d",
    $user_id
));
```

### MT-002 — find_all() DEVE receber tenant_id obrigatório [ERRO]

**Regra:** Todo método `find_all()` em repositório de tabela com `tenant_id` DEVE filtrar por tenant. Pode ser via parâmetro explícito ou via `TenantAwareTrait` que injeta automaticamente.

**Verifica:** `grep -rn "find_all" inc/core/repositorios/` — todo `find_all` em tabela com `tenant_id` deve conter filtro ou usar `TenantAwareTrait`.

**Por quê na BGR:** `find_all()` sem escopo é o vetor mais comum de leak. No discovery do plano 0010, 49 repositórios tinham `find_all()` sem escopo — 23 eram CRITICAL (dados sensíveis).

**Exemplo correto:**
```php
public function find_all(): array
{
    $rows = $this->wpdb->get_results($this->wpdb->prepare(
        "SELECT * FROM {$this->table_name()}
         WHERE tenant_id = %d ORDER BY nome ASC",
        $this->tenant_id()
    ));
    return array_map([Entity::class, 'from_row'], $rows ?: []);
}
```

### MT-005 — Conteúdo exclusivo de tenant X NÃO pode aparecer pra tenant Y [ERRO]

**Regra:** Dados com `tenant_id = X` são invisíveis pra qualquer outro tenant. Não existe "visibilidade parcial" entre tenants. O único compartilhamento é o catálogo base (`tenant_id = 0`).

**Verifica:** Testar com 2 tenants — query com tenant A nunca retorna dados de tenant B. Inspecionar repos que listam dados.

**Por quê na BGR:** Isolamento é contrato com o cliente. Empresa que compra white-label espera que seus dados sejam exclusivos. Violação é quebra de contrato, não bug técnico.

---

## 2. Catálogo Extensível

### MT-003 — Catálogo base (tenant_id = 0) é imutável por tenants [ERRO]

**Regra:** Itens de catálogo com `tenant_id = 0` (base BGR) NÃO podem ser editados ou deletados por nenhum tenant. Somente o tenant BGR (id = 1) ou um administrador global pode modificar o catálogo base.

**Verifica:** `grep -rn "update_catalogo\|delete_catalogo" inc/` — todo update/delete deve ter guard `if ($item->tenant_id() === 0) throw`.

**Por quê na BGR:** O catálogo base é o produto. Se um tenant edita uma competência base, todos os outros tenants são afetados. Catálogo base é lei — extensões são democracia.

**Exemplo correto:**
```php
public function update_catalogo(int $item_id, array $data): bool
{
    $item = $this->find_by_id($item_id);
    if ($item->tenant_id() === 0) {
        throw new \DomainException('Catálogo base é imutável.');
    }
    if ($item->tenant_id() !== $this->tenant_id()) {
        throw new \DomainException('Item pertence a outro tenant.');
    }
    // ... update
}
```

### MT-004 — Query de catálogo extensível DEVE usar IN (0, :current) [ERRO]

**Regra:** Queries que listam catálogo extensível (competências, habilidades, perguntas, etc.) DEVEM retornar itens do catálogo base (`tenant_id = 0`) mais extensões do tenant atual (`tenant_id = :current`). Nunca extensões de outros tenants.

**Verifica:** `grep -rn "tenant_id IN" inc/` — queries de catálogo devem usar `IN (0, %d)` com tenant atual.

**Por quê na BGR:** O produto inclui o catálogo base + extensões próprias. Query com `WHERE tenant_id = :current` esconde o catálogo base. Query sem filtro mostra extensões de todos.

**Exemplo correto:**
```php
$this->wpdb->get_results($this->wpdb->prepare(
    "SELECT * FROM {$this->table_name()}
     WHERE tenant_id IN (0, %d)
     ORDER BY nome ASC",
    $this->tenant_id()
));
```

---

## 3. Resolução de Contexto

### MT-007 — current_tenant_id() NUNCA retorna null em contexto autenticado [ERRO]

**Regra:** A função `unibgr_current_tenant_id()` DEVE retornar um inteiro válido quando o usuário está autenticado. Se retornar `null`, é bug de configuração (blog_id sem tenant cadastrado). Código que depende de tenant DEVE tratar `null` como erro, não como ausência.

**Verifica:** `grep -rn "current_tenant_id()" inc/` — todo uso em contexto auth deve ter guard `if ($tenant_id === null) throw`.

**Por quê na BGR:** Todo o isolamento depende de `current_tenant_id()`. Se retorna `null` e o código trata como "sem filtro", os dados ficam expostos. `null` em contexto autenticado é falha grave, não caso válido.

**Exemplo correto:**
```php
$tenant_id = unibgr_current_tenant_id();
if ($tenant_id === null) {
    throw new \RuntimeException('Tenant não configurado para o blog atual.');
}
```

---

## 4. Handlers e Ownership

### MT-006 — Handler que recebe ID externo DEVE validar ownership do tenant [AVISO]

**Regra:** Todo handler AJAX ou REST que recebe um ID de recurso externo (item_id, pedido_id, licenca_id, etc.) DEVE verificar que o recurso pertence ao tenant do usuário autenticado antes de processar.

**Verifica:** Inspecionar handlers AJAX/REST — todo `$_POST['*_id']` ou `$request->get_param('*_id')` deve ter check de `tenant_id` antes de processar.

**Por quê na BGR:** IDOR (Insecure Direct Object Reference) é o vetor mais comum em multi-tenant. Receber `pedido_id=42` e processar sem verificar se pertence ao tenant do usuário é bypass de isolamento.

**Exemplo correto:**
```php
public function handle_detalhes_pedido(): void
{
    $this->check_permission();
    $pedido_id = absint($_POST['pedido_id']);
    $pedido = $this->pedidoRepo->find_by_id($pedido_id);

    if (!$pedido || $pedido->tenant_id() !== unibgr_current_tenant_id()) {
        wp_send_json_error(['erro' => 'Pedido não encontrado.'], 404);
        return;
    }
    // ... processar
}
```

---

## 5. Migrations e Backfill

### MT-008 — Migration que adiciona tenant_id DEVE backfill para tenant 1 [ERRO]

**Regra:** Toda migration que adiciona coluna `tenant_id` em tabela existente DEVE usar `DEFAULT 1` (BGR) para dados existentes. Dados que são catálogo base DEVEM receber `DEFAULT 0` seguido de backfill explícito.

**Verifica:** Inspecionar migrations que adicionam `tenant_id` — `ALTER TABLE ... ADD COLUMN tenant_id` deve ter `DEFAULT 1` ou `DEFAULT 0` explícito.

**Por quê na BGR:** Dados existentes são todos da BGR (tenant 1). Migration sem default ou com `DEFAULT NULL` deixa registros sem tenant, que podem vazar em queries com `WHERE tenant_id = ?` por não matcharem nenhum filtro — ou pior, matcharem todos.

**Exemplo correto:**
```sql
ALTER TABLE wpro_mapa_testes
    ADD COLUMN tenant_id INT UNSIGNED NOT NULL DEFAULT 1;
CREATE INDEX idx_mapa_testes_tenant ON wpro_mapa_testes (tenant_id);
```

### MT-009 — Transfer de licença entre tenants requer autorização explícita [AVISO]

**Regra:** Transferência de licença entre tenants diferentes DEVE ser bloqueada por padrão. Se o negócio exigir cross-tenant transfer, DEVE haver flag explícita (`cross_tenant_transfer = true`) e log de auditoria.

**Verifica:** `grep -rn "transfer" inc/` — métodos de transfer de licença devem ter guard `if ($from_tenant !== $to_tenant) throw` ou flag explícita.

**Por quê na BGR:** Licença é ativo financeiro. Transfer cross-tenant sem controle é equivalente a transfer bancária sem autorização.

---

## 6. Repositórios

### MT-010 — Novo repositório DEVE herdar TenantAwareTrait [ERRO]

**Regra:** Todo novo repositório criado em tabela que possui `tenant_id` DEVE usar `TenantAwareTrait`. O trait garante que queries incluam filtro de tenant automaticamente.

**Verifica:** `grep -rL "TenantAwareTrait" inc/core/repositorios/` em repos de tabelas com `tenant_id` — nenhum deve ficar de fora.

**Por quê na BGR:** Filtro manual é esquecível. Trait é automático. Em code review, é mais fácil auditar "usa o trait?" do que verificar cada query individual.

**Exemplo correto:**
```php
final class NovoRepository
{
    use TenantAwareTrait;

    public function find_by_user(int $user_id): array
    {
        $rows = $this->wpdb->get_results($this->wpdb->prepare(
            "SELECT * FROM {$this->table_name()}
             WHERE user_id = %d {$this->where_tenant()}",
            $user_id,
            $this->tenant_id()
        ));
        return array_map([Entity::class, 'from_row'], $rows ?: []);
    }
}
```

---

## DoD — Definition of Done (Multi-Tenant)

Antes de abrir PR que toca isolamento de dados ou queries com tenant_id:

- [ ] Toda query em tabela com `tenant_id` filtra por tenant (MT-001)
- [ ] `find_all()` em repos com tenant filtra por tenant (MT-002)
- [ ] Catálogo base não é editável por tenants (MT-003)
- [ ] Queries de catálogo usam `IN (0, :current)` (MT-004)
- [ ] Dados cross-tenant não vazam (MT-005)
- [ ] Handlers validam ownership por tenant (MT-006)
- [ ] `current_tenant_id()` não retorna null em contexto auth (MT-007)
- [ ] Migrations de tenant_id fazem backfill correto (MT-008)
- [ ] Transfer cross-tenant bloqueada por padrão (MT-009)
- [ ] Novos repos usam TenantAwareTrait (MT-010)

---

## Versionamento

| Versão | Data | Responsável | Alteração |
|--------|------|-------------|-----------|
| 1.0.0 | 2026-04-13 | Joc + Reliable | Criação — 10 regras (7 ERRO, 3 AVISO) |
| 1.1.0 | 2026-04-16 | Reliable | Adição de campo **Verifica** em todas as 10 regras |

---

*BGR Software House. Isolamento é contrato, não feature.*
