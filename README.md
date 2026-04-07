# Interface de Colaboração com Claude

**E se a sua IA lembrasse quem você é?**

Pense na melhor conversa que você já teve com alguém. Não precisou explicar quem era, o que fazia, nem por que pensava daquele jeito. A pessoa já sabia. E por isso, a conversa foi *sobre o que importava* — não sobre contexto.

Agora pense em como você usa o Claude Code. Ele não começa *exatamente* do zero — lê o CLAUDE.md do projeto, tem um sistema básico de memória, entende o contexto dos arquivos. Mas a cada nova conversa, muita coisa se perde. As preferências sutis que você levou sessões pra calibrar. As decisões que vocês tomaram juntos ontem. O tom que finalmente estava do jeito certo. A IA sabe *sobre* o projeto, mas não sabe *sobre você*. E essa diferença é o que separa uma ferramenta útil de uma colaboração real.

Este framework preenche essa lacuna. Não é uma lista de prompts. Não é um truque. É uma **arquitetura de relacionamento** entre você e sua IA — com identidade, memória estruturada e comportamento que persistem de verdade entre conversas.

Você configura uma vez. A partir daí, ela te conhece.

---

## Como funciona — em 5 minutos

Quando você clona este repositório e abre o Claude Code, todas as skills já estão disponíveis automaticamente — o Claude Code descobre elas sozinho na pasta `.claude/skills/`. Não precisa instalar nada, não precisa rodar nada antes. É como plugar um instrumento e ele já estar afinado.

Você digita `/comece-por-aqui` e a IA te faz cinco perguntas:

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

Não é um questionário. É uma conversa. A IA reage às suas respostas, faz follow-up, e no final te mostra o resultado para aprovação antes de salvar qualquer coisa.

---

## O que muda na prática

Existe uma diferença enorme entre uma ferramenta que obedece e uma que colabora. A primeira espera comandos. A segunda lembra contexto, respeita preferências e evolui com você.

| Sem este framework | Com este framework |
|---|---|
| "Sou um desenvolvedor backend trabalhando em..." (toda sessão) | A IA já sabe seu papel e sua experiência |
| "Não adicione comentários em código que eu não alterei" (de novo) | A IA lembra suas preferências desde o primeiro dia |
| "Onde paramos ontem?" | A IA retoma exatamente de onde parou |
| Respostas genéricas, iguais pra todo mundo | Personalidade e comportamento sob medida pra você |
| Toda conversa é uma folha em branco | Toda conversa constrói sobre a anterior |

---

## Os quatro pilares

Todo relacionamento funcional tem estrutura. Este framework se apoia em quatro:

### Identidade

Um arquivo chamado `CLAUDE.md` que funciona como a **constituição** da sua IA. Nele você define nome, personalidade e regras de comportamento. "Ao revisar código, seja direto. Ao ensinar, use analogias. Nunca adicione funcionalidades que eu não pedi."

O Claude Code lê esse arquivo automaticamente. A skill `/comece-por-aqui` cria o seu — personalizado a partir das suas respostas. O repositório nunca sobrescreve um `CLAUDE.md` que já exista.

### Memória

Arquivos que persistem entre conversas. Seu papel, suas preferências, o contexto do projeto, as decisões que vocês tomaram juntos. A IA lê tudo silenciosamente no início de cada sessão. Você nunca mais precisa se repetir.

É como trabalhar com alguém que anota o que importa — e relê as anotações antes de cada reunião.

### Skills

Comandos que automatizam fluxos de trabalho inteiros. Em vez de digitar 15 instruções toda vez que abre uma sessão, você digita `/iniciar` e a IA carrega identidade, memória e contexto em um segundo. Em vez de lembrar de salvar o estado antes de fechar, você digita `/ate-a-proxima` e ela cuida de tudo.

Pense em skills como rituais produtivos. Você faz a mesma coisa toda vez, do mesmo jeito, e por isso funciona.

### Troca de arquivos

Um protocolo simples de pastas. Coloque arquivos na `entrada/` para a IA processar. Ela entrega resultados na `saida/`. Sem copiar, sem colar, sem perder contexto no meio do caminho.

---

## Início rápido

```bash
git clone https://github.com/jocsaacesar/interface-de-colaboracao.git
cd interface-de-colaboracao
```

Abra o Claude Code nessa pasta e digite:

```
/comece-por-aqui
```

Nenhuma configuração prévia. Nenhuma instalação. As skills já estão na pasta do projeto e o Claude Code as descobre sozinho. Você clona, abre e usa.

> **O comando não foi reconhecido?** Em algumas máquinas, a auto-descoberta de skills pode não funcionar na primeira abertura. Veja [PRIMEIRO-USO.md](PRIMEIRO-USO.md) para resolver em 1 minuto.

> **Importante:** Tudo fica dentro da pasta do projeto. Nada é instalado globalmente. Sua configuração existente do Claude Code não é afetada. Veja [Segurança e Escopo](#segurança-e-escopo) para detalhes.

---

## Já tem um projeto rodando?

Se você não está começando do zero — se já tem um repositório com código, `.gitignore`, `README.md` e tudo mais — **não clone este repositório por cima**.

O framework foi pensado pra coexistir com projetos existentes, mas precisa de um cuidado que um `git clone` direto não dá: separar o que é do framework do que é do seu projeto.

Na prática, você só precisa de **duas coisas**:
1. A pasta `.claude/skills/` (as skills)
2. Algumas linhas no seu `.gitignore` (pra proteger dados pessoais)

Todo o resto — README, LICENSE, guias, exemplos — é documentação do framework e não vai pro seu projeto.

**[Guia completo de instalação em projeto existente →](guias/instalacao-projeto-existente.md)**

O guia cobre:
- Exatamente o que copiar e o que ignorar
- Como fazer merge no `.gitignore` sem sobrescrever
- O que fazer se você já tem um `CLAUDE.md`
- Como desinstalar sem deixar resíduo

---

## O ritmo de uma sessão

Uma vez configurado, cada sessão de trabalho segue um ritmo natural — como abrir e fechar um caderno:

```
/iniciar                    Abertura — IA carrega quem ela é, o que sabe
    │                       sobre você, e te cumprimenta. Pronta.
    ▼
[ seu trabalho ]            Você trabalha normalmente. A IA se comporta
    │                       como vocês combinaram.
    ▼
/ate-a-proxima              Fechamento — IA salva o estado, atualiza a
                            memória, se despede. Amanhã retoma daqui.
```

### Skills incluídas

| Comando | Quando | O que faz |
|---------|--------|-----------|
| `/comece-por-aqui` | Uma vez, após clonar | Te entrevista e constrói sua IA personalizada. |
| `/iniciar` | Início de cada sessão | Carrega tudo. A IA chega pronta. |
| `/ate-a-proxima` | Final de cada sessão | Salva o estado e encerra de forma limpa. |
| `/criar-skill` | Quando quiser criar uma nova skill | Entrevista guiada que gera o SKILL.md completo. |
| `/marketplace` | Quando quiser descobrir skills extras | Mostra o catálogo, recomenda e ativa com um comando. |

---

## Marketplace — expandindo suas skills

As 5 skills que vêm com o framework cobrem o essencial: configurar, abrir, fechar, criar e descobrir. Mas cada pessoa trabalha de um jeito diferente. Alguns precisam de revisão ortográfica. Outros de sanitização de dados pessoais. Outros de coisas que ainda nem imaginamos.

Por isso existe o **marketplace** — um repositório separado com skills extras criadas pela comunidade. Pense nele como uma loja de extensões: você instala só o que faz sentido pra você.

**[github.com/jocsaacesar/interface-colaboracao-skills](https://github.com/jocsaacesar/interface-colaboracao-skills)**

### Skills disponíveis hoje

| Skill | O que faz | Pra quem é útil |
|-------|-----------|-----------------|
| `/tornar-publico` | Separa dados pessoais de conteúdo público, sanitiza e prepara para publicação. Nada sai sem sua aprovação. | Quem trabalha em repositórios públicos e precisa proteger dados sensíveis. |
| `/revisar-texto` | Percorre todos os .md do projeto corrigindo ortografia, convenções brasileiras e inconsistências. Correções ambíguas pedem aprovação. | Quem escreve documentação e quer manter consistência e qualidade. |

### Como instalar uma skill

Existem duas formas:

**Pela conversa (recomendado):** Digite `/marketplace`. A IA mostra o catálogo, explica cada skill, recomenda as que fazem sentido pro seu perfil, e instala com um comando. Se o marketplace não estiver baixado, ela oferece fazer o clone pra você.

**Manualmente:**

```bash
# 1. Baixe o marketplace (só precisa fazer uma vez)
git clone https://github.com/jocsaacesar/interface-colaboracao-skills.git marketplace

# 2. Copie a skill que quiser para a pasta de skills ativas
cp -r marketplace/tornar-publico .claude/skills/
```

Pronto. O Claude Code descobre sozinho. Sem reiniciar, sem configurar.

### Como desinstalar uma skill

Delete a pasta de dentro de `.claude/skills/`:

```bash
rm -rf .claude/skills/tornar-publico
```

A skill deixa de existir. Sem efeitos colaterais, sem resíduos. Se mudar de ideia, instale de novo.

### Como receber novas skills

A comunidade pode contribuir com skills a qualquer momento. Para atualizar seu marketplace local:

```bash
cd marketplace
git pull origin main
```

As novas skills aparecem na pasta. Ative as que quiser com o mesmo `cp -r`.

### Como contribuir com uma skill

Criou uma skill que resolveu um problema real pra você? Provavelmente resolve pra outros também.

1. Faça um fork do [repositório de skills](https://github.com/jocsaacesar/interface-colaboracao-skills).
2. Crie uma pasta com o nome da skill e um `SKILL.md` dentro.
3. Abra um PR descrevendo o que ela faz e por que é útil.

Requisitos: documentação em português, sem dados pessoais, e a skill precisa funcionar de forma independente.

---

## Segurança e escopo

Quando alguém te pede para clonar um repositório e rodar comandos, é justo perguntar: *"o que isso faz na minha máquina?"*

A resposta aqui é simples.

### Tudo é local ao projeto

- Todos os arquivos — identidade, memórias, skills — ficam **dentro da pasta do projeto**. Ponto.
- Nada é instalado na sua configuração global do Claude Code (`~/.claude/`).
- Nada modifica outros projetos, outros workflows, outras configurações.
- O Claude Code descobre as skills automaticamente quando abre a pasta. Não há instalação.

### Convivência com projetos existentes

- O repositório envia um `CLAUDE.md` placeholder — o `/comece-por-aqui` o substitui com o seu.
- A documentação do framework vive em `CLAUDE-IC.md`, separada da sua identidade.
- Skills só existem dentro desta pasta. Fora dela, é como se não existissem.
- Se você já tem um projeto com `.gitignore`, `README.md` ou `CLAUDE.md`, **não clone por cima** — use o [guia de instalação em projeto existente](guias/instalacao-projeto-existente.md).

### Como desinstalar

Delete a pasta. Pronto. Não tem nada pra desinstalar, nenhum estado global, nenhuma configuração residual.

Se sincronizou memórias para `~/.claude/projects/`:
```bash
rm -rf ~/.claude/projects/<pasta-do-seu-projeto>/memory/
```

---

## Indo mais fundo

- **[Glossário de Skills](GLOSSARIO_DE_SKILLS.md)** — Cada skill explicada em detalhe: o que faz, o que esperar, o que nunca fará.
- **[Primeiro uso](PRIMEIRO-USO.md)** — Se as skills não funcionarem na primeira abertura.
- **[Instalação em projeto existente](guias/instalacao-projeto-existente.md)** — O que copiar, o que ignorar, como evitar conflitos.
- **[Marketplace](https://github.com/jocsaacesar/interface-colaboracao-skills)** — Skills opcionais criadas pela comunidade.
- **[Guias](guias/)** — Como criar um CLAUDE.md, projetar skills, usar o sistema de memória.
- **[Modelos](modelos/)** — Arquivos iniciais para montar do zero.
- **[Exemplos](exemplos/leland/)** — Uma implementação real, sanitizada, como referência.
- **[CLAUDE-IC.md](CLAUDE-IC.md)** — Documentação técnica completa do framework.
- **[Contribuindo](CONTRIBUTING.md)** — Como contribuir para este projeto.

<details>
<summary>Estrutura do projeto (clique para expandir)</summary>

```
├── CLAUDE.md                           # Sua identidade (gerado pelo /comece-por-aqui)
├── CLAUDE-IC.md                        # Documentação do framework
├── README.md                           # Você está aqui
├── JOURNAL.md                          # Decisões e aprendizados
├── GLOSSARIO_DE_SKILLS.md              # Guia do usuário para todas as skills
├── SECURITY.md                         # Política de segurança
├── LICENSE                             # Licença MIT
├── CONTRIBUTING.md                     # Como contribuir
├── CODE_OF_CONDUCT.md                  # Código de conduta
├── guias/                              # Como usar cada componente
├── modelos/                            # Arquivos iniciais para seu projeto
├── exemplos/                           # Implementação de referência
├── .claude/skills/                     # Skills core (locais ao projeto)
├── memoria/                            # Seus arquivos de memória (no gitignore)
└── troca/                              # Troca de arquivos (no gitignore)
```

</details>

---

## A história por trás

Este framework nasceu por acidente. **Joc** estava construindo o Jiim Hawkins — um projeto ambicioso de agente de IA pessoal. E no processo de preparar o ambiente de trabalho com o Claude Code, percebeu algo: *a preparação era o produto*.

O jeito como você configura identidade, memória e comportamento para uma IA não é um passo preliminar — é a coisa em si. É o que separa usar IA como um buscador glorificado de usar IA como um instrumento que evolui com você.

Um músico não compra um instrumento e sai tocando. Ele afina. Aprende os vícios. Desenvolve um relacionamento com o que o instrumento faz bem e onde ele resiste. Essa afinação é o que este repositório documenta.

E o mais bonito: o repositório é o framework *e* o exemplo vivo ao mesmo tempo. O `CLAUDE-IC.md` documenta como tudo funciona. O `exemplos/leland/` mostra uma implementação real, sanitizada. As skills, o diário, os guias — todos são usados ativamente, não foram escritos para vitrine.

**Repositório:** [github.com/jocsaacesar/interface-de-colaboracao](https://github.com/jocsaacesar/interface-de-colaboracao)

---

## Contribuindo

Contribuições são bem-vindas. Leia [CONTRIBUTING.md](CONTRIBUTING.md) antes de enviar um PR. Este projeto segue um [Código de Conduta](CODE_OF_CONDUCT.md).

## Licença

[MIT](LICENSE)

---

> *"A diferença entre usar uma ferramenta e ter um relacionamento com ela é simples: o relacionamento tem memória."*
