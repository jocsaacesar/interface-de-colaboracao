---
name: marketplace
description: Explores available skills in the marketplace, describes each one, and suggests activations based on the user's profile and project. Manual trigger only.
---

# /marketplace — Explore available skills

Explores skills available in the marketplace (separate repository or local `marketplace/` folder), presents what each one does, and suggests which would be useful for the user based on what it knows about them (identity, project, memories).

## When to use

- **ONLY** when the user explicitly types `/marketplace`.
- When the user wants to discover new skills or doesn't know what's available.
- Never trigger automatically.

## Process

### Phase 1 — Inventory

1. Check if a `marketplace/` folder exists in the project (cloned from the skills repo). If it doesn't, inform the user how to get it:
   > "The marketplace hasn't been downloaded yet. To access extra skills, clone the marketplace repository into the `marketplace/` folder."
   If the user confirms, execute the clone. If not, exit.
2. List all folders inside `marketplace/` (except README.md, LICENSE).
3. For each folder, read the complete `SKILL.md`.
4. Check which marketplace skills **are already active** (already copied to `.claude/skills/`).

### Phase 2 — User context

1. Read the user's `CLAUDE.md` (identity, project, current phase).
2. Read available memories (profile, preferences, project context).
3. Use this information silently to inform suggestions — **don't recite it back**.

### Phase 3 — Present catalog

Show each marketplace skill clearly and accessibly:

For each skill, present:
- **Name and command** — how to call it
- **What it does** — 1-2 sentence description, plain language
- **When it's useful** — in what situation this skill shines
- **Status** — already activated / available to activate

Example format:

```
## Skills available in the marketplace

### /make-public (available)
Sanitizes personal data and publishes session work to the repository.
Useful if you work on public projects and need to separate personal from what goes to GitHub.

### /review-text (already activated)
Spelling and convention review across all .md files in the project.
Useful if you write documentation and want to maintain consistency.
```

### Phase 4 — Recommend

After presenting the catalog, make **one personalized recommendation** based on the user's context:

> "Based on your project and what I know about how you work, I think `/make-public` would be useful for you because [concrete reason based on context]. Want to activate it?"

**Recommendation rules:**
- Recommend at most **2 skills** at a time. Don't overwhelm.
- The recommendation must have a **concrete reason** — not "might be useful", but "because you work with a public repository and need to sanitize personal data".
- If no skill makes sense for the user right now, say so honestly: "None of the marketplace skills seem to fit what you're doing right now. When you need them, they'll be here."
- If all are already activated, say: "You already have everything the marketplace offers. When new skills appear, run `/marketplace` again."

### Phase 5 — Activate (if the user wants)

If the user wants to activate a skill:

1. Copy the folder from `marketplace/<skill>` to `.claude/skills/<skill>`.
2. Confirm:

> "Skill `/skill-name` activated. Claude Code has already discovered it — you can use it now."

If the user wants to deactivate a skill:

1. Delete the folder from `.claude/skills/<skill>`.
2. Confirm:

> "Skill `/skill-name` deactivated. The original is still in the marketplace if you want to reactivate later."

## Rules

- **Never activate without asking.** Always ask before copying.
- **Never deactivate core skills.** If the user asks to deactivate `/start`, `/get-started`, `/wrap-up`, or `/create-skill`, warn that they're essential and should not be removed.
- **Honest recommendations.** If nothing makes sense, say so. Don't push a skill for the sake of it.
- **Accessible descriptions.** Don't copy the technical frontmatter — translate to language anyone can understand.
- **One recommendation at a time.** If you activate a skill, don't suggest another immediately. Let the user try it before recommending more.
