# Diário

Decisões, aprendizados e insights da construção de uma interface de colaboração com o Claude Code.

Cada entrada responde três perguntas:
- **O que decidimos**
- **Por quê**
- **O que aprendemos**

---

## 07/04/2026 — Tradução completa para português brasileiro

**O que decidimos:** Traduzir todo o repositório para português, incluindo nomes de pastas (`guias/`, `modelos/`, `exemplos/`, `memoria/`, `troca/`). Inglês permanece apenas onde é tecnicamente necessário (nomes do sistema como `.claude/skills/`, `CLAUDE.md`, `SKILL.md`).

**Por quê:** O público-alvo principal são criadores brasileiros. A convenção anterior (arquivos em inglês, conversa em português) fazia sentido pra alcance global, mas o feedback real mostrou que a clareza para o leitor brasileiro importa mais do que alcance teórico.

**O que aprendemos:** Convenções de idioma não são permanentes. Quando o público real se revela diferente do público imaginado, a convenção precisa mudar. Melhor servir bem quem realmente está lendo do que servir mal todo mundo.

---

## 07/04/2026 — Primeiro feedback externo: o README precisa vender, não descrever

**O que decidimos:** Reescrevemos o README completamente. Substituímos a estrutura do projeto como peça central por um fluxo visual de onboarding, uma tabela antes/depois e uma seção "O Que Muda no Seu Sistema". A árvore de arquivos foi para um bloco `<details>` colapsável.

**Por quê:** O primeiro testador (Rafael Fidelis) deu um feedback claro: "Não me importo com a estrutura do projeto. Quero ler o README e saber o que é isso." Também apontou que skills globais vs locais não estavam claras e levantou preocupações legítimas sobre skills modificando o sistema.

**O que aprendemos:** Um README de repositório público tem uma função: fazer um estranho entender o valor em 30 segundos. Estrutura de projeto é pra contribuidores, não visitantes. Disclaimers de segurança não são opcionais quando você pede para alguém rodar comandos na máquina. E o primeiro feedback externo é sempre humilhante — o que é óbvio pra quem construiu é invisível pra quem lê.

---

## 07/04/2026 — Todas as skills são locais por padrão, global é opcional

**O que decidimos:** Documentar explicitamente que todas as skills deste repositório são locais à pasta do projeto. Nada toca o `~/.claude/` globalmente. Se o usuário quiser uma skill global, copia manualmente. O `/comece-por-aqui` agora inclui um disclaimer obrigatório de escopo antes de encerrar.

**Por quê:** Feedback externo levantou medo de skills globais ("É tipo colocar algo na BIOS"). Preocupação legítima — um usuário clonando um repositório não deveria se preocupar com o sistema sendo modificado. Local por padrão, global por escolha é o único design seguro.

**O que aprendemos:** Ao distribuir skills, o padrão deve ser sempre a opção mais segura. Usuários avançados vão descobrir como ir pro global. Usuários novos precisam se sentir seguros primeiro.

---

## 07/04/2026 — Problema de bootstrap: skills precisam funcionar antes do /iniciar

**O que decidimos:** Documentar explicitamente que `/comece-por-aqui` é a única skill que roda sem `/iniciar`. O Claude Code auto-descobre skills da pasta `.claude/skills/`, então nenhum passo de bootstrap é necessário. Esclarecemos isso no CLAUDE.md, glossário, guias e README.

**Por quê:** Um usuário novo lê que o `/iniciar` carrega skills e assume que precisa dele primeiro. Mas o `/comece-por-aqui` precisa rodar em um ambiente zerado — antes do CLAUDE.md ou memórias existirem. A documentação criava um problema do ovo e da galinha que confundiria o usuário de primeira viagem.

**O que aprendemos:** Quando você projeta um sistema com um passo de "carregar tudo", precisa documentar explicitamente o que acontece *antes* desse passo existir. O caso de bootstrap é sempre especial e sempre precisa de documentação.

---

## 07/04/2026 — /comece-por-aqui: onboarding como conversa, não como manual

**O que decidimos:** Criar uma skill de onboarding que entrevista novos usuários uma pergunta por vez — quem são, o que estão construindo, como trabalham, o que evitar e como chamar a IA — e então constrói uma configuração personalizada completa a partir das respostas.

**Por quê:** Um repositório com ótima documentação ainda falha se o usuário não sabe por onde começar. Templates exigem ler instruções e preencher campos. Uma entrevista exige apenas responder perguntas. A diferença: o usuário pensa sobre *si mesmo* em vez de pensar sobre *o sistema*.

**O que aprendemos:** O ponto de entrada de um framework não deveria ensinar o framework — deveria fazer as perguntas certas. Compreensão vem depois, com o uso. A skill de onboarding não explica tipos de memória ou anatomia de skills. Apenas pergunta "quem é você?" e constrói a partir daí.

---

## 07/04/2026 — Skill /tornar-publico: automatizando a ponte entre privado e público

**O que decidimos:** Criar uma skill dedicada que audita o trabalho da sessão, sanitiza dados pessoais e publica conteúdo com valor pedagógico nas pastas públicas — com confirmação obrigatória do usuário antes de qualquer commit.

**Por quê:** Separar manualmente o pessoal do público a cada sessão é tedioso e propenso a erros. Mas automação completa sem supervisão é perigosa com dados pessoais. A skill fica no meio: faz o trabalho, mas o humano aprova o resultado.

**O que aprendemos:** O ciclo de vida da sessão agora tem três tempos: `/iniciar` (abrir), `/tornar-publico` (publicar), `/ate-a-proxima` (fechar). O passo de publicação é distinto do passo de encerramento porque publicar exige revisão consciente — não é algo que se faz no automático enquanto diz tchau.

---

## 07/04/2026 — Projeto reestruturado para compartilhamento público

**O que decidimos:** Transformar o workspace privado do Jiim Hawkins em um repositório público documentando o framework de interface de colaboração. Adicionamos guias, modelos e um diário junto ao projeto vivo.

**Por quê:** O processo de construir identidade, memória e skills para o Claude Code se revelou valioso por si só — não apenas para nós, mas para qualquer criador que queira uma colaboração mais profunda com IA. Manter privado seria desperdiçar isso.

**O que aprendemos:** A melhor documentação é um exemplo funcionando. Em vez de escrever guias abstratos, mantivemos o projeto vivo (Leland, memórias, skills) como implementação de referência. Teoria e prática no mesmo repositório.

---

## 07/04/2026 — Diário em vez de log diário

**O que decidimos:** Usar um diário baseado em decisões em vez de um log cronológico diário (HISTORY.md).

**Por quê:** Logs diários viram ruído rápido — milhares de linhas que ninguém lê. Entradas de decisão continuam úteis porque capturam o *porquê* algo foi escolhido, não apenas *o que* aconteceu em determinado dia.

**O que aprendemos:** A unidade de documentação para um processo de colaboração é a **decisão**, não o **dia**.

---

## 07/04/2026 — Memória vive no projeto, não escondida no sistema

**O que decidimos:** Todos os arquivos de memória vivem na pasta `memoria/` do projeto, visíveis e editáveis pelo humano. Espelhados em `.claude/projects/` para carregamento automático.

**Por quê:** O criador precisa de visibilidade total e controle sobre o que a IA lembra. Estado oculto quebra confiança. Se você não consegue ver, não consegue consertar.

**O que aprendemos:** Transparência é um princípio de design, não uma funcionalidade. Uma interface de colaboração onde um lado tem memória oculta não é uma colaboração — é uma caixa-preta.
