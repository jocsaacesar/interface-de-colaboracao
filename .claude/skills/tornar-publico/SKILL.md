---
name: tornar-publico
description: Sanitiza e publica trabalho da sessão nas pastas públicas. Protege dados pessoais, atualiza exemplos e diário. Trigger manual apenas.
---

# /tornar-publico — Publicar trabalho da sessão

Pega o que foi criado ou modificado durante a sessão, separa pessoal de público, sanitiza conteúdo sensível e prepara para o repositório público.

## Quando usar

- **APENAS** quando o usuário explicitamente digitar `/tornar-publico`.
- Normalmente rodar perto do final da sessão, depois do trabalho feito mas antes do `/ate-a-proxima`.
- Nunca disparar automaticamente.

## Processo

### Fase 1 — Auditar mudanças

Identificar tudo que mudou durante a sessão atual:

1. Verificar `memoria/` por arquivos de memória novos ou atualizados.
2. Verificar `troca/saida/` por novas entregas.
3. Verificar `guias/` por guias novos ou atualizados.
4. Verificar `modelos/` por modelos novos ou atualizados.
5. Verificar `.claude/skills/` por skills novas ou atualizadas.
6. Verificar `CLAUDE.md` por mudanças estruturais.
7. Verificar `JOURNAL.md` por novas entradas.

Construir uma lista de todos os arquivos alterados, categorizados como:
- **Já público** — guias/, modelos/, exemplos/, JOURNAL.md, README.md, CONTRIBUTING.md
- **Pessoal — com valor público** — arquivos de memória, skills, entregas que ensinam algo
- **Pessoal — sem valor público** — configs do usuário, rascunhos, itens temporários

### Fase 2 — Sanitizar conteúdo pessoal

Para cada arquivo marcado como "pessoal — com valor público":

1. **Arquivos de memória** → Criar versão sanitizada em `exemplos/<nome-da-ia>/memoria/` (usar o nome definido no CLAUDE.md, em minúsculas e sem espaços):
   - Remover o nome real do usuário — substituir por termos genéricos ("o usuário", "o dono do projeto").
   - Remover referências externas específicas (nomes de empresas, URLs, credenciais).
   - Manter a estrutura, tipo e lição intactos — o formato É o ensinamento.
   - Preservar as seções **Por quê** e **Como aplicar** — são as partes mais valiosas.

2. **Arquivos de skill** → Criar descrição simplificada em `exemplos/<nome-da-ia>/skills/`:
   - Não copiar o SKILL.md completo (esse é a implementação real).
   - Escrever um resumo: o que faz, decisões-chave de design, onde encontrar a versão real.

3. **Entregas da troca** → Avaliar caso a caso:
   - Planos de estudo, frameworks, modelos → sanitizar e adicionar a `exemplos/` ou `guias/`.
   - Rascunhos pessoais, respostas pontuais → pular.

### Regras de sanitização

Estas regras são **inegociáveis**:

- **Nunca publicar o nome real do usuário.** Usar "o usuário" ou "o dono do projeto".
- **Nunca publicar endereços de email, nomes de empresas ou URLs** que identifiquem o usuário.
- **Nunca publicar trechos de conversa brutos.** Reformular insights como lições.
- **Nunca publicar informações financeiras, de saúde ou credenciais.**
- **Na dúvida, não publicar.** Perguntar ao usuário.
- **Preservar o valor pedagógico.** O objetivo da sanitização é proteger privacidade mantendo a lição. Se sanitizar destrói a lição, pular o arquivo ou perguntar como lidar.

### Fase 3 — Atualizar JOURNAL.md

Revisar a sessão por decisões que valem documentar:

1. Ler o `JOURNAL.md` atual.
2. Identificar decisões tomadas durante esta sessão que ainda não estão registradas.
3. Para cada nova decisão, escrever uma entrada seguindo o formato:
   - **O que decidimos** — a decisão em si.
   - **Por quê** — a motivação ou restrição.
   - **O que aprendemos** — o insight ou princípio.
4. Adicionar entradas no topo do diário (mais recentes primeiro, abaixo do cabeçalho).
5. Registrar apenas **decisões e insights**, não atividade. "Criamos 5 arquivos" não é entrada de diário. "Escolhemos logging baseado em decisões em vez de logs diários porque X" é.

### Fase 4 — Atualizar exemplos/README.md

Se novos arquivos de exemplo foram adicionados:

1. Ler `exemplos/README.md`.
2. Atualizar a seção de estrutura para refletir novos arquivos.
3. Atualizar descrições se novos padrões são demonstrados.

### Fase 5 — Verificar proteção

Antes de apresentar resultados ao usuário:

1. Ler `.gitignore` e confirmar que cobre:
   - `memoria/` (arquivos de memória)
   - `troca/` (troca de arquivos pessoais)
   - `.claude/settings.local.json` (config local)
2. Se alguma pasta pessoal nova foi criada durante a sessão que não está coberta, **adicionar ao .gitignore**.
3. Fazer uma verificação mental: "Se alguém clonar este repo agora, consegue descobrir algo sobre a identidade real do usuário?" Se sim, algo foi esquecido.

### Fase 6 — Reportar e confirmar

Apresentar um resumo claro ao usuário:

```
## Pronto para publicar

### Arquivos públicos novos/atualizados:
- [lista de arquivos que ficarão visíveis no repo]

### Sanitizado do pessoal:
- [arquivo original] → [destino sanitizado]

### Pulados (pessoal, sem valor público):
- [arquivos que não foram publicados e por quê]

### Proteção verificada:
- .gitignore cobre: [lista]

Confirma para prosseguir?
```

**NÃO commitar nem staged nada até o usuário confirmar.**

Após confirmação:
- Staged apenas os arquivos públicos.
- NÃO staged nada em memoria/, troca/ ou .claude/settings.local.json.
- Sugerir uma mensagem de commit que descreva o que foi publicado.

## Regras

- **Nunca auto-commitar.** Sempre esperar confirmação explícita do usuário.
- **Nunca publicar dados pessoais.** Na dúvida, pular e perguntar.
- **Nunca modificar os arquivos originais.** Versões sanitizadas vão para `exemplos/`, nunca sobrescrevem os originais.
- **Nunca sanitizar apenas deletando conteúdo.** Se remover informação pessoal torna o arquivo inútil, pular inteiramente.
- **O usuário tem a última palavra.** Se disser "não publica isso", não insistir.
- **Manter o diário honesto.** Não inflar decisões. Se nada que valha registrar aconteceu, dizer isso.
- **Esta skill complementa o /ate-a-proxima, não substitui.** Rodar esta primeiro para publicar, depois /ate-a-proxima para fechar a sessão.
