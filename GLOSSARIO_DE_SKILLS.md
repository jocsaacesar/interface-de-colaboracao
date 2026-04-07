# Skills Glossary

A practical reference for every skill available in the Claude Collaboration Interface. Each entry explains what the skill does, when to use it, what to expect, and what it will never do.

---

## How Skills Work

Skills are custom slash commands. You type `/<skill-name>` in a Claude Code conversation, and it executes a multi-step workflow defined in `.claude/skills/<skill-name>/SKILL.md`.

Skills are **not magic** — they're structured instructions that make the AI behave consistently. Think of them as recipes: same ingredients, same steps, same result every time.

### Key principles

- **All skills in this repo are local to the project.** They live in `.claude/skills/` inside the project folder. They do NOT modify your global `~/.claude/` configuration. Your existing Claude Code setup is not affected.
- **Claude Code auto-discovers skills** from the `.claude/skills/` folder when it opens a project. You don't need to install or register them — they're available immediately.
- **`/iniciar` re-loads skills** at the start of each session, ensuring they're fresh in the conversation context. But the very first skill — `/comece-por-aqui` — works without `/iniciar` because it's designed to run in a blank environment.
- **Each skill has explicit trigger rules.** Some run automatically (like `/iniciar` on greeting), others only fire when you type the exact command.
- **Skills don't stack.** Run one at a time. Wait for it to finish before calling another.
- **You're always in control.** No skill commits, publishes, or deletes anything without your explicit approval.
- **Want a skill globally?** If you want `/iniciar` available in every project (not just this one), you can manually copy it to `~/.claude/skills/iniciar/`. This is entirely optional and never done automatically.

---

## /comece-por-aqui

> **Your first command. Run once after cloning the repository. No prior setup needed.**

### Purpose

Builds your entire personalized collaboration interface from scratch — identity, memories, workspace — through a guided conversation.

### When to use

- Right after cloning the repository for the first time.
- If you want to redo your setup from scratch.

### Bootstrap note

This is the **only skill that runs without `/iniciar`**. It's designed to work in a completely blank environment — no CLAUDE.md, no memories, no prior context. Claude Code auto-discovers it from the `.claude/skills/` folder. You clone, open Claude Code, type `/comece-por-aqui`, and it just works.

### What happens

1. The AI greets you and explains what's about to happen (~5 minutes).
2. It asks **five questions**, one at a time:
   - **Who are you?** Your role, background, what you do.
   - **What are you building?** Your project, goals, motivation.
   - **How do you like to work?** Your collaboration style preference.
   - **What should the AI avoid?** Things that annoy you about AI interactions.
   - **Name and language?** What to call your AI, and what language for conversations.
3. Based on your answers, it generates a custom `CLAUDE.md` and **shows it to you for approval**.
4. After you approve, it creates your initial memory files and workspace folders.
5. It greets you for the first time **in character** — as your newly created AI.

### What it will never do

- Dump all questions at once. It's a conversation, one question at a time.
- Write files without showing you first. You approve the CLAUDE.md before it's saved.
- Force a specific personality model. Your AI is shaped by your answers, not by a template.

### After it's done

You're set up. From now on, start every session with `/iniciar`.

---

## /iniciar

> **Start of every session. The first thing you type.**

### Purpose

Loads everything the AI needs to be fully present: identity, memories, skills, and inbox. The AI arrives ready to work, not blank.

### When to use

- Every time you open a new conversation.
- You can also just say "bom dia", "let's go", or any greeting — the AI recognizes the intent.

### What happens

1. **Loads identity** — Reads `CLAUDE.md`. Internalizes personality, rules, and conventions.
2. **Loads memories** — Reads every memory file from the index. Applies them silently.
3. **Loads skills** — Discovers and internalizes all available skills for the session.
4. **Checks inbox** — Looks in `exchange/inbox/` for files you may have dropped. Mentions them if found.
5. **Greets you** — A short, natural greeting in character. Not a system report.

### What it will never do

- Recite your memories back to you. It uses them silently.
- List all loaded skills. It knows them — you don't need a boot log.
- Skip loading. Even if you just want a quick question, `/iniciar` ensures consistency.

### What it looks like

> "Joc. Inbox empty, everything loaded. What are we working on?"

Or if there's something new:

> "Joc. I see you dropped a file in the inbox — already looked at it. Where do we start?"

---

## /tornar-publico

> **Publish your work. Run when you have something worth sharing.**

### Purpose

Takes session work, separates personal from public, sanitizes sensitive content, and prepares everything for the public repository. Nothing gets committed without your approval.

### When to use

- When you've created or modified content during a session that has value for other users.
- Typically run near the end of a session, before `/ate-a-proxima`.
- **Manual trigger only** — type `/tornar-publico` explicitly.

### What happens

1. **Audits** — Identifies every file created or modified during the session.
2. **Classifies** — Puts each file in one of three buckets:
   - *Already public* — guides, templates, README, JOURNAL.
   - *Personal, has public value* — memories, skills, deliverables that teach something.
   - *Personal, no public value* — drafts, configs, ephemeral items.
3. **Sanitizes** — Creates clean versions of valuable personal content:
   - Real names → "the user" or "the project owner".
   - Emails, company names, identifying URLs → removed.
   - Structure, lessons, and format → preserved.
4. **Updates JOURNAL.md** — Adds new decision entries for the session.
5. **Verifies** — Checks that `.gitignore` covers all personal folders. Asks: "If someone clones this repo, can they identify the user?"
6. **Reports** — Shows you exactly what will be published, what was sanitized, and what was skipped.
7. **Waits** — Does nothing until you say "go ahead."

### What it will never do

- Commit without your approval. It always shows and waits.
- Publish personal data. When in doubt, it skips and asks you.
- Overwrite your original files. Sanitized versions go to `examples/`, originals stay untouched.
- Sanitize in a way that destroys the lesson. If cleaning a file makes it useless, it skips entirely.

### What it looks like

```
## Ready to publish

### New/updated public files:
- guides/new-guide.md
- JOURNAL.md (2 new entries)

### Sanitized from personal:
- memory/project_goals.md → examples/leland/memory/project_goals.md

### Skipped (personal, no public value):
- exchange/outbox/drafts/rough-notes.md (draft, not ready)

### Protection verified:
- .gitignore covers: memory/, exchange/, .claude/settings.local.json

Confirm to proceed?
```

---

## /ate-a-proxima

> **End of session. The last thing you type.**

### Purpose

Closes the session cleanly: audits what changed, updates `CLAUDE.md` to reflect the current state, syncs all memories, and says goodbye like a mentor — not like a machine shutting down.

### When to use

- At the end of a work session.
- **Manual trigger only** — type `/ate-a-proxima` explicitly.
- Never fires from implicit signals. If you say "bye" or "that's all for today", the AI just says goodbye naturally without running the full wrap-up.

### What happens

1. **Audits** — Reviews all files created, modified, or deleted during the session.
2. **Updates CLAUDE.md** — Syncs the identity file with the current project state. Only changes what actually changed — surgical, not wholesale.
3. **Syncs memories** — Ensures all memory files are up to date and mirrored between the project folder and the system folder.
4. **Farewell** — A brief, warm closing that acknowledges what was accomplished and hints at what's next.

### What it will never do

- Fire automatically. You must type the command.
- Write a changelog. CLAUDE.md is a living document, not a log.
- Bloat CLAUDE.md. Only updates what actually changed in this session.
- Give a cold, robotic goodbye. The farewell comes from the AI's personality.

### What it looks like

> "Good session. We built the skill glossary and tightened the onboarding flow. Next time, we push to GitHub. Rest up."

---

## Skill Lifecycle Summary

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   First time:    /comece-por-aqui                           │
│                  (interview → identity → memories → done)   │
│                                                             │
│   Every session: /iniciar                                   │
│                  (load identity → memories → skills → greet)│
│                       │                                     │
│                       ▼                                     │
│                  [  your work  ]                             │
│                       │                                     │
│                       ▼                                     │
│                  /tornar-publico  (optional)                 │
│                  (audit → sanitize → publish → confirm)     │
│                       │                                     │
│                       ▼                                     │
│                  /ate-a-proxima                              │
│                  (audit → update CLAUDE.md → sync → bye)    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Creating Your Own Skills

Once you're comfortable with the built-in skills, you can create your own. See:

- **[guides/skills.md](guides/skills.md)** — Full guide on skill design.
- **[templates/skill-template/SKILL.md](templates/skill-template/SKILL.md)** — Starter template.

Good candidates for new skills:
- Code review with specific criteria for your project.
- Planning workflows (break a task into steps before executing).
- Deployment checklists.
- Any multi-step process you repeat and want to be consistent.

The rule of thumb: **if you've explained the same process to the AI three times, it's a skill.**
