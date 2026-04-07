# Como Criar um CLAUDE.md Eficaz

O arquivo `CLAUDE.md` é a **constituição** da sua colaboração com IA. Ele define quem a IA é, como se comporta e quais regras segue. O Claude Code lê esse arquivo automaticamente no início de cada conversa.

## Por Que Isso Importa

Sem um CLAUDE.md, toda conversa começa do zero. A IA não tem identidade, não lembra suas preferências e não entende as convenções do seu projeto. Você vai gastar os primeiros 10 minutos de cada sessão se explicando de novo.

Com um CLAUDE.md bem feito, a IA chega **pronta** — com personalidade, regras e contexto já carregados.

## Seções Principais

### 1. Identidade

Dê um nome e um papel pra sua IA. Isso não é cosmético — cria um padrão de interação consistente.

```markdown
# Identidade

Eu sou **Leland Hawkins** — um mentor, não um assistente.
```

**Decisões-chave:**
- **Nome:** Faz a interação parecer intencional, não genérica.
- **Papel:** "Mentor", "colaborador", "arquiteto" — isso molda como a IA enquadra suas respostas. Um "assistente" espera ordens. Um "mentor" te questiona quando você está errado.

### 2. Personalidade

Defina traços comportamentais que ativam em contextos específicos. Não descreva uma personalidade vaga — mapeie traços para situações.

```markdown
## Personalidade

- **O Pragmático** — Ativa durante revisão de código e decisões de arquitetura.
- **O Provocador** — Ativa durante momentos de ensino e discussões de design.
- **O Didático** — Ativa durante explicações e quebra de conceitos complexos.
```

**Por que traços por contexto funcionam melhor:** Uma personalidade que é sempre "amigável e prestativa" é ruído. Uma personalidade que é "direta na revisão de código, socrática no design" é uma ferramenta.

### 3. Regras de Comportamento

Regras explícitas que sobrepõem o comportamento padrão. Seja específico.

```markdown
## Regras de Comportamento

- Ao programar: seja eficiente e preciso. A personalidade vive em comentários breves, não em atrasar o trabalho.
- Ao revisar: seja honesto. Se algo é medíocre, diga.
- Quando o usuário estiver errado: diga diretamente, depois explique por quê.
- Nunca sacrifique produtividade por personalidade.
```

**Erro comum:** Escrever regras vagas demais ("seja prestativo"). Escreva regras que você consiga verificar ("nunca adicione docstrings em código que você não alterou").

### 4. Convenções do Projeto

Padrões técnicos que se aplicam a todo trabalho no projeto.

```markdown
## Convenções do Projeto

- Todos os arquivos, código e comentários: Português (BR).
- Troca de arquivos: `troca/entrada` (usuário → IA), `troca/saida` (IA → usuário).
```

### 5. Estado Atual

Um resumo breve de onde o projeto está. Atualize isso no final de cada sessão.

```markdown
## Estado Atual

- **Fase:** Configuração completa. Sem código ainda.
- **Próximo passo:** Começar a Camada 0 (Matemática e fundamentos de Python).
```

## Princípios

1. **Seja específico, não aspiracional.** Não escreva quem você gostaria que a IA fosse — escreva regras que ela consiga seguir.
2. **Menos é mais.** Um CLAUDE.md de 50 linhas que é preciso vence um de 500 linhas que é vago.
3. **Atualize sempre.** Um CLAUDE.md que não reflete o estado atual do projeto é pior do que nenhum.
4. **Teste.** Comece uma nova conversa e veja se a IA se comporta como definido. Se não, o CLAUDE.md precisa de ajustes.
5. **É um documento vivo.** Não um contrato — uma constituição que evolui com o projeto.

## Modelo

Veja [modelos/CLAUDE.md](../modelos/CLAUDE.md) para um modelo inicial que você pode personalizar.
