# Primeiro uso — se as skills não funcionarem

Se você clonou o repositório, abriu o Claude Code e digitou `/comece-por-aqui` ou `/iniciar` mas o comando não foi reconhecido, siga os passos abaixo.

## O que aconteceu

O Claude Code descobre skills automaticamente da pasta `.claude/skills/`. Na maioria dos casos isso funciona na primeira abertura. Mas em alguns ambientes — especialmente em máquinas novas ou na primeira vez que o Claude Code é usado — a auto-descoberta pode não acontecer imediatamente.

## Como resolver

### Opção 1 — Fechar e reabrir

Feche o Claude Code e abra novamente **dentro da pasta do projeto**. Na segunda abertura, as skills costumam ser descobertas normalmente.

```bash
cd interface-de-colaboracao
claude
```

### Opção 2 — Pedir pro Claude configurar

Se a opção 1 não funcionar, copie e cole a mensagem abaixo na conversa com o Claude Code. Ele vai ler as skills do projeto e se configurar:

---

**Cole isso na conversa:**

> Leia todos os arquivos SKILL.md dentro da pasta `.claude/skills/` deste projeto. Para cada skill encontrada, internalize o nome, as condições de acionamento, o processo completo e as regras. A partir de agora, quando eu digitar o comando de uma skill (como `/iniciar` ou `/comece-por-aqui`), execute o processo descrito no SKILL.md correspondente. Comece listando as skills que você encontrou.

---

Depois que o Claude listar as skills, digite `/comece-por-aqui` para iniciar a configuração.

### Opção 3 — Configurar skills globais (opcional)

Se quiser que o `/iniciar` funcione em **qualquer projeto** do seu computador (não apenas neste), copie a skill para a pasta global:

```bash
# Criar a pasta global de skills (se não existir)
mkdir -p ~/.claude/skills/iniciar

# Copiar a skill
cp .claude/skills/iniciar/SKILL.md ~/.claude/skills/iniciar/
```

Isso é totalmente opcional. As skills do projeto funcionam sem configuração global.

## Depois que funcionar

Uma vez que as skills estejam ativas, você não precisa repetir esse processo. O fluxo normal é:

1. **Primeira vez:** `/comece-por-aqui` (configura tudo)
2. **Cada sessão:** `/iniciar` (carrega contexto)
3. **Final da sessão:** `/ate-a-proxima` (salva estado)

Se tiver dúvidas, abra uma [issue](https://github.com/jocsaacesar/interface-de-colaboracao/issues) no repositório.
