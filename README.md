# Interface de Colaboração com Claude

**Faça o Claude Code lembrar quem você é.**

Toda vez que você abre o Claude Code, ele começa do zero. Não sabe seu nome, seu projeto, como você gosta de trabalhar, nem o que vocês conversaram ontem. Você se explica de novo. Toda. Santa. Vez.

Este framework resolve isso. Você configura uma vez, e a partir daí, sua IA sabe quem você é, o que está construindo e como trabalhar com você — em todas as conversas.

---

## O Que Acontece Quando Você Usa

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  Você clona o repositório e digita /comece-por-aqui             │
│                          │                                      │
│                          ▼                                      │
│               ┌─────────────────────┐                           │
│               │  A IA te entrevista  │                           │
│               │   (5 perguntas)      │                           │
│               └─────────┬───────────┘                           │
│                          │                                      │
│           "Quem é você? O que está construindo?                 │
│            Como você trabalha? O que te irrita?                 │
│            Como devo me chamar?"                                │
│                          │                                      │
│                          ▼                                      │
│               ┌─────────────────────┐                           │
│               │  Ela constrói sua   │                           │
│               │  IA personalizada   │                           │
│               └─────────┬───────────┘                           │
│                          │                                      │
│            Identidade, personalidade, memória,                  │
│            regras de comportamento — tudo a                     │
│            partir das suas respostas.                           │
│                          │                                      │
│                          ▼                                      │
│               ┌─────────────────────┐                           │
│               │  Pronto. Sua IA     │                           │
│               │  te conhece agora.  │                           │
│               └─────────────────────┘                           │
│                                                                 │
│  Na próxima vez, digite /iniciar e tudo estará lá.              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Antes e Depois

| Sem este framework | Com este framework |
|---|---|
| "Sou um desenvolvedor backend trabalhando em..." (toda sessão) | A IA já sabe seu papel e sua experiência |
| "Por favor, não adicione comentários em código que eu não alterei" (de novo) | A IA lembra suas preferências desde o primeiro dia |
| "Onde paramos ontem?" | A IA retoma exatamente de onde parou |
| Respostas genéricas, iguais pra todo mundo | Personalidade e comportamento sob medida pra você |
| Toda conversa é uma folha em branco | Toda conversa constrói sobre a anterior |

## Como Funciona

O framework tem quatro componentes:

**Identidade (CLAUDE.md)** — Um arquivo que define o nome, a personalidade e as regras da sua IA. Pense nisso como uma constituição: "Ao revisar código, seja direto. Ao ensinar, use analogias. Nunca adicione funcionalidades que eu não pedi." O Claude Code lê esse arquivo automaticamente.

**Memória** — Arquivos que persistem entre conversas. Seu papel, preferências, contexto do projeto e decisões. A IA lê tudo silenciosamente no início da sessão — sem precisar se repetir.

**Skills** — Comandos personalizados para fluxos de trabalho repetíveis. Digite `/iniciar` para começar uma sessão (a IA carrega tudo e te cumprimenta). Digite `/ate-a-proxima` para encerrar (a IA salva o estado e se despede). Você pode criar os seus próprios para qualquer fluxo que repita.

**Troca de Arquivos** — Um protocolo simples de pastas. Coloque arquivos na `entrada/` para a IA processar. Ela entrega os resultados na `saida/`. Sem copiar e colar.

---

## Início Rápido

```bash
git clone https://github.com/jocsaacesar/interface-de-colaboracao.git
cd interface-de-colaboracao
```

Abra o Claude Code nessa pasta e digite:

```
/comece-por-aqui
```

Nenhuma configuração prévia necessária. A IA vai te guiar por tudo.

> **O que isso faz no seu sistema:** Tudo fica dentro da pasta do projeto. Skills, memórias e arquivos de identidade são todos locais. Nada é instalado globalmente. Sua configuração existente do Claude Code não é afetada. Veja [O Que Muda no Seu Sistema](#o-que-muda-no-seu-sistema) para detalhes.

---

## Ciclo de Vida da Sessão

Uma vez configurado, cada sessão de trabalho segue este fluxo:

```
/iniciar                    Início — IA carrega identidade, memória, skills.
    │                       Te cumprimenta no personagem. Pronta pra trabalhar.
    ▼
[ seu trabalho ]            Você trabalha normalmente. A IA se comporta de
    │                       acordo com a personalidade e regras que você definiu.
    ▼
/tornar-publico (opcional)  Se quiser compartilhar seu trabalho publicamente,
    │                       isso sanitiza dados pessoais antes.
    ▼
/ate-a-proxima              Encerramento — IA salva o estado, atualiza memória,
                            se despede. Próxima sessão retoma daqui.
```

| Comando | Quando | O que faz |
|---------|--------|-----------|
| `/comece-por-aqui` | Uma vez, após clonar | Te entrevista e constrói sua IA personalizada. |
| `/iniciar` | Início de cada sessão | Carrega tudo. A IA chega pronta. |
| `/tornar-publico` | Quando tiver trabalho pra compartilhar | Sanitiza dados pessoais antes de publicar. |
| `/ate-a-proxima` | Final de cada sessão | Salva o estado e encerra de forma limpa. |

---

## O Que Muda no Seu Sistema

**Isso é importante.** Queremos que você se sinta seguro usando este framework.

### Tudo é local

- Todos os arquivos (identidade, memórias, skills) ficam **dentro da pasta do seu projeto**.
- Nada é instalado na sua configuração global do Claude Code.
- Nada modifica `~/.claude/` a menos que você escolha explicitamente sincronizar memórias lá (o `/comece-por-aqui` pergunta antes de fazer isso).
- Seus fluxos de trabalho existentes no Claude Code, outros projetos e configurações globais **não são afetados**.

### Sem conflitos com configurações existentes

- Se você já tem um `CLAUDE.md` no seu projeto, o onboarding vai **mostrar o novo e pedir aprovação** antes de sobrescrever.
- Skills só funcionam dentro da pasta deste projeto. Não existem fora dela.
- Arquivos de memória são limitados ao projeto. Não vazam para outros projetos.

### Como remover

Quer parar de usar? Delete a pasta do projeto. Pronto. Não tem nada pra desinstalar, nenhum estado global pra limpar, nenhuma configuração residual.

Se você sincronizou memórias para `~/.claude/projects/`, delete essa pasta específica também:
```bash
rm -rf ~/.claude/projects/<pasta-do-seu-projeto>/memory/
```

---

## Indo Mais Fundo

- **[Glossário de Skills](GLOSSARIO_DE_SKILLS.md)** — Guia detalhado de cada skill: o que faz, o que esperar, o que nunca fará.
- **[Guias](guias/)** — Como criar um CLAUDE.md, criar skills, usar o sistema de memória.
- **[Modelos](modelos/)** — Arquivos iniciais para montar sua própria configuração do zero.
- **[Exemplos](exemplos/leland/)** — Uma implementação real e funcional (sanitizada) como referência.
- **[Contribuindo](CONTRIBUTING.md)** — Como contribuir para este projeto.

## Estrutura do Projeto

<details>
<summary>Clique para expandir a árvore de arquivos</summary>

```
├── CLAUDE.md                           # Arquivo de identidade (a constituição da IA)
├── README.md                           # Você está aqui
├── JOURNAL.md                          # Decisões e aprendizados
├── GLOSSARIO_DE_SKILLS.md              # Guia do usuário para todas as skills
├── SECURITY.md                         # Política de segurança
├── LICENSE                             # Licença MIT
├── CONTRIBUTING.md                     # Como contribuir
├── CODE_OF_CONDUCT.md                  # Código de conduta
├── guias/
│   ├── claude-md.md                    # Como criar um CLAUDE.md eficaz
│   ├── skills.md                       # Como criar e organizar skills
│   └── memoria.md                      # Como usar o sistema de memória
├── modelos/
│   ├── CLAUDE.md                       # Modelo inicial de identidade
│   ├── skill-modelo/SKILL.md           # Modelo inicial de skill
│   └── modelo-de-memoria.md            # Modelo inicial de memória
├── exemplos/
│   └── leland/                         # Implementação de referência sanitizada
├── .github/                            # Templates de issues e PRs
├── .claude/skills/                     # Definições de skills (locais ao projeto)
├── memoria/                            # Arquivos de memória pessoal (no gitignore)
└── troca/                              # Protocolo de troca de arquivos (no gitignore)
```

</details>

## O Exemplo Vivo

Este repositório é o framework *e* uma implementação funcional ao mesmo tempo. O `CLAUDE.md` na raiz define **Leland Hawkins** — uma IA com personalidade de mentor e três vozes contextuais (pragmático, provocador, didático). As skills, guias e o diário são todos usados ativamente.

O conteúdo pessoal (memórias, arquivos de troca) está no gitignore. Versões sanitizadas ficam em [exemplos/leland/](exemplos/leland/) para que você veja como funciona sem que os dados de ninguém sejam expostos.

## Origem

Criado por **Joc** durante o desenvolvimento do Jiim Hawkins — um projeto de agente de IA pessoal. A interface de colaboração surgiu como um artefato valioso por si só.

**Repositório:** [github.com/jocsaacesar/interface-de-colaboracao](https://github.com/jocsaacesar/interface-de-colaboracao)

## Contribuindo

Contribuições são bem-vindas. Leia [CONTRIBUTING.md](CONTRIBUTING.md) antes de enviar um PR. Este projeto segue um [Código de Conduta](CODE_OF_CONDUCT.md).

## Licença

[MIT](LICENSE)

---

> "Uma ferramenta é tão boa quanto a mão que a molda — e a intenção por trás da moldagem."
