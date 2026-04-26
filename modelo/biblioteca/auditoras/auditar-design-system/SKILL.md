---
name: auditar-design-system
description: Audita consistência visual do código contra o design system do projeto (docs/design-system.md). Genérica — funciona em qualquer projeto com documento de design system. Cobre tokens, inputs, botões, cards, tipografia, espaçamento e acessibilidade visual. Trigger manual apenas.
---

# /auditar-design-system — Auditora de Design System

Lê o documento de design system do projeto, identifica os arquivos de template/página alterados (ou todos, em modo varredura) e compara cada arquivo contra cada regra visual definida. Foco em: tokens de cor, consistência de inputs, botões, cards, tipografia, espaçamento e acessibilidade de touch targets.

**Diferença das outras auditoras:** não tem regras embutidas. As regras vivem no `docs/design-system.md` de cada projeto. A auditora é o motor; o documento é o combustível.

Complementa `/auditar-frontend` (UX/UI geral) e `/auditar-js` (código JS).

## Quando usar

- **APENAS** quando o usuário digitar `/auditar-design-system` explicitamente.
- Rodar antes de mergear um PR que toca templates, páginas, componentes ou CSS.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Pré-requisito

O projeto DEVE ter um arquivo `docs/design-system.md` (ou path equivalente documentado no CLAUDE.md do projeto). Se não existir, a auditora aborta com:

> "Design system não encontrado. Criar `docs/design-system.md` antes de auditar."

## Processo

### Fase 1 — Carregar regras

1. **Localizar o documento de design system:**
   - Primeiro: procurar em `docs/design-system.md` (path padrão)
   - Se não encontrar: procurar menção de "design-system" ou "design system" no CLAUDE.md do projeto
   - Se não encontrar: abortar

2. **Ler o documento inteiro.** Extrair:
   - Todas as regras com ID (ex: `DS-001`, `DS-002`)
   - Severidade de cada regra (`ERRO` ou `AVISO`)
   - Padrões corretos (classes CSS, valores, snippets)
   - Exceções documentadas

3. **Anotar internamente o inventário de regras.**

### Fase 2 — Identificar escopo

**Modo PR (padrão):** Identificar arquivos alterados no PR aberto.
```bash
gh pr diff --name-only | grep -E "\.(php|html|css|blade|tsx|jsx|vue|svelte)$"
```

**Modo varredura (quando Joc pedir):** Auditar TODOS os arquivos de template/página do projeto. Usar os paths documentados no design system ou no CLAUDE.md.

Filtrar apenas arquivos que contêm HTML/templates (páginas, componentes, layouts). Ignorar:
- Arquivos PHP de lógica pura (entidades, repos, managers, handlers)
- Arquivos de teste
- Arquivos de configuração
- Arquivos CSS source (são a definição, não o consumidor)

### Fase 3 — Auditar

Para cada arquivo no escopo:

1. **Ler o arquivo.**

2. **Aplicar cada regra do design system:**
   - Buscar padrões que violam a regra (ex: `border-gray-300` quando DS-002 proíbe)
   - Verificar se o padrão encontrado está nas exceções documentadas
   - Se está nas exceções: ignorar
   - Se não está: registrar violação

3. **Verificações automatizadas** (se o design system documentar comandos de verificação):
   - Rodar os comandos de verificação listados no documento
   - Capturar resultados e incluir no relatório

4. **Para cada violação, registrar:**
   - Arquivo e linha
   - Regra violada (ID + severidade)
   - O que foi encontrado (trecho do código)
   - O que deveria ser (conforme o design system)

### Fase 4 — Relatório

Formato de saída:

```
## Relatório de Auditoria — Design System

**Projeto:** {nome}
**Escopo:** {N} arquivos ({modo PR ou varredura})
**Documento:** {path do design-system.md}

### Resumo
- {X} ERRO(s)
- {Y} AVISO(s)

### Violações

#### ERRO

| # | Arquivo:Linha | Regra | Encontrado | Esperado |
|---|--------------|-------|-----------|----------|
| 1 | pages/page-login.php:398 | DS-002 | `border-gray-300` | `border-card-border` |

#### AVISO

| # | Arquivo:Linha | Regra | Encontrado | Esperado |
|---|--------------|-------|-----------|----------|
| 1 | pages/page-convidar.php:41 | DS-010 | `mb-1.5` (label) | `mb-1` |

### Exceções aplicadas
- {lista de exceções que foram encontradas e corretamente ignoradas}
```

### Fase 5 — Correção (se autorizado)

Se o Joc autorizar correções:

1. **ERRO primeiro, AVISO depois.**
2. **Commitar por grupo lógico** (ex: "fix: DS-002 tokens de borda em auth pages").
3. **Se tocou CSS/templates: rebuild obrigatório** (ver design system, seção de build se existir).
4. **Re-rodar verificações automatizadas** pós-correção.
5. **Relatório final** com contagem zerada de ERROs.

## Regras

- **Nunca inventar regras.** Só aplica o que está no `docs/design-system.md`. Se encontrar algo suspeito que não tem regra, reportar como sugestão, não como violação.
- **Exceções documentadas são lei.** Se o design system diz que é exceção, é exceção. Não questionar.
- **Severidade é do documento.** ERRO bloqueia merge. AVISO precisa de justificativa. A auditora não muda severidade.
- **Contexto importa.** Uma classe num spinner SVG é diferente da mesma classe num input de formulário. Verificar o contexto antes de marcar violação.
- **Falso positivo é pior que falso negativo.** Na dúvida, não marcar. Violação fantasma desperdiça tempo e erode confiança na auditoria.
- **Relatório em formato auditável.** `arquivo:linha — DS-XXX — descrição`. Nada narrativo.
