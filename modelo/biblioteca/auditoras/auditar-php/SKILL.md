---
name: auditar-php
description: Audita código PHP do PR aberto contra as regras definidas em docs/padroes-php.md. Entrega relatório de violações e plano de correções. Trigger manual apenas.
---

# /auditar-php — Auditora de padrões PHP

Lê as regras de `docs/padroes-php.md`, identifica os arquivos PHP alterados no PR aberto (não mergeado) e compara cada arquivo contra cada regra aplicável. Entrega um relatório de violações com referência ao ID da regra e um plano de correções quando necessário.

## Quando usar

- **APENAS** quando o usuário digitar `/auditar-php` explicitamente.
- Rodar antes de mergear um PR — funciona como gate de qualidade.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Padrões mínimos exigidos

> Esta seção contém os padrões completos usados pela auditoria. Edite para personalizar ao seu projeto.

# Padrão de programação em PHP

## Descrição

Documento de referência para auditoria de código PHP no projeto Acertando os Pontos. Define regras obrigatórias e recomendações que toda classe, método e arquivo PHP deve seguir. A skill `/auditar-php` lê este documento e compara contra o código-alvo.

## Escopo

- Todo código PHP dentro de `acertandoospontos/inc/` e `acertandoospontos/paginas/`
- PHP 8.1+ com `declare(strict_types=1)`
- Contexto: WordPress Multisite, OOP, dados financeiros

## Referências

- [PSR-1: Basic Coding Standard](https://www.php-fig.org/psr/psr-1/)
- [PSR-4: Autoloading Standard](https://www.php-fig.org/psr/psr-4/)
- [PSR-12: Extended Coding Style Guide](https://www.php-fig.org/psr/psr-12/)
- [WordPress Coding Standards — PHP](https://developer.wordpress.org/coding-standards/wordpress-coding-standards/php/)
- [SemVer 2.0.0](https://semver.org/lang/pt-BR/)

## Severidade

- **ERRO** — Violação bloqueia aprovação. Deve ser corrigida antes de merge.
- **AVISO** — Recomendação forte. Deve ser justificada se ignorada.

---

## 1. Princípios fundamentais

Estes princípios regem toda decisão de código. A skill os usa como critério de julgamento quando uma regra específica não cobre o caso.

### PHP-001 — KISS: simplicidade primeiro [AVISO]

O código deve ser o mais simples possível. Se existe uma forma direta de resolver, usar essa. Abstrações, patterns e indireções só entram quando o problema exige.

```php
// correto — direto
public function estaAtiva(): bool
{
    return $this->status === self::STATUS_ATIVA;
}

// incorreto — indireção sem necessidade
public function estaAtiva(): bool
{
    return (new StatusChecker($this))->verificar(self::STATUS_ATIVA);
}
```

### PHP-002 — DRY: uma regra, um lugar [ERRO]

Uma regra de negócio é implementada em um único ponto do sistema. Se o mesmo cálculo ou validação aparece em dois lugares, extrair para um método ou classe.

```php
// correto — cálculo centralizado na entidade
class Lancamento
{
    public function valorLiquido(): int
    {
        return $this->valorCents - $this->descontoCents;
    }
}

// incorreto — cálculo duplicado no handler e no manager
// handler: $liquido = $valor - $desconto;
// manager: $liquido = $valor - $desconto;
```

### PHP-003 — YAGNI: não construa o que não precisa agora [AVISO]

Não implementar classes, métodos ou parâmetros pensando em "possibilidades futuras". Implementar estritamente o que o requisito atual exige. Código que nunca será usado é dívida técnica desde o nascimento.

### PHP-004 — Separação de responsabilidades (SoC) [ERRO]

Cada camada tem um trabalho:

| Camada | Responsabilidade | Pasta |
|--------|-----------------|-------|
| Entidade | Lógica de domínio, estado, predicados | `inc/entidades/` |
| Repositório | Acesso a dados, queries, hidratação | `inc/repositorios/` |
| Gerenciador | Orquestração, regras entre entidades | `inc/gerenciadores/` |
| Handler | Receber request, validar, delegar, responder | `inc/handlers/` |

Handler nunca faz query. Repositório nunca valida request. Entidade nunca acessa banco.

### PHP-005 — Lei de Demeter: fale só com seus vizinhos [AVISO]

Um objeto interage apenas com suas dependências diretas. Nunca encadear chamadas que atravessam camadas.

```php
// correto
$saldo = $conta->saldoAtual();

// incorreto — o handler conhece a estrutura interna da conta
$saldo = $lancamento->conta()->repositorio()->calcularSaldo();
```

---

## 2. Nomenclatura

### PHP-006 — Classes em PascalCase [ERRO]

```php
// correto
class LancamentoRepository {}
class FinanceiroManager {}

// incorreto
class lancamento_repository {}
class financeiroManager {}
```

### PHP-007 — Métodos e propriedades em camelCase [ERRO]

```php
// correto
public function calcularSaldo(): int {}
private int $valorCents;

// incorreto
public function calcular_saldo(): int {}
private int $valor_cents;
```

### PHP-008 — Constantes em UPPER_SNAKE_CASE [ERRO]

```php
// correto
public const STATUS_ATIVO = 'ativo';
private const MAX_TENTATIVAS = 3;

// incorreto
public const statusAtivo = 'ativo';
private const maxTentativas = 3;
```

### PHP-009 — Variáveis locais em camelCase [AVISO]

```php
// correto
$valorTotal = $lancamento->valorCents();
$categoriaId = $request['categoria_id'];

// incorreto
$valor_total = $lancamento->valorCents();
$CategoriaId = $request['categoria_id'];
```

### PHP-010 — Nomes descritivos, sem abreviações obscuras [AVISO]

```php
// correto
$lancamentoRepository = new LancamentoRepository($wpdb);
$categoriaAtiva = $categoria->estaAtiva();

// incorreto
$lr = new LancamentoRepository($wpdb);
$ca = $categoria->estaAtiva();
```

---

## 3. Estrutura de arquivos

### PHP-011 — Um arquivo por classe [ERRO]

Cada classe PHP vive em seu próprio arquivo. O nome do arquivo é o nome da classe seguido de `.php`.

```
inc/entidades/Lancamento.php              ← classe Lancamento
inc/repositorios/LancamentoRepository.php ← classe LancamentoRepository
```

### PHP-012 — Todo arquivo PHP abre com strict_types [ERRO]

```php
// correto
<?php
declare(strict_types=1);

class Lancamento {}

// incorreto
<?php
class Lancamento {}
```

### PHP-013 — Sem tag de fechamento PHP [ERRO]

Arquivos que contêm apenas PHP não usam `?>` no final.

---

## 4. Tipagem

### PHP-014 — Type hints obrigatórios em parâmetros [ERRO]

```php
// correto
public function buscarPorUsuario(int $userId): array {}

// incorreto
public function buscarPorUsuario($userId) {}
```

### PHP-015 — Tipo de retorno obrigatório [ERRO]

```php
// correto
public function calcularSaldo(): int {}
public function buscarOuNulo(int $id): ?Lancamento {}

// incorreto
public function calcularSaldo() {}
```

### PHP-016 — Usar tipos union quando necessário, nunca mixed [AVISO]

```php
// correto
public function encontrar(int $id): Lancamento|null {}

// incorreto
public function encontrar(int $id): mixed {}
```

### PHP-017 — Propriedades tipadas [ERRO]

```php
// correto
private int $valorCents;
private string $descricao;
private ?DateTimeImmutable $prazo;

// incorreto
private $valorCents;
private $descricao;
```

---

## 5. Classes e objetos

### PHP-018 — Visibilidade explícita em tudo [ERRO]

Toda propriedade, método e constante deve declarar visibilidade (`public`, `protected`, `private`).

```php
// correto
private int $id;
public function id(): int { return $this->id; }

// incorreto
int $id;
function id(): int { return $this->id; }
```

### PHP-019 — Propriedades readonly quando não mutáveis [AVISO]

```php
// correto
public function __construct(
    private readonly int $id,
    private readonly string $nome,
) {}

// incorreto (se o valor nunca muda após construção)
public function __construct(
    private int $id,
    private string $nome,
) {}
```

### PHP-020 — Construtores via promoção de propriedades [AVISO]

Preferir constructor promotion quando aplicável.

```php
// correto
public function __construct(
    private readonly \wpdb $wpdb,
    private readonly Criptografia $cripto,
) {}

// aceitável mas verboso
public function __construct(\wpdb $wpdb, Criptografia $cripto)
{
    $this->wpdb = $wpdb;
    $this->cripto = $cripto;
}
```

### PHP-021 — Composição sobre herança [AVISO]

Herança cria acoplamento forte. Usar apenas para hierarquias reais (ex.: exceções tipadas). Para reutilizar comportamento, injetar dependências.

```php
// correto — composição
class FinanceiroManager
{
    public function __construct(
        private readonly LancamentoRepository $lancamentos,
        private readonly Criptografia $cripto,
    ) {}
}

// incorreto — herança para reaproveitar código
class FinanceiroManager extends BaseManager {}
```

### PHP-022 — Entidades ricas, não anêmicas [ERRO]

Entidades contêm lógica de domínio: predicados, transições de estado, validações de regra de negócio. Nunca devem ser apenas sacos de getters e setters.

```php
// correto — entidade com comportamento
class Lancamento
{
    public function confirmar(): void
    {
        if ($this->status !== self::STATUS_PENDENTE) {
            throw new TransicaoInvalidaException($this->status, self::STATUS_CONFIRMADO);
        }
        $this->status = self::STATUS_CONFIRMADO;
    }

    public function estaConfirmado(): bool
    {
        return $this->status === self::STATUS_CONFIRMADO;
    }
}

// incorreto — entidade anêmica
class Lancamento
{
    public function getStatus(): string { return $this->status; }
    public function setStatus(string $status): void { $this->status = $status; }
}
```

### PHP-023 — Getters sem prefixo get_ [ERRO]

Métodos de acesso usam o nome da propriedade diretamente.

```php
// correto
public function id(): int { return $this->id; }
public function nome(): string { return $this->nome; }
public function valorCents(): int { return $this->valorCents; }

// incorreto
public function getId(): int { return $this->id; }
public function getNome(): string { return $this->nome; }
```

### PHP-024 — FSM na entidade via STATUS_TRANSITIONS [ERRO]

Entidades com estado definem suas transições válidas como constante e expõem lifecycle methods.

```php
class Lancamento
{
    public const STATUS_PENDENTE = 'pendente';
    public const STATUS_CONFIRMADO = 'confirmado';
    public const STATUS_CANCELADO = 'cancelado';

    public const STATUS_TRANSITIONS = [
        self::STATUS_PENDENTE   => [self::STATUS_CONFIRMADO, self::STATUS_CANCELADO],
        self::STATUS_CONFIRMADO => [self::STATUS_CANCELADO],
        self::STATUS_CANCELADO  => [],
    ];

    public function confirmar(): void
    {
        if (!$this->podeTransicionarPara(self::STATUS_CONFIRMADO)) {
            throw new TransicaoInvalidaException($this->status, self::STATUS_CONFIRMADO);
        }
        $this->status = self::STATUS_CONFIRMADO;
    }

    public function podeTransicionarPara(string $novoStatus): bool
    {
        return in_array($novoStatus, self::STATUS_TRANSITIONS[$this->status] ?? [], true);
    }
}
```

### PHP-025 — from_row() tolerante, nunca lança exception [ERRO]

Dados do banco são fato consumado. O método `from_row()` nunca lança exception — usa `ReflectionClass::newInstanceWithoutConstructor()` para bypassar validações do construtor.

```php
// correto
public static function fromRow(object $row): self
{
    $entity = (new \ReflectionClass(self::class))
        ->newInstanceWithoutConstructor();

    $entity->id = (int) $row->id;
    $entity->nome = (string) $row->nome;
    $entity->status = (string) $row->status;

    return $entity;
}

// incorreto — explode com dado sujo do banco
public static function fromRow(object $row): self
{
    return new self(
        id: (int) $row->id,
        nome: (string) $row->nome, // construtor pode validar e lançar exception
    );
}
```

### PHP-026 — Entidades não dependem de infraestrutura [ERRO]

Classes de entidade (`inc/entidades/`) nunca importam `$wpdb`, classes de repositório ou serviços externos. Entidades contêm lógica de domínio pura.

```php
// correto — entidade pura
class Lancamento
{
    public function estaConfirmado(): bool
    {
        return $this->status === self::STATUS_CONFIRMADO;
    }
}

// incorreto — entidade acoplada a infraestrutura
class Lancamento
{
    public function salvar(\wpdb $wpdb): void
    {
        $wpdb->insert(...);
    }
}
```

### PHP-027 — SOLID: responsabilidade única por classe [ERRO]

Uma classe tem um único motivo para mudar. Se uma classe faz validação, cálculo e persistência, ela tem três motivos — dividir.

### PHP-028 — SOLID: aberto para extensão, fechado para modificação [AVISO]

Quando um novo comportamento é necessário (ex.: novo tipo de lançamento), preferir polimorfismo ou estratégia em vez de adicionar `if/else` ao código existente.

### PHP-029 — SOLID: inversão de dependência [AVISO]

Gerenciadores e handlers dependem de abstrações (interfaces), não de classes concretas, quando a dependência pode variar (ex.: mecanismo de criptografia, provedor de email).

```php
// correto
public function __construct(
    private readonly CriptografiaInterface $cripto,
) {}

// aceitável para dependências estáveis (ex.: $wpdb)
public function __construct(
    private readonly \wpdb $wpdb,
) {}
```

---

## 6. Métodos

### PHP-030 — Máximo 20 linhas por método [AVISO]

Se um método ultrapassa 20 linhas, provavelmente faz mais de uma coisa. Extrair submétodos.

### PHP-031 — Retorno antecipado (early return) [AVISO]

Reduzir aninhamento usando guard clauses.

```php
// correto
public function processar(Lancamento $lancamento): void
{
    if ($lancamento->estaCancelado()) {
        return;
    }

    if (!$lancamento->temConta()) {
        throw new LancamentoSemContaException();
    }

    // lógica principal aqui
}

// incorreto
public function processar(Lancamento $lancamento): void
{
    if (!$lancamento->estaCancelado()) {
        if ($lancamento->temConta()) {
            // lógica principal aqui
        } else {
            throw new LancamentoSemContaException();
        }
    }
}
```

### PHP-032 — Máximo 4 parâmetros por método [AVISO]

Se um método precisa de mais de 4 parâmetros, considerar um objeto de valor (Value Object) ou DTO.

### PHP-033 — Métodos públicos de entidade como predicados descritivos [AVISO]

```php
// correto
$lancamento->estaConfirmado();
$conta->estaAtiva();
$meta->foiAtingida();

// incorreto
$lancamento->getStatus() === 'confirmado';
$conta->getAtiva() === true;
```

---

## 7. Tratamento de erros

### PHP-034 — Exceções tipadas, nunca genéricas [ERRO]

```php
// correto
throw new SaldoInsuficienteException($conta->id(), $valorSolicitado);
throw new LancamentoNaoEncontradoException($id);

// incorreto
throw new \Exception('Saldo insuficiente');
throw new \RuntimeException('Não encontrado');
```

### PHP-035 — Nunca silenciar erros com @ [ERRO]

```php
// correto
$resultado = json_decode($json, true);
if (json_last_error() !== JSON_ERROR_NONE) {
    throw new JsonInvalidoException(json_last_error_msg());
}

// incorreto
$resultado = @json_decode($json, true);
```

### PHP-036 — Catch específico, nunca \Throwable genérico [AVISO]

```php
// correto
try {
    $this->repositorio->salvar($lancamento);
} catch (DuplicataException $e) {
    // tratar caso específico
}

// incorreto
try {
    $this->repositorio->salvar($lancamento);
} catch (\Throwable $e) {
    // engolir tudo
}
```

---

## 8. Segurança

### PHP-037 — Dados financeiros sempre criptografados em repouso [ERRO]

Todo valor financeiro sensível (valores, descrições, nomes de contas) deve ser criptografado antes de gravar no banco e descriptografado após leitura. Usar a classe `Criptografia` do projeto.

```php
// correto
$valorCriptografado = $this->cripto->criptografar((string) $lancamento->valorCents());
$wpdb->insert($tabela, ['valor_cents' => $valorCriptografado]);

// incorreto
$wpdb->insert($tabela, ['valor_cents' => $lancamento->valorCents()]);
```

### PHP-038 — Sempre usar $wpdb->prepare() para queries [ERRO]

```php
// correto
$wpdb->get_results($wpdb->prepare(
    "SELECT * FROM {$tabela} WHERE user_id = %d AND status = %s",
    $userId,
    $status
));

// incorreto
$wpdb->get_results("SELECT * FROM {$tabela} WHERE user_id = {$userId}");
```

### PHP-039 — Sanitizar entrada, escapar saída [ERRO]

```php
// correto
$descricao = sanitize_text_field($_POST['descricao']);  // entrada
echo esc_html($lancamento->descricao());                // saída

// incorreto
$descricao = $_POST['descricao'];
echo $lancamento->descricao();
```

### PHP-040 — Validação na fronteira do sistema [ERRO]

Handlers validam e sanitizam todos os dados recebidos antes de passar para gerenciadores ou repositórios. Entidades e repositórios confiam que os dados já chegam limpos.

### PHP-041 — Chaves e segredos vivem no .env, nunca no código [ERRO]

```php
// correto
$chave = getenv('APP_ENCRYPTION_KEY');

// incorreto
$chave = 'minha-chave-secreta-hardcoded';
```

### PHP-042 — Não otimizar prematuramente [AVISO]

Otimizações de performance (cache, desnormalização, queries complexas) só entram quando há medição comprovando o gargalo. Código claro e correto primeiro, otimizado depois.

---

## 9. Formatação

### PHP-043 — Indentação com 4 espaços [ERRO]

Nunca tabs. Sempre 4 espaços.

### PHP-044 — Chaves na mesma linha para estruturas de controle [AVISO]

```php
// correto
if ($condicao) {
    // corpo
}

// incorreto
if ($condicao)
{
    // corpo
}
```

### PHP-045 — Chaves na linha seguinte para classes e métodos [AVISO]

```php
// correto (PSR-12)
class Lancamento
{
    public function valorCents(): int
    {
        return $this->valorCents;
    }
}
```

### PHP-046 — Linha em branco entre métodos [AVISO]

```php
// correto
public function id(): int
{
    return $this->id;
}

public function nome(): string
{
    return $this->nome;
}

// incorreto
public function id(): int
{
    return $this->id;
}
public function nome(): string
{
    return $this->nome;
}
```

### PHP-047 — Máximo 120 caracteres por linha [AVISO]

Quebrar linhas longas com alinhamento.

```php
// correto
$resultado = $wpdb->get_results($wpdb->prepare(
    "SELECT * FROM {$tabela} WHERE user_id = %d AND status = %s ORDER BY created_at DESC",
    $userId,
    $status
));
```

### PHP-048 — Uma instrução por linha [ERRO]

```php
// correto
$a = 1;
$b = 2;

// incorreto
$a = 1; $b = 2;
```

---

## 10. Versionamento

### PHP-049 — SemVer 2.0.0 [AVISO]

O projeto adota versionamento semântico:

- **MAJOR** (X.y.z) — Alterações incompatíveis na API.
- **MINOR** (x.Y.z) — Funcionalidades novas mantendo compatibilidade.
- **PATCH** (x.y.Z) — Correções de bugs mantendo compatibilidade.

---

## Checklist de auditoria

A skill `/auditar-php` deve verificar, para cada arquivo:

- [ ] Princípios: KISS, DRY, YAGNI, SoC, Demeter respeitados
- [ ] `declare(strict_types=1)` presente
- [ ] Sem tag de fechamento `?>`
- [ ] Uma classe por arquivo
- [ ] Classe em PascalCase, métodos em camelCase, constantes em UPPER_SNAKE_CASE
- [ ] Visibilidade explícita em tudo
- [ ] Type hints em todos os parâmetros e retornos
- [ ] Propriedades tipadas
- [ ] Entidades ricas (com comportamento), não anêmicas
- [ ] Getters sem prefixo get_ (ex.: nome(), não getNome())
- [ ] FSM na entidade via STATUS_TRANSITIONS + lifecycle methods
- [ ] from_row() tolerante (nunca lança exception)
- [ ] Entidades sem dependência de infraestrutura
- [ ] Responsabilidade única por classe
- [ ] Composição sobre herança
- [ ] Exceções tipadas (nunca genéricas)
- [ ] Sem `@` supressor de erro
- [ ] Dados financeiros criptografados via classe `Criptografia`
- [ ] `$wpdb->prepare()` em toda query
- [ ] Entrada sanitizada, saída escapada
- [ ] Sem segredos hardcoded
- [ ] Indentação com 4 espaços
- [ ] Máximo 120 caracteres por linha

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
5. Filtrar apenas arquivos `.php` dentro de `acertandoospontos/`.

### Fase 3 — Auditar arquivo por arquivo

Para cada arquivo PHP alterado no PR:

1. Ler o arquivo completo (não apenas o diff — contexto importa).
2. Comparar contra **cada regra** de `docs/padroes-php.md`, uma por uma, na ordem do documento.
3. Para cada violação encontrada, registrar:
   - **Arquivo** e **linha(s)** onde ocorre
   - **ID da regra** violada (ex.: PHP-024)
   - **Severidade** (ERRO ou AVISO)
   - **O que está errado** — descrição concisa
   - **Como corrigir** — correção específica para aquele trecho
4. Se o arquivo não viola nenhuma regra, registrar como aprovado.

### Fase 4 — Relatório

Apresentar o relatório ao usuário no seguinte formato:

```
## Relatório de auditoria PHP

**PR:** #<numero> — <titulo>
**Branch:** <branch>
**Arquivos auditados:** <quantidade>
**Régua:** docs/padroes-php.md

### Resumo

- Erros: <quantidade>
- Avisos: <quantidade>
- Arquivos aprovados: <quantidade>

### Violações

#### <arquivo.php>

| Linha | Regra | Severidade | Descrição | Correção |
|-------|-------|------------|-----------|----------|
| 15 | PHP-024 | ERRO | FSM não definida | Adicionar STATUS_TRANSITIONS |
| 32 | PHP-030 | AVISO | Método com 25 linhas | Extrair submétodo |

#### <outro-arquivo.php>
✅ Aprovado — nenhuma violação encontrada.
```

### Fase 5 — Plano de correções

Se houver violações do tipo ERRO:

1. Listar as correções necessárias agrupadas por arquivo.
2. Ordenar por severidade (ERROs primeiro, AVISOs depois).
3. Para cada correção, indicar exatamente o que mudar e onde.
4. Perguntar ao usuário: "Quer que eu execute as correções agora?"

Se houver apenas AVISOs ou nenhuma violação:

> "Nenhum erro bloquante. Os avisos são recomendações — quer que eu corrija algum?"

## Regras

- **Nunca alterar código durante a auditoria.** A skill é read-only até o usuário pedir correção explicitamente.
- **Nunca auditar arquivos fora do PR.** Apenas arquivos PHP alterados no PR aberto.
- **Sempre referenciar o ID da regra violada.** O relatório deve ser rastreável ao documento de padrões.
- **Nunca inventar regras.** A régua é exclusivamente o `docs/padroes-php.md` — sem opinião, sem sugestões extras.
- **Ser metódica e processual.** Cada arquivo é comparado contra cada regra, na ordem do documento, sem pular.
- **Fidelidade ao documento.** Se o código viola uma regra do documento, reportar. Se o documento não cobre o caso, não reportar.
- **Mostrar o relatório completo antes de qualquer ação.** Nunca executar correções sem aprovação explícita.
