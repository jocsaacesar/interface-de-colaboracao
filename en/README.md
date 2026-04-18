# Mnemosine

## What if your AI remembered who you are?

You open the terminal. Type `claude`. And start explaining — again — what you're building, why you're building it, how you like the code to look, what you've already tried and what didn't work. Every session is a first date. Every conversation starts from scratch.

It doesn't have to be this way.

Mnemosine is a framework for [Claude Code](https://claude.ai/code) that transforms your relationship with your AI from **disposable assistant** to **partnership with continuity**. It's not a plugin. It's not an extension. It's a file structure — pure markdown — that lives inside your repository and gives your AI three things it doesn't have on its own:

**Memory.** It knows who you are, what you've built together, and what went wrong last time.

**Identity.** It has a name, personality, behavioral rules. It's not a text box — it's someone who knows when to challenge you and when to execute.

**Discipline.** It follows processes. It audits code against rules with IDs. It logs errors in a 4-file protocol. It doesn't repeat the same mistakes.

---

## The problem nobody talks about

Most developers use AI as a Google that writes code. Ask, copy, forget. In the next session, the AI doesn't know you prefer composition over inheritance, that your project uses conventional commits, that last week an `apt install` without `--no-install-recommends` took down the server.

The language model is brilliant. What's missing isn't intelligence — it's **persistent context**. And context isn't just technical memory. It's knowing you're senior and don't need basic explanations. It's knowing you like to be challenged when you ask for something half-baked. It's knowing that file was refactored yesterday and doesn't need to be read again.

Mnemosine solves this without magic. Without a database. Without an external API. Just markdown files in your repository that Claude Code already knows how to read.

---

## How it works

When you install Mnemosine, your project gets a simple structure:

```
.claude/skills/          <- Recipes your AI follows (10 ready to use)
memory/                  <- What the AI remembers between sessions
learning/                <- What went wrong and how to prevent it
standards/               <- Auditable rules with IDs and severity levels
plans/                   <- Work management (backlog, operational, emergency)
CLAUDE.md                <- Who the AI is (identity, rules, state)
```

Nothing is installed globally. Nothing touches your system. Everything lives in the repository — versioned, visible, editable.

### The session cycle

```
/start                -> The AI loads identity, memories, past errors, plan status
                        It knows who you are before you say a word

[you work]            -> The AI follows rules, audits code, records decisions

/wrap-up              -> The AI saves state, syncs memories, audits the session
                        Tomorrow it picks up where it left off
```

It's not automation. It's continuity.

---

## What changes in your daily workflow

**Without Mnemosine:** You explain. The AI obeys. You review. Repeat tomorrow.

**With Mnemosine:**

- You open the terminal and the AI already knows you have 2 overdue operational plans and 1 bug in the backlog.
- You request a feature and it creates a plan before writing code — because the planning skill requires it.
- It audits its own code against 250+ rules before delivering — PHP, security, tests, OOP, frontend, each with an ID and severity level.
- When it makes a mistake, it logs the incident in 4 files (what happened, why it happened, what was fixed, how to prevent it). Next time it touches that area, it checks the history before acting.
- When you're wrong, it tells you. With arguments, with evidence. Because you configured it to do that.

---

## Installation

### Existing project (one line)

```bash
curl -sSL https://raw.githubusercontent.com/jocsaacesar/mnemosine/main/install.sh | bash
```

The installer offers three modes:

| Mode | What it installs |
|------|-----------------|
| **Full** | Skills, auditors, standards, learning, guides, examples |
| **Essential** | Session skills + learning + memory |
| **Choose** | You select component by component |

### New project (template)

Click **"Use this template"** at the top of this page and create your repository.

### After installing

```bash
claude                    # open Claude Code
# type: /get-started
```

The AI will interview you — who you are, what you build, how you work, what to avoid — and generate your personalized configuration. It takes 5 minutes. After that, it's yours.

---

## What's included

### 10 global skills

Skills are recipes the AI follows. Same steps, same result, every time.

| Skill | What it does |
|-------|-------------|
| `/start` | Loads identity, memories, state — the AI wakes up knowing everything |
| `/wrap-up` | Saves state, syncs memories — nothing is lost |
| `/get-started` | Interviews you and builds the configuration from scratch |
| `/create-skill` | Creates new skills through a guided interview |
| `/active-learning` | Logs incidents with a 4-file protocol |
| `/approve-pr` | Reviews PRs by orchestrating auditors per stack |
| `/telemetry` | Shows what the AI did, when, and whether it succeeded |
| `/review-text` | Spelling and convention review |
| `/make-public` | Sanitizes personal data before publishing |
| `/marketplace` | Explores available skills |

### 7 code auditors

Each auditor reads a standards document and applies every rule against your code. Violations have an ID (`PHP-025`), severity (ERROR blocks merge, WARNING requires justification), and a "Checks:" section that states exactly what to verify.

| Auditor | Stack |
|---------|-------|
| `/audit-php` | PHP |
| `/audit-oop` | Object-oriented programming |
| `/audit-tests` | Tests (unit, integration, API) |
| `/audit-security` | Security (OWASP, sanitization, auth) |
| `/audit-frontend` | Frontend (HTML, CSS, accessibility) |
| `/audit-js` | JavaScript / TypeScript |
| `/audit-crypto` | Cryptography |

### 250+ auditable rules

8 standards documents + 1 template for creating your own. Each rule has a unique ID, severity, a "why" explanation, and a verification section. These aren't suggestions — they're contracts.

### Project pipeline

4 templates to build your workflow:

```
You request something -> Manager orchestrates:
    1. Planner (interprets, creates plan)
    2. Executor (writes code following the plan)
    3. Tester (creates tests against standards)
    4. Auditor (audits against stack rules)
```

### Learning system

When something goes wrong, `/active-learning` creates 4 files:

```
learning/
├── errors/0001-description.md              # What happened
├── situation-context/0001-description.md   # Why it happened
├── correction/0001-description.md          # What was fixed
└── mitigation/0001-description.md          # How to prevent it
```

The AI checks this history before acting in areas with previous incidents. A documented error becomes a vaccine. A repeated error becomes a violation.

---

## Where it came from

Mnemosine was born from the real-world practice of a Brazilian software house in 2026. An AI operating as a manager across multiple projects — with identity, 28 documented incidents, 250+ auditable rules, 10 global skills, 7 auditors, and an internal constitution. All orchestrated by a single human.

This isn't theory. It's what we use every day. And now it's yours.

---

## Security

- All skills are **local to the project**. Nothing touches `~/.claude/` globally.
- Review the content of skills before using them — they guide commands in your environment.
- `/make-public` sanitizes personal data before any publication.
- For global use, manually copy to `~/.claude/skills/`.

---

## Philosophy

> *In neuroscience, an engram is the trace an experience leaves in the brain — the physical mark that transforms lived experience into identity.*

Most AI tools treat interaction as disposable. You ask, it answers, and everything disappears. Mnemosine starts from a different premise: **the quality of collaboration is proportional to the depth of the relationship.**

An AI that remembers who you are, that knows what went wrong, that follows rules you built together, that challenges you when you're wrong — that AI is no longer a tool. It's a partner.

And partnership is built one brick at a time.

---

## License

MIT — use, modify, distribute.

## Contributing

Issues and PRs are welcome. If you've built something on top of Mnemosine, let us know.
