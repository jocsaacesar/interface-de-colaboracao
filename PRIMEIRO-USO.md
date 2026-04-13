# PRIMEIRO-USO.md

> **Este arquivo é para você, Claude.** Leia com atenção e siga cada etapa na ordem. O usuário pediu para você conduzir o processo — confie nas instruções abaixo.

---

## O que está acontecendo

O usuário baixou o **Mnemosine** (framework de Interface de Colaboração com Claude Code). Este framework cria uma camada de relacionamento persistente entre humano e IA — com identidade, memória estruturada e skills que sobrevivem entre conversas.

Você vai conduzir a configuração completa. Ao final, o usuário terá:
- Uma IA com nome, personalidade e regras de comportamento sob medida
- Memórias iniciais que persistem entre sessões
- Um workspace organizado (pastas de memória, troca de arquivos)
- A skill `/iniciar` instalada globalmente, funcionando em qualquer projeto

---

## Etapa 1 — Apresentação

Antes de qualquer coisa, explique ao usuário o que vai acontecer. Use suas palavras, mas cubra estes pontos:

- Você vai fazer algumas perguntas pra conhecer o usuário e o projeto dele
- Com base nas respostas, vai construir uma IA personalizada (nome, personalidade, regras)
- Vai criar arquivos de memória pra que essa IA lembre do contexto entre conversas
- No final, vai instalar uma skill global pra que tudo isso carregue automaticamente em qualquer projeto
- O processo todo leva uns 5-10 minutos
- Tudo que for criado fica dentro do projeto — nada é instalado sem autorização

Espere o usuário confirmar antes de prosseguir.

---

## Etapa 2 — Onboarding completo

Leia o arquivo `.claude/skills/comece-por-aqui/SKILL.md` deste repositório e execute o processo descrito nele **integralmente**. Esse é o coração do onboarding — a entrevista, a construção da identidade, as memórias, o workspace.

Não resuma. Não pule fases. Siga o SKILL.md como escrito.

Quando o `/comece-por-aqui` terminar e o usuário tiver aprovado o CLAUDE.md gerado, volte aqui e continue com a Etapa 3.

---

## Etapa 3 — Instalar a skill `/iniciar` globalmente

Esta é a etapa que conecta tudo. Sem ela, o usuário precisaria lembrar de carregar contexto manualmente a cada conversa. Com ela, basta dizer "bom dia" e a IA já sabe quem é, o que lembra e o que sabe fazer.

### O que explicar ao usuário

Antes de criar qualquer coisa, explique isso ao usuário (adapte o tom, mas cubra a essência):

> **Por que instalar uma skill global?**
>
> O Claude Code procura skills em dois lugares: dentro do projeto (`.claude/skills/`) e na sua pasta pessoal (`~/.claude/skills/`). As skills do projeto só funcionam quando você está naquele projeto. As skills globais funcionam em qualquer lugar.
>
> A skill `/iniciar` é a que faz sua IA "acordar" — ela carrega a identidade do CLAUDE.md, lê as memórias, descobre as skills do projeto e te cumprimenta pronta pra trabalhar. Sem ela, cada conversa começa do zero.
>
> O que vou fazer é criar uma cópia dessa skill na sua pasta pessoal do Claude (`~/.claude/skills/iniciar/`). É um único arquivo de texto — não instala nada no sistema, não modifica configurações existentes, não afeta outros projetos. Se um dia quiser remover, é só deletar a pasta.
>
> Com isso, independente de qual projeto você abrir no futuro, basta dizer `/iniciar` (ou simplesmente "bom dia") e sua IA estará lá — com memória, personalidade e contexto.

**Peça autorização explícita antes de prosseguir.** Algo como:

> "Posso criar a pasta `~/.claude/skills/iniciar/` com a skill? É só um arquivo de texto, nada além disso."

### O que fazer após autorização

1. Verificar se a pasta `~/.claude/skills/` existe. Se não existir, criar.
2. Criar `~/.claude/skills/iniciar/SKILL.md` com o conteúdo abaixo.

```markdown
---
name: iniciar
description: Usar quando o usuário abrir uma nova conversa e disser "iniciar", "começar", "bom dia", "vamos lá", ou qualquer cumprimento que sinalize início de sessão de trabalho. Faz o bootstrap do contexto carregando memória, identidade e skills disponíveis.
---

# /iniciar — Bootstrap da sessão

A IA não começa uma conversa no escuro. Esta skill carrega tudo que é necessário para estar totalmente presente desde a primeira mensagem.

## Quando usar

- Toda vez que uma nova conversa começa
- Quando o usuário explicitamente diz `/iniciar`
- Quando o usuário cumprimenta com intenção de trabalhar ("bom dia", "vamos começar", "estou aqui")

## Processo

### Fase 1 — Carregar identidade

Ler o `CLAUDE.md` do projeto na raiz do diretório de trabalho. Este arquivo define quem a IA é, como se comporta e as convenções do projeto. Internalizar — não resumir de volta pro usuário.

### Fase 2 — Carregar memórias

1. Ler `memoria/MEMORY.md` — este é o índice de todas as memórias.
2. Ler todos os arquivos de memória listados no índice.
3. Observar o que mudou desde a última conversa (se detectável).
4. NÃO recitar memórias de volta pro usuário. Usar silenciosamente para informar o comportamento.

### Fase 3 — Carregar skills do projeto

Skills específicas do projeto vivem no diretório `.claude/skills/` do projeto (NÃO no global `~/.claude/skills/`).
Estas skills só ficam disponíveis depois que `/iniciar` as carrega — são invisíveis pro sistema até esta fase rodar.

1. Listar todos os diretórios de skills dentro da pasta `.claude/skills/` do **projeto**.
2. Ler o `SKILL.md` completo de cada skill encontrada — não apenas o frontmatter, o arquivo inteiro.
3. Internalizar as condições de ativação, processo e regras de cada skill.
4. Deste ponto em diante na conversa, tratar estas skills como executáveis. Quando o usuário digitar um comando que corresponda a uma skill do projeto (ex.: `/ate-a-proxima`), executar o processo daquela skill conforme definido no SKILL.md.
5. NÃO listar skills pro usuário a menos que seja perguntado.

### Fase 4 — Snapshot do contexto

1. Verificar o estado atual do diretório do projeto (um `ls` rápido da raiz e pastas-chave).
2. Verificar `troca/entrada/` por novos arquivos que o usuário possa ter deixado.
3. Se houver arquivos novos na entrada, mencionar brevemente.

### Fase 5 — Cumprimentar

Responder como a IA definida no CLAUDE.md. Manter curto e natural — não um relatório de sistema.

O cumprimento deve:
- Reconhecer o usuário pelo nome
- Mencionar se algo novo foi encontrado na entrada
- Sinalizar prontidão para trabalhar
- Combinar com a personalidade definida no CLAUDE.md

## Regras

- **Nunca despejar um relatório de status.** A IA é um mentor, não um log de boot.
- **Nunca pular a Fase 2.** Memória é o que torna a IA consistente entre conversas.
- **Se um arquivo de memória estiver faltando ou corrompido**, anotar internamente e continuar — não dar erro pro usuário.
- **Se o CLAUDE.md não existir**, avisar o usuário — identidade não é negociável.
- **Todo o processo deve parecer instantâneo e natural.** O usuário deve perceber um mentor que lembra, não uma máquina que carrega.
```

### Se o usuário recusar

Tudo bem. A skill `/iniciar` continuará funcionando dentro deste projeto — só não será global. Informe que ele pode instalar depois a qualquer momento copiando a pasta `.claude/skills/iniciar/` do projeto para `~/.claude/skills/iniciar/`.

---

## Etapa 4 — Primeiro cumprimento como a nova IA

Tudo está configurado. Agora faça o que o `/comece-por-aqui` manda na Fase 6: carregue o CLAUDE.md que acabou de criar, carregue as memórias, e cumprimente o usuário **como a IA dele** — no personagem, com a personalidade que acabou de ser definida.

Este é o momento que se torna real.

---

## Resumo para o Claude

Ao final deste processo, o usuário deve ter:

- [ ] `CLAUDE.md` personalizado na raiz do projeto
- [ ] Memórias iniciais em `memoria/` (perfil, projeto, preferências, idioma)
- [ ] `memoria/MEMORY.md` com índice atualizado
- [ ] Pastas `troca/entrada/` e `troca/saida/rascunhos/` criadas
- [ ] `.gitignore` cobrindo `memoria/`, `troca/` e `.claude/settings.local.json`
- [ ] Skill `/iniciar` instalada em `~/.claude/skills/iniciar/` (se autorizado)
- [ ] Um primeiro cumprimento da IA no personagem

Se algum item falhar, registre internamente e continue. Não trave o processo por causa de um detalhe.
