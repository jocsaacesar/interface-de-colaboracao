---
name: auditar-wordpress
description: Audita uso de APIs e convenções WordPress do PR aberto contra as regras definidas em docs/padroes-wordpress.md. Cobre $wpdb, nonces, hooks, multisite, transações e migrations. Trigger manual apenas.
---

# /auditar-wordpress — Auditora de padrões WordPress

Lê as regras de `docs/padroes-wordpress.md`, identifica os arquivos PHP alterados no PR aberto (não mergeado) e compara cada arquivo contra cada regra de uso correto das APIs WordPress. Foco em: acesso a banco ($wpdb), sanitização/escape nativos, nonces, hooks, enqueue de assets, multisite, transações e migrations.

Complementa `/auditar-php` (sintaxe), `/auditar-poo` (arquitetura), `/auditar-testes` (testes) e `/auditar-seguranca` (segurança).

## Quando usar

- **APENAS** quando o usuário digitar `/auditar-wordpress` explicitamente.
- Rodar antes de mergear um PR — funciona como gate de conformidade WordPress.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Padrões mínimos exigidos

> Esta seção contém os padrões completos usados pela auditoria. Edite para personalizar ao seu projeto.

# Padrão WordPress

## Descrição

Documento de referência para auditoria de código WordPress no projeto Acertando os Pontos. Define como usar corretamente as APIs nativas do WordPress, convenções de multisite, hooks, enqueue de assets e integração com o ecossistema WP. A skill `/auditar-wordpress` lê este documento e compara contra o código-alvo.

Complementa `docs/padroes-seguranca.md` (que cobre segurança genérica). Este documento cobre **uso correto das APIs e convenções WordPress**.

## Escopo

- Todo código PHP dentro de `acertandoospontos/inc/` e `acertandoospontos/paginas/`
- Arquivos JavaScript em `acertandoospontos/assets/js/`
- Contexto: WordPress Multisite, subsite tenant (blog_id 9), integração via endpoint

## Referências

- `docs/padroes-seguranca.md` — Regras de segurança (complementar)
- `referencias/entrada/CLAUDE-UniBGR.md` — Convenções da plataforma-mãe
- [WordPress Plugin Handbook — Security](https://developer.wordpress.org/plugins/security/)
- [WordPress Coding Standards](https://developer.wordpress.org/coding-standards/)

## Severidade

- **ERRO** — Violação bloqueia aprovação. Deve ser corrigida antes de merge.
- **AVISO** — Recomendação forte. Deve ser justificada se ignorada.

---

## 1. Acesso ao banco de dados

### WP-001 — $wpdb->prepare() em toda query com dados variáveis [ERRO]

Toda query que recebe dados variáveis usa `$wpdb->prepare()` com placeholders tipados: `%s` para strings, `%d` para inteiros, `%f` para floats.

```php
// correto
$wpdb->get_results($wpdb->prepare(
    "SELECT * FROM {$this->tableName()} WHERE user_id = %d AND status = %s",
    $userId,
    $status
));

// incorreto
$wpdb->get_results("SELECT * FROM {$this->tableName()} WHERE user_id = $userId");
```

### WP-002 — Helpers seguros para INSERT e UPDATE [AVISO]

Preferir `$wpdb->insert()` e `$wpdb->update()` com array de formato. Queries manuais apenas quando os helpers não cobrem (ex.: transações atômicas, `SELECT FOR UPDATE`).

```php
// correto — helper seguro
$wpdb->insert($this->tableName(), [
    'user_id' => $userId,
    'valor_cents' => $valorCriptografado,
    'status' => 'pendente',
], ['%d', '%s', '%s']);

// correto — query manual quando necessário (transação)
$wpdb->query('START TRANSACTION');
$wpdb->get_row($wpdb->prepare(
    "SELECT * FROM {$this->tableName()} WHERE id = %d FOR UPDATE",
    $id
));
```

### WP-003 — Nome de tabela via método privado, nunca hardcoded [ERRO]

Todo repositório define o nome da tabela em método privado `tableName()` usando o prefixo do WordPress.

```php
// correto
private function tableName(): string
{
    return $this->wpdb->prefix . 'financeiro_lancamentos';
}

// incorreto
$tabela = 'wpro_9_financeiro_lancamentos'; // hardcoded
```

### WP-004 — $wpdb->prefix para tabelas do tenant, $wpdb->base_prefix para tabelas globais [ERRO]

No contexto multisite:
- `$wpdb->prefix` retorna o prefixo do subsite atual (ex.: `wpro_9_`) — usar para tabelas do tenant.
- `$wpdb->base_prefix` retorna o prefixo global (ex.: `wpro_`) — usar apenas para tabelas compartilhadas da UniBGR (quando autorizado).

```php
// correto — tabela do tenant
$this->wpdb->prefix . 'financeiro_lancamentos'; // wpro_9_financeiro_lancamentos

// correto — tabela global (leitura autorizada)
$this->wpdb->base_prefix . 'mapa_testes'; // wpro_mapa_testes

// incorreto — hardcoded
'wpro_9_financeiro_lancamentos';
```

---

## 2. Sanitização e escape (APIs WordPress)

### WP-005 — Funções nativas de sanitização por tipo de dado [ERRO]

Cada tipo de dado tem sua função de sanitização. Nunca sanitizar genérico.

| Tipo de dado | Função | Uso |
|-------------|--------|-----|
| Texto curto | `sanitize_text_field()` | Nomes, descrições, status |
| Inteiro positivo | `absint()` | IDs, quantidades, valores em centavos |
| URL (para banco) | `esc_url_raw()` | URLs antes de persistir |
| HTML seguro | `wp_kses_post()` | Conteúdo rico com tags permitidas |
| Email | `sanitize_email()` | Endereços de email |
| Nome de arquivo | `sanitize_file_name()` | Uploads |

```php
// correto — cada dado com sua função
$descricao = sanitize_text_field($_POST['descricao'] ?? '');
$contaId = absint($_POST['conta_id'] ?? 0);
$email = sanitize_email($_POST['email'] ?? '');
```

### WP-006 — Funções nativas de escape por contexto de saída [ERRO]

Cada contexto de saída tem sua função de escape.

| Contexto | Função | Exemplo |
|----------|--------|---------|
| Dentro de tags HTML | `esc_html()` | `<p><?php echo esc_html($nome); ?></p>` |
| Atributos HTML | `esc_attr()` | `<input value="<?php echo esc_attr($valor); ?>">` |
| URLs em href/src | `esc_url()` | `<a href="<?php echo esc_url($link); ?>">` |
| Contexto JavaScript | `wp_json_encode()` | `<script>var d = <?php echo wp_json_encode($dados); ?>;</script>` |

### WP-007 — Nunca usar echo direto com dados do banco [ERRO]

Todo dado exibido é escapado, mesmo que venha do banco (que pode ter sido comprometido).

```php
// correto
echo esc_html($lancamento->descricao());

// incorreto
echo $lancamento->descricao();
```

---

## 3. Nonces e AJAX

### WP-008 — Nonce gerado com wp_create_nonce() e ação específica [ERRO]

Cada módulo usa uma ação de nonce descritiva e única.

```php
// correto — ação específica do módulo
$nonce = wp_create_nonce('acp_financeiro_action');

// incorreto — ação genérica
$nonce = wp_create_nonce('nonce');
$nonce = wp_create_nonce('ajax');
```

### WP-009 — Nonce localizado via wp_localize_script() [ERRO]

O nonce é injetado no JavaScript via `wp_localize_script()`, nunca hardcoded no HTML ou em variável global.

```php
// correto
wp_localize_script('acp-financeiro', 'acpFinanceiro', [
    'ajaxUrl' => admin_url('admin-ajax.php'),
    'nonce' => wp_create_nonce('acp_financeiro_action'),
]);
```

```javascript
// correto — JavaScript lê da variável localizada
fetch(acpFinanceiro.ajaxUrl, {
    method: 'POST',
    body: formData, // formData inclui nonce: acpFinanceiro.nonce
});
```

### WP-010 — check_ajax_referer() com ação e campo corretos [ERRO]

A verificação usa a mesma string de ação do `wp_create_nonce()` e o nome do campo correto.

```php
// correto
check_ajax_referer('acp_financeiro_action', 'nonce');

// incorreto — ação diferente da geração
check_ajax_referer('generic_nonce', 'nonce');
```

### WP-011 — wp_send_json_success() e wp_send_json_error() para respostas [ERRO]

Handlers sempre respondem com as funções nativas do WordPress. Nunca `echo json_encode()` + `die()`.

```php
// correto
wp_send_json_success(['mensagem' => 'Lançamento criado.', 'id' => $id]);
wp_send_json_error(['mensagem' => 'Dados inválidos.'], 400);

// incorreto
echo json_encode(['success' => true]);
die();
```

---

## 4. Hooks e registro de handlers

### WP-012 — Handlers registrados via add_action no register() [ERRO]

Todo handler tem método `register()` que conecta os métodos ao sistema de hooks do WordPress.

```php
// correto
class FinanceiroAjaxHandler
{
    public function register(): void
    {
        add_action('wp_ajax_acp_criar_lancamento', [$this, 'handleCriarLancamento']);
        add_action('wp_ajax_acp_listar_lancamentos', [$this, 'handleListarLancamentos']);
    }
}

// incorreto — hooks soltos em functions.php
add_action('wp_ajax_acp_criar_lancamento', 'criar_lancamento_callback');
```

### WP-013 — Prefixo acp_ em todas as actions AJAX [ERRO]

Toda action AJAX do módulo usa prefixo `acp_` para evitar colisão com outros módulos ou plugins.

```php
// correto
add_action('wp_ajax_acp_criar_lancamento', [$this, 'handleCriarLancamento']);

// incorreto — sem prefixo, pode colidir
add_action('wp_ajax_criar_lancamento', [$this, 'handleCriarLancamento']);
```

### WP-014 — Sem wp_ajax_nopriv_ para endpoints autenticados [ERRO]

Endpoints que manipulam dados financeiros nunca usam `wp_ajax_nopriv_` (que permite acesso sem login).

```php
// correto — apenas usuários logados
add_action('wp_ajax_acp_criar_lancamento', [$this, 'handleCriarLancamento']);

// incorreto — abre pra qualquer visitante
add_action('wp_ajax_nopriv_acp_criar_lancamento', [$this, 'handleCriarLancamento']);
```

---

## 5. Enqueue de assets

### WP-015 — CSS e JS via wp_enqueue_script/style [ERRO]

Assets são carregados com as funções nativas do WordPress, nunca com `<script>` ou `<link>` direto no HTML.

```php
// correto
function acp_enqueue_assets(): void
{
    if (!is_page('dashboard-financeiro')) {
        return; // só carrega onde precisa
    }

    wp_enqueue_style(
        'acp-financeiro',
        get_stylesheet_directory_uri() . '/acertandoospontos/assets/css/financeiro.css',
        [],
        '1.0.0'
    );

    wp_enqueue_script(
        'acp-financeiro',
        get_stylesheet_directory_uri() . '/acertandoospontos/assets/js/financeiro.js',
        [],
        '1.0.0',
        true // no footer
    );
}
add_action('wp_enqueue_scripts', 'acp_enqueue_assets');
```

### WP-016 — Assets carregados condicionalmente [AVISO]

Só carregar CSS e JS nas páginas que os usam. Nunca carregar em todas as páginas do site.

---

## 6. Multisite

### WP-017 — get_users() sempre com blog_id explícito [ERRO]

No multisite, `get_users()` sem `blog_id` filtra pelo blog corrente e perde usuários de outros subsites. Alinhado com a Lição Arquitetural #6 da UniBGR.

```php
// correto — busca no blog do tenant
$usuarios = get_users([
    'blog_id' => get_current_blog_id(),
    'role' => 'acp_user',
]);

// correto — busca network-wide
$usuarios = get_users([
    'blog_id' => 0,
    'role__in' => ['acp_user', 'acp_admin'],
]);

// incorreto — sem blog_id, filtra pelo blog corrente silenciosamente
$usuarios = get_users(['role' => 'acp_user']);
```

### WP-018 — Roles registradas no blog do tenant [ERRO]

Roles do Acertando os Pontos (`acp_user`, `acp_admin`) são registradas no blog_id do tenant, não globalmente.

```php
// correto
switch_to_blog($tenantBlogId);
add_role('acp_user', 'Usuário ACP', ['read' => true, 'acp_view_dashboard' => true]);
add_role('acp_admin', 'Admin ACP', ['read' => true, 'acp_view_dashboard' => true, 'acp_manage' => true]);
restore_current_blog();
```

### WP-019 — Sem switch_to_blog() desnecessário [AVISO]

`switch_to_blog()` é custoso. Só usar quando realmente precisa acessar dados de outro subsite. Para o subsite corrente, `$wpdb->prefix` já retorna o prefixo correto.

---

## 7. Transações e concorrência

### WP-020 — Operações financeiras dentro de transação [ERRO]

Qualquer operação que modifica saldo, cria lançamento ou altera estado financeiro usa transação do banco.

```php
// correto — transação atômica
$this->wpdb->query('START TRANSACTION');

try {
    $saldo = $this->wpdb->get_var($this->wpdb->prepare(
        "SELECT saldo_cents FROM {$this->tableName()} WHERE id = %d FOR UPDATE",
        $contaId
    ));

    if ($saldo < $valorCents) {
        $this->wpdb->query('ROLLBACK');
        throw new SaldoInsuficienteException($contaId, $valorCents);
    }

    $this->wpdb->update($this->tableName(), [
        'saldo_cents' => $saldo - $valorCents,
    ], ['id' => $contaId], ['%d'], ['%d']);

    $this->wpdb->query('COMMIT');
} catch (\Throwable $e) {
    $this->wpdb->query('ROLLBACK');
    throw $e;
}
```

### WP-021 — SELECT FOR UPDATE em operações de saldo [ERRO]

Leituras que precedem escrita de saldo usam `FOR UPDATE` para lock da linha e prevenir race condition.

### WP-022 — Idempotência em operações críticas [AVISO]

Operações de pagamento, transferência e checkout devem ser idempotentes — processar a mesma requisição duas vezes não duplica o efeito.

---

## 8. Migrations

### WP-023 — Migrations numeradas sequencialmente [ERRO]

Arquivos em `inc/migracoes/` seguem numeração sequencial sem gaps: `001_`, `002_`, etc.

```
inc/migracoes/
├── 001_create_financeiro_categorias.php
├── 002_create_financeiro_contas.php
├── 003_create_financeiro_lancamentos.php
└── 004_create_financeiro_metas.php
```

### WP-024 — Migrations idempotentes [ERRO]

Toda migration pode rodar múltiplas vezes sem quebrar. Usar `CREATE TABLE IF NOT EXISTS`, `INSERT ... ON DUPLICATE KEY UPDATE`, guards com `SELECT`.

```php
// correto
$wpdb->query("CREATE TABLE IF NOT EXISTS {$tabela} (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

// incorreto — explode na segunda execução
$wpdb->query("CREATE TABLE {$tabela} (...)");
```

### WP-025 — Sem dados hardcoded em migrations [AVISO]

Migrations criam estrutura (tabelas, colunas, índices). Dados de seed vão em migration separada com TRUNCATE + INSERT para idempotência.

---

## Checklist de auditoria

A skill `/auditar-wordpress` deve verificar, para cada arquivo:

**Banco de dados:**
- [ ] `$wpdb->prepare()` em toda query com dados variáveis
- [ ] Helpers seguros ($wpdb->insert, $wpdb->update) quando aplicável
- [ ] Nome de tabela via `tableName()`, nunca hardcoded
- [ ] `$wpdb->prefix` para tenant, `$wpdb->base_prefix` para global

**Sanitização e escape:**
- [ ] Funções nativas por tipo de dado (sanitize_text_field, absint, etc.)
- [ ] Escape por contexto de saída (esc_html, esc_attr, esc_url)
- [ ] Sem echo direto de dados do banco

**Nonces e AJAX:**
- [ ] Nonce com ação específica do módulo (acp_*)
- [ ] Nonce localizado via wp_localize_script()
- [ ] check_ajax_referer() com ação e campo corretos
- [ ] Respostas via wp_send_json_success/error

**Hooks:**
- [ ] Handlers registrados em register() via add_action
- [ ] Prefixo acp_ em todas as actions
- [ ] Sem wp_ajax_nopriv_ para endpoints autenticados

**Assets:**
- [ ] CSS/JS via wp_enqueue_script/style
- [ ] Assets carregados condicionalmente

**Multisite:**
- [ ] get_users() com blog_id explícito
- [ ] Roles registradas no blog do tenant
- [ ] switch_to_blog() apenas quando necessário

**Transações:**
- [ ] Operações financeiras dentro de transação
- [ ] SELECT FOR UPDATE em operações de saldo
- [ ] Idempotência em operações críticas

**Migrations:**
- [ ] Numeração sequencial sem gaps
- [ ] CREATE TABLE IF NOT EXISTS (idempotente)
- [ ] Seed separado com TRUNCATE + INSERT

## Processo

### Fase 1 — Carregar a régua

1. Ler a seção **Padrões mínimos exigidos** deste documento.
2. Internalizar todas as regras com seus IDs, descrições, exemplos e severidades (ERRO/AVISO).
3. Não resumir nem recitar o documento de volta.

### Fase 2 — Identificar o PR aberto

1. Executar `gh pr list --state open --base develop --json number,title,headBranch --limit 1` para encontrar o PR aberto mais recente contra `develop`.
2. Se houver mais de um PR aberto, listar todos e perguntar ao usuário qual auditar.
3. Se não houver PR aberto, informar o usuário e encerrar.
4. Executar `gh pr diff <numero>` para obter o diff completo do PR.
5. Filtrar arquivos `.php` e `.js` dentro de `acertandoospontos/`.

### Fase 3 — Auditar arquivo por arquivo

Para cada arquivo alterado no PR:

1. Ler o arquivo completo (não apenas o diff — contexto importa).
2. Comparar contra **cada regra** de `docs/padroes-wordpress.md`, uma por uma, na ordem do documento.
3. Para cada violação encontrada, registrar:
   - **Arquivo** e **linha(s)** onde ocorre
   - **ID da regra** violada (ex.: WP-004)
   - **Severidade** (ERRO ou AVISO)
   - **O que está errado** — descrição concisa
   - **Como corrigir** — correção específica para aquele trecho, usando a API WordPress correta
4. Se o arquivo não viola nenhuma regra, registrar como aprovado.

### Fase 4 — Relatório

Apresentar o relatório ao usuário no seguinte formato:

```
## Relatório de auditoria WordPress

**PR:** #<numero> — <titulo>
**Branch:** <branch>
**Arquivos auditados:** <quantidade>
**Régua:** docs/padroes-wordpress.md

### Resumo

- Erros: <quantidade>
- Avisos: <quantidade>
- Arquivos aprovados: <quantidade>

### Violações

#### <arquivo.php>

| Linha | Regra | Severidade | Descrição | Correção |
|-------|-------|------------|-----------|----------|
| 18 | WP-003 | ERRO | Tabela hardcoded | Usar tableName() com $wpdb->prefix |
| 33 | WP-011 | ERRO | echo json_encode + die | Usar wp_send_json_success() |

#### <outro-arquivo.php>
✅ Aprovado — nenhuma violação encontrada.
```

### Fase 5 — Plano de correções

Se houver violações do tipo ERRO:

1. Listar as correções necessárias agrupadas por arquivo.
2. Ordenar por severidade (ERROs primeiro, AVISOs depois).
3. Para cada correção, indicar exatamente o que mudar e onde, referenciando a API WordPress correta.
4. Perguntar ao usuário: "Quer que eu execute as correções agora?"

Se houver apenas AVISOs ou nenhuma violação:

> "Nenhum erro bloquante. Os avisos são recomendações — quer que eu corrija algum?"

## Regras

- **Nunca alterar código durante a auditoria.** A skill é read-only até o usuário pedir correção explicitamente.
- **Nunca auditar arquivos fora do PR.** Apenas arquivos alterados no PR aberto.
- **Sempre referenciar o ID da regra violada.** O relatório deve ser rastreável ao documento de padrões.
- **Nunca inventar regras.** A régua é exclusivamente o `docs/padroes-wordpress.md` — sem opinião, sem sugestões extras.
- **Ser metódica e processual.** Cada arquivo é comparado contra cada regra, na ordem do documento, sem pular.
- **Fidelidade ao documento.** Se o código viola uma regra do documento, reportar. Se o documento não cobre o caso, não reportar.
- **Sempre indicar a API WordPress correta na correção.** Nunca sugerir solução genérica quando existe função nativa.
- **Mostrar o relatório completo antes de qualquer ação.** Nunca executar correções sem aprovação explícita.
