---
name: auditar-js
description: Audita código JavaScript do PR aberto contra as regras definidas em docs/padroes-js.md. Cobre princípios, nomenclatura, DOM, AJAX, segurança, UX e formatação. Trigger manual apenas.
---

# /auditar-js — Auditora de padrões JavaScript

Lê as regras de `docs/padroes-js.md`, identifica os arquivos JavaScript alterados no PR aberto (não mergeado) e compara cada arquivo contra cada regra aplicável. Foco em: princípios de engenharia, nomenclatura, estrutura de arquivos, manipulação de DOM, comunicação AJAX, feedback visual, segurança client-side e formatação.

Complementa `/auditar-frontend` (que cobre UX/UI e identidade visual) e `/auditar-wordpress` (que cobre APIs WP).

## Quando usar

- **APENAS** quando o usuário digitar `/auditar-js` explicitamente.
- Rodar antes de mergear um PR — funciona como gate de qualidade do JavaScript.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Padrões mínimos exigidos

> Esta seção contém os padrões completos usados pela auditoria. Edite para personalizar ao seu projeto.

# Padrão de programação em JavaScript

## Descrição

Documento de referência para auditoria de código JavaScript no projeto Acertando os Pontos. Define regras obrigatórias e recomendações que todo arquivo, função e módulo JS deve seguir. A skill `/auditar-js` lê este documento e compara contra o código-alvo.

## Escopo

- Todo JavaScript dentro de `acertandoospontos/assets/js/`
- Vanilla JS (sem frameworks, sem jQuery)
- Bootstrap 5.3 como única biblioteca de componentes
- Comunicação AJAX via `fetch()` com WordPress `admin-ajax.php`
- Contexto: aplicação financeira no navegador (client-side)

## Referências

- [MDN Web Docs — JavaScript](https://developer.mozilla.org/pt-BR/docs/Web/JavaScript)
- [Bootstrap 5.3 — JavaScript](https://getbootstrap.com/docs/5.3/getting-started/javascript/)
- [WCAG 2.1](https://www.w3.org/TR/WCAG21/)
- `docs/padroes-ux-ui.md` — Padrões de UX/UI (complementar)

## Severidade

- **ERRO** — Violação bloqueia aprovação. Deve ser corrigida antes de merge.
- **AVISO** — Recomendação forte. Deve ser justificada se ignorada.

---

## 1. Princípios fundamentais

### JS-001 — KISS: simplicidade primeiro [AVISO]

O código deve ser o mais simples possível. Se existe uma forma direta de resolver, usar essa. Abstrações, patterns e indireções só entram quando o problema exige.

```javascript
// correto — direto
function estaVazio(valor) {
    return valor === '' || valor === null || valor === undefined;
}

// incorreto — indireção sem necessidade
function estaVazio(valor) {
    return new Validator(valor).check('empty').result();
}
```

### JS-002 — DRY: uma regra, um lugar [ERRO]

Uma lógica é implementada em um único ponto. Se o mesmo cálculo ou validação aparece em dois arquivos, extrair para um módulo compartilhado.

```javascript
// correto — função reutilizável
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

// incorreto — mesma lógica duplicada em cada arquivo
```

### JS-003 — YAGNI: não construa o que não precisa agora [AVISO]

Não implementar funções, classes ou parâmetros pensando em "possibilidades futuras". Implementar estritamente o que o requisito atual exige.

### JS-004 — Separação de responsabilidades [ERRO]

Cada arquivo JS tem um escopo claro. Um arquivo não mistura lógica de formulário, manipulação de DOM e comunicação AJAX sem estrutura. Separar em funções com responsabilidade única.

### JS-005 — Lei de Demeter: fale só com seus vizinhos [AVISO]

Não encadear chamadas que atravessam múltiplos objetos. Acessar apenas propriedades e métodos do objeto imediato.

```javascript
// correto
var navbarHeight = navbar.offsetHeight;

// incorreto — encadeamento profundo
var height = document.querySelector('.container').firstChild.nextSibling.offsetHeight;
```

---

## 2. Estilo e nomenclatura

### JS-006 — Variáveis e funções em camelCase [ERRO]

```javascript
// correto
var valorTotal = 0;
function calcularSaldo() {}

// incorreto
var valor_total = 0;
function calcular_saldo() {}
```

### JS-007 — Constantes em UPPER_SNAKE_CASE [AVISO]

```javascript
// correto
var MAX_TENTATIVAS = 5;
var TEMPO_EXPIRACAO_MS = 600000;

// incorreto
var maxTentativas = 5;
```

### JS-008 — Nomes descritivos, sem abreviações obscuras [AVISO]

```javascript
// correto
var formularioCadastro = document.getElementById('acp-cadastro-form');
var botaoEnviar = document.getElementById('acp-btn-cadastrar');

// incorreto
var fc = document.getElementById('acp-cadastro-form');
var be = document.getElementById('acp-btn-cadastrar');
```

### JS-009 — Funções nomeadas, nunca anônimas soltas [AVISO]

Funções devem ter nomes descritivos para facilitar debugging e stack traces. Exceção: callbacks curtos de uma linha em `.then()` ou `.forEach()`.

```javascript
// correto
document.addEventListener('DOMContentLoaded', inicializarLogin);

function inicializarLogin() {
    // ...
}

// incorreto
document.addEventListener('DOMContentLoaded', function () {
    // 50 linhas de código anônimo
});
```

---

## 3. Estrutura de arquivos

### JS-010 — Um arquivo por página/funcionalidade [ERRO]

Cada arquivo JS corresponde a uma página ou funcionalidade isolada. Nunca um arquivo monolítico com toda a lógica da aplicação.

```
assets/js/
├── app.js                  ← comportamento global (navbar, smooth scroll)
└── auth/
    ├── login.js            ← lógica da página de login
    ├── cadastro.js         ← lógica da página de cadastro
    ├── resetar-senha.js    ← lógica da página de reset
    ├── confirmar-email.js  ← lógica da confirmação de email
    └── configurar-auth.js  ← lógica da configuração de auth
```

### JS-011 — Enqueue condicional via WordPress [ERRO]

Cada arquivo JS é carregado apenas na página que o utiliza, via `wp_enqueue_script()` com condição de página no PHP. Nunca carregar todos os scripts em todas as páginas.

### JS-012 — Padrão de inicialização via DOMContentLoaded [ERRO]

Todo arquivo JS inicia com `document.addEventListener('DOMContentLoaded', ...)` e encapsula toda a lógica dentro desse escopo.

```javascript
// correto
document.addEventListener('DOMContentLoaded', function () {
    var form = document.getElementById('meu-form');
    if (!form) return;
    // ...
});

// incorreto — código solto no escopo global
var form = document.getElementById('meu-form');
form.addEventListener('submit', ...);
```

### JS-013 — Guard clause no início [ERRO]

Se o elemento principal da página não existe (ex.: o formulário), retornar imediatamente. Evita erros em páginas onde o script foi carregado indevidamente.

```javascript
document.addEventListener('DOMContentLoaded', function () {
    var form = document.getElementById('acp-login-form');
    if (!form) return; // guard clause

    // resto da lógica
});
```

---

## 4. Manipulação de DOM

### JS-014 — Seleção por ID ou classe semântica, nunca por tag [ERRO]

Usar `getElementById` ou `querySelector` com seletores semânticos. Nunca selecionar por tag genérica.

```javascript
// correto
var alerta = document.getElementById('acp-login-alerta');
var cards = document.querySelectorAll('.acp-benefit-card');

// incorreto
var divs = document.querySelectorAll('div');
var paragrafo = document.querySelector('p');
```

### JS-015 — IDs e classes com prefixo acp- [AVISO]

Elementos manipulados por JS usam prefixo `acp-` para evitar colisão com Bootstrap ou outros scripts.

```html
<!-- correto -->
<form id="acp-login-form">
<button id="acp-btn-cadastrar">

<!-- incorreto — pode colidir -->
<form id="login-form">
<button id="submit">
```

### JS-016 — addEventListener, nunca onclick inline [ERRO]

Eventos são registrados via `addEventListener`. Nunca usar atributos `onclick`, `onsubmit` ou similares no HTML.

```javascript
// correto
document.getElementById('btn').addEventListener('click', handleClick);

// incorreto
// <button onclick="handleClick()">
```

### JS-017 — Criar elementos via DOM API, nunca innerHTML para dados dinâmicos [ERRO]

Para inserir dados dinâmicos do usuário, usar `textContent` ou DOM API. `innerHTML` só é aceitável para templates estáticos sem dados do usuário (previne XSS).

```javascript
// correto — dado do usuário
elemento.textContent = mensagem;

// correto — template estático
container.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';

// incorreto — dado do usuário via innerHTML (XSS)
elemento.innerHTML = resposta.mensagem;
```

---

## 5. Comunicação AJAX

### JS-018 — fetch() para toda comunicação, nunca XMLHttpRequest [ERRO]

```javascript
// correto
fetch(acpAuth.ajaxUrl, {
    method: 'POST',
    body: formData,
})
    .then(function (resp) { return resp.json(); })
    .then(function (json) { /* ... */ });

// incorreto
var xhr = new XMLHttpRequest();
xhr.open('POST', url);
```

### JS-019 — Nonce obrigatório em toda requisição AJAX [ERRO]

Toda requisição para `admin-ajax.php` inclui o nonce localizado via `wp_localize_script()`. Nunca hardcodar nonce no HTML.

```javascript
// correto — nonce vem do objeto localizado
var formData = new FormData();
formData.append('action', 'acp_login');
formData.append('nonce', acpAuth.nonce);

// incorreto — nonce hardcoded
formData.append('nonce', 'abc123xyz');
```

### JS-020 — Action com prefixo acp_ [ERRO]

Toda action AJAX enviada ao WordPress usa prefixo `acp_` para evitar colisão.

```javascript
// correto
formData.append('action', 'acp_cadastrar');

// incorreto
formData.append('action', 'cadastrar');
```

### JS-021 — Tratamento de erros em toda requisição [ERRO]

Toda chamada `fetch()` tem tratamento de sucesso, erro de negócio (`json.success === false`) e erro de rede (`.catch()`).

```javascript
// correto — três caminhos tratados
fetch(url, { method: 'POST', body: formData })
    .then(function (resp) { return resp.json(); })
    .then(function (json) {
        if (json.success) {
            // sucesso
        } else {
            mostrarAlerta(json.data.mensagem, 'danger');
        }
    })
    .catch(function () {
        mostrarAlerta('Erro de conexão. Tente novamente.', 'danger');
    });

// incorreto — sem catch, sem tratamento de erro
fetch(url, { method: 'POST', body: formData })
    .then(function (resp) { return resp.json(); })
    .then(function (json) { /* assume que sempre dá certo */ });
```

### JS-022 — FormData para envio, nunca JSON manual [AVISO]

Preferir `FormData` para envio ao `admin-ajax.php`. O WordPress espera `application/x-www-form-urlencoded` ou `multipart/form-data`.

---

## 6. Feedback visual e UX

### JS-023 — Loading state em toda operação assíncrona [ERRO]

Enquanto uma operação AJAX está em andamento, o botão que disparou fica desabilitado com spinner. Impede cliques duplos e informa o usuário.

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

### JS-024 — Feedback em toda ação do usuário [ERRO]

Toda ação produz feedback visual: alerta Bootstrap para erros, mensagem de sucesso, ou mudança de estado na UI. O usuário nunca fica sem saber o resultado.

### JS-025 — Validação no cliente como UX, não como segurança [AVISO]

Validação no JS é para feedback rápido ao usuário. A validação real acontece no handler PHP. Nunca confiar apenas na validação do cliente.

```javascript
// correto — valida no JS para UX, backend valida de verdade
if (senha.length < 8) {
    mostrarAlerta('A senha deve ter pelo menos 8 caracteres.', 'danger');
    return;
}
// envia pro backend que também valida
```

---

## 7. Segurança

### JS-026 — Nunca armazenar dados sensíveis no cliente [ERRO]

Tokens de autenticação, senhas, chaves de API nunca ficam em `localStorage`, `sessionStorage` ou cookies acessíveis por JS. O airlock token fica apenas em variável JS em memória (morre com a página).

```javascript
// correto — token em memória
var airlockToken = null;
// ... recebe do backend, usa na verificação, nunca persiste

// incorreto
localStorage.setItem('token', airlockToken);
```

### JS-027 — Sem eval(), Function() ou innerHTML com dados do usuário [ERRO]

Nunca executar código dinâmico. Nunca inserir dados do usuário via `innerHTML`. Previne XSS.

### JS-028 — Dados do backend são suspeitos [AVISO]

Mesmo dados vindos do próprio backend devem ser inseridos com `textContent`, não `innerHTML`. O banco pode ter sido comprometido.

---

## 8. Compatibilidade e performance

### JS-029 — ES5+ compatível, sem transpilação [AVISO]

O projeto não usa build step (sem Webpack, sem Babel). O JavaScript deve ser compatível com navegadores modernos (ES6+ features como `const`, `let`, arrow functions são aceitáveis, mas `var` é preferido para máxima compatibilidade no projeto atual).

### JS-030 — Sem bibliotecas externas desnecessárias [ERRO]

jQuery proibido. Bibliotecas só entram quando justificadas (ex.: QR code generator para TOTP). Bootstrap JS é a única dependência autorizada.

### JS-031 — Event delegation para listas dinâmicas [AVISO]

Para elementos que são adicionados/removidos dinamicamente (tabelas, listas de lançamentos), usar delegação de eventos no container pai em vez de registrar listeners em cada item.

```javascript
// correto — delegação
document.getElementById('tabela-lancamentos').addEventListener('click', function (e) {
    var btn = e.target.closest('[data-action]');
    if (!btn) return;
    // tratar ação
});

// incorreto — listener em cada linha
linhas.forEach(function (linha) {
    linha.querySelector('.btn-editar').addEventListener('click', handleEditar);
});
```

### JS-032 — Sem polling, preferir eventos [AVISO]

Não usar `setInterval` para verificar mudanças de estado. Usar eventos do DOM, callbacks de fetch ou MutationObserver quando necessário.

---

## 9. Formatação

### JS-033 — Indentação com 4 espaços [ERRO]

Consistente com o padrão PHP do projeto. Nunca tabs.

### JS-034 — Chaves na mesma linha [AVISO]

```javascript
// correto
if (condicao) {
    // corpo
}

function minhaFuncao() {
    // corpo
}

// incorreto
if (condicao)
{
    // corpo
}
```

### JS-035 — Máximo 120 caracteres por linha [AVISO]

Quebrar linhas longas com alinhamento.

### JS-036 — Ponto e vírgula obrigatório [ERRO]

Toda instrução termina com `;`. Sem ASI (*Automatic Semicolon Insertion*) implícito.

```javascript
// correto
var nome = 'Acertando os Pontos';
var valor = 1500;

// incorreto
var nome = 'Acertando os Pontos'
var valor = 1500
```

### JS-037 — Aspas simples para strings [AVISO]

Preferir aspas simples. Template literals (backticks) apenas quando necessário interpolação.

```javascript
// correto
var mensagem = 'Lançamento criado.';

// aceitável — template literal com interpolação
var msg = `Erro: ${json.data.mensagem}`;

// incorreto — aspas duplas sem necessidade
var mensagem = "Lançamento criado.";
```

---

## Checklist de auditoria

A skill `/auditar-js` deve verificar, para cada arquivo:

**Princípios:**
- [ ] KISS, DRY, YAGNI, SoC, Demeter respeitados
- [ ] Separação de responsabilidades (um arquivo = uma funcionalidade)

**Nomenclatura:**
- [ ] Variáveis e funções em camelCase
- [ ] Constantes em UPPER_SNAKE_CASE
- [ ] Nomes descritivos
- [ ] Funções nomeadas (não anônimas longas)

**Estrutura:**
- [ ] Um arquivo por página/funcionalidade
- [ ] Enqueue condicional no WordPress
- [ ] Inicialização via DOMContentLoaded
- [ ] Guard clause no início

**DOM:**
- [ ] Seleção por ID/classe semântica
- [ ] Prefixo acp- em IDs/classes manipulados por JS
- [ ] addEventListener (sem onclick inline)
- [ ] textContent para dados dinâmicos (não innerHTML)

**AJAX:**
- [ ] fetch() em toda comunicação
- [ ] Nonce em toda requisição
- [ ] Action com prefixo acp_
- [ ] Tratamento de sucesso, erro e catch
- [ ] FormData para envio

**UX:**
- [ ] Loading state em operações assíncronas
- [ ] Feedback visual em toda ação
- [ ] Validação no cliente como UX (não segurança)

**Segurança:**
- [ ] Sem dados sensíveis no cliente (localStorage/cookies)
- [ ] Sem eval(), Function() ou innerHTML com dados do usuário
- [ ] Dados do backend tratados como suspeitos

**Compatibilidade:**
- [ ] Sem jQuery, sem bibliotecas desnecessárias
- [ ] Event delegation para listas dinâmicas

**Formatação:**
- [ ] Indentação com 4 espaços
- [ ] Ponto e vírgula obrigatório
- [ ] Máximo 120 caracteres por linha

## Processo

### Fase 1 — Carregar a régua

1. Ler a seção **Padrões mínimos exigidos** deste documento.
2. Internalizar todas as regras com seus IDs, descrições, exemplos e severidades (ERRO/AVISO).
3. Não resumir nem recitar o documento de volta.

### Fase 2 — Identificar o PR aberto

1. Executar `gh pr list --state open --base develop --json number,title,headRefName --limit 1` para encontrar o PR aberto mais recente contra `develop`.
2. Se houver mais de um PR aberto, listar todos e perguntar ao usuário qual auditar.
3. Se não houver PR aberto, informar o usuário e encerrar.
4. Executar `gh pr diff <numero>` para obter o diff completo do PR.
5. Filtrar apenas arquivos `.js` dentro de `acertandoospontos/assets/js/`.

### Fase 3 — Auditar arquivo por arquivo

Para cada arquivo JavaScript alterado no PR:

1. Ler o arquivo completo (não apenas o diff — contexto importa).
2. Comparar contra **cada regra** de `docs/padroes-js.md`, uma por uma, na ordem do documento.
3. Para cada violação encontrada, registrar:
   - **Arquivo** e **linha(s)** onde ocorre
   - **ID da regra** violada (ex.: JS-018)
   - **Severidade** (ERRO ou AVISO)
   - **O que está errado** — descrição concisa
   - **Como corrigir** — correção específica para aquele trecho
4. Se o arquivo não viola nenhuma regra, registrar como aprovado.

### Fase 4 — Relatório

Apresentar o relatório ao usuário no seguinte formato:

```
## Relatório de auditoria JavaScript

**PR:** #<numero> — <titulo>
**Branch:** <branch>
**Arquivos auditados:** <quantidade>
**Régua:** docs/padroes-js.md

### Resumo

- Erros: <quantidade>
- Avisos: <quantidade>
- Arquivos aprovados: <quantidade>

### Violações

#### <arquivo.js>

| Linha | Regra | Severidade | Descrição | Correção |
|-------|-------|------------|-----------|----------|
| 15 | JS-018 | ERRO | Usa XMLHttpRequest | Substituir por fetch() |
| 32 | JS-026 | ERRO | Token em localStorage | Mover para variável em memória |

#### <outro-arquivo.js>
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
- **Nunca auditar arquivos fora do PR.** Apenas arquivos JavaScript alterados no PR aberto.
- **Sempre referenciar o ID da regra violada.** O relatório deve ser rastreável ao documento de padrões.
- **Nunca inventar regras.** A régua é exclusivamente o `docs/padroes-js.md` — sem opinião, sem sugestões extras.
- **Ser metódica e processual.** Cada arquivo é comparado contra cada regra, na ordem do documento, sem pular.
- **Fidelidade ao documento.** Se o código viola uma regra do documento, reportar. Se o documento não cobre o caso, não reportar.
- **Mostrar o relatório completo antes de qualquer ação.** Nunca executar correções sem aprovação explícita.
