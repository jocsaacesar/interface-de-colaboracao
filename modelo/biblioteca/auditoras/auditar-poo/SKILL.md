---
name: auditar-poo
description: Audita arquitetura e design OOP do PR aberto contra as regras definidas em docs/padroes-poo.md. Entrega relatório de violações e plano de correções. Trigger manual apenas.
---

# /auditar-poo — Auditora de padrões orientados a objetos

Lê as regras de `docs/padroes-poo.md`, identifica os arquivos PHP alterados no PR aberto (não mergeado) e compara cada arquivo contra cada regra aplicável. Foco em arquitetura e design: modelagem de domínio, encapsulamento, padrões do projeto (entidade, repositório, gerenciador, handler), SOLID e Value Objects.

Complementa a `/auditar-php`, que cobre sintaxe e regras de linguagem.

## Quando usar

- **APENAS** quando o usuário digitar `/auditar-poo` explicitamente.
- Rodar antes de mergear um PR — funciona como gate de qualidade arquitetural.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Padrões mínimos exigidos

> Esta seção contém os padrões completos usados pela auditoria. Edite para personalizar ao seu projeto.

# Padrão de programação orientada a objetos

## Descrição

Documento de referência para auditoria de arquitetura e design orientado a objetos no projeto Acertando os Pontos. Define como classes devem ser modeladas, como objetos se relacionam e como os padrões arquiteturais do projeto devem ser aplicados. A skill `/auditar-poo` lê este documento e compara contra o código-alvo.

Complementa o `docs/padroes-php.md`, que cobre sintaxe, formatação e regras de linguagem. Este documento cobre **design e arquitetura**.

## Escopo

- Todo código PHP dentro de `acertandoospontos/inc/`
- Foco em: entidades, repositórios, gerenciadores, handlers
- Compatível com os padrões da UniBGR Campus Digital (plataforma-mãe)

## Referências

- `docs/padroes-php.md` — Regras de linguagem PHP (complementar)
- `referencias/entrada/CLAUDE-UniBGR.md` — Padrões da plataforma-mãe
- [PHP-FIG PSR-4](https://www.php-fig.org/psr/psr-4/) — Autoloading
- SOLID Principles (Robert C. Martin)
- Domain-Driven Design — Eric Evans (conceitos aplicáveis)

## Severidade

- **ERRO** — Violação bloqueia aprovação. Deve ser corrigida antes de merge.
- **AVISO** — Recomendação forte. Deve ser justificada se ignorada.

---

## 1. Modelagem de domínio

### POO-001 — Classes representam substantivos do domínio [ERRO]

Cada classe de entidade representa um conceito real do negócio financeiro. O nome da classe dita seu papel — sem classes "curinga" que tentam ser duas coisas.

```php
// correto — conceitos claros do domínio
class Lancamento {}
class ContaBancaria {}
class CategoriaFinanceira {}
class MetaFinanceira {}

// incorreto — genérico, ambíguo
class Item {}
class Registro {}
class Dados {}
```

### POO-002 — Métodos expressam intenção com verbos de ação [ERRO]

Métodos de negócio usam verbos que descrevem o que o objeto **faz**, não o que ele **expõe**.

```php
// correto — intenção clara
$lancamento->confirmar();
$conta->transferirPara($outraConta, $valor);
$meta->registrarProgresso($valor);

// incorreto — sem intenção, operação mecânica
$lancamento->setStatus('confirmado');
$conta->atualizarSaldo($novoSaldo);
```

### POO-003 — Sem classes anêmicas [ERRO]

Entidades contêm lógica de domínio: predicados de estado, transições, validações e cálculos de negócio. Nunca sacos de getters e setters.

```php
// correto — entidade rica com comportamento
class Lancamento
{
    public function confirmar(): void
    {
        if (!$this->podeTransicionarPara(self::STATUS_CONFIRMADO)) {
            throw new TransicaoInvalidaException($this->status, self::STATUS_CONFIRMADO);
        }
        $this->status = self::STATUS_CONFIRMADO;
    }

    public function estaConfirmado(): bool
    {
        return $this->status === self::STATUS_CONFIRMADO;
    }

    public function valorLiquido(): int
    {
        return $this->valorCents - $this->descontoCents;
    }
}

// incorreto — anêmica, lógica vive fora
class Lancamento
{
    public function getStatus(): string { return $this->status; }
    public function setStatus(string $s): void { $this->status = $s; }
    public function getValorCents(): int { return $this->valorCents; }
}
```

---

## 2. Encapsulamento

### POO-004 — Atributos sempre privados [ERRO]

Toda propriedade é `private` (ou `readonly` via constructor promotion). `protected` apenas em hierarquias de herança reais. Nunca `public`.

```php
// correto
class ContaBancaria
{
    private int $saldoCents;
    private string $nome;
    private bool $ativa;
}

// incorreto
class ContaBancaria
{
    public int $saldoCents;
    public string $nome;
}
```

### POO-005 — Tell, Don't Ask [ERRO]

Não extraia dados do objeto para tomar decisões fora dele. Diga ao objeto o que fazer — ele decide internamente.

```php
// correto — o objeto decide
$lancamento->confirmar();
// internamente: verifica se pode transicionar, muda status, lança exception se não pode

// incorreto — decisão externa
if ($lancamento->status() === 'pendente') {
    $lancamento->setStatus('confirmado');
}
```

### POO-006 — Setters privados, mutação via métodos de negócio [ERRO]

Propriedades mutáveis são alteradas por métodos que expressam intenção de negócio, nunca por setters públicos.

```php
// correto
class MetaFinanceira
{
    private string $status;

    public function atingir(): void
    {
        if ($this->valorAtualCents < $this->valorAlvoCents) {
            throw new MetaNaoAtingidaException();
        }
        $this->status = self::STATUS_ATINGIDA;
    }
}

// incorreto
class MetaFinanceira
{
    public function setStatus(string $status): void
    {
        $this->status = $status;
    }
}
```

### POO-007 — Objetos imutáveis quando possível [AVISO]

Para dados que não mudam após criação (configurações, Value Objects, DTOs de leitura), usar `readonly` no construtor. Sem setters, sem mutação.

```php
// correto — imutável
class PeriodoRelatorio
{
    public function __construct(
        private readonly DateTimeImmutable $inicio,
        private readonly DateTimeImmutable $fim,
    ) {
        if ($fim <= $inicio) {
            throw new PeriodoInvalidoException();
        }
    }
}
```

---

## 3. Herança e polimorfismo

### POO-008 — Herança apenas para subtipos reais [ERRO]

Herança só quando a afirmativa "X **é um** Y" é verdadeira comportamentalmente. Para reutilizar código, usar composição (injeção de dependência).

```php
// correto — subtipo real
abstract class ExcecaoFinanceira extends \DomainException {}
class SaldoInsuficienteException extends ExcecaoFinanceira {}
class LancamentoNaoEncontradoException extends ExcecaoFinanceira {}

// incorreto — herança para reaproveitar código
class FinanceiroManager extends BaseManager {} // "tem funcionalidades de", não "é um"
```

### POO-009 — Classes concretas são finais [AVISO]

Classes concretas que não foram projetadas para extensão devem usar `final`. Impede herança acidental.

```php
// correto
final class LancamentoRepository
{
    // ...
}

// aceitável — sem final, mas sem herança no projeto
class LancamentoRepository
{
    // ...
}
```

### POO-010 — Polimorfismo substitui switch/if em tipo [AVISO]

Quando múltiplos `if/else` ou `switch` decidem comportamento baseado no "tipo" de algo, extrair para hierarquia polimórfica.

```php
// correto — polimorfismo
interface CalculadoraDeJuros
{
    public function calcular(int $valorCents, int $dias): int;
}

class JurosSimples implements CalculadoraDeJuros
{
    public function calcular(int $valorCents, int $dias): int
    {
        return (int) ($valorCents * 0.01 * $dias);
    }
}

class JurosCompostos implements CalculadoraDeJuros
{
    public function calcular(int $valorCents, int $dias): int
    {
        return (int) ($valorCents * ((1.01 ** $dias) - 1));
    }
}

// incorreto — switch no tipo
function calcularJuros(string $tipo, int $valor, int $dias): int
{
    switch ($tipo) {
        case 'simples': return (int) ($valor * 0.01 * $dias);
        case 'compostos': return (int) ($valor * ((1.01 ** $dias) - 1));
    }
}
```

---

## 4. Interfaces e abstrações

### POO-011 — Interfaces magras e específicas [AVISO]

Interfaces definem contratos pequenos e coesos. Nunca "interfaces gordas" que forçam implementação de métodos irrelevantes.

```php
// correto — interface magra
interface Criptografavel
{
    public function criptografar(string $dado): string;
    public function descriptografar(string $dado): string;
}

// incorreto — interface gorda
interface ServicoFinanceiro
{
    public function criptografar(string $dado): string;
    public function calcularSaldo(int $contaId): int;
    public function enviarEmail(string $para, string $assunto): void;
}
```

### POO-012 — Depender de abstrações, não de implementações concretas [AVISO]

Gerenciadores e handlers recebem interfaces quando a dependência pode variar. Dependências estáveis (como `$wpdb`) podem ser concretas.

```php
// correto — depende da abstração
class FinanceiroManager
{
    public function __construct(
        private readonly CriptografiaInterface $cripto,
        private readonly \wpdb $wpdb, // estável, concreto aceitável
    ) {}
}

// incorreto — depende de implementação que pode variar
class FinanceiroManager
{
    public function __construct(
        private readonly AES256Criptografia $cripto, // e se trocar o algoritmo?
    ) {}
}
```

### POO-013 — Classes abstratas como molde de hierarquia [AVISO]

Classes abstratas compartilham estado e comportamento entre subtipos reais. Nunca usar como "repositório de métodos utilitários".

```php
// correto — molde para hierarquias reais de exceção
abstract class ExcecaoFinanceira extends \DomainException
{
    public function __construct(
        string $mensagem,
        private readonly string $codigoNegocio,
    ) {
        parent::__construct($mensagem);
    }

    public function codigoNegocio(): string
    {
        return $this->codigoNegocio;
    }
}
```

---

## 5. Value Objects

### POO-014 — Tipos primitivos com significado de domínio viram Value Objects [AVISO]

Quando um primitivo carrega regras de validação ou formatação, encapsular em Value Object. Exemplos: dinheiro em centavos, CPF, período de datas.

```php
// correto — Value Object com validação
final class Dinheiro
{
    public function __construct(
        private readonly int $centavos,
    ) {
        if ($centavos < 0) {
            throw new ValorNegativoException($centavos);
        }
    }

    public function centavos(): int
    {
        return $this->centavos;
    }

    public function somar(self $outro): self
    {
        return new self($this->centavos + $outro->centavos);
    }

    public function maiorQue(self $outro): bool
    {
        return $this->centavos > $outro->centavos;
    }

    public function formatado(): string
    {
        return 'R$ ' . number_format($this->centavos / 100, 2, ',', '.');
    }
}
```

### POO-015 — Value Objects são imutáveis [ERRO]

Value Objects nunca mudam após criação. Operações retornam novas instâncias.

```php
// correto — operação retorna nova instância
$total = $preco->somar($frete); // novo Dinheiro, $preco não muda

// incorreto — mutação
$preco->adicionar($frete); // muda o objeto original
```

### POO-016 — Comparação por valor, não por referência [AVISO]

Value Objects implementam método de igualdade baseado nos atributos, não na referência de memória.

```php
// correto
final class Dinheiro
{
    public function igualA(self $outro): bool
    {
        return $this->centavos === $outro->centavos;
    }
}
```

---

## 6. Padrões arquiteturais do projeto

### POO-017 — Entidade: Rich Domain Model com FSM [ERRO]

Toda entidade com estado segue o padrão Rich Domain Model com máquina de estados finita. Padrão obrigatório, alinhado com a UniBGR.

Estrutura obrigatória:
1. Constantes de status
2. `STATUS_TRANSITIONS` definindo transições válidas
3. Construtor parametrizado (estado válido desde a criação)
4. Getters sem prefixo `get_`
5. Lifecycle methods (`confirmar()`, `cancelar()`) com Tell, Don't Ask
6. Predicados de estado (`estaConfirmado()`, `estaPendente()`)
7. `podeTransicionarPara()` público
8. `fromRow()` tolerante (nunca lança exception)
9. `toArray()` para serialização

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

    public function __construct(
        private readonly int $id,
        private readonly int $userId,
        private readonly int $contaId,
        private int $valorCents,
        private string $status = self::STATUS_PENDENTE,
        private readonly DateTimeImmutable $criadoEm = new DateTimeImmutable(),
    ) {}

    // Getters sem get_
    public function id(): int { return $this->id; }
    public function status(): string { return $this->status; }
    public function valorCents(): int { return $this->valorCents; }

    // Lifecycle methods
    public function confirmar(): void
    {
        if (!$this->podeTransicionarPara(self::STATUS_CONFIRMADO)) {
            throw new TransicaoInvalidaException($this->status, self::STATUS_CONFIRMADO);
        }
        $this->status = self::STATUS_CONFIRMADO;
    }

    public function cancelar(): void
    {
        if (!$this->podeTransicionarPara(self::STATUS_CANCELADO)) {
            throw new TransicaoInvalidaException($this->status, self::STATUS_CANCELADO);
        }
        $this->status = self::STATUS_CANCELADO;
    }

    // Predicados
    public function estaConfirmado(): bool { return $this->status === self::STATUS_CONFIRMADO; }
    public function estaPendente(): bool { return $this->status === self::STATUS_PENDENTE; }

    // FSM
    public function podeTransicionarPara(string $novoStatus): bool
    {
        return in_array($novoStatus, self::STATUS_TRANSITIONS[$this->status] ?? [], true);
    }

    // Hidratação tolerante
    public static function fromRow(object $row): self
    {
        $entity = (new \ReflectionClass(self::class))
            ->newInstanceWithoutConstructor();

        $entity->id = (int) $row->id;
        $entity->userId = (int) $row->user_id;
        $entity->contaId = (int) $row->conta_id;
        $entity->valorCents = (int) $row->valor_cents;
        $entity->status = (string) $row->status;

        return $entity;
    }

    // Serialização
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->userId,
            'conta_id' => $this->contaId,
            'valor_cents' => $this->valorCents,
            'status' => $this->status,
        ];
    }
}
```

### POO-018 — Repositório: interface uniforme [ERRO]

Todo repositório segue a mesma estrutura de métodos. Padrão alinhado com a UniBGR.

Métodos obrigatórios:
1. `findById(int $id): ?Entidade`
2. `findAll(): array`
3. `create(Entidade $e): int`
4. `update(Entidade $e): bool`
5. `delete(int $id): bool`
6. `tableName(): string` (privado)
7. `hydrate(object $row): Entidade` (privado)

```php
class LancamentoRepository
{
    public function __construct(
        private readonly \wpdb $wpdb,
        private readonly Criptografia $cripto,
    ) {}

    public function findById(int $id): ?Lancamento
    {
        $row = $this->wpdb->get_row($this->wpdb->prepare(
            "SELECT * FROM {$this->tableName()} WHERE id = %d",
            $id
        ));

        return $row ? $this->hydrate($row) : null;
    }

    public function create(Lancamento $lancamento): int
    {
        $this->wpdb->insert($this->tableName(), [
            'user_id' => $lancamento->userId(),
            'valor_cents' => $this->cripto->criptografar((string) $lancamento->valorCents()),
            'status' => $lancamento->status(),
        ]);

        return (int) $this->wpdb->insert_id;
    }

    private function tableName(): string
    {
        return $this->wpdb->prefix . 'financeiro_lancamentos';
    }

    private function hydrate(object $row): Lancamento
    {
        $row->valor_cents = (int) $this->cripto->descriptografar($row->valor_cents);
        return Lancamento::fromRow($row);
    }
}
```

### POO-019 — Gerenciador: orquestração sem lógica de domínio [ERRO]

Gerenciadores coordenam operações entre entidades e repositórios. A lógica de domínio vive na entidade, não no gerenciador.

```php
// correto — gerenciador orquestra
class FinanceiroManager
{
    public function __construct(
        private readonly LancamentoRepository $lancamentos,
        private readonly ContaBancariaRepository $contas,
    ) {}

    public function confirmarLancamento(int $lancamentoId): void
    {
        $lancamento = $this->lancamentos->findById($lancamentoId);

        if (!$lancamento) {
            throw new LancamentoNaoEncontradoException($lancamentoId);
        }

        $lancamento->confirmar(); // lógica na entidade
        $this->lancamentos->update($lancamento);
    }
}

// incorreto — gerenciador com lógica de domínio
class FinanceiroManager
{
    public function confirmarLancamento(int $id): void
    {
        $lancamento = $this->lancamentos->findById($id);

        if ($lancamento->status() !== 'pendente') { // lógica deveria estar na entidade
            throw new \Exception('Não pode confirmar');
        }

        // ... muda status diretamente
    }
}
```

### POO-020 — Handler: fronteira do sistema [ERRO]

Handlers são a fronteira entre o mundo externo (request HTTP/AJAX) e o domínio. Responsabilidades:
1. Verificar autenticação e autorização (nonce + roles)
2. Sanitizar e validar input
3. Delegar para o gerenciador
4. Retornar resposta

Handlers nunca contêm lógica de domínio nem acessam `$wpdb` diretamente.

```php
class FinanceiroAjaxHandler
{
    private const ALLOWED_ROLES = ['acp_admin', 'acp_user'];

    public function __construct(
        private readonly FinanceiroManager $manager,
    ) {}

    public function register(): void
    {
        add_action('wp_ajax_acp_confirmar_lancamento', [$this, 'handleConfirmarLancamento']);
    }

    public function handleConfirmarLancamento(): void
    {
        $this->checkPermission();

        $lancamentoId = absint($_POST['lancamento_id'] ?? 0);

        if (!$lancamentoId) {
            wp_send_json_error(['mensagem' => 'ID do lançamento é obrigatório.']);
        }

        try {
            $this->manager->confirmarLancamento($lancamentoId);
            wp_send_json_success(['mensagem' => 'Lançamento confirmado.']);
        } catch (LancamentoNaoEncontradoException $e) {
            wp_send_json_error(['mensagem' => 'Lançamento não encontrado.']);
        } catch (TransicaoInvalidaException $e) {
            wp_send_json_error(['mensagem' => 'Transição de status inválida.']);
        }
    }

    private function checkPermission(): void
    {
        check_ajax_referer('acp_nonce', 'nonce');

        $user = wp_get_current_user();
        $hasRole = array_intersect(self::ALLOWED_ROLES, $user->roles);

        if (empty($hasRole)) {
            wp_send_json_error(['mensagem' => 'Sem permissão.'], 403);
        }
    }
}
```

---

## 7. SOLID aplicado ao projeto

### POO-021 — SRP: uma razão para mudar por classe [ERRO]

Cada classe tem uma única responsabilidade. Se uma classe faz validação, cálculo e persistência, dividir em entidade (cálculo/validação), repositório (persistência) e handler (validação de input).

### POO-022 — OCP: extensão sem modificação [AVISO]

Quando novo comportamento é necessário (ex.: novo tipo de lançamento, nova regra de cálculo), preferir polimorfismo ou estratégia em vez de `if/else` no código existente.

### POO-023 — LSP: subtipos substituíveis [AVISO]

Toda classe filha deve poder substituir a classe mãe sem quebrar o comportamento. Se a subclasse precisa desabilitar um método da mãe, o design está errado — extrair para classes irmãs.

### POO-024 — ISP: interfaces segregadas [AVISO]

Interfaces pequenas e coesas. Se uma classe precisa implementar métodos que não usa, a interface é gorda — dividir.

### POO-025 — DIP: inversão de dependência [AVISO]

Módulos de alto nível (gerenciadores) dependem de abstrações (interfaces), não de implementações concretas, quando a dependência pode variar.

---

## 8. Enums e tipos seguros

### POO-026 — Enums para domínios fechados [AVISO]

Status, tipos e categorias com conjunto fixo de valores devem usar PHP Enums (8.1+), não strings soltas.

```php
// correto
enum TipoLancamento: string
{
    case Receita = 'receita';
    case Despesa = 'despesa';
    case Transferencia = 'transferencia';
}

enum TipoConta: string
{
    case Corrente = 'corrente';
    case Poupanca = 'poupanca';
    case Carteira = 'carteira';
    case Investimento = 'investimento';
}

// incorreto — string solta
$tipo = 'receita'; // pode ser qualquer coisa, sem validação
```

### POO-027 — Usar DateTimeImmutable, nunca strings de data [ERRO]

Datas são objetos, não strings. Usar `DateTimeImmutable` para todas as propriedades temporais.

```php
// correto
private readonly DateTimeImmutable $criadoEm;
private ?DateTimeImmutable $prazo;

// incorreto
private string $criadoEm; // '2026-04-07'
private ?string $prazo;
```

---

## Checklist de auditoria

A skill `/auditar-poo` deve verificar, para cada arquivo:

**Modelagem e encapsulamento:**
- [ ] Classes representam conceitos do domínio financeiro (nomes claros)
- [ ] Métodos expressam intenção com verbos de ação
- [ ] Entidade não é anêmica (contém lógica de domínio)
- [ ] Atributos são privados (nunca public)
- [ ] Tell, Don't Ask respeitado (decisões dentro do objeto)
- [ ] Sem setters públicos (mutação via métodos de negócio)

**Herança e polimorfismo:**
- [ ] Herança apenas para subtipos reais
- [ ] Composição sobre herança para reutilização de código
- [ ] Switch/if em tipo substituído por polimorfismo quando aplicável

**Interfaces:**
- [ ] Interfaces magras e específicas
- [ ] Dependências que podem variar recebem interface

**Value Objects:**
- [ ] Primitivos com significado de domínio encapsulados em VO
- [ ] Value Objects são imutáveis
- [ ] Datas usam DateTimeImmutable

**Padrões do projeto:**
- [ ] Entidade segue Rich Domain Model (FSM, lifecycle, predicados, fromRow, toArray)
- [ ] Repositório segue interface uniforme (findById, findAll, create, update, delete, hydrate)
- [ ] Gerenciador orquestra sem lógica de domínio
- [ ] Handler valida e delega (nunca acessa $wpdb, nunca contém lógica de domínio)

**SOLID:**
- [ ] Uma responsabilidade por classe (SRP)
- [ ] Extensão sem modificação quando aplicável (OCP)
- [ ] Subtipos substituíveis (LSP)
- [ ] Interfaces segregadas (ISP)
- [ ] Inversão de dependência quando a dependência varia (DIP)

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
2. Comparar contra **cada regra** de `docs/padroes-poo.md`, uma por uma, na ordem do documento.
3. Para cada violação encontrada, registrar:
   - **Arquivo** e **linha(s)** onde ocorre
   - **ID da regra** violada (ex.: POO-017)
   - **Severidade** (ERRO ou AVISO)
   - **O que está errado** — descrição concisa
   - **Como corrigir** — correção específica para aquele trecho
4. Se o arquivo não viola nenhuma regra, registrar como aprovado.

### Fase 4 — Relatório

Apresentar o relatório ao usuário no seguinte formato:

```
## Relatório de auditoria POO

**PR:** #<numero> — <titulo>
**Branch:** <branch>
**Arquivos auditados:** <quantidade>
**Régua:** docs/padroes-poo.md

### Resumo

- Erros: <quantidade>
- Avisos: <quantidade>
- Arquivos aprovados: <quantidade>

### Violações

#### <arquivo.php>

| Linha | Regra | Severidade | Descrição | Correção |
|-------|-------|------------|-----------|----------|
| 10 | POO-003 | ERRO | Entidade anêmica, só getters/setters | Adicionar lógica de domínio |
| 25 | POO-005 | ERRO | Decisão de status fora da entidade | Mover para lifecycle method |

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
- **Nunca inventar regras.** A régua é exclusivamente o `docs/padroes-poo.md` — sem opinião, sem sugestões extras.
- **Ser metódica e processual.** Cada arquivo é comparado contra cada regra, na ordem do documento, sem pular.
- **Fidelidade ao documento.** Se o código viola uma regra do documento, reportar. Se o documento não cobre o caso, não reportar.
- **Mostrar o relatório completo antes de qualquer ação.** Nunca executar correções sem aprovação explícita.
