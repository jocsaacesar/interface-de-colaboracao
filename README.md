# Claude Collaboration Interface

**Make Claude Code remember who you are.**

Every time you open Claude Code, it starts from zero. It doesn't know your name, your project, how you like to work, or what you discussed yesterday. You re-explain yourself. Every. Single. Time.

This framework fixes that. You set it up once, and from then on, your AI knows who you are, what you're building, and how to work with you — across every conversation.

---

## What Happens When You Use This

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  You clone the repo and type /comece-por-aqui                   │
│                          │                                      │
│                          ▼                                      │
│               ┌─────────────────────┐                           │
│               │  The AI interviews  │                           │
│               │  you (5 questions)  │                           │
│               └─────────┬───────────┘                           │
│                          │                                      │
│           "Who are you? What are you building?                  │
│            How do you work? What annoys you?                    │
│            What should I call myself?"                          │
│                          │                                      │
│                          ▼                                      │
│               ┌─────────────────────┐                           │
│               │  It builds your     │                           │
│               │  personalized AI    │                           │
│               └─────────┬───────────┘                           │
│                          │                                      │
│            Identity, personality, memory,                       │
│            behavioral rules — all from                          │
│            your answers.                                        │
│                          │                                      │
│                          ▼                                      │
│               ┌─────────────────────┐                           │
│               │  Done. Your AI      │                           │
│               │  remembers you now. │                           │
│               └─────────────────────┘                           │
│                                                                 │
│  Next time, just type /iniciar and it's all there.              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Before and After

| Without this framework | With this framework |
|----------------------|-------------------|
| "I'm a backend developer working on..." (every session) | AI already knows your role and background |
| "Please don't add comments to code I didn't change" (again) | AI remembers your preferences from day one |
| "Where were we yesterday?" | AI picks up exactly where you left off |
| Generic, one-size-fits-all responses | Personality and behavior tailored to you |
| Every conversation is a blank slate | Every conversation builds on the last |

## How It Works

The framework has four components:

**Identity (CLAUDE.md)** — A file that defines your AI's name, personality, and rules. Think of it as a constitution: "When reviewing code, be blunt. When teaching, use analogies. Never add features I didn't ask for." Claude Code reads this automatically.

**Memory** — Files that persist across conversations. Your role, preferences, project context, and decisions. The AI reads them silently at session start — no need to repeat yourself.

**Skills** — Custom slash commands for repeatable workflows. Type `/iniciar` to start a session (AI loads everything and greets you). Type `/ate-a-proxima` to close it (AI saves state and says goodbye). You can create your own for any workflow you repeat.

**Exchange** — A simple folder protocol. Drop files in `inbox/` for the AI to process. It delivers results to `outbox/`. No copy-pasting.

---

## Quick Start

```bash
git clone https://github.com/jocsaacesar/interface-de-colaboracao.git
cd interface-de-colaboracao
```

Open Claude Code in that folder and type:

```
/comece-por-aqui
```

No prior setup needed. The AI will guide you through everything.

> **What this does to your system:** Everything stays inside your project folder. Skills, memories, and identity files are all local to this directory. Nothing is installed globally. Your existing Claude Code setup is not affected. See [What This Changes](#what-this-changes-on-your-system) for details.

---

## The Session Lifecycle

Once set up, every work session follows this flow:

```
/iniciar                    Start — AI loads identity, memory, skills.
    │                       Greets you in character. Ready to work.
    ▼
[ your work ]               You work normally. The AI behaves according
    │                       to the personality and rules you defined.
    ▼
/tornar-publico (optional)  If you want to share your work publicly,
    │                       this sanitizes personal data first.
    ▼
/ate-a-proxima              Close — AI saves state, updates memory,
                            says goodbye. Next session picks up here.
```

| Command | When | What it does |
|---------|------|-------------|
| `/comece-por-aqui` | Once, after cloning | Interviews you and builds your personalized AI. |
| `/iniciar` | Start of every session | Loads everything. AI arrives ready. |
| `/tornar-publico` | When you have work to share | Sanitizes personal data before publishing. |
| `/ate-a-proxima` | End of every session | Saves state and closes cleanly. |

---

## What This Changes on Your System

**This is important.** We want you to feel safe using this framework.

### Everything is local

- All files (identity, memories, skills) live **inside your project folder**.
- Nothing is installed in your global Claude Code configuration.
- Nothing modifies `~/.claude/` unless you explicitly choose to sync memories there (the `/comece-por-aqui` onboarding asks before doing this).
- Your existing Claude Code workflows, other projects, and global settings are **not affected**.

### No conflicts with existing setups

- If you already have a `CLAUDE.md` in your project, the onboarding will **show you the new one and ask for approval** before overwriting.
- Skills only activate inside this project's folder. They don't exist outside it.
- Memory files are project-scoped. They don't leak into other projects.

### How to remove

Want to stop using it? Delete the project folder. That's it. There's nothing to uninstall, no global state to clean up, no lingering configuration.

If you synced memories to `~/.claude/projects/`, delete that specific project folder too:
```bash
rm -rf ~/.claude/projects/<your-project-folder>/memory/
```

---

## Going Deeper

- **[Skills Glossary](GLOSSARIO_DE_SKILLS.md)** — Detailed guide for every skill: what it does, what to expect, what it will never do.
- **[Guides](guides/)** — How to design a CLAUDE.md, create skills, use the memory system.
- **[Templates](templates/)** — Starter files to build your own setup from scratch.
- **[Examples](examples/leland/)** — A real, working implementation (sanitized) as reference.
- **[Contributing](CONTRIBUTING.md)** — How to contribute to this project.

## Project Structure

<details>
<summary>Click to expand file tree</summary>

```
├── CLAUDE.md                     # Identity file (the AI's constitution)
├── README.md                     # You are here
├── JOURNAL.md                    # Decisions and learnings
├── GLOSSARIO_DE_SKILLS.md        # User guide for all skills
├── SECURITY.md                   # Security policy
├── LICENSE                       # MIT License
├── CONTRIBUTING.md               # How to contribute
├── CODE_OF_CONDUCT.md            # Community standards
├── guides/
│   ├── claude-md.md              # How to design an effective CLAUDE.md
│   ├── skills.md                 # How to create and organize custom skills
│   └── memory.md                 # How to use the memory system
├── templates/
│   ├── CLAUDE.md                 # Starter identity template
│   ├── skill-template/SKILL.md   # Starter skill template
│   └── memory-template.md        # Starter memory template
├── examples/
│   └── leland/                   # Sanitized reference implementation
├── .github/                      # Issue and PR templates
├── .claude/skills/               # Skill definitions (local to project)
├── memory/                       # Personal memory files (gitignored)
└── exchange/                     # File exchange protocol (gitignored)
```

</details>

## The Living Example

This repository is both the framework *and* a working implementation. The `CLAUDE.md` at the root defines **Leland Hawkins** — a mentor-personality AI with three contextual voices (pragmatist, provocateur, didact). The skills, guides, and journal are all actively used.

The personal stuff (memories, exchange files) is gitignored. Sanitized versions live in [examples/leland/](examples/leland/) so you can see how it works without anyone's data being exposed.

## Origin

Built by **Joc** during the development of Jiim Hawkins — a personal AI agent project. The collaboration interface emerged as a valuable artifact of its own.

**Repository:** [github.com/jocsaacesar/interface-de-colaboracao](https://github.com/jocsaacesar/interface-de-colaboracao)

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a PR. This project follows a [Code of Conduct](CODE_OF_CONDUCT.md).

## License

[MIT](LICENSE)

---

> "A tool is only as good as the hand that shapes it — and the intention behind the shaping."
