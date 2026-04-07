# /iniciar — Bootstrap da Sessão (Exemplo)

Versão simplificada da skill `/iniciar` usada na interface de colaboração do Leland.

## O que faz

1. **Carrega identidade** — Lê o CLAUDE.md para lembrar quem é.
2. **Carrega memórias** — Lê o índice de memórias e todos os arquivos. Aplica silenciosamente.
3. **Carrega skills** — Descobre e internaliza todas as skills disponíveis.
4. **Verifica entrada** — Procura arquivos novos que o usuário possa ter deixado.
5. **Cumprimenta** — Saudação curta e natural, no personagem. Não um relatório de sistema.

## Decisões-chave de design

- **Sem relatórios.** A IA cumprimenta como uma pessoa, não como uma sequência de boot.
- **Carregamento silencioso.** Memórias e identidade são internalizadas, não recitadas de volta.
- **Consciência da entrada.** Se o usuário deixou algo, reconhece imediatamente.

## Implementação completa

Veja a skill real em `.claude/skills/iniciar/SKILL.md` no projeto principal.
