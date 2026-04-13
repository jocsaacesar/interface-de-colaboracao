# Instalação em projeto existente

Este guia é para quem **já tem um projeto rodando** e quer adicionar o framework de colaboração sem quebrar nada. Se está começando do zero, o caminho mais simples é clonar o repositório direto — veja o [README](../README.md#início-rápido).

---

## O que você precisa copiar

Nem tudo no repositório do framework é pra ir pro seu projeto. A maioria dos arquivos é documentação, exemplos e infraestrutura do repositório em si. O que realmente precisa estar no seu projeto é pouca coisa:

### Essencial (sem isso o framework não funciona)

| O quê | Pra quê |
|-------|---------|
| `.claude/skills/` | As skills — `/comece-por-aqui`, `/iniciar`, `/ate-a-proxima`, `/criar-skill`, `/marketplace`. Sem elas, não há framework. |
| Entradas no `.gitignore` | Proteger suas pastas de memória e troca de arquivos. **Não copie o arquivo inteiro** — adicione as linhas ao seu `.gitignore` existente. |

### Recomendado (referência e documentação)

| O quê | Pra quê |
|-------|---------|
| `CLAUDE-IC.md` | Documentação completa do framework. Nome único, não conflita com nada. |
| `GLOSSARIO_DE_SKILLS.md` | Guia do usuário para todas as skills. |

### Não copie (são do repositório do framework, não do seu projeto)

| O quê | Por quê não |
|-------|-------------|
| `README.md` | É a apresentação do framework, não do seu projeto. Você já tem o seu. |
| `LICENSE` | Seu projeto tem sua própria licença. |
| `CONTRIBUTING.md` | Regras de contribuição do framework, não do seu projeto. |
| `CODE_OF_CONDUCT.md` | Idem. |
| `SECURITY.md` | Idem. |
| `.github/` | Templates de PR e issues do framework. Você pode já ter os seus. |
| `JOURNAL.md` | Opcional. Se quiser manter um diário de decisões, crie o seu do zero. |
| `guias/` | Referência. Leia no repositório original, não precisa estar no seu projeto. |
| `modelos/` | Templates. Use quando precisar, não precisa copiar. |
| `exemplos/` | Implementação de referência. Não faz sentido no seu projeto. |

---

## Passo a passo

### 1. Baixe o framework

```bash
# Em qualquer lugar fora do seu projeto
git clone https://github.com/jocsaacesar/mnemosine.git
```

### 2. Copie as skills

```bash
# Dentro da pasta do seu projeto
# Se já tiver .claude/skills/, as skills são adicionadas sem apagar as existentes
cp -r /caminho/para/mnemosine/.claude/skills/* .claude/skills/
```

Se a pasta `.claude/skills/` não existir, crie:

```bash
mkdir -p .claude/skills
cp -r /caminho/para/mnemosine/.claude/skills/* .claude/skills/
```

### 3. Atualize seu .gitignore

**Não sobrescreva seu `.gitignore`.** Adicione estas linhas ao final:

```gitignore
# === Mnemosine — dados pessoais ===
/memoria/
/memory/
/troca/
/exchange/
```

A barra inicial (`/`) é importante — garante que só ignora essas pastas na raiz do projeto, sem afetar subpastas com nomes iguais.

### 4. Copie a documentação de referência (opcional)

```bash
cp /caminho/para/mnemosine/CLAUDE-IC.md .
cp /caminho/para/mnemosine/GLOSSARIO_DE_SKILLS.md .
```

### 5. Rode o onboarding

Abra o Claude Code na pasta do seu projeto e digite:

```
/comece-por-aqui
```

A skill vai te entrevistar e gerar um `CLAUDE.md` personalizado. Se você **já tiver um `CLAUDE.md`**, a skill deve detectar e perguntar o que fazer. Se não perguntar, veja a seção [Cuidados](#cuidados) abaixo.

---

## Cuidados

### Você já tem um `CLAUDE.md`

Se seu projeto já usa um `CLAUDE.md` com instruções pro Claude Code, o `/comece-por-aqui` vai tentar criar um novo. Antes de rodar:

1. **Leia seu `CLAUDE.md` atual** — anote o que é importante.
2. **Renomeie temporariamente** — `mv CLAUDE.md CLAUDE.backup.md`.
3. **Rode `/comece-por-aqui`** — deixe a skill gerar o novo.
4. **Mescle manualmente** — pegue as instruções do backup e adicione ao novo `CLAUDE.md` gerado.

Esse é o único arquivo que exige atenção manual. Todos os outros ou não conflitam ou não precisam ser copiados.

### Você já tem `.claude/skills/`

Sem problema. O `cp -r` adiciona as skills do framework ao lado das suas. Nenhuma skill existente é sobrescrita — a menos que você já tenha uma pasta com o mesmo nome (improvável, os nomes são em português).

### Você já tem `.github/`

Não copie a `.github/` do framework. Os templates de issue e PR foram escritos para o repositório do framework, não para o seu projeto.

### Marketplace em projeto existente

O marketplace funciona da mesma forma:

```bash
git clone https://github.com/jocsaacesar/interface-colaboracao-skills.git marketplace
```

Ou, depois de instalar as skills core, digite `/marketplace` na conversa e a IA cuida do resto.

---

## O que o framework cria no seu projeto

Depois do `/comece-por-aqui`, estas pastas e arquivos novos vão existir:

```
seu-projeto/
├── .claude/skills/          ← Skills do framework (você copiou)
├── CLAUDE.md                ← Identidade da sua IA (gerado pela skill)
├── CLAUDE-IC.md             ← Documentação do framework (você copiou)
├── memoria/                 ← Criada pelo /comece-por-aqui (no .gitignore)
│   └── MEMORY.md
└── troca/                   ← Criada pelo /comece-por-aqui (no .gitignore)
    ├── entrada/
    └── saida/
```

As pastas `memoria/` e `troca/` são protegidas pelo `.gitignore` — nunca vão para o seu repositório. Tudo o mais coexiste com os arquivos que você já tem.

---

## Como desinstalar

Se quiser remover o framework do seu projeto:

```bash
# Remover skills
rm -rf .claude/skills/comece-por-aqui
rm -rf .claude/skills/iniciar
rm -rf .claude/skills/ate-a-proxima
rm -rf .claude/skills/criar-skill
rm -rf .claude/skills/marketplace

# Remover arquivos do framework
rm -f CLAUDE-IC.md GLOSSARIO_DE_SKILLS.md

# Remover pastas criadas (opcional — contêm seus dados)
rm -rf memoria/ troca/

# Remover entradas do .gitignore (edite manualmente)
# Remova as linhas /memoria/, /memory/, /troca/, /exchange/

# Remover CLAUDE.md (decisão sua — pode querer manter)
```

Se sincronizou memórias para a pasta do sistema:
```bash
rm -rf ~/.claude/projects/<nome-do-seu-projeto>/memory/
```

Nenhum resíduo. Nenhum estado global. Seu projeto volta a ser exatamente como era antes.
