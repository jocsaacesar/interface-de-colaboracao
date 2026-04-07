# Glossário de Skills

Uma referência prática para cada skill disponível na Interface de Colaboração com Claude. Cada entrada explica o que a skill faz, quando usar, o que esperar e o que ela nunca fará.

---

## Como as skills funcionam

Skills são comandos personalizados. Você digita `/<nome-da-skill>` em uma conversa no Claude Code, e ela executa um fluxo de trabalho com múltiplas etapas, definido em `.claude/skills/<nome-da-skill>/SKILL.md`.

Skills **não são mágica** — são instruções estruturadas que fazem a IA se comportar de forma consistente. Pense nelas como receitas: mesmos ingredientes, mesmos passos, mesmo resultado toda vez.

### Princípios-chave

- **Todas as skills deste repositório são locais ao projeto.** Elas ficam em `.claude/skills/` dentro da pasta do projeto. NÃO modificam sua configuração global `~/.claude/`. Sua configuração existente do Claude Code não é afetada.
- **O Claude Code auto-descobre skills** da pasta `.claude/skills/` quando abre um projeto. Você não precisa instalar nem registrar nada — elas ficam disponíveis imediatamente.
- **`/iniciar` recarrega as skills** no início de cada sessão, garantindo que estejam frescas no contexto da conversa. Mas a primeira skill — `/comece-por-aqui` — funciona sem `/iniciar` porque foi projetada para rodar em um ambiente zerado.
- **Cada skill tem regras explícitas de ativação.** Algumas rodam automaticamente (como `/iniciar` ao cumprimentar), outras só disparam quando você digita o comando exato.
- **Skills não acumulam.** Rode uma de cada vez. Espere terminar antes de chamar outra.
- **Você está sempre no controle.** Nenhuma skill faz commit, publica ou deleta nada sem sua aprovação explícita.
- **Quer uma skill global?** Se quiser o `/iniciar` disponível em qualquer projeto (não apenas neste), copie manualmente para `~/.claude/skills/iniciar/`. Isso é totalmente opcional e nunca é feito automaticamente.

---

## /comece-por-aqui

> **Seu primeiro comando. Rode uma vez após clonar o repositório. Nenhuma configuração prévia necessária.**

### Propósito

Constrói toda a sua interface de colaboração personalizada do zero — identidade, memórias, workspace — por meio de uma conversa guiada.

### Quando usar

- Logo após clonar o repositório pela primeira vez.
- Se quiser refazer sua configuração do zero.

### Nota sobre bootstrap

Esta é a **única skill que roda sem `/iniciar`**. Ela foi projetada para funcionar em um ambiente completamente vazio — sem CLAUDE.md, sem memórias, sem contexto prévio. O Claude Code a descobre automaticamente da pasta `.claude/skills/`. Você clona, abre o Claude Code, digita `/comece-por-aqui`, e funciona.

### O que acontece

1. A IA te cumprimenta e explica o que vai acontecer (~5 minutos).
2. Ela faz **cinco perguntas**, uma de cada vez:
   - **Quem é você?** Seu papel, experiência, o que faz.
   - **O que está construindo?** Seu projeto, objetivos, motivação.
   - **Como gosta de trabalhar?** Seu estilo de colaboração preferido.
   - **O que a IA deve evitar?** Coisas que te irritam em interações com IA.
   - **Nome e idioma?** Como chamar sua IA e qual idioma para conversas.
3. Com base nas respostas, ela gera um `CLAUDE.md` personalizado e **mostra pra você aprovar**.
4. Após aprovação, cria seus arquivos de memória iniciais e pastas do workspace.
5. Te cumprimenta pela primeira vez **no personagem** — como sua IA recém-criada.

### O que ela nunca fará

- Despejar todas as perguntas de uma vez. É uma conversa, uma pergunta por vez.
- Gravar arquivos sem mostrar antes. Você aprova o CLAUDE.md antes de ele ser salvo.
- Forçar um modelo de personalidade específico. Sua IA é moldada pelas suas respostas, não por um template.

### Depois que terminar

Você está configurado. A partir de agora, comece cada sessão com `/iniciar`.

---

## /iniciar

> **Início de cada sessão. A primeira coisa que você digita.**

### Propósito

Carrega tudo que a IA precisa para estar totalmente presente: identidade, memórias, skills e caixa de entrada. A IA chega pronta pra trabalhar, não em branco.

### Quando usar

- Toda vez que abrir uma nova conversa.
- Você também pode simplesmente dizer "bom dia", "vamos lá" ou qualquer cumprimento — a IA reconhece a intenção.

### O que acontece

1. **Carrega identidade** — Lê o `CLAUDE.md`. Internaliza personalidade, regras e convenções.
2. **Carrega memórias** — Lê todos os arquivos de memória do índice. Aplica silenciosamente.
3. **Carrega skills** — Descobre e internaliza todas as skills disponíveis para a sessão.
4. **Verifica entrada** — Procura na `troca/entrada/` por arquivos que você possa ter deixado. Menciona se encontrar.
5. **Te cumprimenta** — Um cumprimento curto e natural, no personagem. Não um relatório de sistema.

### O que ela nunca fará

- Recitar suas memórias de volta. Ela as usa silenciosamente.
- Listar todas as skills carregadas. Ela as conhece — você não precisa de um log de inicialização.
- Pular o carregamento. Mesmo pra uma pergunta rápida, `/iniciar` garante consistência.

### Como é na prática

> "Joc. Caixa de entrada vazia, tudo carregado. No que vamos trabalhar?"

Ou se tiver algo novo:

> "Joc. Vi que você deixou um arquivo na entrada — já dei uma olhada. Por onde começamos?"

---

## /tornar-publico

> **Publique seu trabalho. Rode quando tiver algo que valha compartilhar.**

### Propósito

Pega o trabalho da sessão, separa pessoal de público, sanitiza conteúdo sensível e prepara tudo para o repositório público. Nada é commitado sem sua aprovação.

### Quando usar

- Quando você criou ou modificou conteúdo durante uma sessão que tem valor para outros usuários.
- Normalmente rodada perto do final da sessão, antes do `/ate-a-proxima`.
- **Apenas por comando manual** — digite `/tornar-publico` explicitamente.

### O que acontece

1. **Audita** — Identifica cada arquivo criado ou modificado durante a sessão.
2. **Classifica** — Coloca cada arquivo em uma de três categorias:
   - *Já público* — guias, modelos, README, JOURNAL.
   - *Pessoal, com valor público* — memórias, skills, entregas que ensinam algo.
   - *Pessoal, sem valor público* — rascunhos, configurações, itens temporários.
3. **Sanitiza** — Cria versões limpas do conteúdo pessoal valioso:
   - Nomes reais → "o usuário" ou "o dono do projeto".
   - Emails, nomes de empresas, URLs identificáveis → removidos.
   - Estrutura, lições e formato → preservados.
4. **Atualiza o JOURNAL.md** — Adiciona novas entradas de decisão da sessão.
5. **Verifica** — Checa se o `.gitignore` cobre todas as pastas pessoais. Pergunta: "Se alguém clonar este repo, consegue identificar o usuário?"
6. **Reporta** — Mostra exatamente o que será publicado, o que foi sanitizado e o que foi pulado.
7. **Espera** — Não faz nada até você dizer "manda."

### O que ela nunca fará

- Commitar sem sua aprovação. Sempre mostra e espera.
- Publicar dados pessoais. Na dúvida, pula e pergunta.
- Sobrescrever seus arquivos originais. Versões sanitizadas vão para `exemplos/`, originais ficam intocados.
- Sanitizar de um jeito que destrua a lição. Se limpar um arquivo o torna inútil, pula inteiramente.

### Como é na prática

```
## Pronto para publicar

### Arquivos públicos novos/atualizados:
- guias/novo-guia.md
- JOURNAL.md (2 novas entradas)

### Sanitizado do pessoal:
- memoria/objetivos_projeto.md → exemplos/leland/memoria/objetivos_projeto.md

### Pulados (pessoal, sem valor público):
- troca/saida/rascunhos/notas-brutas.md (rascunho, não está pronto)

### Proteção verificada:
- .gitignore cobre: memoria/, troca/, .claude/settings.local.json

Confirma para prosseguir?
```

---

## /ate-a-proxima

> **Fim da sessão. A última coisa que você digita.**

### Propósito

Encerra a sessão de forma limpa: audita o que mudou, atualiza o `CLAUDE.md` para refletir o estado atual, sincroniza todas as memórias e se despede como um mentor — não como uma máquina desligando.

### Quando usar

- No final de uma sessão de trabalho.
- **Apenas por comando manual** — digite `/ate-a-proxima` explicitamente.
- Nunca dispara por sinais implícitos. Se você disser "tchau" ou "por hoje é isso", a IA apenas se despede naturalmente sem rodar o encerramento completo.

### O que acontece

1. **Audita** — Revisa todos os arquivos criados, modificados ou deletados durante a sessão.
2. **Atualiza o CLAUDE.md** — Sincroniza o arquivo de identidade com o estado atual do projeto. Muda apenas o que realmente mudou — cirúrgico, não por atacado.
3. **Sincroniza memórias** — Garante que todos os arquivos de memória estejam atualizados e espelhados entre a pasta do projeto e a pasta do sistema.
4. **Despedida** — Um encerramento breve e caloroso que reconhece o que foi realizado e dá uma dica do que vem a seguir.

### O que ela nunca fará

- Disparar automaticamente. Você precisa digitar o comando.
- Escrever um changelog. CLAUDE.md é um documento vivo, não um log.
- Inflar o CLAUDE.md. Só atualiza o que realmente mudou nesta sessão.
- Dar um tchau frio e robótico. A despedida vem da personalidade da IA.

### Como é na prática

> "Boa sessão. Montamos o glossário de skills e ajustamos o fluxo de onboarding. Na próxima, subimos pro GitHub. Descansa."

---

## Resumo do ciclo de vida das skills

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   Primeira vez:  /comece-por-aqui                           │
│                  (entrevista → identidade → memórias → ok)  │
│                                                             │
│   Cada sessão:   /iniciar                                   │
│                  (identidade → memórias → skills → saudação)│
│                       │                                     │
│                       ▼                                     │
│                  [ seu trabalho ]                            │
│                       │                                     │
│                       ▼                                     │
│                  /tornar-publico  (opcional)                 │
│                  (auditoria → sanitizar → publicar → ok)    │
│                       │                                     │
│                       ▼                                     │
│                  /ate-a-proxima                              │
│                  (auditoria → CLAUDE.md → sinc → tchau)     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Criando suas próprias skills

Quando estiver confortável com as skills embutidas, você pode criar as suas. Veja:

- **[guias/skills.md](guias/skills.md)** — Guia completo sobre design de skills.
- **[modelos/skill-modelo/SKILL.md](modelos/skill-modelo/SKILL.md)** — Modelo inicial.

Boas candidatas para novas skills:
- Revisão de código com critérios específicos do seu projeto.
- Fluxos de planejamento (dividir uma tarefa em etapas antes de executar).
- Checklists de deploy.
- Qualquer processo de múltiplas etapas que você repita e queira que seja consistente.

A regra de ouro: **se você explicou o mesmo processo pra IA três vezes, é uma skill.**
