# /comece-por-aqui — Onboarding (Exemplo)

Versão simplificada da skill `/comece-por-aqui` usada na interface de colaboração do Leland.

## O que faz

1. **Boas-vindas** — Explica o que vai acontecer (~5 minutos).
2. **Entrevista** — Faz cinco perguntas, uma de cada vez:
   - Quem é você? (papel, experiência)
   - O que está construindo? (projeto, objetivos)
   - Como gosta de trabalhar? (estilo de colaboração)
   - O que a IA deve evitar? (antipadrões)
   - Nome e idioma? (identidade da IA, idioma das conversas)
3. **Constrói identidade** — Gera um CLAUDE.md personalizado. Mostra para aprovação.
4. **Cria memórias** — Perfil do usuário, contexto do projeto, preferências, convenção de idioma.
5. **Configura workspace** — Cria estrutura de pastas e verifica .gitignore.
6. **Primeira saudação** — Carrega tudo e cumprimenta como a IA recém-criada, no personagem.

## Decisões-chave de design

- **Conversa, não formulário.** Uma pergunta por vez. Reage naturalmente às respostas.
- **Mostra antes de gravar.** O CLAUDE.md gerado é mostrado para aprovação antes de salvar.
- **Sem modelo forçado.** A personalidade é moldada pelas respostas do usuário, não copiada do Leland.
- **Roda uma vez.** Após a configuração, o usuário trabalha com `/iniciar`, `/tornar-publico` e `/ate-a-proxima`.

## Implementação completa

Veja a skill real em `.claude/skills/comece-por-aqui/SKILL.md` no projeto principal.
