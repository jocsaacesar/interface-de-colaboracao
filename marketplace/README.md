# Marketplace de skills

Skills opcionais para a Interface de Colaboração com Claude. Cada uma resolve um problema específico — você instala só as que precisar.

## Skills disponíveis

| Skill | O que faz |
|-------|-----------|
| [/tornar-publico](tornar-publico/) | Sanitiza dados pessoais e publica trabalho da sessão no repositório público. |
| [/revisar-texto](revisar-texto/) | Revisão ortográfica e de convenções em todos os arquivos .md do projeto. |

## Como instalar uma skill

Copie a pasta da skill para `.claude/skills/` no seu projeto:

```bash
# exemplo: instalar /tornar-publico
cp -r marketplace/tornar-publico .claude/skills/
```

Pronto. O Claude Code descobre automaticamente. Na próxima vez que abrir uma conversa ou rodar `/iniciar`, a skill estará disponível.

## Como desinstalar uma skill

Delete a pasta de dentro de `.claude/skills/`:

```bash
rm -rf .claude/skills/tornar-publico
```

Sem efeitos colaterais. A skill simplesmente deixa de existir.

## Contribuindo com novas skills

Criou uma skill útil e quer compartilhar? Abra um PR adicionando uma pasta aqui no marketplace.

### Requisitos

- A skill deve ter um `SKILL.md` completo seguindo o [modelo](../modelos/skill-modelo/SKILL.md).
- Documentação em português (BR).
- Nenhum dado pessoal embutido.
- A skill deve funcionar de forma independente — sem depender de outras skills do marketplace.
- Descreva claramente o propósito, quando usar e as regras.

### Estrutura esperada

```
marketplace/
└── nome-da-skill/
    └── SKILL.md
```

Abra o PR com uma descrição do que a skill faz e por que seria útil para outros usuários.
