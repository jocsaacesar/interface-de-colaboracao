---
documento: padroes-wordpress
versao: 2.1.0
criado: 2025-01-01
atualizado: 2026-04-16
total_regras: 25
severidades:
  erro: 20
  aviso: 5
stack: wordpress
escopo: Todo código WordPress desenvolvido ou mantido pela BGR — plugins, themes, mu-plugins e configurações multisite.
aplica_a: ["todos os projetos WordPress"]
requer: [padroes-seguranca, padroes-php]
substitui: [padroes-wordpress v1]
---

# Padroes de WordPress — BGR Software House

> Documento constitucional. Contrato de entrega entre a BGR e todo
> desenvolvedor que toca WordPress nos nossos projetos.
> Codigo que viola regras ERRO nao e discutido — e devolvido.

---

## Como usar este documento

### Para o desenvolvedor

1. Leia as regras que cobrem a area do seu trabalho antes de escrever codigo.
2. Consulte o DoD no final antes de abrir qualquer Pull Request.
3. Use os IDs das regras (WP-001 a WP-025) para referenciar em PRs e code reviews.

### Para o auditor (humano ou IA)

1. Leia o frontmatter para entender escopo e dependencias.
2. Audite o codigo contra cada regra por ID.
3. Classifique violacoes pela severidade definida neste documento.
4. Referencie violacoes pelo ID da regra (ex.: "viola WP-003").

### Para o Claude Code

1. Leia o frontmatter para identificar escopo e documentos relacionados.
2. Em code review, verifique cada regra ERRO como bloqueante.
3. Referencie violacoes pelo ID (ex.: "viola WP-007 — echo direto sem escape").
4. Regras AVISO devem ser reportadas, mas nao bloqueiam merge se justificadas.

---

## Severidades

| Nivel | Significado | Acao |
|-------|-------------|------|
| **ERRO** | Violacao inegociavel | Bloqueia merge. Corrigir antes de review. |
| **AVISO** | Recomendacao forte | Deve ser justificada por escrito se ignorada. |

---

## 1. Acesso ao banco de dados

### WP-001 — $wpdb->prepare() em toda query com dados variaveis [ERRO]

**Regra:** Toda query SQL que recebe dados variaveis deve usar `$wpdb->prepare()` com placeholders tipados: `%s` para strings, `%d` para inteiros, `%f` para floats.

**Verifica:** Grep por `$wpdb->get_|$wpdb->query(` sem `prepare` no mesmo statement. Variável interpolada em string SQL = ERRO.

**Por que na BGR:** A BGR mantém múltiplos projetos WordPress com dados sensíveis (financeiros, pessoais, de tenants). SQL injection em qualquer um desses projetos compromete toda a infraestrutura multisite. Prepare é a única barreira confiável.

**Exemplo correto:**
```php
$wpdb->get_results($wpdb->prepare(
    "SELECT * FROM {$this->tableName()} WHERE user_id = %d AND status = %s",
    $userId,
    $status
));
```

**Exemplo incorreto:**
```php
$wpdb->get_results("SELECT * FROM {$this->tableName()} WHERE user_id = $userId");
```

---

### WP-002 — Helpers seguros para INSERT e UPDATE [AVISO]

**Regra:** Preferir `$wpdb->insert()` e `$wpdb->update()` com array de formato. Queries manuais apenas quando os helpers não cobrem (transações atômicas, `SELECT FOR UPDATE`, bulk operations).

**Verifica:** Grep por `$wpdb->query("INSERT|$wpdb->query("UPDATE`. Se não é transação/bulk/FOR UPDATE, deveria usar helper.

**Por que na BGR:** Helpers do `$wpdb` aplicam prepare internamente e reduzem a superfície de erro. Com desenvolvimento distribuído e assistido por IA na BGR, menos SQL manual significa menos vetores de injection esquecidos.

**Exemplo correto:**
```php
$wpdb->insert($this->tableName(), [
    'user_id' => $userId,
    'descricao' => $descricao,
    'status' => 'pendente',
], ['%d', '%s', '%s']);
```

**Exemplo incorreto:**
```php
$wpdb->query("INSERT INTO {$this->tableName()} (user_id, descricao, status) VALUES ($userId, '$descricao', 'pendente')");
```

**Exceções:** Transações atômicas, `SELECT FOR UPDATE`, bulk inserts com performance crítica — nesses casos, usar `$wpdb->prepare()` diretamente.

---

### WP-003 — Nome de tabela via método, nunca hardcoded [ERRO]

**Regra:** Todo repositório define o nome da tabela em método dedicado usando o prefixo do WordPress. Nomes de tabela nunca aparecem como string literal no código.

**Verifica:** Grep por `wpro_|wp_\d+_` como string literal fora de migrations/seeds. Tabela hardcoded = ERRO.

**Por que na BGR:** A BGR opera ambientes multisite onde o prefixo muda por subsite. Hardcodar nomes de tabela causa queries no banco errado, vazamento de dados entre tenants e falhas silenciosas em ambientes de staging/produção com prefixos diferentes.

**Exemplo correto:**
```php
private function tableName(): string
{
    return $this->wpdb->prefix . 'pedidos';
}
```

**Exemplo incorreto:**
```php
$tabela = 'wpro_9_pedidos'; // hardcoded — quebra em outro subsite ou ambiente
```

---

### WP-004 — $wpdb->prefix para tenant, $wpdb->base_prefix para tabelas globais [ERRO]

**Regra:** Em ambientes multisite, usar `$wpdb->prefix` para tabelas do subsite atual e `$wpdb->base_prefix` exclusivamente para tabelas compartilhadas da rede. Nunca construir o prefixo manualmente.

**Verifica:** Grep por concatenação manual de prefixo (`'wpro_' . $blogId`). Verificar que tabelas globais usam `base_prefix` e tabelas de subsite usam `prefix`.

**Por que na BGR:** A BGR utiliza WordPress multisite para isolar dados de tenants diferentes. Confundir prefix com base_prefix causa leitura ou escrita de dados no tenant errado — uma violação de isolamento que compromete múltiplos clientes simultaneamente.

**Exemplo correto:**
```php
// Tabela do subsite atual (tenant)
$this->wpdb->prefix . 'pedidos'; // ex.: wpro_3_pedidos

// Tabela global da rede (quando autorizado)
$this->wpdb->base_prefix . 'configuracoes_rede'; // ex.: wpro_configuracoes_rede
```

**Exemplo incorreto:**
```php
// Prefixo construído manualmente — quebra quando blog_id muda
'wpro_9_pedidos';
```

---

## 2. Sanitização e escape (APIs WordPress)

### WP-005 — Funções nativas de sanitização por tipo de dado [ERRO]

**Regra:** Cada tipo de dado de entrada deve ser sanitizado com a função WordPress correspondente. Nunca usar uma função genérica para todos os tipos.

**Verifica:** Grep por `$_POST\[|$_GET\[|$_REQUEST\[` sem `sanitize_text_field|absint|esc_url_raw|wp_kses_post|sanitize_email|sanitize_file_name` na mesma linha ou linha seguinte.

**Por que na BGR:** Projetos WordPress da BGR recebem dados de múltiplas fontes (formulários, APIs, integrações). Sanitização genérica (ex.: `strip_tags` para tudo) deixa passar vetores de ataque específicos de cada tipo de dado.

| Tipo de dado | Função | Uso |
|-------------|--------|-----|
| Texto curto | `sanitize_text_field()` | Nomes, descrições, status |
| Inteiro positivo | `absint()` | IDs, quantidades |
| URL (para banco) | `esc_url_raw()` | URLs antes de persistir |
| HTML seguro | `wp_kses_post()` | Conteúdo rico com tags permitidas |
| Email | `sanitize_email()` | Endereços de email |
| Nome de arquivo | `sanitize_file_name()` | Uploads |

**Exemplo correto:**
```php
$descricao = sanitize_text_field($_POST['descricao'] ?? '');
$itemId = absint($_POST['item_id'] ?? 0);
$email = sanitize_email($_POST['email'] ?? '');
```

**Exemplo incorreto:**
```php
$descricao = strip_tags($_POST['descricao']);
$itemId = (int) $_POST['item_id']; // não garante positivo
$email = $_POST['email']; // sem sanitização
```

---

### WP-006 — Funções nativas de escape por contexto de saída [ERRO]

**Regra:** Todo dado exibido deve ser escapado com a função correspondente ao contexto de saída. Cada contexto exige uma função diferente.

**Verifica:** Grep por `echo \$` em templates PHP. Cada echo deve ter `esc_html|esc_attr|esc_url|wp_json_encode` correspondente ao contexto.

**Por que na BGR:** A BGR tem projetos com áreas públicas e painéis administrativos. XSS em qualquer contexto de saída pode comprometer sessões de administradores, expor dados de tenants e afetar a reputação dos clientes.

| Contexto | Função | Exemplo |
|----------|--------|---------|
| Dentro de tags HTML | `esc_html()` | `<p><?php echo esc_html($nome); ?></p>` |
| Atributos HTML | `esc_attr()` | `<input value="<?php echo esc_attr($valor); ?>">` |
| URLs em href/src | `esc_url()` | `<a href="<?php echo esc_url($link); ?>">` |
| Contexto JavaScript | `wp_json_encode()` | `<script>var d = <?php echo wp_json_encode($dados); ?>;</script>` |

**Exemplo correto:**
```php
<p><?php echo esc_html($produto->nome()); ?></p>
<a href="<?php echo esc_url($produto->link()); ?>">Ver</a>
```

**Exemplo incorreto:**
```php
<p><?php echo $produto->nome(); ?></p>
<a href="<?php echo $produto->link(); ?>">Ver</a>
```

---

### WP-007 — Nunca usar echo direto com dados do banco [ERRO]

**Regra:** Todo dado exibido na interface deve ser escapado antes do echo, mesmo que venha do banco de dados.

**Verifica:** Grep por `echo \$.*->` em arquivos de template/view. Dado do banco sem `esc_*()` = ERRO.

**Por que na BGR:** Dados no banco podem ter sido comprometidos por injection, migração mal feita ou import de sistema externo. Na BGR, onde múltiplos projetos compartilham infraestrutura, confiar cegamente no banco é aceitar que uma falha em um ponto propague XSS em toda a plataforma.

**Exemplo correto:**
```php
echo esc_html($registro->descricao());
```

**Exemplo incorreto:**
```php
echo $registro->descricao();
```

---

## 3. Nonces e AJAX

### WP-008 — Nonce gerado com wp_create_nonce() e ação específica [ERRO]

**Regra:** Cada módulo ou funcionalidade deve gerar nonces com uma ação descritiva e única. Nunca usar nomes genéricos como 'nonce' ou 'ajax'.

**Verifica:** Grep por `wp_create_nonce(`. Ação deve conter prefixo do projeto + nome descritivo. Ações genéricas ('nonce', 'ajax', 'action') = ERRO.

**Por que na BGR:** A BGR mantém múltiplos plugins e módulos no mesmo ambiente WordPress. Nonces genéricos permitem que uma requisição forjada em um módulo seja validada por outro, anulando a proteção CSRF entre funcionalidades.

**Exemplo correto:**
```php
$nonce = wp_create_nonce('bgr_catalogo_salvar_produto');
```

**Exemplo incorreto:**
```php
$nonce = wp_create_nonce('nonce');
$nonce = wp_create_nonce('ajax');
```

---

### WP-009 — Nonce localizado via wp_localize_script() [ERRO]

**Regra:** O nonce deve ser injetado no JavaScript via `wp_localize_script()` ou `wp_add_inline_script()`. Nunca hardcodar no HTML ou em variável global manual.

**Verifica:** Grep por `wp_create_nonce` em arquivos `.php` de template/view. Nonce em `<script>` inline = ERRO. Deve estar em `wp_localize_script`.

**Por que na BGR:** Projetos da BGR usam cache agressivo. Nonces hardcoded no HTML podem ser cacheados e expirar, causando falhas silenciosas para o usuário. `wp_localize_script()` garante que o nonce é gerado no momento correto.

**Exemplo correto:**
```php
wp_localize_script('bgr-catalogo', 'bgrCatalogo', [
    'ajaxUrl' => admin_url('admin-ajax.php'),
    'nonce' => wp_create_nonce('bgr_catalogo_action'),
]);
```

```javascript
// JavaScript lê da variável localizada
fetch(bgrCatalogo.ajaxUrl, {
    method: 'POST',
    body: formData, // inclui nonce: bgrCatalogo.nonce
});
```

**Exemplo incorreto:**
```html
<script>var nonce = '<?php echo wp_create_nonce("action"); ?>';</script>
```

---

### WP-010 — check_ajax_referer() com ação e campo corretos [ERRO]

**Regra:** A verificação do nonce no handler AJAX deve usar a mesma string de ação usada no `wp_create_nonce()` e o nome exato do campo enviado.

**Verifica:** Comparar string de `wp_create_nonce('X')` com `check_ajax_referer('X', ...)`. Ação diferente = ERRO.

**Por que na BGR:** Ação de nonce diferente entre geração e verificação faz o check passar com nonce de outro módulo. Em ambientes BGR com múltiplos módulos ativos, isso equivale a desligar CSRF.

**Exemplo correto:**
```php
check_ajax_referer('bgr_catalogo_action', 'nonce');
```

**Exemplo incorreto:**
```php
check_ajax_referer('generic_nonce', 'nonce'); // ação diferente da geração
```

---

### WP-011 — wp_send_json_success() e wp_send_json_error() para respostas AJAX [ERRO]

**Regra:** Handlers AJAX devem responder exclusivamente com `wp_send_json_success()` e `wp_send_json_error()`. Nunca usar `echo json_encode()` + `die()`.

**Verifica:** Grep por `echo json_encode|echo wp_json_encode` seguido de `die()|exit` em handlers AJAX. Deve usar `wp_send_json_*`.

**Por que na BGR:** As funções nativas do WordPress definem headers corretos, chamam `wp_die()` com cleanup adequado e seguem o contrato `{success: bool, data: mixed}` que o JavaScript espera. Na BGR, padrões consistentes de resposta permitem tratamento de erro unificado no frontend de todos os projetos.

**Exemplo correto:**
```php
wp_send_json_success(['mensagem' => 'Item criado.', 'id' => $id]);
wp_send_json_error(['mensagem' => 'Dados inválidos.'], 400);
```

**Exemplo incorreto:**
```php
echo json_encode(['success' => true, 'data' => $dados]);
die();
```

---

## 4. Hooks e registro de handlers

### WP-012 — Handlers registrados via add_action em método register() [ERRO]

**Regra:** Todo handler AJAX ou de hook deve ter um método `register()` que conecta os métodos ao sistema de hooks do WordPress. Hooks soltos em `functions.php` são proibidos.

**Verifica:** Grep por `add_action('wp_ajax_` em `functions.php`. Deve estar em método `register()` de classe dedicada.

**Por que na BGR:** A BGR usa desenvolvimento assistido por IA e múltiplos desenvolvedores por projeto. Hooks espalhados por functions.php são invisíveis em code review, impossíveis de testar isoladamente e criam acoplamento oculto. O método `register()` centraliza todos os hooks da classe em um ponto auditável.

**Exemplo correto:**
```php
class ProdutoAjaxHandler
{
    public function register(): void
    {
        add_action('wp_ajax_bgr_criar_produto', [$this, 'handleCriar']);
        add_action('wp_ajax_bgr_listar_produtos', [$this, 'handleListar']);
    }
}
```

**Exemplo incorreto:**
```php
// hooks soltos em functions.php
add_action('wp_ajax_criar_produto', 'criar_produto_callback');
```

---

### WP-013 — Prefixo do projeto em todas as actions AJAX [ERRO]

**Regra:** Toda action AJAX deve usar um prefixo exclusivo do projeto (ex.: `bgr_`, `acp_`, `lms_`) para evitar colisão com outros plugins ou módulos no mesmo ambiente.

**Verifica:** Grep por `add_action('wp_ajax_`. A action deve começar com prefixo do projeto (`bgr_`, `lms_`, etc.). Sem prefixo = ERRO.

**Por que na BGR:** A BGR opera múltiplos plugins e módulos em ambientes WordPress compartilhados. Actions sem prefixo colidem silenciosamente com plugins de terceiros — o WordPress executa o primeiro handler registrado, causando bugs impossíveis de diagnosticar sem ler o source de todos os plugins ativos.

**Exemplo correto:**
```php
add_action('wp_ajax_bgr_criar_pedido', [$this, 'handleCriarPedido']);
```

**Exemplo incorreto:**
```php
add_action('wp_ajax_criar_pedido', [$this, 'handleCriarPedido']); // sem prefixo
```

---

### WP-014 — Sem wp_ajax_nopriv_ para endpoints autenticados [ERRO]

**Regra:** Endpoints que manipulam dados sensíveis (financeiros, pessoais, administrativos) nunca usam `wp_ajax_nopriv_`. Apenas endpoints genuinamente públicos (busca aberta, contato) podem usar nopriv.

**Verifica:** Grep por `wp_ajax_nopriv_`. Cada ocorrência deve ser justificada como genuinamente pública. Dados sensíveis com nopriv = ERRO.

**Por que na BGR:** Na BGR, a maioria dos projetos WordPress lida com dados de tenants, financeiros ou pessoais. `wp_ajax_nopriv_` permite acesso sem login. Registrar um endpoint sensível com nopriv expõe dados a qualquer visitante anônimo.

**Exemplo correto:**
```php
// Endpoint autenticado — apenas usuários logados
add_action('wp_ajax_bgr_criar_pedido', [$this, 'handleCriarPedido']);
```

**Exemplo incorreto:**
```php
// Abre para qualquer visitante anônimo
add_action('wp_ajax_nopriv_bgr_criar_pedido', [$this, 'handleCriarPedido']);
```

---

## 5. Enqueue de assets

### WP-015 — CSS e JS via wp_enqueue_script/style [ERRO]

**Regra:** Todos os assets (CSS e JS) devem ser carregados com `wp_enqueue_style()` e `wp_enqueue_script()`. Tags `<script>` e `<link>` diretas no HTML são proibidas.

**Verifica:** Grep por `<script src=|<link rel="stylesheet"` em templates PHP. Deve usar `wp_enqueue_*` no hook `wp_enqueue_scripts`.

**Por que na BGR:** O sistema de enqueue do WordPress gerencia dependências, versionamento e deduplicação. Na BGR, onde projetos combinam plugins próprios e de terceiros, assets carregados fora do enqueue duplicam bibliotecas, causam conflitos de versão e não são removíveis por outros plugins quando necessário.

**Exemplo correto:**
```php
function bgr_enqueue_assets(): void
{
    wp_enqueue_style(
        'bgr-catalogo',
        plugins_url('assets/css/catalogo.css', __FILE__),
        [],
        '1.0.0'
    );

    wp_enqueue_script(
        'bgr-catalogo',
        plugins_url('assets/js/catalogo.js', __FILE__),
        ['jquery'],
        '1.0.0',
        true
    );
}
add_action('wp_enqueue_scripts', 'bgr_enqueue_assets');
```

**Exemplo incorreto:**
```html
<link rel="stylesheet" href="/wp-content/plugins/bgr-catalogo/assets/css/catalogo.css">
<script src="/wp-content/plugins/bgr-catalogo/assets/js/catalogo.js"></script>
```

---

### WP-016 — Assets carregados condicionalmente [AVISO]

**Regra:** CSS e JS devem ser enfileirados apenas nas páginas que efetivamente os utilizam. Nunca carregar em todas as páginas do site.

**Verifica:** Inspecionar callbacks de `wp_enqueue_scripts`. Deve ter guard condicional (`is_page`, `is_singular`, etc.) antes do enqueue.

**Por que na BGR:** Projetos BGR atendem múltiplos tenants e funcionalidades no mesmo WordPress. Carregar todos os assets em todas as páginas impacta performance de tenants que não usam aquele módulo, aumenta tempo de carregamento e consome banda em escala.

**Exemplo correto:**
```php
function bgr_enqueue_catalogo(): void
{
    if (!is_page('catalogo') && !is_singular('produto')) {
        return;
    }

    wp_enqueue_style('bgr-catalogo', plugins_url('assets/css/catalogo.css', __FILE__), [], '1.0.0');
    wp_enqueue_script('bgr-catalogo', plugins_url('assets/js/catalogo.js', __FILE__), [], '1.0.0', true);
}
add_action('wp_enqueue_scripts', 'bgr_enqueue_catalogo');
```

**Exemplo incorreto:**
```php
function bgr_enqueue_catalogo(): void
{
    // Carrega em todas as páginas — desperdício
    wp_enqueue_style('bgr-catalogo', plugins_url('assets/css/catalogo.css', __FILE__), [], '1.0.0');
    wp_enqueue_script('bgr-catalogo', plugins_url('assets/js/catalogo.js', __FILE__), [], '1.0.0', true);
}
add_action('wp_enqueue_scripts', 'bgr_enqueue_catalogo');
```

---

## 6. Multisite

### WP-017 — get_users() sempre com blog_id explícito [ERRO]

**Regra:** Em ambientes multisite, toda chamada a `get_users()` deve incluir `blog_id` explicitamente. Usar `get_current_blog_id()` para o subsite atual ou `0` para busca network-wide.

**Verifica:** Grep por `get_users(` e verificar presença de `blog_id` no array de args. Ausente = ERRO.

**Por que na BGR:** A BGR opera WordPress multisite com múltiplos tenants. `get_users()` sem `blog_id` filtra silenciosamente pelo blog corrente, o que em contextos como WP-CLI, cron ou REST API pode retornar o blog errado. Resultado: dados de um tenant vazam para outro ou queries retornam vazio sem explicação.

**Exemplo correto:**
```php
// Busca no subsite atual
$usuarios = get_users([
    'blog_id' => get_current_blog_id(),
    'role' => 'editor',
]);

// Busca network-wide
$usuarios = get_users([
    'blog_id' => 0,
    'role__in' => ['administrator', 'editor'],
]);
```

**Exemplo incorreto:**
```php
// Sem blog_id — filtra pelo blog corrente silenciosamente
$usuarios = get_users(['role' => 'editor']);
```

---

### WP-018 — Roles registradas no blog correto [ERRO]

**Regra:** Roles e capabilities customizadas devem ser registradas no blog_id do tenant correspondente, nunca globalmente. Usar `switch_to_blog()` + `add_role()` + `restore_current_blog()`.

**Verifica:** Grep por `add_role(`. Deve estar entre `switch_to_blog($id)` e `restore_current_blog()`. Registro global = ERRO.

**Por que na BGR:** Em multisite BGR, cada tenant pode ter roles específicas. Registrar roles globalmente polui todos os subsites com capabilities que não pertencem àquele contexto, criando riscos de escalação de privilégio entre tenants.

**Exemplo correto:**
```php
switch_to_blog($tenantBlogId);
add_role('bgr_operador', 'Operador', [
    'read' => true,
    'bgr_view_dashboard' => true,
]);
restore_current_blog();
```

**Exemplo incorreto:**
```php
// Registra globalmente — polui todos os subsites
add_role('bgr_operador', 'Operador', [
    'read' => true,
    'bgr_view_dashboard' => true,
]);
```

---

### WP-019 — Sem switch_to_blog() desnecessário [AVISO]

**Regra:** `switch_to_blog()` deve ser usado apenas quando o código precisa acessar dados de outro subsite. Para o subsite corrente, `$wpdb->prefix` já retorna o prefixo correto.

**Verifica:** Grep por `switch_to_blog(get_current_blog_id())`. Switch pro blog atual = desnecessário.

**Por que na BGR:** `switch_to_blog()` é custoso — reseta cache de objetos, recarrega options e altera estado global do WordPress. Em projetos BGR com alta carga, chamadas desnecessárias degradam performance e introduzem bugs sutis quando `restore_current_blog()` é esquecido.

**Exemplo correto:**
```php
// Acessa dados do subsite atual — não precisa de switch
$resultados = $wpdb->get_results($wpdb->prepare(
    "SELECT * FROM {$wpdb->prefix}pedidos WHERE status = %s",
    'ativo'
));
```

**Exemplo incorreto:**
```php
// switch_to_blog() para o blog atual — desnecessário e custoso
switch_to_blog(get_current_blog_id());
$resultados = $wpdb->get_results($wpdb->prepare(
    "SELECT * FROM {$wpdb->prefix}pedidos WHERE status = %s",
    'ativo'
));
restore_current_blog();
```

---

## 7. Transações e concorrência

### WP-020 — Operações críticas dentro de transação [ERRO]

**Regra:** Qualquer operação que modifica dados financeiros, cria registros dependentes ou altera estado crítico deve ser envolvida em transação do banco (`START TRANSACTION` / `COMMIT` / `ROLLBACK`).

**Verifica:** Localizar métodos que fazem >1 write em dados financeiros/dependentes. Deve ter `START TRANSACTION` + `COMMIT` + `ROLLBACK` no catch.

**Por que na BGR:** Projetos BGR lidam com dados financeiros, pedidos e estados interdependentes. Sem transação, uma falha no meio da operação deixa o banco em estado inconsistente — metade do pedido criado, saldo debitado sem lançamento correspondente. Em multisite, inconsistências propagam para relatórios consolidados.

**Exemplo correto:**
```php
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

**Exemplo incorreto:**
```php
// Sem transação — se o update falha, o saldo já foi lido e pode estar stale
$saldo = $this->wpdb->get_var($this->wpdb->prepare(
    "SELECT saldo_cents FROM {$this->tableName()} WHERE id = %d",
    $contaId
));

$this->wpdb->update($this->tableName(), [
    'saldo_cents' => $saldo - $valorCents,
], ['id' => $contaId], ['%d'], ['%d']);
```

---

### WP-021 — SELECT FOR UPDATE em operações de saldo [ERRO]

**Regra:** Leituras que precedem escrita de saldo ou quantidade devem usar `FOR UPDATE` para lock da linha e prevenir race condition.

**Verifica:** Grep por `SELECT.*saldo|SELECT.*quantidade` dentro de transação. Ausência de `FOR UPDATE` = ERRO.

**Por que na BGR:** Projetos BGR com operações financeiras concorrentes (múltiplos usuários, webhooks, cron jobs) sofrem race conditions sem lock. Dois requests simultâneos leem o mesmo saldo, ambos debitam, e o resultado final está errado — dinheiro sumiu ou apareceu do nada.

**Exemplo correto:**
```php
$this->wpdb->query('START TRANSACTION');
$saldo = $this->wpdb->get_var($this->wpdb->prepare(
    "SELECT saldo_cents FROM {$this->tableName()} WHERE id = %d FOR UPDATE",
    $contaId
));
// ... atualiza saldo com segurança
$this->wpdb->query('COMMIT');
```

**Exemplo incorreto:**
```php
$this->wpdb->query('START TRANSACTION');
$saldo = $this->wpdb->get_var($this->wpdb->prepare(
    "SELECT saldo_cents FROM {$this->tableName()} WHERE id = %d",
    $contaId
));
// Sem FOR UPDATE — outro request pode ler o mesmo saldo simultaneamente
```

---

### WP-022 — Idempotência em operações críticas [AVISO]

**Regra:** Operações de pagamento, transferência, checkout e qualquer escrita disparada por webhook ou retry devem ser idempotentes — processar a mesma requisição duas vezes nunca duplica o efeito.

**Verifica:** Localizar handlers de webhook/pagamento. Deve ter guard por `idempotency_key` ou equivalente antes do INSERT.

**Por que na BGR:** Projetos BGR recebem webhooks de gateways de pagamento, integrações externas e retries automáticos. Sem idempotência, um webhook reenviado duplica lançamentos, cobra o cliente duas vezes ou cria registros fantasma que corrompem relatórios.

**Exemplo correto:**
```php
// Usa idempotency_key para evitar duplicação
$existe = $this->wpdb->get_var($this->wpdb->prepare(
    "SELECT COUNT(*) FROM {$this->tableName()} WHERE idempotency_key = %s",
    $idempotencyKey
));

if ($existe > 0) {
    return; // já processado — ignora sem erro
}

$this->wpdb->insert($this->tableName(), [
    'idempotency_key' => $idempotencyKey,
    'valor_cents' => $valorCents,
    'status' => 'processado',
], ['%s', '%d', '%s']);
```

**Exemplo incorreto:**
```php
// Sem verificação de duplicação — webhook reenviado duplica o lançamento
$this->wpdb->insert($this->tableName(), [
    'valor_cents' => $valorCents,
    'status' => 'processado',
], ['%d', '%s']);
```

---

## 8. Migrations

### WP-023 — Migrations numeradas sequencialmente [ERRO]

**Regra:** Arquivos de migration devem seguir numeração sequencial sem gaps. Formato: `NNN_descricao.php` (ex.: `001_`, `002_`).

**Verifica:** Listar `migrations/` e verificar sequência numérica. Gap na numeração = ERRO.

**Por que na BGR:** A BGR usa migrations para versionar o schema do banco em todos os projetos WordPress. Gaps na numeração criam ambiguidade sobre a ordem de execução e dificultam diagnóstico quando uma migration falha — não fica claro se o gap é intencional ou se uma migration foi perdida.

**Exemplo correto:**
```
migrations/
├── 001_create_pedidos.php
├── 002_create_itens_pedido.php
├── 003_add_coluna_status_pedidos.php
└── 004_create_historico_status.php
```

**Exemplo incorreto:**
```
migrations/
├── 001_create_pedidos.php
├── 003_create_itens_pedido.php  # gap — onde está 002?
└── 005_add_coluna_status.php    # gaps causam confusão
```

---

### WP-024 — Migrations idempotentes [ERRO]

**Regra:** Toda migration deve poder rodar múltiplas vezes sem quebrar. Usar `CREATE TABLE IF NOT EXISTS`, `IF NOT EXISTS` para colunas, e guards com `SELECT` antes de inserts.

**Verifica:** Grep por `CREATE TABLE` sem `IF NOT EXISTS` em migrations. Grep por `INSERT` sem guard de existência.

**Por que na BGR:** Migrations na BGR rodam em múltiplos ambientes (dev, staging, produção) e em múltiplos subsites no multisite. Uma migration que falha na segunda execução bloqueia deploy e exige intervenção manual em cada subsite afetado.

**Exemplo correto:**
```php
$wpdb->query("CREATE TABLE IF NOT EXISTS {$tabela} (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ativo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
```

**Exemplo incorreto:**
```php
// Explode na segunda execução — tabela já existe
$wpdb->query("CREATE TABLE {$tabela} (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
)");
```

---

### WP-025 — Sem dados hardcoded em migrations de estrutura [AVISO]

**Regra:** Migrations de estrutura criam tabelas, colunas e índices. Dados de seed vão em migration separada com lógica de idempotência (TRUNCATE + INSERT ou INSERT ... ON DUPLICATE KEY UPDATE).

**Verifica:** Inspecionar migrations com `CREATE TABLE`. Se contém `INSERT` de dados seed na mesma migration = AVISO.

**Por que na BGR:** Misturar estrutura e dados na mesma migration impossibilita reexecutar a estrutura sem resetar os dados. Em ambientes BGR multisite, dados de seed variam por tenant — separar permite aplicar seeds diferentes por subsite.

**Exemplo correto:**
```php
// 005_seed_categorias.php — migration de dados, separada da estrutura
$wpdb->query("TRUNCATE TABLE {$tabela}");
$wpdb->insert($tabela, ['nome' => 'Alimentação', 'slug' => 'alimentacao'], ['%s', '%s']);
$wpdb->insert($tabela, ['nome' => 'Transporte', 'slug' => 'transporte'], ['%s', '%s']);
```

**Exemplo incorreto:**
```php
// Estrutura e dados na mesma migration
$wpdb->query("CREATE TABLE IF NOT EXISTS {$tabela} (...)");
$wpdb->insert($tabela, ['nome' => 'Alimentação'], ['%s']); // dados misturados
```

---

## 9. Documentação e versionamento

Regras de documentação e versionamento para código WordPress na BGR seguem os padrões definidos em `padroes-php`. Cross-reference: consultar o documento `padroes-php` para regras de commits semânticos, CHANGELOG e SemVer.

Para código WordPress especificamente, aplicam-se as regras WP-001 a WP-025 deste documento. Toda PR que toca código WordPress deve referenciar as regras deste documento no checklist de review.

---

## Definition of Done — Checklist de entrega

> PR que não cumpre o DoD não entra em review. É devolvido.

| # | Item | Regras | Verificação |
|---|------|--------|-------------|
| 1 | Queries com dados variáveis usam prepare() | WP-001 | Buscar `$wpdb->get_` e `$wpdb->query` sem `prepare` |
| 2 | Nomes de tabela via método com prefix | WP-003, WP-004 | Buscar strings hardcoded com prefixo de tabela |
| 3 | Sanitização por tipo em toda entrada | WP-005 | Buscar `$_POST`, `$_GET`, `$_REQUEST` sem sanitize |
| 4 | Escape por contexto em toda saída | WP-006, WP-007 | Buscar `echo $` sem `esc_html`/`esc_attr`/`esc_url` |
| 5 | Nonces com ação específica e verificação | WP-008, WP-010 | Verificar que ação do create_nonce bate com check_ajax_referer |
| 6 | Nonce localizado via wp_localize_script | WP-009 | Buscar nonces hardcoded em HTML |
| 7 | Respostas AJAX via wp_send_json_* | WP-011 | Buscar `echo json_encode` e `die()` em handlers |
| 8 | Handlers com register() e prefixo | WP-012, WP-013 | Buscar `add_action('wp_ajax_` sem prefixo do projeto |
| 9 | Sem nopriv em endpoints sensíveis | WP-014 | Buscar `wp_ajax_nopriv_` e validar se é genuinamente público |
| 10 | Assets via enqueue, condicionais | WP-015, WP-016 | Buscar `<script>` e `<link>` hardcoded em templates |
| 11 | get_users() com blog_id explícito | WP-017 | Buscar `get_users(` sem `blog_id` |
| 12 | Roles no blog correto | WP-018 | Verificar `add_role` precedido de `switch_to_blog` |
| 13 | Operações críticas em transação | WP-020, WP-021 | Verificar START TRANSACTION + FOR UPDATE em operações de saldo |
| 14 | Migrations idempotentes e sequenciais | WP-023, WP-024 | Verificar IF NOT EXISTS e numeração sem gaps |
