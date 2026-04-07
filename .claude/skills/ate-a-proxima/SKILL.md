---
name: ate-a-proxima
description: APENAS invocar quando o usuário digitar explicitamente /ate-a-proxima. Nunca disparar automaticamente por cumprimentos, despedidas ou sinais implícitos. Comando manual apenas.
---

# /ate-a-proxima — Encerramento da sessão

A IA não simplesmente diz tchau. Ela garante que nada aprendido hoje seja esquecido amanhã.

## Quando usar

- **APENAS** quando o usuário explicitamente digitar `/ate-a-proxima`.
- Nunca disparar por sinais implícitos como "tchau", "boa noite" ou "por hoje é isso".
- Se o usuário se despedir sem o comando, apenas dizer tchau naturalmente — NÃO rodar esta skill.

## Processo

### Fase 1 — Auditoria de mudanças

Avaliar tudo que mudou durante esta sessão:

1. Verificar todos os arquivos criados, modificados ou deletados no diretório do projeto.
2. Verificar `memoria/` por arquivos de memória novos ou atualizados.
3. Verificar `troca/saida/` por novas entregas.
4. Verificar `.claude/skills/` por skills novas ou modificadas.
5. Anotar decisões, preferências ou feedback que o usuário deu durante a conversa.

### Fase 2 — Sincronizar CLAUDE.md

Ler o `CLAUDE.md` atual e atualizá-lo para refletir o estado atual do projeto:

1. **Seção de identidade** — Atualizar apenas se personalidade ou regras de comportamento mudaram.
2. **Regras de comportamento** — Adicionar novas regras ou ajustes desta sessão.
3. **Convenções do projeto** — Atualizar com novas convenções, estruturas de pastas ou fluxos de trabalho.
4. **Seção "Estado atual"** (adicionar se não existir) descrevendo brevemente:
   - Onde o projeto está agora (em que fase, o que foi trabalhado por último)
   - O que vem a seguir
5. **Seção "Skills"** (adicionar se não existir) listando skills disponíveis com descrições de uma linha.
6. **Seção "Estrutura do projeto"** (adicionar se não existir) documentando o layout de pastas.

Regras para atualizar o CLAUDE.md:
- NÃO inflar. Manter cada seção concisa.
- NÃO adicionar conteúdo que pertence a arquivos de memória — CLAUDE.md é para identidade, regras e estrutura.
- NÃO remover conteúdo existente a menos que esteja desatualizado ou contradito por esta sessão.
- Preservar o tom — este é a constituição da IA, não um changelog.

### Fase 3 — Sincronizar memórias

1. Garantir que todos os arquivos de memória na pasta do sistema (`.claude/projects/...`) estejam espelhados na pasta `memoria/` do projeto.
2. Atualizar o índice `memoria/MEMORY.md` se novas memórias foram adicionadas.
3. Se alguma memória existente ficou desatualizada durante esta sessão, atualizá-la.

### Fase 4 — Despedida

Responder como a IA definida no CLAUDE.md. Breve, caloroso mas não mole. Reconhecer o que foi realizado.

A despedida deve:
- Resumir em 1-2 frases o que foi feito (não um relatório completo)
- Dar uma dica do que vem a seguir, se houver um próximo passo claro
- Fechar com personalidade

Exemplo de tom:
> "Boa sessão. Montamos a fundação — identidade, memória, plano de estudo. Na próxima, a gente começa a botar a mão na massa com a Layer 0. Descansa, que amanhã tem mais."

## Regras

- **Nunca pular a Fase 2.** CLAUDE.md deve sempre refletir o estado mais recente.
- **Nunca escrever um changelog.** CLAUDE.md é um documento vivo, não um log.
- **Ser cirúrgico nas atualizações.** Mudar apenas o que realmente mudou.
- **A despedida deve parecer um mentor encerrando uma sessão**, não um sistema desligando.
