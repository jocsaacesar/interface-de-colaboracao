# Claude Collaboration Interface

A framework for building deep, persistent collaboration between humans and Claude Code.

## What This Is

Most people use AI as a search engine with extra steps. This project treats Claude Code as a **collaborative instrument** — one that needs to be tuned, trained, and designed with intention.

This repository documents the process of building a real collaboration interface: identity, memory, skills, and conventions that make Claude Code genuinely useful for creators — not just users.

## Core Concepts

| Concept | What It Does |
|---------|-------------|
| **CLAUDE.md** | Defines the AI's identity, personality, behavioral rules, and project conventions. The constitution. |
| **Memory** | Persistent files that carry context across conversations — who you are, what you've decided, what you've learned. |
| **Skills** | Custom slash commands that automate multi-step workflows (session bootstrap, wrap-up, reviews). |
| **Exchange** | A file-based protocol for passing documents between human and AI. |

## Project Structure

```
├── CLAUDE.md                     # Live identity file (this project's AI is "Leland Hawkins")
├── README.md                     # You are here
├── JOURNAL.md                    # Decisions, learnings, and insights — not a daily log
├── LICENSE                       # MIT License
├── CONTRIBUTING.md               # How to contribute
├── CODE_OF_CONDUCT.md            # Community standards
├── guides/
│   ├── claude-md.md              # How to design an effective CLAUDE.md
│   ├── skills.md                 # How to create and organize custom skills
│   └── memory.md                 # How to use the memory system
├── templates/
│   ├── CLAUDE.md                 # Starter template for your own identity file
│   ├── skill-template/SKILL.md   # Starter template for a custom skill
│   └── memory-template.md        # Starter template for a memory file
├── examples/
│   └── leland/                   # Sanitized reference implementation
│       ├── CLAUDE.md
│       ├── memory/               # Example memory files
│       └── skills/               # Skill descriptions
├── .github/
│   ├── ISSUE_TEMPLATE/           # Bug, feature, and question templates
│   └── PULL_REQUEST_TEMPLATE.md  # PR template
├── memory/                       # Live memory files (gitignored — personal)
├── exchange/                     # File exchange (gitignored — personal)
└── .claude/skills/               # Live skill definitions
```

## Quick Start

1. **Clone this repository**: `git clone https://github.com/jocsaacesar/interface-de-colaboracao.git`
2. **Open Claude Code** in that folder.
3. **Type `/comece-por-aqui`** — no prior setup needed. Claude Code auto-discovers the skill. It will interview you and build your personalized AI in ~5 minutes.
4. **Done.** From now on, start every session with `/iniciar` and your AI will remember who you are.

## Going Deeper

- **Read the [Skills Glossary](GLOSSARIO_DE_SKILLS.md)** — detailed guide for every available skill.
- **Read the [guides](guides/)** to understand each component in detail.
- **Check the [templates](templates/)** if you want to build from scratch instead of using the onboarding.
- **Explore [examples/leland/](examples/leland/)** to see a real implementation.
- **Build custom [skills](.claude/skills/)** for workflows you repeat across sessions.

## Available Skills

| Command | When | What it does |
|---------|------|-------------|
| `/comece-por-aqui` | Once, after cloning | Interviews you and builds your personalized AI identity, memories, and workspace. |
| `/iniciar` | Start of every session | Loads identity, memories, and skills. Checks inbox. Greets you in character. |
| `/tornar-publico` | When you have work to share | Sanitizes personal data and publishes valuable content to the public repo. |
| `/ate-a-proxima` | End of every session | Updates the AI's state, syncs memories, and closes the session. |

## The Living Example

This repository is not just documentation — it's a working project. The `CLAUDE.md` at the root defines **Leland Hawkins**, a mentor-personality AI built for a specific creator. The skills are actively used; the memory and exchange folders are gitignored (they contain personal data), but sanitized examples live in `examples/leland/`.

You're seeing the framework *and* a real implementation of it, side by side.

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a PR. This project follows a [Code of Conduct](CODE_OF_CONDUCT.md).

## License

[MIT](LICENSE)

## Who This Is For

Creators who want more from AI collaboration:
- Developers building complex projects over many sessions
- Writers, researchers, and designers who need persistent context
- Anyone tired of re-explaining themselves every conversation

## Origin

Built by **Joc** during the development of Jiim Hawkins — a personal AI agent project. The collaboration interface emerged as a valuable artifact of its own.

**Repository:** [github.com/jocsaacesar/interface-de-colaboracao](https://github.com/jocsaacesar/interface-de-colaboracao)

---

> "A tool is only as good as the hand that shapes it — and the intention behind the shaping."
