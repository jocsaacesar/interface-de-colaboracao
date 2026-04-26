---
name: auditar-frontend
description: Audita HTML, CSS, JavaScript e UX do PR aberto contra as regras definidas em docs/padroes-ux-ui.md. Cobre identidade visual, Bootstrap, UX financeira, formulários, acessibilidade e interatividade. Trigger manual apenas.
---

# /auditar-frontend — Auditora de padrões frontend e UX/UI

Lê as regras de `docs/padroes-ux-ui.md`, identifica os arquivos HTML, CSS e JavaScript alterados no PR aberto (não mergeado) e compara cada arquivo contra cada regra aplicável. Foco em: tokens visuais da marca, convenções Bootstrap 5.3, UX financeira, formulários, tabelas, dashboards, acessibilidade e JavaScript.

Complementa `/auditar-php` (sintaxe), `/auditar-poo` (arquitetura), `/auditar-testes` (testes), `/auditar-seguranca` (segurança) e `/auditar-wordpress` (APIs WP).

## Quando usar

- **APENAS** quando o usuário digitar `/auditar-frontend` explicitamente.
- Rodar antes de mergear um PR — funciona como gate de qualidade visual e de UX.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Padrões mínimos exigidos

> Esta seção contém os padrões completos usados pela auditoria. Edite para personalizar ao seu projeto.

# Padrão de UX/UI e estilos visuais

## Descrição

Documento de referência para auditoria de interface, experiência do usuário e estilos visuais no projeto Acertando os Pontos. Define tokens visuais da marca, convenções de Bootstrap 5.3, padrões de UX para aplicações financeiras e acessibilidade. A skill `/auditar-frontend` lê este documento e compara contra o código-alvo.

## Escopo

- Todo HTML em `paginas/`, `header.php`, `footer.php`, `index.php`
- Todo CSS em `assets/css/`
- Todo JavaScript em `assets/js/`
- Framework: Bootstrap 5.3 (via CDN)

## Referências

- [Bootstrap 5.3 Documentation](https://getbootstrap.com/docs/5.3/)
- [WCAG 2.1 — Web Content Accessibility Guidelines](https://www.w3.org/TR/WCAG21/)
- [HTML Living Standard — Input modes](https://html.spec.whatwg.org/multipage/interaction.html#input-modalities:-the-inputmode-attribute)

## Severidade

- **ERRO** — Violação bloqueia aprovação. Deve ser corrigida antes de merge.
- **AVISO** — Recomendação forte. Deve ser justificada se ignorada.

---

## 1. Tokens visuais da marca

Identidade visual desenvolvida por @isabelademenezes. Arquivo de referência completo em `referencias/entrada/identidade-visual-acertandoospontos/`.

### UI-001 — Cores definidas como CSS custom properties [ERRO]

Todas as cores da marca são declaradas como variáveis CSS na raiz do `assets/css/estilo.css`. Nunca usar valores hexadecimais direto nos componentes.

**Paleta da marca:**
- Rosa/nude `#E2C5B0` — cor principal. Transmite cuidado, amor, ternura e afeto.
- Rosa claro `#EFD7D3` — cor de apoio. Fundos suaves, hover, destaques leves.
- Cinza escuro `#939393` — tipografia secundária. Credibilidade, sobriedade, sensatez.
- Cinza médio `#707070` — textos auxiliares, bordas, ícones.

```css
/* assets/css/estilo.css */
:root {
    /* Cores da marca Acertando os Pontos */
    --acp-primary: #E2C5B0;
    --acp-primary-hover: #d4b39e;
    --acp-primary-light: #EFD7D3;
    --acp-gray-dark: #939393;
    --acp-gray-medium: #707070;

    /* Semânticas financeiras */
    --acp-receita: #198754;
    --acp-despesa: #dc3545;
    --acp-transferencia: #0dcaf0;
    --acp-saldo-positivo: #198754;
    --acp-saldo-negativo: #dc3545;

    /* Neutras */
    --acp-bg: #faf8f6;
    --acp-bg-card: #ffffff;
    --acp-texto: #3d3d3d;
    --acp-texto-muted: #939393;
    --acp-borda: #e8e0da;
}
```

```html
<!-- correto — usa variável -->
<div style="color: var(--acp-receita);">+R$ 1.500,00</div>

<!-- incorreto — cor hardcoded -->
<div style="color: #198754;">+R$ 1.500,00</div>
```

### UI-002 — Cores semânticas para dados financeiros [ERRO]

Receitas são sempre verdes (`--acp-receita`), despesas sempre vermelhas (`--acp-despesa`), transferências sempre azul-claro (`--acp-transferencia`). Nunca misturar significados.

### UI-003 — Tipografia da marca [AVISO]

A marca usa uma fonte exclusiva para o logotipo (não replicável em CSS — usar imagem SVG). Para o corpo da aplicação, usar a stack de fontes do Bootstrap como base. Se uma fonte de corpo for definida futuramente, declarar via `--acp-font-family`.

```css
:root {
    --acp-font-family: var(--bs-body-font-family);
    --acp-font-mono: var(--bs-font-monospace);
}

body {
    font-family: var(--acp-font-family);
    color: var(--acp-texto);
    background-color: var(--acp-bg);
}
```

### UI-004 — Valores monetários em fonte monospace [AVISO]

Números financeiros (saldos, valores de lançamento, metas) usam fonte monospace para alinhamento visual.

```html
<!-- correto -->
<span class="font-monospace">R$ 1.500,00</span>

<!-- incorreto -->
<span>R$ 1.500,00</span>
```

### UI-005 — Logotipo e ícone da marca [ERRO]

O logotipo é um asset gráfico — nunca recriado via CSS ou texto. Servido como SVG ou PNG otimizado.

**Variações disponíveis (em `assets/img/`):**
- `logo-horizontal.svg` — ícone flor + monograma "ap" + texto (uso principal em header/sidebar)
- `logo-vertical.svg` — marca completa empilhada (uso em landing, login)
- `logo-marca-dagua.svg` — versão circular com fundo cinza (uso em backgrounds)
- `logo-negativa.svg` — versão clara para fundos escuros
- `favicon.svg` — monograma "ap" sozinho (favicon, ícones pequenos)

**Regras de uso:**
- Área de respiro mínima ao redor do logo: equivalente à altura do monograma "ap"
- Nunca distorcer, rotacionar ou alterar as cores do logotipo
- Sobre fundo escuro, usar versão negativa
- Sobre fundo claro, usar versão padrão (rosa/cinza)

### UI-006 — Elementos visuais da marca [AVISO]

A identidade visual inclui:
- **Ícone flor de corações** — formada por mãos dadas, com estrela no centro (sucesso). Usar como elemento decorativo em headers, loading states, empty states.
- **Pattern** — repetição do ícone flor + monograma "ap" em grid. Usar como background sutil em áreas de destaque, seções de onboarding, ou como textura.
- **Slogan** — "Juntos e de mãos dadas". Usar em rodapés, tela de login, about.

---

## 2. Bootstrap 5.3 — melhores práticas

### UI-007 — Utility-first, CSS custom só quando necessário [AVISO]

Preferir classes utilitárias do Bootstrap. CSS custom apenas quando a utility não cobre (animações, pseudo-elementos, layouts muito específicos).

```html
<!-- correto — utilities do Bootstrap -->
<div class="card shadow-sm border-0 mb-3">
    <div class="card-body p-4">
        <h5 class="card-title fw-bold">Saldo</h5>
    </div>
</div>

<!-- incorreto — CSS custom desnecessário -->
<div class="meu-card"><!-- .meu-card { box-shadow: ...; border: none; margin-bottom: 1rem; } --></div>
```

### UI-008 — Grid system para layout, nunca posicionamento manual [ERRO]

Layouts usam o grid system do Bootstrap (`container`, `row`, `col-*`). Nunca usar `float`, `position: absolute` para layout de página.

```html
<!-- correto -->
<div class="container">
    <div class="row g-4">
        <div class="col-md-8"><!-- conteúdo principal --></div>
        <div class="col-md-4"><!-- sidebar --></div>
    </div>
</div>

<!-- incorreto -->
<div style="float: left; width: 66%;"><!-- conteúdo --></div>
<div style="float: right; width: 33%;"><!-- sidebar --></div>
```

### UI-009 — Breakpoints responsivos padrão do Bootstrap [ERRO]

Usar os breakpoints nativos do Bootstrap. Nunca criar media queries com valores custom.

| Breakpoint | Prefixo | Largura mínima |
|-----------|---------|----------------|
| Extra small | (nenhum) | < 576px |
| Small | `sm` | ≥ 576px |
| Medium | `md` | ≥ 768px |
| Large | `lg` | ≥ 992px |
| Extra large | `xl` | ≥ 1200px |
| XXL | `xxl` | ≥ 1400px |

```html
<!-- correto — breakpoints Bootstrap -->
<div class="col-12 col-md-6 col-lg-4">...</div>

<!-- incorreto — media query custom -->
<style>@media (min-width: 850px) { ... }</style>
```

### UI-010 — Componentes Bootstrap nativos, sem reinventar [AVISO]

Usar os componentes do Bootstrap (cards, modals, alerts, tables, badges, dropdowns, toasts) antes de criar componentes custom. Se o Bootstrap resolve, não criar do zero.

### UI-011 — Sem !important [ERRO]

Nunca usar `!important` em CSS custom. Se precisar sobrescrever Bootstrap, usar especificidade maior ou CSS custom properties.

```css
/* correto — especificidade */
.acp-dashboard .card-title {
    font-size: 1.25rem;
}

/* incorreto */
.card-title {
    font-size: 1.25rem !important;
}
```

### UI-012 — Sem CSS inline em HTML [ERRO]

Estilos vivem em `assets/css/estilo.css` ou em classes utilitárias do Bootstrap. Nunca `style=""` direto no HTML, exceto para valores dinâmicos injetados por PHP/JS (ex.: cor do tema, largura de barra de progresso).

```html
<!-- correto — classe -->
<div class="text-success fw-bold">+R$ 500,00</div>

<!-- correto — dinâmico (aceitável) -->
<div class="progress-bar" style="width: <?php echo esc_attr($percentual); ?>%"></div>

<!-- incorreto — estilo estático inline -->
<div style="color: green; font-weight: bold;">+R$ 500,00</div>
```

### UI-013 — Dark mode preparado [AVISO]

Usar `data-bs-theme="light"` no `<html>` e respeitar as variáveis CSS do Bootstrap (`--bs-body-bg`, `--bs-body-color`). Quando dark mode for implementado, basta trocar o atributo.

```html
<html data-bs-theme="light">
```

Custom properties da marca devem funcionar em ambos os temas:

```css
[data-bs-theme="dark"] {
    --acp-bg: #212529;
    --acp-bg-card: #2b3035;
    --acp-texto: #dee2e6;
    --acp-borda: #495057;
}
```

---

## 3. UX financeira

### UI-014 — Modo privacidade (ocultação de saldo) [ERRO]

O dashboard deve ter um botão (ícone de olho) que oculta/exibe todos os valores financeiros. Quando oculto, valores são substituídos por `•••••`.

```html
<!-- visível -->
<span class="acp-saldo" data-visible="true">R$ 12.450,00</span>

<!-- oculto -->
<span class="acp-saldo" data-visible="false">•••••</span>
```

O estado de privacidade persiste no `localStorage` do navegador. Ao recarregar a página, mantém a última escolha do usuário.

### UI-015 — Ações rápidas no dashboard [AVISO]

A tela inicial exibe ações primárias em destaque: "Novo lançamento", "Ver extrato", "Metas". Sempre acessíveis sem scroll ou navegação profunda.

### UI-016 — Fricção positiva em operações financeiras [ERRO]

Toda operação que altera estado financeiro (confirmar lançamento, cancelar, deletar) exige confirmação explícita do usuário via modal.

```html
<!-- correto — modal de confirmação -->
<div class="modal" id="confirmarLancamento">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirmar lançamento</h5>
            </div>
            <div class="modal-body">
                <p>Confirmar lançamento de <strong>R$ 500,00</strong> na conta <strong>Corrente</strong>?</p>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button class="btn btn-primary" id="btnConfirmar">Confirmar</button>
            </div>
        </div>
    </div>
</div>

<!-- incorreto — ação direta sem confirmação -->
<button onclick="confirmarLancamento(id)">Confirmar</button>
```

### UI-017 — Feedback visual em toda ação [ERRO]

Toda ação do usuário produz feedback visual: toast de sucesso, alert de erro, spinner de loading. O usuário nunca fica sem saber se a ação funcionou.

```html
<!-- Toast de sucesso -->
<div class="toast align-items-center text-bg-success" role="alert">
    <div class="d-flex">
        <div class="toast-body">Lançamento confirmado com sucesso.</div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
    </div>
</div>

<!-- Spinner durante operação -->
<button class="btn btn-primary" disabled>
    <span class="spinner-border spinner-border-sm" role="status"></span>
    Processando...
</button>
```

### UI-018 — Estados vazios com orientação [AVISO]

Quando uma lista está vazia (sem lançamentos, sem metas, sem categorias), exibir uma mensagem orientando o usuário sobre o que fazer.

```html
<!-- correto — estado vazio com orientação -->
<div class="text-center py-5 text-muted">
    <p class="mb-3">Nenhum lançamento registrado ainda.</p>
    <a href="#" class="btn btn-primary">Criar primeiro lançamento</a>
</div>

<!-- incorreto — lista vazia sem explicação -->
<table><tbody></tbody></table>
```

---

## 4. Formulários financeiros

### UI-019 — inputmode correto para valores monetários [ERRO]

Campos de valor financeiro usam `inputmode="decimal"` para invocar teclado numérico com separador decimal em dispositivos móveis.

```html
<!-- correto -->
<input type="text" inputmode="decimal" name="valor" placeholder="0,00"
       class="form-control" autocomplete="off">

<!-- incorreto — type number com setas de incremento -->
<input type="number" name="valor">
```

### UI-020 — inputmode="numeric" para campos de código/PIN [AVISO]

Campos de código numérico (PIN, código de verificação) usam `inputmode="numeric"`.

### UI-021 — Labels obrigatórios em todo campo de formulário [ERRO]

Todo `<input>`, `<select>` e `<textarea>` tem um `<label>` associado via `for`/`id`. Nunca placeholder como substituto de label.

```html
<!-- correto -->
<label for="descricao" class="form-label">Descrição</label>
<input type="text" class="form-control" id="descricao" name="descricao">

<!-- incorreto — placeholder como label -->
<input type="text" class="form-control" placeholder="Descrição">
```

### UI-022 — Validação visual via Bootstrap [AVISO]

Usar classes `is-valid` e `is-invalid` do Bootstrap com `invalid-feedback` para mensagens de erro.

```html
<input type="text" class="form-control is-invalid" id="valor">
<div class="invalid-feedback">Valor é obrigatório.</div>
```

### UI-023 — Formulários agrupados com fieldset e legend [AVISO]

Formulários complexos (cadastro de lançamento, configuração de conta) usam `<fieldset>` e `<legend>` para agrupar campos relacionados.

---

## 5. Tabelas e listagens

### UI-024 — Tabelas responsivas com Bootstrap [ERRO]

Toda tabela usa `.table-responsive` para scroll horizontal em telas pequenas.

```html
<!-- correto -->
<div class="table-responsive">
    <table class="table table-hover align-middle">
        <thead class="table-light">
            <tr>
                <th>Data</th>
                <th>Descrição</th>
                <th class="text-end">Valor</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody><!-- dados --></tbody>
    </table>
</div>
```

### UI-025 — Valores alinhados à direita em tabelas [ERRO]

Colunas com valores monetários são alinhadas à direita (`text-end`) e usam fonte monospace.

```html
<td class="text-end font-monospace">R$ 1.500,00</td>
```

### UI-026 — Status com badges coloridos [AVISO]

Status de lançamentos e metas são exibidos com badges Bootstrap usando cores semânticas.

```html
<span class="badge text-bg-warning">Pendente</span>
<span class="badge text-bg-success">Confirmado</span>
<span class="badge text-bg-danger">Cancelado</span>
<span class="badge text-bg-info">Ativa</span>
<span class="badge text-bg-primary">Atingida</span>
```

---

## 6. Dashboards e gráficos

### UI-027 — Cards para métricas do dashboard [AVISO]

Métricas principais (saldo total, receitas do mês, despesas do mês, metas ativas) são exibidas em cards Bootstrap.

```html
<div class="row g-4">
    <div class="col-sm-6 col-xl-3">
        <div class="card border-0 shadow-sm">
            <div class="card-body">
                <p class="text-muted small mb-1">Saldo total</p>
                <h3 class="fw-bold font-monospace acp-saldo" data-visible="true">
                    R$ 12.450,00
                </h3>
            </div>
        </div>
    </div>
    <!-- mais cards -->
</div>
```

### UI-028 — Gráficos com alternativa textual acessível [ERRO]

Todo gráfico (`<canvas>`, ApexCharts ou similar) deve ter uma descrição textual acessível via `aria-label` ou texto oculto com `visually-hidden`.

```html
<!-- correto -->
<div id="grafico-despesas" 
     role="img" 
     aria-label="Gráfico de despesas por categoria: Alimentação 35%, Transporte 20%, Moradia 30%, Lazer 15%">
</div>

<!-- incorreto — sem alternativa textual -->
<div id="grafico-despesas"></div>
```

### UI-029 — Cores de gráfico consistentes com tokens da marca [AVISO]

Gráficos usam as mesmas cores definidas nas CSS custom properties. Receita = verde, despesa = vermelho, transferência = azul.

---

## 7. Acessibilidade

### UI-030 — Contraste mínimo WCAG AA [ERRO]

Todo texto tem contraste mínimo de 4.5:1 contra o fundo (WCAG AA). Texto grande (18px+) aceita 3:1.

### UI-031 — Navegação por teclado funcional [ERRO]

Todo elemento interativo (botões, links, inputs, modais) é acessível via teclado (Tab, Enter, Escape). Ordem de tabulação lógica.

### UI-032 — ARIA roles em componentes dinâmicos [AVISO]

Componentes dinâmicos (modais, toasts, dropdowns, abas) usam roles ARIA corretos. Bootstrap já faz isso nativamente — não remover.

### UI-033 — Sem informação transmitida apenas por cor [ERRO]

Indicadores financeiros (receita/despesa) nunca dependem apenas de cor. Sempre acompanhados de ícone, sinal (+/-) ou texto.

```html
<!-- correto — cor + sinal -->
<span class="text-success font-monospace">+R$ 1.500,00</span>
<span class="text-danger font-monospace">-R$ 800,00</span>

<!-- incorreto — só cor -->
<span class="text-success font-monospace">R$ 1.500,00</span>
<span class="text-danger font-monospace">R$ 800,00</span>
```

---

## 8. JavaScript e interatividade

### UI-034 — Vanilla JS, sem jQuery [ERRO]

Todo JavaScript é vanilla (nativo) ou via Bootstrap JS. Sem jQuery, sem bibliotecas de manipulação DOM.

### UI-035 — Eventos via addEventListener, sem onclick inline [ERRO]

```javascript
// correto
document.getElementById('btnConfirmar').addEventListener('click', confirmarLancamento);

// incorreto
// <button onclick="confirmarLancamento()">
```

### UI-036 — Fetch para AJAX, nunca XMLHttpRequest [AVISO]

Comunicação com o backend via `fetch()` com `FormData`. Nonce vem de `acpConfig.nonce` (localizado via `wp_localize_script`).

```javascript
// correto
async function criarLancamento(dados) {
    const form = new FormData();
    form.append('action', 'acp_criar_lancamento');
    form.append('nonce', acpConfig.nonce);
    form.append('valor', dados.valor);

    const resp = await fetch(acpConfig.ajaxUrl, {
        method: 'POST',
        body: form,
    });

    const json = await resp.json();

    if (json.success) {
        mostrarToast('Lançamento criado.', 'success');
    } else {
        mostrarToast(json.data.mensagem, 'danger');
    }
}
```

### UI-037 — Loading state em toda operação assíncrona [ERRO]

Enquanto uma operação AJAX está em andamento, o botão que disparou fica desabilitado com spinner. Impede cliques duplos.

```javascript
function setLoading(btn, loading) {
    if (loading) {
        btn.disabled = true;
        btn.dataset.originalText = btn.innerHTML;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Processando...';
    } else {
        btn.disabled = false;
        btn.innerHTML = btn.dataset.originalText;
    }
}
```

---

## Checklist de auditoria

A skill `/auditar-frontend` deve verificar, para cada arquivo:

**Tokens visuais:**
- [ ] Cores via CSS custom properties, nunca hardcoded
- [ ] Cores semânticas corretas (receita=verde, despesa=vermelho)
- [ ] Valores monetários em fonte monospace

**Bootstrap:**
- [ ] Utilities-first, CSS custom só quando necessário
- [ ] Grid system para layout (nunca float/position)
- [ ] Breakpoints nativos do Bootstrap
- [ ] Sem `!important`
- [ ] Sem CSS inline estático

**UX financeira:**
- [ ] Modo privacidade implementado
- [ ] Fricção positiva (modal de confirmação) em operações financeiras
- [ ] Feedback visual em toda ação (toast, alert, spinner)
- [ ] Estados vazios com orientação

**Formulários:**
- [ ] `inputmode="decimal"` em valores monetários
- [ ] Labels associados via for/id em todo campo
- [ ] Validação visual via Bootstrap (is-valid/is-invalid)

**Tabelas:**
- [ ] `.table-responsive` em toda tabela
- [ ] Valores alinhados à direita em monospace

**Dashboards:**
- [ ] Gráficos com alternativa textual acessível
- [ ] Cores de gráfico consistentes com tokens

**Acessibilidade:**
- [ ] Contraste mínimo WCAG AA (4.5:1)
- [ ] Navegação por teclado funcional
- [ ] Sem informação transmitida apenas por cor

**JavaScript:**
- [ ] Vanilla JS, sem jQuery
- [ ] addEventListener, sem onclick inline
- [ ] fetch() para AJAX
- [ ] Loading state em operações assíncronas

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
5. Filtrar arquivos `.php` (templates com HTML), `.css`, `.js` dentro do projeto.

### Fase 3 — Auditar arquivo por arquivo

Para cada arquivo alterado no PR:

1. Ler o arquivo completo (não apenas o diff — contexto importa).
2. Comparar contra **cada regra** de `docs/padroes-ux-ui.md`, uma por uma, na ordem do documento.
3. Para cada violação encontrada, registrar:
   - **Arquivo** e **linha(s)** onde ocorre
   - **ID da regra** violada (ex.: UI-012)
   - **Severidade** (ERRO ou AVISO)
   - **O que está errado** — descrição concisa
   - **Como corrigir** — correção específica para aquele trecho
4. Se o arquivo não viola nenhuma regra, registrar como aprovado.

### Fase 4 — Relatório

Apresentar o relatório ao usuário no seguinte formato:

```
## Relatório de auditoria frontend

**PR:** #<numero> — <titulo>
**Branch:** <branch>
**Arquivos auditados:** <quantidade>
**Régua:** docs/padroes-ux-ui.md

### Resumo

- Erros: <quantidade>
- Avisos: <quantidade>
- Arquivos aprovados: <quantidade>

### Violações

#### <arquivo.php>

| Linha | Regra | Severidade | Descrição | Correção |
|-------|-------|------------|-----------|----------|
| 12 | UI-012 | ERRO | CSS inline estático | Usar classe Bootstrap ou custom property |
| 28 | UI-021 | ERRO | Input sem label associado | Adicionar <label for="..."> |

#### <outro-arquivo.css>
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
- **Nunca auditar arquivos fora do PR.** Apenas arquivos alterados no PR aberto.
- **Sempre referenciar o ID da regra violada.** O relatório deve ser rastreável ao documento de padrões.
- **Nunca inventar regras.** A régua é exclusivamente o `docs/padroes-ux-ui.md` — sem opinião, sem sugestões extras.
- **Ser metódica e processual.** Cada arquivo é comparado contra cada regra, na ordem do documento, sem pular.
- **Fidelidade ao documento.** Se o código viola uma regra do documento, reportar. Se o documento não cobre o caso, não reportar.
- **Verificar consistência com a identidade visual.** Cores devem usar as custom properties da marca, nunca hex direto.
- **Mostrar o relatório completo antes de qualquer ação.** Nunca executar correções sem aprovação explícita.
