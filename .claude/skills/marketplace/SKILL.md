---
name: marketplace
description: Explora as skills disponíveis no marketplace, descreve cada uma e sugere ativações com base no perfil e projeto do usuário. Trigger manual apenas.
---

# /marketplace — Explorar skills disponíveis

Lê todas as skills da pasta `marketplace/`, apresenta o que cada uma faz, e sugere quais seriam úteis para o usuário com base no que sabe sobre ele (identidade, projeto, memórias).

## Quando usar

- **APENAS** quando o usuário digitar `/marketplace` explicitamente.
- Quando o usuário quiser descobrir skills novas ou não souber o que está disponível.
- Nunca disparar automaticamente.

## Processo

### Fase 1 — Inventário

1. Listar todas as pastas dentro de `marketplace/`.
2. Para cada pasta, ler o `SKILL.md` completo.
3. Verificar quais skills do marketplace **já estão ativas** (já copiadas em `.claude/skills/`).

### Fase 2 — Contexto do usuário

1. Ler o `CLAUDE.md` do usuário (identidade, projeto, fase atual).
2. Ler as memórias disponíveis (perfil, preferências, contexto do projeto).
3. Usar essas informações silenciosamente para informar as sugestões — **não recitar de volta**.

### Fase 3 — Apresentar catálogo

Mostrar cada skill do marketplace de forma clara e acessível:

Para cada skill, apresentar:
- **Nome e comando** — como chamar
- **O que faz** — descrição em 1-2 frases, linguagem simples
- **Quando é útil** — em que situação essa skill brilha
- **Status** — ✅ já ativada / ⬇️ disponível para ativar

Exemplo de formato:

```
## Skills disponíveis no marketplace

### /tornar-publico ⬇️
Sanitiza dados pessoais e publica trabalho da sessão no repositório.
Útil se você trabalha em projetos públicos e precisa separar o pessoal do que vai pro GitHub.

### /revisar-texto ✅ (já ativada)
Revisão ortográfica e de convenções em todos os .md do projeto.
Útil se você escreve documentação e quer manter consistência.
```

### Fase 4 — Recomendar

Depois de apresentar o catálogo, fazer **uma recomendação personalizada** baseada no contexto do usuário:

> "Com base no seu projeto e no que sei sobre como você trabalha, acho que a `/tornar-publico` seria útil pra você porque [razão concreta baseada no contexto]. Quer ativar?"

**Regras da recomendação:**
- Recomendar no máximo **2 skills** por vez. Não sobrecarregar.
- A recomendação deve ter **razão concreta** — não "pode ser útil", mas "porque você trabalha com repositório público e precisa sanitizar dados pessoais".
- Se nenhuma skill faz sentido pro usuário agora, dizer isso honestamente: "Nenhuma das skills do marketplace parece encaixar no que você está fazendo agora. Quando precisar, elas estarão aqui."
- Se todas já estão ativadas, dizer: "Você já tem tudo que o marketplace oferece. Quando novas skills aparecerem, rode `/marketplace` de novo."

### Fase 5 — Ativar (se o usuário quiser)

Se o usuário quiser ativar uma skill:

1. Copiar a pasta de `marketplace/<skill>` para `.claude/skills/<skill>`.
2. Confirmar:

> "Skill `/nome-da-skill` ativada. O Claude Code já a descobriu — pode usar agora."

Se o usuário quiser desativar uma skill:

1. Deletar a pasta de `.claude/skills/<skill>`.
2. Confirmar:

> "Skill `/nome-da-skill` desativada. O original continua no marketplace se quiser reativar depois."

## Regras

- **Nunca ativar sem pedir.** Sempre perguntar antes de copiar.
- **Nunca desativar skills core.** Se o usuário pedir pra desativar `/iniciar`, `/comece-por-aqui`, `/ate-a-proxima` ou `/criar-skill`, avisar que são essenciais e não devem ser removidas.
- **Recomendações honestas.** Se nada faz sentido, dizer. Não empurrar skill por empurrar.
- **Descrições acessíveis.** Não copiar o frontmatter técnico — traduzir pra linguagem que qualquer pessoa entenda.
- **Uma recomendação por vez.** Se ativar uma skill, não sugerir outra imediatamente. Deixar o usuário usar antes de recomendar mais.
