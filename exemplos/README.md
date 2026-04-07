# Exemplos

Esta pasta contém implementações de referência sanitizadas de interfaces de colaboração construídas com este framework.

## Leland

**Leland Hawkins** é a interface de colaboração original construída durante este projeto. Ela demonstra:

- Uma identidade multi-personalidade (Pragmático, Provocador, Didático)
- Ciclo de vida completo de sessão (`/comece-por-aqui`, `/iniciar`, `/tornar-publico`, `/ate-a-proxima`)
- Sistema de memória tipado (user, feedback, project, reference)
- Convenção bilíngue (artefatos em português, termos técnicos em inglês quando necessário)

### Estrutura

```
leland/
├── CLAUDE.md                           # Arquivo de identidade
├── memoria/
│   ├── MEMORY.md                       # Índice de memórias
│   ├── feedback_idioma.md              # Convenção de idioma
│   ├── perfil_usuario.md               # Exemplo de memória de usuário
│   └── feedback_bootstrap_sessao.md    # Preferência de transparência
└── skills/
    ├── comece-por-aqui.md              # Onboarding (simplificado)
    ├── iniciar.md                      # Bootstrap de sessão (simplificado)
    ├── tornar-publico.md               # Fluxo de publicação (simplificado)
    └── ate-a-proxima.md                # Encerramento de sessão (simplificado)
```

### Nota

Esta é uma versão **sanitizada**. Informações pessoais foram removidas ou generalizadas. A implementação real existe na raiz do projeto.

## Adicionando Seu Próprio Exemplo

Se você construiu uma interface de colaboração e quer compartilhar:

1. Crie uma pasta com o nome da sua IA (ex.: `exemplos/atlas/`).
2. Inclua um CLAUDE.md sanitizado, memórias de exemplo e descrições de skills.
3. **Nunca inclua dados pessoais reais** — generalize perfis de usuário e remova detalhes identificáveis.
4. Abra um PR seguindo as [diretrizes de contribuição](../CONTRIBUTING.md).
