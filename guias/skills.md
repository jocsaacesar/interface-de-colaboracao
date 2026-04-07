# Criando e Organizando Skills

Skills são comandos personalizados que automatizam fluxos de trabalho com múltiplas etapas no Claude Code. Elas ficam em `.claude/skills/` e são acionadas digitando `/<nome-da-skill>` na conversa.

**Como funciona a descoberta:** O Claude Code auto-descobre skills da pasta `.claude/skills/` quando abre um projeto. Você não precisa registrar nem instalar nada — coloque a pasta da skill lá e ela fica disponível. A skill `/iniciar` as recarrega no início da sessão para um contexto fresco, mas skills funcionam mesmo sem `/iniciar` (é assim que o `/comece-por-aqui` funciona como primeiro comando em um clone recém-feito).

## Por Que Skills Importam

Sem skills, você repete as mesmas instruções toda sessão:
- "Carregue minhas memórias"
- "Verifique a caixa de entrada"
- "Atualize o CLAUDE.md antes de encerrar"

Skills transformam processos repetidos em comandos de uma palavra.

## Anatomia de uma Skill

Cada skill vive em sua própria pasta com um arquivo `SKILL.md`:

```
.claude/skills/
└── minha-skill/
    └── SKILL.md
```

### Estrutura do SKILL.md

```markdown
---
name: minha-skill
description: Descrição em uma linha do que essa skill faz e quando deve ser acionada.
---

# /minha-skill — Título Legível

Breve descrição do propósito.

## Quando usar

- Condições explícitas de acionamento
- Quando NÃO acionar (importante para evitar ativações falsas)

## Processo

### Fase 1 — Nome
Instruções passo a passo.

### Fase 2 — Nome
Mais passos.

## Regras

- Restrições rígidas que a IA deve seguir durante a execução.
```

## Princípios de Design

### 1. Uma skill, um fluxo de trabalho

Uma skill deve fazer uma coisa coerente. Não combine "carregar sessão" e "revisar código" em uma skill só — são dois fluxos diferentes.

### 2. Gatilhos explícitos

Seja muito claro sobre quando uma skill deve e NÃO deve ativar. A IA vai tentar ser prestativa — se suas condições de ativação forem vagas, ela vai disparar a skill quando você não quer.

```markdown
## Quando usar

- APENAS quando o usuário digitar explicitamente `/ate-a-proxima`
- Nunca acionar por sinais implícitos como "tchau" ou "boa noite"
```

### 3. Execução por fases

Divida skills complexas em fases numeradas. Isso torna o processo previsível e depurável.

### 4. Regras como guardrails

Termine toda skill com regras explícitas. Elas impedem a IA de "melhorar" o processo de formas que você não pediu.

## Padrões Comuns de Skills

| Skill | Propósito |
|-------|-----------|
| `/iniciar` | Bootstrap da sessão — carrega identidade, memórias, verifica entrada |
| `/ate-a-proxima` | Encerramento — audita mudanças, sincroniza estado, despedida |
| `/revisar` | Revisão de código com critérios específicos |
| `/planejar` | Dividir uma tarefa em etapas antes de executar |

## Dicas

- **Comece simples.** Sua primeira skill deve ter 10 linhas, não 100.
- **Itere com base na fricção.** Se uma skill continua fazendo algo errado, adicione uma regra.
- **Não automatize demais.** Nem toda ação repetida precisa de uma skill. Se você faz uma vez por semana, simplesmente digite as instruções.
- **Teste em uma nova conversa.** Skills carregam do zero cada vez — garanta que funcionem sem contexto prévio.

## Modelo

Veja [modelos/skill-modelo/SKILL.md](../modelos/skill-modelo/SKILL.md) para um modelo inicial.
