---
name: auditar-testes
description: Audita testes PHPUnit do PR aberto contra as regras definidas em docs/padroes-testes.md. Entrega relatório de violações e plano de correções. Trigger manual apenas.
---

# /auditar-testes — Auditora de padrões de testes

Lê as regras de `docs/padroes-testes.md`, identifica os arquivos de teste alterados no PR aberto (não mergeado) e compara cada arquivo contra cada regra aplicável. Foco em qualidade de testes: organização, nomenclatura, cobertura por camada, determinismo, isolamento e antipadrões.

Complementa `/auditar-php` (sintaxe) e `/auditar-poo` (arquitetura).

## Quando usar

- **APENAS** quando o usuário digitar `/auditar-testes` explicitamente.
- Rodar antes de mergear um PR — funciona como gate de qualidade dos testes.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Padrões mínimos exigidos

> Esta seção contém os padrões completos usados pela auditoria. Edite para personalizar ao seu projeto.

# Padrão de testes

## Descrição

Documento de referência para auditoria de testes no projeto Acertando os Pontos. Define como testes devem ser escritos, organizados e o que devem cobrir. A skill `/auditar-testes` lê este documento e compara contra os testes do PR aberto.

Complementa `docs/padroes-php.md` (sintaxe) e `docs/padroes-poo.md` (arquitetura).

## Escopo

- Testes PHPUnit dentro de `acertandoospontos/testes/`
- Cobertura de: entidades, repositórios, gerenciadores, handlers, templates
- Foco em testes que simulam condições reais de uso
- Organização em 5 camadas conforme a pirâmide de testes

## Referências

- `docs/padroes-php.md` — Regras de linguagem PHP
- `docs/padroes-poo.md` — Padrões de arquitetura OOP
- `referencias/entrada/CLAUDE-UniBGR.md` — Padrões de testes da plataforma-mãe
- `referencias/entrada/testes.jpeg` — Pirâmide de testes do projeto
- [PHPUnit 12.x](https://docs.phpunit.de/en/12.0/)
- Better Specs / Even Better Specs (convenções de qualidade)

## Severidade

- **ERRO** — Violação bloqueia aprovação. Deve ser corrigida antes de merge.
- **AVISO** — Recomendação forte. Deve ser justificada se ignorada.

---

## 1. Pirâmide de testes

### TST-001 — Cinco camadas, base larga, topo estreito [ERRO]

O projeto adota a pirâmide de testes com 5 camadas. Cada camada tem escopo, custo e proporção definidos. A base (unitários) concentra o maior volume de testes. O topo (funcionais) tem poucos testes de alto valor.

| Camada | Pasta | O que testa | Custo/Esforço |
|--------|-------|-------------|---------------|
| Unitários | `testes/unitarios/` | Entidades, Value Objects — lógica pura de domínio | Baixo |
| Componentes | `testes/componentes/` | Gerenciadores com mocks — orquestração isolada | Baixo-médio |
| Integração | `testes/integracao/` | Repositórios com banco real, criptografia | Médio |
| API | `testes/api/` | Handlers AJAX — request/response completo | Médio-alto |
| Funcionais | `testes/funcionais/` | Página renderiza, fluxos end-to-end | Alto |

Proporção esperada (aproximada):

```
         /\          Funcionais       ~5%
        /  \         API              ~10%
       /    \        Integração       ~15%
      /      \       Componentes      ~20%
     /________\      Unitários        ~50%
```

**Regra:** quanto mais alto na pirâmide, menos testes e mais seletivos. Testes funcionais cobrem fluxos críticos, não cada variação. Testes unitários cobrem cada caso.

### TST-002 — Cada teste vive na camada correta [ERRO]

Um teste que acessa banco de dados não é unitário. Um teste que mocka tudo não é de integração. Classificar corretamente:

| Se o teste... | Camada |
|---------------|--------|
| Testa lógica pura sem dependência externa | Unitário |
| Testa orquestração com mocks de repositórios | Componente |
| Acessa banco de dados real | Integração |
| Simula requisição AJAX com nonce/roles | API |
| Verifica se a página renderiza com WordPress carregado | Funcional |

---

## 2. Filosofia

### TST-003 — Testes simulam condições reais [ERRO]

Testes existem para provar que o código funciona em situações que acontecem de verdade. Não testar cenários inventados que nunca ocorrem em produção. Não testar o óbvio por testar.

```php
// correto — simula uso real
public function testConfirmarLancamentoPendenteTransicionaParaConfirmado(): void
{
    $lancamento = LancamentoFactory::pendente();

    $lancamento->confirmar();

    $this->assertSame('confirmado', $lancamento->status());
}

// incorreto — cenário que nunca acontece
public function testLancamentoComIdNegativo(): void
{
    // IDs negativos nunca existem no banco, teste inútil
}
```

### TST-004 — Bug encontrado = teste faltando [ERRO]

Se um bug aparece, o primeiro passo é escrever um teste que reproduz o bug. Depois corrigir. O teste garante que o bug nunca volta.

### TST-005 — Todo código novo tem teste [ERRO]

Toda entidade, repositório, gerenciador e handler entregue em PR deve ter testes correspondentes na camada adequada da pirâmide. Código sem teste não mergeia.

Exceção: templates puros (HTML com chamadas WordPress como `get_header()`, `wp_head()`) não exigem testes unitários — são cobertos por testes funcionais quando o fluxo justifica.

---

## 3. Organização e nomenclatura

### TST-006 — Estrutura de pastas espelha o código em 5 camadas [ERRO]

```
acertandoospontos/
├── inc/
│   ├── entidades/Lancamento.php
│   ├── repositorios/LancamentoRepository.php
│   ├── gerenciadores/FinanceiroManager.php
│   └── handlers/FinanceiroAjaxHandler.php
└── testes/
    ├── unitarios/
    │   ├── LancamentoTest.php
    │   ├── ContaBancariaTest.php
    │   └── DinheiroTest.php
    ├── componentes/
    │   └── FinanceiroManagerTest.php
    ├── integracao/
    │   ├── LancamentoRepositoryTest.php
    │   └── CriptografiaTest.php
    ├── api/
    │   └── FinanceiroAjaxHandlerTest.php
    └── funcionais/
        └── LandingPageTest.php
```

### TST-007 — Nomes de teste descrevem comportamento com contexto [ERRO]

Usar o padrão: `test` + ação + contexto + resultado esperado. Sem a palavra "deve" (should). Contextos com "quando", "com", "sem".

```php
// correto — comportamento claro
public function testConfirmarQuandoPendenteTransicionaParaConfirmado(): void {}
public function testConfirmarQuandoJaConfirmadoLancaExcecao(): void {}
public function testCriarComValorNegativoLancaExcecao(): void {}
public function testCalcularSaldoSemLancamentosRetornaZero(): void {}

// incorreto — vago, não diz o que espera
public function testConfirmar(): void {}
public function testLancamento(): void {}
public function testDeveConfirmarOLancamento(): void {} // "deve" proibido
```

### TST-008 — Descrições curtas, máximo 100 caracteres [AVISO]

Se o nome do teste ultrapassar 100 caracteres, o cenário é complexo demais — dividir em testes menores ou usar contextos.

---

## 4. Estrutura do teste

### TST-009 — Padrão AAA: Arrange, Act, Assert [ERRO]

Todo teste segue três blocos separados por linha em branco: preparar, executar, verificar.

```php
// correto — AAA claro
public function testConfirmarQuandoPendenteTransicionaParaConfirmado(): void
{
    // Arrange
    $lancamento = LancamentoFactory::pendente();

    // Act
    $lancamento->confirmar();

    // Assert
    $this->assertSame('confirmado', $lancamento->status());
}

// incorreto — tudo misturado
public function testConfirmar(): void
{
    $this->assertSame('confirmado', LancamentoFactory::pendente()->confirmar()->status());
}
```

### TST-010 — Uma asserção por teste unitário [AVISO]

Testes unitários e de componentes validam um único comportamento com uma asserção. Testes de integração, API e funcionais podem ter até 3 asserções relacionadas.

```php
// correto — uma asserção (unitário)
public function testConfirmarTransicionaStatus(): void
{
    $lancamento = LancamentoFactory::pendente();

    $lancamento->confirmar();

    $this->assertSame('confirmado', $lancamento->status());
}

// aceitável em integração/API — asserções relacionadas
public function testCriarLancamentoPersisteTodosOsCampos(): void
{
    $id = $this->repository->create($lancamento);

    $salvo = $this->repository->findById($id);
    $this->assertNotNull($salvo);
    $this->assertSame($lancamento->valorCents(), $salvo->valorCents());
    $this->assertSame($lancamento->status(), $salvo->status());
}
```

### TST-011 — Testar os três caminhos: feliz, inválido, limite [ERRO]

Todo comportamento testado cobre:
1. **Caminho feliz** — funciona como esperado
2. **Caso inválido** — rejeita entrada errada
3. **Caso limite** — comportamento na fronteira (zero, vazio, máximo)

```php
// Caminho feliz
public function testConfirmarQuandoPendenteTransicionaParaConfirmado(): void {}

// Caso inválido
public function testConfirmarQuandoCanceladoLancaExcecao(): void {}

// Caso limite
public function testCalcularSaldoComNenhumLancamentoRetornaZero(): void {}
```

---

## 5. Dados de teste

### TST-012 — Factories, nunca fixtures [ERRO]

Usar factories para criar objetos de teste. Factories são controláveis, flexíveis e explícitas. Fixtures são frágeis e opacas.

```php
// correto — factory
class LancamentoFactory
{
    public static function pendente(array $overrides = []): Lancamento
    {
        return new Lancamento(
            id: $overrides['id'] ?? 1,
            userId: $overrides['userId'] ?? 100,
            contaId: $overrides['contaId'] ?? 1,
            valorCents: $overrides['valorCents'] ?? 15000,
            status: Lancamento::STATUS_PENDENTE,
        );
    }

    public static function confirmado(array $overrides = []): Lancamento
    {
        $lancamento = self::pendente($overrides);
        $lancamento->confirmar();
        return $lancamento;
    }
}

// incorreto — fixture JSON/YAML compartilhada
// fixtures/lancamento.json ← frágil, difícil de rastrear, compartilhada entre testes
```

### TST-013 — Criar apenas o necessário [AVISO]

Cada teste constrói estritamente o mínimo de dados para o cenário. Sem carregar objetos completos quando um parcial resolve.

```php
// correto — só o que o teste precisa
public function testEstaAtivaRetornaTrueQuandoStatusAtivo(): void
{
    $conta = ContaBancariaFactory::ativa();

    $this->assertTrue($conta->estaAtiva());
}

// incorreto — constrói o mundo inteiro
public function testEstaAtiva(): void
{
    $usuario = UsuarioFactory::completo();
    $conta = ContaBancariaFactory::completaComUsuario($usuario);
    $lancamento1 = LancamentoFactory::pendente(['contaId' => $conta->id()]);
    $lancamento2 = LancamentoFactory::confirmado(['contaId' => $conta->id()]);
    // ... só pra testar se a conta está ativa
}
```

### TST-014 — Sem valores soltos duplicados entre setup e asserção [ERRO]

Nunca repetir literais entre a construção e a verificação. Ler do objeto, não de strings duplicadas.

```php
// correto — lê do objeto
public function testCriarLancamentoPersiste(): void
{
    $lancamento = LancamentoFactory::pendente(['valorCents' => 5000]);

    $id = $this->repository->create($lancamento);
    $salvo = $this->repository->findById($id);

    $this->assertSame($lancamento->valorCents(), $salvo->valorCents());
}

// incorreto — valor duplicado
public function testCriarLancamentoPersiste(): void
{
    $lancamento = LancamentoFactory::pendente(['valorCents' => 5000]);

    $id = $this->repository->create($lancamento);
    $salvo = $this->repository->findById($id);

    $this->assertSame(5000, $salvo->valorCents()); // 5000 repetido
}
```

---

## 6. Isolamento por camada

### TST-015 — Testes unitários: sem dependência externa [ERRO]

Testes em `testes/unitarios/` trabalham com objetos em memória. Sem banco, sem rede, sem filesystem, sem WordPress. Testam entidades e Value Objects puros.

```php
// correto — unitário puro
public function testConfirmarQuandoPendenteTransiciona(): void
{
    $lancamento = LancamentoFactory::pendente();

    $lancamento->confirmar();

    $this->assertSame('confirmado', $lancamento->status());
}
```

### TST-016 — Testes de componentes: mocks de dependências [ERRO]

Testes em `testes/componentes/` isolam o sujeito mockando suas dependências (repositórios, serviços). Testam orquestração sem tocar infraestrutura.

```php
// correto — componente com mock
public function testConfirmarLancamentoAtualizaRepositorio(): void
{
    $repository = $this->createMock(LancamentoRepository::class);
    $repository->expects($this->once())
        ->method('findById')
        ->willReturn(LancamentoFactory::pendente());
    $repository->expects($this->once())
        ->method('update');

    $manager = new FinanceiroManager($repository);

    $manager->confirmarLancamento(1);
}
```

### TST-017 — Testes de integração: banco real, sem mocks [ERRO]

Testes em `testes/integracao/` usam banco de dados real (MariaDB). Testam repositórios, criptografia e persistência de ponta a ponta. Sem mocks de `$wpdb`.

```php
// correto — integração com banco real
public function testCriarLancamentoPersisteCriptografado(): void
{
    $lancamento = LancamentoFactory::pendente(['valorCents' => 5000]);

    $id = $this->repository->create($lancamento);
    $salvo = $this->repository->findById($id);

    $this->assertSame($lancamento->valorCents(), $salvo->valorCents());
}
```

### TST-018 — Testes de API: request/response completo [ERRO]

Testes em `testes/api/` simulam requisições AJAX completas, incluindo nonce, roles e payload. Testam handlers como caixa preta: entrada → saída.

```php
// correto — teste de API
public function testConfirmarLancamentoSemNonceRetornaErro(): void
{
    // Arrange — requisição sem nonce
    $_POST = ['lancamento_id' => 1];

    // Act
    $response = $this->handler->handleConfirmarLancamento();

    // Assert
    $this->assertFalse($response['success']);
}

public function testConfirmarLancamentoComDadosValidosRetornaSucesso(): void
{
    // Arrange — requisição completa
    $_POST = [
        'lancamento_id' => 1,
        'nonce' => wp_create_nonce('acp_nonce'),
    ];
    wp_set_current_user($this->usuarioAcp);

    // Act
    $response = $this->handler->handleConfirmarLancamento();

    // Assert
    $this->assertTrue($response['success']);
}
```

### TST-019 — Testes funcionais: WordPress carregado, página renderiza [ERRO]

Testes em `testes/funcionais/` carregam WordPress completo e verificam que páginas renderizam corretamente, assets são registrados e fluxos end-to-end funcionam.

```php
// correto — funcional
public function testLandingPageRenderizaComAssetsCorretos(): void
{
    $this->go_to(home_url('/'));

    do_action('wp_enqueue_scripts');

    $this->assertTrue(wp_style_is('acp-bootstrap', 'enqueued'));
    $this->assertTrue(wp_style_is('acp-estilo', 'enqueued'));
    $this->assertTrue(wp_script_is('acp-bootstrap-js', 'enqueued'));
    $this->assertTrue(wp_script_is('acp-app', 'enqueued'));
}

public function testLandingPageContemSecoesEsperadas(): void
{
    $this->go_to(home_url('/'));

    ob_start();
    load_template(get_template_directory() . '/index.php');
    $html = ob_get_clean();

    $this->assertStringContainsString('id="inicio"', $html);
    $this->assertStringContainsString('id="sobre"', $html);
    $this->assertStringContainsString('id="beneficios"', $html);
    $this->assertStringContainsString('id="como-funciona"', $html);
}
```

### TST-020 — Mockar dependências externas, nunca o sujeito [ERRO]

Mock em dependências que não são responsabilidade do teste. Nunca mockar o objeto que está sendo testado.

```php
// correto — mock da dependência
public function testConfirmarLancamentoAtualizaRepositorio(): void
{
    $repository = $this->createMock(LancamentoRepository::class);
    $repository->expects($this->once())
        ->method('update');

    $manager = new FinanceiroManager($repository);
    $manager->confirmarLancamento(1);
}

// incorreto — mock do sujeito
public function testLancamento(): void
{
    $lancamento = $this->createMock(Lancamento::class); // não testa nada real
    $lancamento->method('estaConfirmado')->willReturn(true);
}
```

### TST-021 — Sem dependência de estado externo [ERRO]

Testes não dependem de variáveis de ambiente, hora do sistema, arquivos em disco ou estado de outros testes. Cada teste é autossuficiente.

```php
// correto — tempo controlado
public function testLancamentoVencidoQuandoDataPassou(): void
{
    $dataPassada = new DateTimeImmutable('2025-01-01');
    $lancamento = LancamentoFactory::pendente(['dataVencimento' => $dataPassada]);

    $this->assertTrue($lancamento->estaVencido(new DateTimeImmutable('2026-04-07')));
}

// incorreto — depende do relógio real
public function testLancamentoVencido(): void
{
    $lancamento = LancamentoFactory::pendente(['dataVencimento' => new DateTimeImmutable('yesterday')]);
    $this->assertTrue($lancamento->estaVencido()); // quebra dependendo do dia
}
```

---

## 7. Determinismo

### TST-022 — Testes são determinísticos [ERRO]

O mesmo teste rodando 100 vezes produz o mesmo resultado. Sem `time()`, `rand()`, `uniqid()`, `new DateTimeImmutable()` sem argumento.

```php
// correto — valores fixos
$agora = new DateTimeImmutable('2026-04-07 10:00:00');
$id = 42;

// incorreto — não determinístico
$agora = new DateTimeImmutable(); // muda a cada execução
$id = random_int(1, 1000);
```

### TST-023 — Ordem de execução não importa [ERRO]

Nenhum teste depende de outro teste ter rodado antes. Cada teste prepara seu próprio estado e limpa depois se necessário.

---

## 8. Cobertura por camada

### TST-024 — Unitários: entidades cobrem FSM completa [ERRO]

Toda entidade com máquina de estados deve ter testes unitários para:
1. Cada transição válida
2. Cada transição inválida (lança exceção)
3. Cada predicado de estado
4. Construção com parâmetros válidos
5. Construção com parâmetros inválidos
6. `fromRow()` com dados limpos
7. `fromRow()` com dados sujos (não explode)
8. `toArray()` retorna todos os campos

```php
// Exemplo de cobertura mínima para Lancamento (testes/unitarios/)
public function testCriarLancamentoPendente(): void {}
public function testConfirmarQuandoPendenteTransiciona(): void {}
public function testConfirmarQuandoCanceladoLancaExcecao(): void {}
public function testCancelarQuandoPendenteTransiciona(): void {}
public function testCancelarQuandoJaCanceladoLancaExcecao(): void {}
public function testEstaConfirmadoRetornaTrueQuandoConfirmado(): void {}
public function testEstaPendenteRetornaTrueQuandoPendente(): void {}
public function testPodeTransicionarParaConfirmadoQuandoPendente(): void {}
public function testNaoPodeTransicionarParaConfirmadoQuandoCancelado(): void {}
public function testFromRowComDadosLimposHidrataCorretamente(): void {}
public function testFromRowComDadosSujosNaoExplode(): void {}
public function testToArrayRetornaTodosOsCampos(): void {}
```

### TST-025 — Componentes: gerenciadores cobrem orquestração [ERRO]

Gerenciadores são testados em `testes/componentes/` com mocks de repositórios, verificando:
1. Chama os métodos corretos do repositório
2. Lança exceção quando entidade não encontrada
3. Delega lógica de domínio para a entidade (não decide por ela)

### TST-026 — Integração: repositórios cobrem CRUD + criptografia [ERRO]

Todo repositório deve ter testes de integração em `testes/integracao/` para:
1. `create()` persiste e retorna ID
2. `findById()` retorna entidade correta
3. `findById()` retorna null quando não existe
4. `update()` persiste alterações
5. `delete()` remove registro
6. Dados criptografados são descriptografados na leitura

### TST-027 — API: handlers cobrem segurança e contrato [ERRO]

Todo handler deve ter testes de API em `testes/api/` para:
1. Requisição sem nonce é rejeitada
2. Requisição com role inválida é rejeitada
3. Requisição com dados faltando retorna erro
4. Requisição válida retorna sucesso
5. Exceções do gerenciador são capturadas e retornadas como erro

### TST-028 — Funcionais: fluxos críticos e renderização [AVISO]

Testes funcionais em `testes/funcionais/` cobrem:
1. Página carrega sem erro (HTTP 200)
2. Assets essenciais estão enfileirados (CSS, JS)
3. Seções obrigatórias renderizam no HTML
4. Fluxos end-to-end críticos (cadastro → login → dashboard)

Testes funcionais são seletivos — cobrem caminhos críticos, não cada variação. O volume é baixo (topo da pirâmide).

---

## 9. Antipadrões

### TST-029 — Sem hooks complexos nem estado compartilhado [AVISO]

Evitar `setUp()` complexos que constroem estado compartilhado entre testes. Se o `setUp()` tem mais de 5 linhas, provavelmente o teste precisa de factory.

### TST-030 — Sem testes que testam o framework [ERRO]

Não testar se `$wpdb->insert()` funciona. Não testar se `json_encode()` retorna JSON. Testar o **nosso** código, não o do PHP ou WordPress.

```php
// incorreto — testa o PHP, não nosso código
public function testJsonEncodeRetornaString(): void
{
    $this->assertIsString(json_encode(['a' => 1]));
}
```

### TST-031 — Sem testes fantasiosos [ERRO]

Não testar cenários impossíveis ou extremamente improváveis que nunca acontecem em uso real. Testes existem para validar comportamento de produção.

```php
// incorreto — cenário fantasioso
public function testLancamentoComBilhaoDeReais(): void
{
    $lancamento = LancamentoFactory::pendente(['valorCents' => 100000000000000]);
    // ... nunca vai acontecer no sistema
}

// correto — cenário real
public function testLancamentoComValorMaximoPermitido(): void
{
    $lancamento = LancamentoFactory::pendente(['valorCents' => 99999999]); // R$ 999.999,99
    $this->assertSame(99999999, $lancamento->valorCents());
}
```

---

## Checklist de auditoria

A skill `/auditar-testes` deve verificar, para cada arquivo de teste:

**Pirâmide:**
- [ ] Teste está na camada correta (unitário/componente/integração/API/funcional)
- [ ] Proporção da pirâmide respeitada (base larga, topo estreito)

**Filosofia:**
- [ ] Testes simulam condições reais de uso
- [ ] Todo código novo tem teste correspondente na camada adequada
- [ ] Três caminhos cobertos: feliz, inválido, limite

**Organização:**
- [ ] Estrutura de pastas em 5 camadas espelha o código
- [ ] Nomes descrevem comportamento com contexto (sem "deve")
- [ ] Descrições com máximo 100 caracteres

**Estrutura:**
- [ ] Padrão AAA (Arrange, Act, Assert)
- [ ] Uma asserção por teste unitário/componente (até 3 em integração/API/funcional)
- [ ] Sem valores soltos duplicados entre setup e asserção

**Dados:**
- [ ] Factories usadas, nunca fixtures
- [ ] Apenas dados necessários criados

**Isolamento:**
- [ ] Unitários: sem banco, sem rede, sem WordPress
- [ ] Componentes: mocks de dependências, sem infraestrutura
- [ ] Integração: banco real, sem mocks de $wpdb
- [ ] API: request/response completo com nonce e roles
- [ ] Funcionais: WordPress carregado, página renderiza
- [ ] Mocks apenas em dependências, nunca no sujeito
- [ ] Sem dependência de estado externo

**Determinismo:**
- [ ] Sem time(), rand(), uniqid() ou DateTimeImmutable sem argumento
- [ ] Ordem de execução não importa

**Cobertura:**
- [ ] Unitários: entidades com FSM completa testada
- [ ] Componentes: gerenciadores com orquestração testada
- [ ] Integração: repositórios com CRUD + criptografia
- [ ] API: handlers com segurança (nonce, roles, dados, exceções)
- [ ] Funcionais: fluxos críticos e renderização

**Antipadrões:**
- [ ] Sem setUp() complexo nem estado compartilhado
- [ ] Sem testes que testam o framework
- [ ] Sem testes fantasiosos (cenários irreais)

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
5. Filtrar arquivos `*Test.php` dentro de `acertandoospontos/testes/`.
6. Também verificar se arquivos PHP em `acertandoospontos/inc/` alterados no PR possuem testes correspondentes.

### Fase 3 — Auditar arquivo por arquivo

Para cada arquivo de teste alterado no PR:

1. Ler o arquivo completo (não apenas o diff — contexto importa).
2. Comparar contra **cada regra** de `docs/padroes-testes.md`, uma por uma, na ordem do documento.
3. Para cada violação encontrada, registrar:
   - **Arquivo** e **linha(s)** onde ocorre
   - **ID da regra** violada (ex.: TST-009)
   - **Severidade** (ERRO ou AVISO)
   - **O que está errado** — descrição concisa
   - **Como corrigir** — correção específica para aquele trecho
4. Se o arquivo não viola nenhuma regra, registrar como aprovado.

Para cada arquivo PHP em `inc/` sem teste correspondente:

5. Registrar como violação de TST-003 (todo código novo tem teste).

6. Garantir que o coverage seja de 100% 

### Fase 4 — Relatório

Apresentar o relatório ao usuário no seguinte formato:

```
## Relatório de auditoria de testes

**PR:** #<numero> — <titulo>
**Branch:** <branch>
**Arquivos de teste auditados:** <quantidade>
**Arquivos de código sem teste:** <quantidade>
**Régua:** docs/padroes-testes.md

### Resumo

- Erros: <quantidade>
- Avisos: <quantidade>
- Arquivos aprovados: <quantidade>

### Violações

#### <ArquivoTest.php>

| Linha | Regra | Severidade | Descrição | Correção |
|-------|-------|------------|-----------|----------|
| 15 | TST-007 | ERRO | Teste sem padrão AAA | Separar Arrange/Act/Assert |
| 42 | TST-016 | ERRO | Usa DateTimeImmutable sem argumento | Injetar data fixa |

#### Código sem teste

| Arquivo | Regra | Severidade |
|---------|-------|------------|
| inc/entidades/Meta.php | TST-003 | ERRO |

#### <OutroTest.php>
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
- **Nunca auditar arquivos fora do PR.** Apenas arquivos de teste e código alterados no PR aberto.
- **Sempre referenciar o ID da regra violada.** O relatório deve ser rastreável ao documento de padrões.
- **Nunca inventar regras.** A régua é exclusivamente o `docs/padroes-testes.md` — sem opinião, sem sugestões extras.
- **Ser metódica e processual.** Cada arquivo é comparado contra cada regra, na ordem do documento, sem pular.
- **Fidelidade ao documento.** Se o teste viola uma regra do documento, reportar. Se o documento não cobre o caso, não reportar.
- **Verificar cobertura cruzada.** Se o PR tem código novo em `inc/` sem teste em `testes/`, reportar como TST-003.
- **Verificar dependências dinâmicas do `$wpdb` em integration tests.** Se o código de produção tocado pelo PR usa propriedades dinâmicas do `$wpdb` (`$wpdb->users`, `$wpdb->posts`, `$wpdb->comments`, etc. — qualquer `$wpdb->X` que não seja método como `prepare`/`get_*`/`insert`/`update`/`delete`/`query`/`esc_like`), **verificar que o adapter `WpdbPdo` em `testes/helpers/` expõe essas propriedades**. Se não expõe, é ERRO bloqueante de integração. Padrão de detecção:
  ```bash
  grep -nE '\$this->wpdb->[a-z_]+' inc/repositorios/*.php | grep -vE '->(prepare|get_row|get_results|get_var|get_col|insert|update|delete|query|esc_like|base_prefix|prefix)'
  ```
  Cada hit que sobrar é uma propriedade dinâmica que precisa estar no `WpdbPdo`. Origem: incidente 0004 (`aprendizado/erros/0004-skipped-tests-mascararam-quebra-do-wpdbpdo.md`).
- **Suíte com SKIPPED ≠ validada.** Se o PR cria/altera integration test e a única validação reportada for `composer test` local (sem `TEST_DB_HOST`), reportar como ERRO de validação. Skipped ≠ verde. A validação precisa ter rodado contra DB real (`docker compose -f docker-compose.test.yml up -d` + `TEST_DB_HOST=localhost composer test:integration`) ou explicitamente delegar pro CI com aviso. Origem: incidente 0004.
- **Mostrar o relatório completo antes de qualquer ação.** Nunca executar correções sem aprovação explícita.
