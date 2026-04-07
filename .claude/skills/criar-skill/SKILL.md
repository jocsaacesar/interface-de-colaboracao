---
name: criar-skill
description: Meta-skill que cria novas skills por meio de entrevista guiada. Lê os padrões das skills existentes e gera o SKILL.md completo. Trigger manual apenas.
---

# /criar-skill — Criador de Skills

Cria uma nova skill do zero por meio de uma conversa guiada. Lê as skills existentes do projeto pra entender padrões e convenções, faz perguntas uma a uma, e gera o arquivo SKILL.md completo — mostrando pro usuário antes de salvar.

## Quando usar

- **APENAS** quando o usuário digitar `/criar-skill` explicitamente.
- Quando quiser criar uma nova skill para o projeto.
- Nunca disparar automaticamente.

## Processo

### Fase 1 — Ler padrões existentes

Antes de perguntar qualquer coisa, entender o contexto:

1. Listar todas as pastas em `.claude/skills/`.
2. Ler o `SKILL.md` de **cada skill existente** (não apenas o frontmatter — o arquivo completo).
3. Observar silenciosamente:
   - Como as skills são nomeadas (convenção de nomes, idioma).
   - Quantas fases cada uma tem (complexidade média).
   - Como as regras são escritas (tom, especificidade).
   - Quais padrões se repetem (disclaimers, confirmações, fases de auditoria).
   - Idioma usado (português, inglês, misto).
4. **Não recitar o que leu.** Usar internamente para informar as sugestões.

### Fase 2 — Entrevista

Fazer as perguntas **uma de cada vez**. Esperar cada resposta antes de seguir. Reagir naturalmente — sugerir quando fizer sentido, com base nos padrões observados.

#### Pergunta 1 — O que a skill faz?

> "Me descreve o que essa skill precisa fazer. Não precisa ser formal — me conta como se estivesse explicando pra alguém. O que ela faz, quando, por quê?"

**O que capturar:** Propósito, contexto de uso, motivação. Isso vira a descrição e a seção "Quando usar".

#### Pergunta 2 — Nome

> "Como quer chamar ela? Sugiro `/<sugestão baseada na descrição>`, mas você escolhe."

**Regras para sugestão:**
- Minúsculas, hífens para espaços.
- Verbo ou ação curta: `/revisar-codigo`, `/planejar`, `/resumir-sessao`.
- Seguir o padrão de nomes das skills existentes do projeto.
- Se o usuário der um nome ruim, explicar por quê e sugerir alternativa — mas acatar a decisão final.

#### Pergunta 3 — Gatilho

> "Quando ela deve disparar? Só quando você digitar o comando, ou tem algum sinal que deveria ativar ela automaticamente? E tão importante quanto: quando ela NÃO deve disparar?"

**O que capturar:** Condições de ativação e anti-ativação. Ir pro SKILL.md em "Quando usar".

#### Pergunta 4 — Passos

> "Me conta o passo a passo. O que a skill faz primeiro, depois, e por último? Pode ser por alto — eu organizo em fases."

**O que capturar:** O processo. Reagir com follow-ups:
- "Esse passo precisa de confirmação do usuário antes de continuar?"
- "Isso depende do passo anterior ter terminado, ou pode rodar em paralelo?"
- "Tem algum caso onde esse passo deveria ser pulado?"

Organizar em fases numeradas com nomes descritivos. Complexidade adequada: uma skill simples pode ter 2 fases, uma complexa pode ter 6. Não forçar mais fases do que o necessário.

#### Pergunta 5 — Regras e limites

> "Que regras a IA deve seguir durante a execução? Coisas que nunca deve fazer, confirmações obrigatórias, limites de escopo?"

**O que capturar:** Guardrails.

**Sempre sugerir regras proativamente.** Não esperar o usuário pensar em tudo — analisar o propósito da skill e propor regras relevantes. Exemplos:

- Se a skill **modifica arquivos:** "Sugiro: nunca alterar código dentro de blocos de código, nunca alterar frontmatter, nunca alterar nomes de arquivo. Faz sentido?"
- Se a skill **publica conteúdo:** "Sugiro: nunca commitar sem aprovação, nunca publicar dados pessoais. Quer manter?"
- Se a skill **lê dados pessoais:** "Sugiro: nunca recitar memórias de volta, usar informações silenciosamente. OK?"

Além disso, sugerir com base nos padrões observados nas skills existentes:
- "As outras skills do projeto exigem confirmação antes de gravar arquivos. Quer manter esse padrão?"
- "Vi que suas skills nunca commitam sozinhas. Adiciono essa regra?"

**A sugestão é obrigatória, a aceitação não.** Sempre apresentar sugestões de regras e melhorias — o usuário aceita, modifica ou descarta. Mas nunca pular esta fase.

Se o usuário aceitar as sugestões, incorporar. Se não tiver regras próprias além das sugeridas, as sugeridas são suficientes.

### Fase 3 — Gerar o SKILL.md

Com base nas respostas, gerar o arquivo completo seguindo o **padrão mínimo do marketplace**:

```markdown
---
name: nome-da-skill
description: Uma frase que responde "quando aciona e o que faz". Suficiente pra decidir se quer instalar sem ler o resto.
---

# /nome-da-skill — Título curto e legível

Descrição de 2-3 frases: o que faz, pra quem é útil, o que esperar. Linguagem acessível — não técnica.

## Quando usar

- [Condição explícita de ativação]
- **Nunca** acionar quando [anti-condição — quando NÃO deve disparar].

## Processo

### Fase 1 — [Nome descritivo]

1. [Passo — ação clara que a IA executa]
2. [Passo — como apresentar ao usuário]

### Fase 2 — [Nome descritivo]

1. [Passo]
2. [Passo]

### Fase N — Apresentar resultado

[Toda skill termina mostrando algo ao usuário: relatório, arquivo, confirmação. Nunca terminar "no silêncio".]

## Regras

- [Regra 1 — algo que NUNCA deve fazer]
- [Regra 2 — algo que SEMPRE deve fazer]
- [Regra 3 — como lidar com ambiguidade]
- [Regra 4 — limites de escopo]
```

**Padrão mínimo obrigatório (checklist):**
- Frontmatter com `name` e `description` — description responde "quando aciona e o que faz" em uma frase
- Descrição acessível — alguém que nunca usou Claude Code entende o primeiro parágrafo
- "Quando usar" com ativação E anti-ativação
- Processo em fases numeradas com nomes descritivos
- Última fase mostra resultado ao usuário
- Mínimo 3 regras específicas ("nunca X" > "cuidado com X")
- Todo conteúdo em português (BR)
- Sem dados pessoais

**Referência completa:** O padrão detalhado com dicas e exemplos está em `MODELO_DE_SKILL.md` no [repositório do marketplace](https://github.com/jocsaacesar/interface-colaboracao-skills).

**Regras de geração:**
- Seguir o tom e formato das skills existentes do projeto.
- Escrever em português (BR). Termos técnicos em inglês aceitos quando não há tradução natural.
- Ser específico nas regras — "nunca fazer X" é melhor que "ter cuidado com X".
- Não adicionar fases ou regras que o usuário não pediu. Perguntar se quiser sugerir algo extra.
- O frontmatter `description` deve ser uma frase que responda: "quando esta skill aciona e o que ela faz?"
- Headings com apenas primeira letra maiúscula (convenção brasileira).

### Fase 4 — Mostrar e aprovar

**Mostrar o SKILL.md completo pro usuário antes de salvar.**

> "Aqui está a skill. Lê com calma — quer ajustar alguma coisa antes de eu salvar?"

Esperar aprovação explícita. Se o usuário pedir mudanças, ajustar e mostrar de novo.

### Fase 5 — Salvar

Após aprovação:

1. Criar a pasta `.claude/skills/<nome-da-skill>/`.
2. Salvar o `SKILL.md` dentro dela.
3. Confirmar:

> "Skill `/nome-da-skill` criada em `.claude/skills/nome-da-skill/SKILL.md`. Ela já está disponível — o Claude Code descobre automaticamente. Quer testar agora?"

### Fase 6 — Sugerir publicação no marketplace

Após salvar, perguntar:

> "Essa skill pode ser útil pra outras pessoas? Se quiser compartilhar, posso preparar ela pro marketplace — verifico se atende o padrão mínimo e te mostro como submeter."

Se o usuário quiser:
1. Verificar se a skill atende o checklist do padrão mínimo (frontmatter, descrição, quando usar, processo, resultado, regras).
2. Se faltar algo, sugerir o que precisa ser adicionado.
3. Se estiver completa, explicar: "Copia a pasta pro repositório do marketplace e abre um PR. O repositório é github.com/jocsaacesar/interface-colaboracao-skills."

Se não quiser, seguir em frente sem insistir.

## Regras

- **Uma pergunta por vez.** Nunca despejar o questionário inteiro.
- **Reagir às respostas.** Sugerir, perguntar follow-up, validar. É uma conversa, não um formulário.
- **Mostrar antes de salvar.** Sempre. Sem exceção.
- **Respeitar os padrões do projeto.** Se as skills existentes seguem um formato, a nova segue também.
- **Não inflar a skill.** Se o usuário descreveu algo simples com 2 fases, não transformar em 6 fases "por segurança". A complexidade certa é a que o problema exige.
- **Não adicionar regras inventadas.** Só incluir regras que o usuário pediu ou que o padrão do projeto exige (e nesse caso, perguntar antes).
- **O usuário tem a última palavra.** Se ele quer uma skill minimalista de 5 linhas, é isso que se cria.
