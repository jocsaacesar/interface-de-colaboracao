# Mnemósine

## E se sua IA lembrasse quem você é?

Você abre o terminal. Digita `claude`. E começa a explicar — de novo — o que está fazendo, por que está fazendo, como gosta que o código fique, o que já tentou e não funcionou. Toda sessão é uma primeira vez. Toda conversa começa do zero.

Não precisava ser assim.

Mnemósine é um framework para o [Claude Code](https://claude.ai/code) que transforma a relação entre você e sua IA de **assistente descartável** em **parceria com continuidade**. Não é um plugin. Não é uma extensão. É uma estrutura de arquivos — markdown puro — que vive dentro do seu repositório e dá à sua IA três coisas que ela não tem sozinha:

**Memória.** Ela sabe quem você é, o que já construíram juntos, e o que deu errado da última vez.

**Identidade.** Ela tem nome, personalidade, regras de comportamento. Não é uma caixa de texto — é alguém que sabe quando te desafiar e quando executar.

**Disciplina.** Ela segue processos. Audita código contra regras com ID. Registra erros em protocolo de 4 arquivos. Não repete os mesmos erros.

---

## O problema que ninguém fala

A maioria dos desenvolvedores usa IA como um Google que escreve código. Pergunta, copia, esquece. Na próxima sessão, a IA não sabe que você prefere composição sobre herança, que seu projeto usa português nos commits, que na semana passada um `apt install` sem `--no-install-recommends` derrubou o servidor.

O modelo de linguagem é brilhante. O que falta não é inteligência — é **contexto persistente**. E contexto não é só memória técnica. É saber que você é sênior e não precisa de explicações básicas. É saber que você gosta de ser desafiado quando pede algo mal pensado. É saber que aquele arquivo foi refatorado ontem e não precisa ser lido de novo.

Mnemósine resolve isso sem mágica. Sem banco de dados. Sem API externa. Só arquivos markdown no seu repositório que o Claude Code já sabe ler.

---

## Como funciona

Quando você instala a Mnemósine, seu projeto ganha uma estrutura simples:

```
.claude/skills/          ← Receitas que a IA segue (10 prontas pra usar)
memoria/                 ← O que a IA lembra entre sessões
aprendizado/             ← O que deu errado e como prevenir
padroes-minimos/         ← Regras auditáveis com ID e severidade
planos/                  ← Gestão de trabalho (backlog, operacional, emergencial)
CLAUDE.md                ← Quem a IA é (identidade, regras, estado)
```

Nada é instalado globalmente. Nada toca seu sistema. Tudo vive no repositório, versionado, visível, editável.

### O ciclo de uma sessão

```
/iniciar              → A IA carrega identidade, memórias, erros passados, estado dos planos
                        Ela sabe quem você é antes de você falar qualquer coisa

[você trabalha]       → A IA segue regras, audita código, registra decisões

/ate-a-proxima        → A IA salva o estado, sincroniza memórias, audita a sessão
                        Amanhã ela começa de onde parou
```

Não é automação. É continuidade.

---

## O que muda no seu dia a dia

**Sem Mnemósine:** Você explica. A IA obedece. Você revisa. Repete amanhã.

**Com Mnemósine:**

- Você abre o terminal e a IA já sabe que tem 2 planos operacionais atrasados e 1 bug no backlog.
- Você pede uma feature e ela cria um plano antes de escrever código — porque a skill de planejamento exige isso.
- Ela audita o próprio código contra 250+ regras antes de te entregar — PHP, segurança, testes, OOP, frontend, cada uma com ID e severidade.
- Quando erra, registra o incidente em 4 arquivos (o que aconteceu, por que aconteceu, o que corrigiu, como prevenir). Na próxima vez que tocar naquela área, ela consulta o histórico antes de agir.
- Quando você está errado, ela diz. Com argumento, com evidência. Porque você configurou ela pra isso.

---

## Instalação

### Projeto existente (uma linha)

```bash
curl -sSL https://raw.githubusercontent.com/jocsaacesar/mnemosine/main/install.sh | bash
```

O instalador oferece três modos:

| Modo | O que instala |
|------|---------------|
| **Completo** | Skills, auditoras, padrões, aprendizado, guias, exemplos |
| **Essencial** | Skills de sessão + aprendizado + memória |
| **Escolher** | Você seleciona componente por componente |

### Projeto novo (template)

Clique em **"Use this template"** no topo desta página e crie seu repositório.

### Depois de instalar

```bash
claude                    # abre o Claude Code
# digite: /comece-por-aqui
```

A IA vai te entrevistar — quem você é, o que constrói, como trabalha, o que evitar — e gerar sua configuração personalizada. Leva 5 minutos. Depois disso, ela é sua.

---

## O que vem dentro

### 10 skills globais

Skills são receitas que a IA segue. Mesmos passos, mesmo resultado, toda vez.

| Skill | O que faz |
|-------|-----------|
| `/iniciar` | Carrega identidade, memórias, estado — a IA acorda sabendo tudo |
| `/ate-a-proxima` | Salva estado, sincroniza memórias — nada se perde |
| `/comece-por-aqui` | Entrevista você e constrói a configuração do zero |
| `/criar-skill` | Cria novas skills por entrevista guiada |
| `/aprendizado-ativo` | Registra incidentes com protocolo de 4 arquivos |
| `/aprovar-pr` | Revisa PR orquestrando auditoras por stack |
| `/telemetria` | Mostra o que a IA fez, quando, e se deu certo |
| `/revisar-texto` | Revisão ortográfica e de convenções |
| `/tornar-publico` | Sanitiza dados pessoais antes de publicar |
| `/marketplace` | Explora skills disponíveis |

### 7 auditoras de código

Cada auditora lê um documento de padrões e aplica regra por regra no seu código. Violações têm ID (`PHP-025`), severidade (ERRO bloqueia, AVISO exige justificativa), e seção "Verifica:" que diz exatamente o que checar.

| Auditora | Stack |
|----------|-------|
| `/auditar-php` | PHP |
| `/auditar-poo` | Orientação a objetos |
| `/auditar-testes` | Testes (unit, integration, API) |
| `/auditar-seguranca` | Segurança (OWASP, sanitização, auth) |
| `/auditar-frontend` | Frontend (HTML, CSS, acessibilidade) |
| `/auditar-js` | JavaScript / TypeScript |
| `/auditar-cripto` | Criptografia |

### 250+ regras auditáveis

8 documentos de padrões mínimos + 1 modelo para criar os seus. Cada regra tem ID único, severidade, explicação do "por quê", e seção de verificação. Não são sugestões — são contratos.

### Pipeline de projeto

4 templates para montar seu fluxo de trabalho:

```
Você pede algo → Gerente orquestra:
    1. Planejadora (interpreta, cria plano)
    2. Executora (escreve código seguindo o plano)
    3. Teste (cria testes contra padrões)
    4. Auditora (audita contra regras da stack)
```

### Sistema de aprendizado

Quando algo dá errado, o `/aprendizado-ativo` cria 4 arquivos:

```
aprendizado/
├── erros/0001-descricao.md              # O que aconteceu
├── contexto-situacao/0001-descricao.md  # Por que aconteceu
├── correcao/0001-descricao.md           # O que corrigiu
└── mitigacao/0001-descricao.md          # Como prevenir
```

A IA consulta esse histórico antes de agir em áreas com incidentes anteriores. Erro documentado vira vacina. Erro repetido vira violação.

---

## De onde veio

Mnemósine nasceu da prática real de uma software house brasileira em 2026. Uma IA operando como gestora de múltiplos projetos — com identidade, 28 incidentes documentados, 250+ regras auditáveis, 10 skills globais, 7 auditoras, e uma constituição interna. Tudo orquestrado por um único humano.

Não é teoria. É o que usamos todo dia. E agora é seu.

---

## Segurança

- Todas as skills são **locais ao projeto**. Nada toca `~/.claude/` globalmente.
- Revise o conteúdo das skills antes de usar — elas orientam comandos no seu ambiente.
- O `/tornar-publico` sanitiza dados pessoais antes de qualquer publicação.
- Para uso global, copie manualmente para `~/.claude/skills/`.

---

## Filosofia

> *Na neurociência, engrama é o traço que uma experiência deixa no cérebro — a marca física que transforma vivência em identidade.*

A maioria das ferramentas de IA trata a interação como descartável. Você pergunta, ela responde, e tudo desaparece. Mnemósine parte de uma premissa diferente: **a qualidade da colaboração é proporcional à profundidade da relação.**

Uma IA que lembra quem você é, que sabe o que deu errado, que segue regras que vocês construíram juntos, que te desafia quando você está errado — essa IA não é mais uma ferramenta. É uma parceira.

E parceria se constrói um tijolo de cada vez.

---

## Licença

MIT — use, modifique, distribua.

## Contribuindo

Issues e PRs são bem-vindos. Se construiu algo em cima da Mnemósine, conta pra gente.
