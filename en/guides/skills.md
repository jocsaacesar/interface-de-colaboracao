# Creating and organizing skills

Skills are custom commands that automate multi-step workflows in Claude Code. They live in `.claude/skills/` and are triggered by typing `/<skill-name>` in the conversation.

**How discovery works:** Claude Code auto-discovers skills from the `.claude/skills/` folder when opening a project. You don't need to register or install anything — place the skill folder there and it becomes available. The `/start` skill reloads them at the beginning of each session for fresh context, but skills work even without `/start` (that's how `/get-started` works as the first command on a fresh clone).

## Why skills matter

Without skills, you repeat the same instructions every session:
- "Load my memory"
- "Check the inbox"
- "Update CLAUDE.md before closing"

Skills turn repeated processes into one-word commands.

## Anatomy of a skill

Each skill lives in its own folder with a `SKILL.md` file:

```
.claude/skills/
└── my-skill/
    └── SKILL.md
```

### SKILL.md structure

```markdown
---
name: my-skill
description: One-line description of what this skill does and when it should trigger.
---

# /my-skill — Readable Title

Brief description of the purpose.

## When to use

- Explicit trigger conditions
- When NOT to trigger (important to prevent false activations)

## Process

### Phase 1 — Name
Step-by-step instructions.

### Phase 2 — Name
More steps.

## Rules

- Hard constraints the AI must follow during execution.
```

## Design principles

### 1. One skill, one workflow

A skill should do one coherent thing. Don't combine "load session" and "review code" into one skill — those are two different workflows.

### 2. Explicit triggers

Be very clear about when a skill should and should NOT activate. The AI will try to be helpful — if your trigger conditions are vague, it will fire the skill when you don't want it to.

```markdown
## When to use

- ONLY when the user explicitly types `/wrap-up`
- Never trigger on implicit signals like "bye" or "good night"
```

### 3. Phased execution

Break complex skills into numbered phases. This makes the process predictable and debuggable.

### 4. Rules as guardrails

End every skill with explicit rules. They prevent the AI from "improving" the process in ways you didn't ask for.

## Common skill patterns

| Skill | Purpose |
|-------|---------|
| `/start` | Session bootstrap — loads identity, memory, checks inbox |
| `/wrap-up` | Session wrap-up — audits changes, syncs state, farewell |
| `/review` | Code review with specific criteria |
| `/plan` | Break a task into steps before executing |

## Tips

- **Start simple.** Your first skill should be 10 lines, not 100.
- **Iterate based on friction.** If a skill keeps doing something wrong, add a rule.
- **Don't over-automate.** Not every repeated action needs a skill. If you do it once a week, just type the instructions.
- **Test in a new conversation.** Skills load from scratch each time — make sure they work without prior context.

## Template

See [templates/skill-template/SKILL.md](../model/templates/skill-template/SKILL.md) for a starter template.
