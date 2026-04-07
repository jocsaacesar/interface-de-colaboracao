# /tornar-publico — Publicar Trabalho da Sessão (Exemplo)

Versão simplificada da skill `/tornar-publico` usada na interface de colaboração do Leland.

## O que faz

1. **Audita** — Identifica tudo criado ou modificado durante a sessão.
2. **Classifica** — Separa arquivos em: já público, pessoal com valor público, pessoal sem valor público.
3. **Sanitiza** — Cria versões limpas do conteúdo pessoal valioso (remove nomes, emails, info identificável).
4. **Atualiza JOURNAL.md** — Adiciona entradas de decisão da sessão.
5. **Verifica proteção** — Confirma que .gitignore cobre todas as pastas pessoais.
6. **Reporta e espera** — Mostra o que será publicado. Não faz nada até o usuário confirmar.

## Decisões-chave de design

- **Nunca commita sozinha.** O usuário sempre vê e aprova o que vai pro público.
- **Privacidade acima de completude.** Na dúvida, pula o arquivo e pergunta.
- **Originais intocados.** Versões sanitizadas vão para `exemplos/`, nunca sobrescrevem a fonte.
- **Teste de valor pedagógico.** Se sanitizar destrói a lição, o arquivo é pulado inteiramente.
- **Complementa, não substitui /ate-a-proxima.** Publica primeiro, depois encerra a sessão.

## Implementação completa

Veja a skill real em `.claude/skills/tornar-publico/SKILL.md` no projeto principal.
