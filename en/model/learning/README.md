# Learning

> *"Making an error once is learning. Making the same error twice is unacceptable."*

This directory is the living record of everything that went wrong and what was done about it. It's not a wall of shame — it's an immunity library.

## Structure

```
learning/
├── errors/                # What happened (facts, no judgment)
├── situation-context/     # The circumstances that caused it (the chain of events)
├── correction/            # What we did to fix it (immediate action)
└── mitigation/            # What we did to prevent it from ever happening again (prevention)
```

## How to log

Each incident generates **4 files** with the same numeric prefix:

```
errors/0001-short-description.md
situation-context/0001-short-description.md
correction/0001-short-description.md
mitigation/0001-short-description.md
```

## Who uses it

- **The AI** — before making decisions in areas where it has already made mistakes
- **Skills** — when auditing code in domains with a history of incidents
- **The user** — when they want to understand failure patterns
- **New agents** — as part of onboarding, to avoid repeating mistakes

## Rule

If an error logged here happens again, the incident is treated as a **violation of project rules**, not an operational error.
