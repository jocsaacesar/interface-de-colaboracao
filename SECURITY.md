# Política de Segurança

## Escopo

Este projeto é um framework de documentação — não contém código executável, dependências ou serviços em produção. A principal preocupação de segurança é a **exposição acidental de dados pessoais** por meio de arquivos de memória, arquivos de troca ou `.gitignore` mal configurado.

## Reportando uma vulnerabilidade

Se você descobrir um problema de segurança — como dados pessoais expostos em um arquivo público, uma falha na cobertura do `.gitignore`, ou uma skill que possa vazar informações sensíveis — reporte de forma privada:

1. Vá até a aba **Security** deste repositório.
2. Clique em **Report a vulnerability**.
3. Descreva o que encontrou e onde.

Responderemos em até 48 horas e resolveremos o problema o mais rápido possível.

## O que conta como problema de segurança

- Dados pessoais (nomes, emails, credenciais) visíveis em qualquer arquivo público.
- Uma regra do `.gitignore` que falha em proteger `memoria/`, `troca/` ou configurações locais.
- Uma definição de skill que possa publicar conteúdo privado sem confirmação do usuário.
- Qualquer arquivo em `exemplos/` que contenha informações pessoais identificáveis.

## O que NÃO conta

- Erros de digitação, formatação ou links quebrados — use um [Relatório de Bug](../../issues/new?template=bug-report.md).
- Sugestões de funcionalidades — use uma [Sugestão de Funcionalidade](../../issues/new?template=feature-request.md).

## Princípios de design

Este projeto segue uma separação estrita entre público e privado:

- **Público:** guias, modelos, exemplos, skills, CLAUDE.md, JOURNAL.md
- **Privado (no gitignore):** memoria/, troca/, .claude/settings.local.json
- **Sanitização:** A skill `/tornar-publico` verifica a proteção antes de cada publicação e nunca faz commit sem aprovação explícita do usuário.

Se você acredita que alguma dessas fronteiras pode ser contornada, isso é um problema de segurança que vale reportar.
