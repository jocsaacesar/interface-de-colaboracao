# Mnemosine — Interface de Colaboração com Claude

> **Nunca programou? Sem problema.** Este guia rápido te leva do zero até uma IA que te conhece. Se travar em qualquer passo, cola o erro no Claude que ele te ajuda.
>
> **Já programa?** Pule direto para [Como funciona](#como-funciona).

---

## Guia para quem nunca programou

Você não precisa saber programar para usar isto. Precisa apenas seguir estes passos — e se algo der errado, o próprio Claude te ajuda a resolver.

**Site com tutorial completo:** [mnemosine.ia.br](https://mnemosine.ia.br)

### 1. Instale o Node.js

O Claude Code precisa de um programa chamado Node.js para funcionar. Você instala uma vez e esquece.

1. Acesse **[nodejs.org](https://nodejs.org)**
2. Clique no botão grande escrito **LTS** (é a versão recomendada)
3. Abra o arquivo baixado e siga a instalação normal (avançar, avançar, concluir)

### 2. Instale o Claude Code

Abra o **Terminal** do seu computador:
- **Windows:** procure por "Terminal" ou "Prompt de Comando" no menu Iniciar
- **Mac:** procure por "Terminal" no Spotlight (Cmd + Espaço)

Copie e cole este comando e aperte Enter:

```bash
npm install -g @anthropic-ai/claude-code
```

> Na primeira vez, o Claude Code vai pedir que você faça login com sua conta da Anthropic. Siga as instruções na tela.

### 3. Baixe este projeto

Ainda no GitHub (esta página), faça assim:

1. Clique no botão verde **"<> Code"** no canto superior direito
2. Na aba **HTTPS**, clique no icone de copiar ao lado do link
3. Volte ao Terminal e cole este comando (trocando o link se necessário):

```bash
git clone https://github.com/jocsaacesar/mnemosine.git
```

**Não tem o Git instalado?** Sem problema — clique em **"Download ZIP"** no mesmo botão verde, descompacte a pasta onde preferir.

### 4. Abra o Claude Code na pasta do projeto

No Terminal, entre na pasta que acabou de baixar:

```bash
cd mnemosine
```

E depois inicie o Claude:

```bash
claude
```

### 5. Pronto — o Claude faz o resto

Quando o Claude abrir, ele já sabe o que fazer. Diga "oi", "bom dia", ou qualquer coisa — o processo de configuração começa automaticamente. Ele vai te fazer algumas perguntas para te conhecer e criar uma IA personalizada para você. Leva uns 5-10 minutos.

**Deu erro em qualquer passo?** Copie a mensagem de erro e cole no Claude. Ele vai entender o problema e te guiar na solução — você não precisa saber o que o erro significa.

---

> **A partir daqui, o conteúdo é voltado para quem já tem familiaridade com desenvolvimento.**

---

**E se a sua IA lembrasse quem você é?**

Pense na melhor conversa que você já teve com alguém. Não precisou explicar quem era, o que fazia, nem por que pensava daquele jeito. A pessoa já sabia. E por isso, a conversa foi *sobre o que importava* — não sobre contexto.

Agora pense em como você usa inteligência artificial. O [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) — o assistente de IA da Anthropic que funciona direto no seu computador — já tem recursos como memória e leitura de arquivos de configuração. Mas a cada nova conversa, muita coisa se perde. As preferências sutis que você levou sessões pra calibrar. As decisões que vocês tomaram juntos ontem. O tom que finalmente estava do jeito certo. A IA sabe *sobre* o projeto, mas não sabe *sobre você*. E essa diferença é o que separa uma ferramenta útil de uma colaboração real.

Este framework preenche essa lacuna. Não é uma lista de prompts. Não é um truque. É uma **arquitetura de relacionamento** entre você e sua IA — com identidade, memória estruturada e comportamento que persistem de verdade entre conversas.

Você configura uma vez. A partir daí, ela te conhece.

---

## Como funciona

Quando você abre este projeto no Claude Code, ele te faz cinco perguntas — como numa conversa, não num formulário:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  Você abre o projeto e segue as instruções do primeiro uso      │
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
│  Na próxima conversa, digite /iniciar e tudo estará lá.         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

A IA reage às suas respostas, faz follow-up, e no final te mostra o resultado para aprovação antes de salvar qualquer coisa. Você tem controle total.

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

Um arquivo de configuração que funciona como a **constituição** da sua IA. Nele você define nome, personalidade e regras de comportamento. "Ao revisar código, seja direto. Ao ensinar, use analogias. Nunca adicione funcionalidades que eu não pedi."

O Claude Code lê esse arquivo automaticamente. A configuração inicial cria o seu — personalizado a partir das suas respostas.

### Memória

Arquivos que persistem entre conversas. Seu papel, suas preferências, o contexto do projeto, as decisões que vocês tomaram juntos. A IA lê tudo silenciosamente no início de cada sessão. Você nunca mais precisa se repetir.

É como trabalhar com alguém que anota o que importa — e relê as anotações antes de cada reunião.

### Skills

Comandos que automatizam fluxos de trabalho inteiros. Em vez de digitar 15 instruções toda vez que abre uma sessão, você digita `/iniciar` e a IA carrega identidade, memória e contexto em um segundo. Em vez de lembrar de salvar o estado antes de fechar, você digita `/ate-a-proxima` e ela cuida de tudo.

Pense em skills como rituais produtivos. Você faz a mesma coisa toda vez, do mesmo jeito, e por isso funciona.

### Troca de arquivos

Um protocolo simples de pastas. Coloque arquivos na pasta de entrada para a IA processar. Ela entrega resultados na pasta de saída. Sem copiar, sem colar, sem perder contexto no meio do caminho.

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
| `/comece-por-aqui` | Uma vez, na configuração inicial | Te entrevista e constrói sua IA personalizada. |
| `/iniciar` | Início de cada sessão | Carrega tudo. A IA chega pronta. |
| `/ate-a-proxima` | Final de cada sessão | Salva o estado e encerra de forma limpa. |
| `/criar-skill` | Quando quiser criar uma nova skill | Entrevista guiada que gera a automação completa. |
| `/marketplace` | Quando quiser descobrir skills extras | Mostra o catálogo, recomenda e ativa com um comando. |

---

## A história por trás

Este framework nasceu por acidente. **Joc** estava construindo o Jiim Hawkins — um projeto ambicioso de agente de IA pessoal. E no processo de preparar o ambiente de trabalho com o Claude Code, percebeu algo: *a preparação era o produto*.

O jeito como você configura identidade, memória e comportamento para uma IA não é um passo preliminar — é a coisa em si. É o que separa usar IA como um buscador glorificado de usar IA como um instrumento que evolui com você.

Um músico não compra um instrumento e sai tocando. Ele afina. Aprende os vícios. Desenvolve um relacionamento com o que o instrumento faz bem e onde ele resiste. Essa afinação é o que este repositório documenta.

E o mais bonito: o repositório é o framework *e* o exemplo vivo ao mesmo tempo. A documentação técnica explica como tudo funciona. Os exemplos mostram uma implementação real, sanitizada. As skills, o diário, os guias — todos são usados ativamente, não foram escritos para vitrine.

---

## Marketplace — expandindo suas skills

As 5 skills que vêm com o framework cobrem o essencial: configurar, abrir, fechar, criar e descobrir. Mas cada pessoa trabalha de um jeito diferente. Alguns precisam de revisão ortográfica. Outros de sanitização de dados pessoais. Outros de coisas que ainda nem imaginamos.

Por isso existe o **marketplace** — um repositório separado com skills extras criadas pela comunidade. Pense nele como uma loja de extensões: você instala só o que faz sentido pra você.

**[github.com/jocsaacesar/interface-colaboracao-skills](https://github.com/jocsaacesar/interface-colaboracao-skills)**

### Skills disponíveis hoje

| Skill | O que faz | Pra quem é útil |
|-------|-----------|-----------------|
| `/tornar-publico` | Separa dados pessoais de conteúdo público, sanitiza e prepara para publicação. Nada sai sem sua aprovação. | Quem trabalha em repositórios públicos e precisa proteger dados sensíveis. |
| `/revisar-texto` | Percorre todos os arquivos de documentação do projeto corrigindo ortografia, convenções brasileiras e inconsistências. Correções ambíguas pedem aprovação. | Quem escreve documentação e quer manter consistência e qualidade. |

### Como instalar uma skill

A forma mais simples: digite `/marketplace` numa conversa com a IA. Ela mostra o catálogo, explica cada skill, recomenda as que fazem sentido pro seu perfil, e instala pra você.

<details>
<summary>Instalação manual (linha de comando)</summary>

```bash
# 1. Baixe o marketplace (só precisa fazer uma vez)
git clone https://github.com/jocsaacesar/interface-colaboracao-skills.git marketplace

# 2. Copie a skill que quiser para a pasta de skills ativas
cp -r marketplace/tornar-publico .claude/skills/
```

Pronto. O Claude Code descobre sozinho. Sem reiniciar, sem configurar.

**Para desinstalar:** delete a pasta da skill de dentro de `.claude/skills/`.

**Para atualizar o marketplace:** entre na pasta `marketplace/` e rode `git pull origin main`.

</details>

### Como contribuir com uma skill

Criou uma skill que resolveu um problema real pra você? Provavelmente resolve pra outros também.

1. Faça um fork do [repositório de skills](https://github.com/jocsaacesar/interface-colaboracao-skills).
2. Crie uma pasta com o nome da skill e um arquivo de definição dentro.
3. Abra um PR descrevendo o que ela faz e por que é útil.

Requisitos: documentação em português, sem dados pessoais, e a skill precisa funcionar de forma independente.

---

## Começar agora

São quatro passos. Se você nunca usou um terminal antes, não se preocupe — cada passo tem instruções detalhadas.

### Passo 1 — Instalar o Node.js

O [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) precisa do Node.js pra funcionar. O Node.js é um programa que roda nos bastidores — você instala uma vez e não precisa pensar nele de novo.

Acesse **[nodejs.org](https://nodejs.org)**, baixe a versão **LTS** (a recomendada) e siga a instalação padrão. No Windows, é um instalador comum de "avançar, avançar, concluir". No Mac, idem.

<details>
<summary>Como verificar se já tem o Node.js instalado</summary>

Abra o terminal (no Windows, procure por "Terminal" ou "Prompt de Comando"; no Mac, procure por "Terminal") e digite:

```bash
node --version
```

Se aparecer algo como `v20.11.0`, você já tem. Se der erro, instale pelo site acima.

</details>

### Passo 2 — Instalar o Claude Code

Com o Node.js instalado, abra o terminal e digite:

```bash
npm install -g @anthropic-ai/claude-code
```

Esse comando instala o Claude Code no seu computador. Depois disso, o comando `claude` fica disponível no terminal.

> **Primeira vez usando?** Na primeira execução, o Claude Code vai pedir que você faça login com sua conta da Anthropic. Siga as instruções na tela — é um processo de autenticação único.

<details>
<summary>Documentação oficial completa</summary>

Para opções avançadas de instalação, configuração e solução de problemas, consulte a [documentação oficial do Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview).

</details>

### Passo 3 — Baixar este projeto

Você tem duas opções:

**Opção A — Pelo terminal** (se tiver o Git instalado):
```bash
git clone https://github.com/jocsaacesar/mnemosine.git
cd mnemosine
```

**Opção B — Pelo navegador** (sem precisar do Git):
1. Acesse o [repositório no GitHub](https://github.com/jocsaacesar/mnemosine)
2. Clique no botão verde **"Code"** e depois em **"Download ZIP"**
3. Descompacte a pasta onde preferir

### Passo 4 — Configurar sua IA

Abra o terminal **dentro da pasta do projeto** e digite:

```bash
claude
```

O Claude detecta automaticamente que é o primeiro uso e inicia o onboarding sozinho. Diga qualquer coisa ("oi", "começar") e ele conduz a entrevista, cria a identidade, memórias iniciais e configura as skills. Leva uns 5-10 minutos.

> **Importante:** Tudo que é criado fica dentro da pasta do projeto. A única exceção é a skill `/iniciar`, que o Claude vai te pedir autorização para instalar na sua pasta pessoal — isso é o que permite usá-la em qualquer projeto. Totalmente opcional. Veja [Segurança e escopo](#segurança-e-escopo) para detalhes.

<details>
<summary>Já tem um projeto rodando? Não clone por cima</summary>

Se você já tem um repositório com código, `.gitignore`, `README.md` e tudo mais — **não clone este repositório por cima**.

O framework foi pensado pra coexistir com projetos existentes, mas precisa de um cuidado que um clone direto não dá: separar o que é do framework do que é do seu projeto.

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

</details>

---

## Segurança e escopo

Quando alguém te pede para baixar um projeto e rodar comandos, é justo perguntar: *"o que isso faz na minha máquina?"*

A resposta aqui é simples.

**Tudo fica dentro da pasta do projeto.** Identidade, memórias, skills — nada sai dessa pasta. O Claude Code descobre as skills automaticamente quando abre o projeto. Não há instalação global.

A **única exceção** é a skill `/iniciar`, que durante a configuração o Claude oferece instalar na sua pasta pessoal — com sua autorização explícita. É um único arquivo de texto. Se recusar, tudo funciona normalmente dentro do projeto; o `/iniciar` só não será global.

Nada modifica outros projetos, outros workflows, outras configurações.

**Para desinstalar:** delete a pasta do projeto. Pronto.

<details>
<summary>Detalhes técnicos de limpeza</summary>

Se instalou a skill `/iniciar` globalmente durante o onboarding:
```bash
rm -rf ~/.claude/skills/iniciar/
```

Se sincronizou memórias para `~/.claude/projects/`:
```bash
rm -rf ~/.claude/projects/<pasta-do-seu-projeto>/memory/
```

</details>

---

## Indo mais fundo

- **[Glossário de Skills](GLOSSARIO_DE_SKILLS.md)** — Cada skill explicada em detalhe: o que faz, o que esperar, o que nunca fará.
- **[Primeiro uso](PRIMEIRO-USO.md)** — Ponto de entrada do onboarding. O Claude lê e conduz tudo.
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
├── CLAUDE.md                           # Sua identidade (gerado pelo onboarding)
├── CLAUDE-IC.md                        # Documentação do framework
├── PRIMEIRO-USO.md                     # Ponto de entrada — o Claude lê e conduz o setup
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
├── memoria/                            # Seus arquivos de memória (privado)
├── estudos/                            # Resumos pessoais de estudo (privado)
└── troca/                              # Troca de arquivos (privado)
```

</details>

---

## Contribuindo

Contribuições são bem-vindas. Leia [CONTRIBUTING.md](CONTRIBUTING.md) antes de enviar um PR. Este projeto segue um [Código de Conduta](CODE_OF_CONDUCT.md).

## Licença

[MIT](LICENSE)

**Repositório:** [github.com/jocsaacesar/mnemosine](https://github.com/jocsaacesar/mnemosine)

---

> *"A diferença entre usar uma ferramenta e ter um relacionamento com ela é simples: o relacionamento tem memória."*
