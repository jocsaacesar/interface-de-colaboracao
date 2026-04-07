# Usando o sistema de memória

O Claude Code tem um sistema de memória integrado que persiste informações entre conversas. Este guia explica como usá-lo de forma intencional — não apenas deixar acumular.

## Como a memória funciona

Arquivos de memória vivem em dois lugares:
- **Pasta do sistema** (`~/.claude/projects/<projeto>/memory/`) — carregados automaticamente pelo Claude Code.
- **Pasta do projeto** (`memoria/`) — visíveis e editáveis pelo humano.

Ambos devem ficar sincronizados. A pasta do sistema é o que o Claude lê automaticamente; a pasta do projeto é o que você pode ver e editar diretamente.

### MEMORY.md

O arquivo `MEMORY.md` é um **índice**, não uma memória em si. Cada linha aponta para um arquivo de memória com uma breve descrição. O Claude lê esse índice para decidir quais memórias são relevantes.

```markdown
- [Convenção de idioma](feedback_idioma.md) — Arquivos do projeto em português, termos técnicos em inglês quando necessário
- [Perfil do usuário](usuario_perfil.md) — Dono do projeto, valoriza profundidade e mentoria contextual
```

Mantenha entradas com menos de 150 caracteres. Linhas após a 200ª serão truncadas.

## Tipos de memória

| Tipo | Propósito | Quando Salvar |
|------|-----------|--------------|
| **user** | Quem é o humano — papel, preferências, nível de conhecimento | Quando aprender detalhes sobre o usuário |
| **feedback** | Como a IA deve se comportar — correções e confirmações | Quando o usuário corrigir ou validar uma abordagem |
| **project** | Contexto do trabalho — objetivos, prazos, decisões | Quando aprender quem/o quê/por quê/quando sobre o projeto |
| **reference** | Apontadores para recursos externos | Quando descobrir onde informações vivem fora do projeto |

## Formato do arquivo de memória

```markdown
---
name: Título da memória
description: Descrição em uma linha usada para decidir relevância
type: user | feedback | project | reference
---

Conteúdo da memória.

**Por quê:** A razão pela qual isso importa.

**Como aplicar:** Quando e como usar essa informação.
```

## O que salvar

- Preferências do usuário que afetam como a IA deve trabalhar
- Decisões que não são óbvias a partir do código
- Correções — coisas que a IA errou e não deveria repetir
- Validações — abordagens que funcionaram e devem continuar
- Apontadores para sistemas externos (boards do Linear, canais do Slack, dashboards)

## O que NÃO salvar

- Padrões de código (leia o código em vez disso)
- Histórico do git (use `git log`)
- Soluções de debugging (a correção está no código)
- Qualquer coisa que já esteja no CLAUDE.md
- Estado temporário de tarefas (use tarefas em vez disso)

## Princípios

1. **Transparência.** O humano deve poder ler, editar e deletar qualquer memória. Sem estado oculto.
2. **Relevância acima de completude.** Não salve tudo — salve o que muda comportamento.
3. **Atualize, não duplique.** Verifique se uma memória já existe antes de criar uma nova.
4. **Memórias envelhecem.** Informação fica desatualizada. Verifique antes de agir com base em memórias antigas.
5. **O humano é a autoridade.** Se uma memória conflita com o que o humano diz agora, confie no humano.

## Modelo

Veja [modelos/modelo-de-memoria.md](../modelos/modelo-de-memoria.md) para um modelo inicial.
