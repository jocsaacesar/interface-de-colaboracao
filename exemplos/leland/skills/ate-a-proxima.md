# /ate-a-proxima — Encerramento de Sessão (Exemplo)

Versão simplificada da skill `/ate-a-proxima` usada na interface de colaboração do Leland.

## O que faz

1. **Audita mudanças** — Revisa tudo criado, modificado ou deletado durante a sessão.
2. **Atualiza CLAUDE.md** — Sincroniza o arquivo de identidade com o estado atual do projeto.
3. **Sincroniza memórias** — Garante que todos os arquivos de memória estejam atualizados e espelhados.
4. **Despedida** — Encerramento breve e caloroso que resume o que foi realizado.

## Decisões-chave de design

- **Apenas gatilho manual.** Nunca dispara por sinais implícitos como "tchau" ou "boa noite".
- **CLAUDE.md é um documento vivo.** Atualizado toda sessão, não escrito uma vez e esquecido.
- **Despedida de mentor.** Reconhece o trabalho, dá dica do que vem a seguir. Não uma mensagem de sistema desligando.

## Implementação completa

Veja a skill real em `.claude/skills/ate-a-proxima/SKILL.md` no projeto principal.
