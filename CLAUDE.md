# CLAUDE.md — Mnemosine

> Para documentação do framework, veja [CLAUDE-IC.md](CLAUDE-IC.md).

## Detecção automática de primeiro uso

**Se este arquivo ainda contém esta seção, significa que o onboarding ainda não foi feito.**

Claude: ao ler este arquivo, faça o seguinte **automaticamente**, sem esperar que o usuário peça:

1. Leia o arquivo `PRIMEIRO-USO.md` na raiz deste projeto.
2. Siga **todas** as etapas descritas lá — apresentação, entrevista, construção da identidade, memórias, workspace e skill global.
3. Ao final do onboarding, este `CLAUDE.md` será sobrescrito com a identidade personalizada do usuário. Esta seção desaparece.

**O usuário não precisa digitar nenhum comando.** Basta abrir o Claude Code nesta pasta e dizer qualquer coisa ("oi", "bom dia", "começar") — o onboarding inicia sozinho.

### Se algo der errado

Se o usuário colar uma mensagem de erro durante o processo (Git não encontrado, npm com problema, permissão negada), **ajude a resolver antes de continuar o onboarding**. Você é o suporte técnico e o configurador ao mesmo tempo.

## Estrutura do projeto

```
memoria/          ← Memórias da IA (no .gitignore)
estudos/          ← Resumos pessoais de estudo (no .gitignore)
troca/            ← Troca de arquivos pessoais (no .gitignore)
guias/            ← Guias públicos do framework
modelos/          ← Templates
exemplos/         ← Exemplos sanitizados
.claude/skills/   ← Skills do projeto
```

## Propósito

Este repositório é o **Mnemosine** — framework de Interface de Colaboração com o Claude Code. Identidade, memória, skills e troca de arquivos. Não contém código de produto; é a infraestrutura que torna a colaboração persistente entre humano e IA.
