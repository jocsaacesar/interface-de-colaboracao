# Creating and Organizing Skills

Skills are custom slash commands that automate multi-step workflows in Claude Code. They live in `.claude/skills/` and are triggered by typing `/<skill-name>` in conversation.

**How discovery works:** Claude Code auto-discovers skills from the `.claude/skills/` folder when it opens a project. You don't need to register or install them — drop a skill folder in, and it's available. The `/iniciar` skill re-loads them at session start for a fresh context, but skills are usable even without `/iniciar` (this is how `/comece-por-aqui` works as the very first command on a fresh clone).

## Why Skills Matter

Without skills, you repeat the same instructions every session:
- "Load my memories"
- "Check the inbox"
- "Update CLAUDE.md before we stop"

Skills turn repeated processes into one-word commands.

## Anatomy of a Skill

Each skill lives in its own folder with a `SKILL.md` file:

```
.claude/skills/
└── my-skill/
    └── SKILL.md
```

### SKILL.md Structure

```markdown
---
name: my-skill
description: One-line description of what this skill does and when to trigger it.
---

# /my-skill — Human-Readable Title

Brief description of purpose.

## When to use

- Explicit trigger conditions
- When NOT to trigger (important for avoiding false activations)

## Process

### Phase 1 — Name
Step-by-step instructions.

### Phase 2 — Name
More steps.

## Rules

- Hard constraints the AI must follow during execution.
```

## Design Principles

### 1. One skill, one workflow

A skill should do one coherent thing. Don't combine "load session" and "review code" into one skill — those are two different workflows.

### 2. Explicit triggers

Be very clear about when a skill should and should NOT activate. The AI will try to be helpful — if your trigger conditions are vague, it will fire the skill when you don't want it to.

```markdown
## When to use

- ONLY when the user explicitly types `/ate-a-proxima`
- Never trigger from implicit signals like "tchau" or "boa noite"
```

### 3. Phased execution

Break complex skills into numbered phases. This makes the process predictable and debuggable.

### 4. Rules as guardrails

End every skill with explicit rules. These prevent the AI from "improving" the process in ways you didn't ask for.

## Common Skill Patterns

| Skill | Purpose |
|-------|---------|
| `/iniciar` | Session bootstrap — load identity, memories, check inbox |
| `/ate-a-proxima` | Session wrap-up — audit changes, sync state, farewell |
| `/review` | Code review with specific criteria |
| `/plan` | Break a task into steps before executing |

## Tips

- **Start simple.** Your first skill should be 10 lines, not 100.
- **Iterate based on friction.** If a skill keeps doing something wrong, add a rule.
- **Don't over-automate.** Not every repeated action needs a skill. If you do it once a week, just type the instructions.
- **Test in a new conversation.** Skills load fresh each time — make sure they work without prior context.

## Template

See [templates/skill-template/SKILL.md](../templates/skill-template/SKILL.md) for a starter template.
