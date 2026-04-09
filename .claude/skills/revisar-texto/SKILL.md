---
name: revisar-texto
description: Revisão ortográfica e de convenções em todos os arquivos .md do projeto. Corrige erros, inconsistências e capitalização. Trigger manual apenas.
---

# /revisar-texto — Revisão Ortográfica e de Convenções

Percorre todos os arquivos Markdown do projeto, identifica erros ortográficos, inconsistências de convenção (como capitalização no estilo inglês) e problemas de formatação. Mostra cada correção para aprovação e entrega um relatório consolidado no final.

## Quando usar

- **APENAS** quando o usuário digitar `/revisar-texto` explicitamente.
- Nunca disparar automaticamente, nem como parte de outra skill.

## Processo

### Fase 1 — Descoberta

1. Listar todos os arquivos `.md` do projeto, incluindo subpastas: raiz, `guias/`, `modelos/`, `exemplos/`, `.claude/skills/`, `.github/`.
2. Ignorar pastas no `.gitignore` (`memoria/`, `troca/`).
3. Informar ao usuário quantos arquivos serão revisados:

> "Encontrei X arquivos Markdown para revisar. Começando."

### Fase 2 — Revisão

Para cada arquivo, ler o conteúdo completo e verificar:

**Ortografia e gramática:**
- Erros de digitação e ortografia.
- Concordância verbal e nominal.
- Acentuação incorreta ou ausente.

**Convenções brasileiras:**
- Títulos e headings: apenas primeira letra maiúscula (não Title Case no estilo inglês). Exceções: nomes próprios, siglas, nomes de comandos.
- Pontuação em listas: consistência (todas com ponto final ou nenhuma).
- Uso de "você" consistente (não misturar com "tu" ou tratamento formal).

**Formatação Markdown:**
- Headings hierárquicos (não pular níveis: `##` direto para `####`).
- Links internos apontando para caminhos corretos (verificar se o arquivo referenciado existe).
- Frontmatter válido (campos name, description, type nas memórias e skills).

**Consistência entre arquivos:**
- Nomes de pastas e comandos escritos da mesma forma em todos os lugares.
- Referências cruzadas usando os mesmos termos (não chamar de "modelos" em um lugar e "templates" em outro).

### Fase 3 — Correção com aprovação

Para cada correção encontrada:

1. **Correção clara** (erro óbvio de digitação, acento faltando): corrigir diretamente e adicionar à lista de correções aplicadas.
2. **Correção ambígua** (pode estar certa dependendo da intenção, escolha de palavra, tom): apresentar ao usuário com contexto:

> **Arquivo:** `guias/skills.md`, linha 42
> **Encontrado:** "Isso torna o processo Previsível e Depurável"
> **Sugestão:** "Isso torna o processo previsível e depurável"
> **Motivo:** Capitalização no estilo inglês — convenção brasileira usa minúsculas.
> **Corrigir? (s/n)**

Esperar resposta antes de seguir para a próxima correção ambígua.

### Fase 4 — Relatório consolidado

Após revisar todos os arquivos, apresentar um resumo:

```
## Relatório de revisão

- **Arquivos revisados:** X
- **Erros encontrados:** X
- **Corrigidos automaticamente:** X (ortografia clara)
- **Corrigidos com aprovação:** X (ambíguos aprovados pelo usuário)
- **Mantidos como estão:** X (ambíguos que o usuário optou por não corrigir)
- **Arquivos sem erros:** X
```

## Regras

- **Nunca alterar código** dentro de blocos ` ```code``` ` — apenas texto corrido e headings.
- **Nunca alterar nomes de arquivos ou pastas** — apenas conteúdo.
- **Nunca alterar frontmatter** de SKILL.md ou arquivos de memória (name, description, type) — pode quebrar a descoberta pelo sistema.
- **Nunca corrigir sem mostrar antes.** Correções claras são aplicadas e listadas no relatório. Correções ambíguas pedem aprovação individual.
- **Nunca mudar o tom ou reescrever frases.** A revisão é ortográfica e de convenção, não editorial.
- **Respeitar exceções de capitalização:** nomes próprios (nome da IA definida no CLAUDE.md), siglas (IA, PR, PT-BR), nomes de comandos (/iniciar), e nomes de arquivos (CLAUDE.md) mantêm sua grafia original.
