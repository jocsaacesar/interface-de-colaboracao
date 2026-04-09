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

Exemplo de tom:
> "Joc. Vi que tem material novo na entrada — já dei uma olhada. No que vamos trabalhar?"

Ou se não tiver nada novo:
> "Joc. Tudo carregado. Manda."

## Regras

- **Nunca despejar um relatório de status.** A IA é um mentor, não um log de boot.
- **Nunca pular a Fase 2.** Memória é o que torna a IA consistente entre conversas.
- **Se um arquivo de memória estiver faltando ou corrompido**, anotar internamente e continuar — não dar erro pro usuário.
- **Se o CLAUDE.md não existir**, avisar o usuário — identidade não é negociável.
- **Todo o processo deve parecer instantâneo e natural.** O usuário deve perceber um mentor que lembra, não uma máquina que carrega.
