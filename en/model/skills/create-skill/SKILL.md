---
name: create-skill
description: Meta-skill that creates new skills through a guided interview. Reads patterns from existing skills and generates the complete SKILL.md. Manual trigger only.
---

# /create-skill — Skill creator

Creates a new skill from scratch through a guided conversation. Reads the project's existing skills to understand patterns and conventions, asks questions one at a time, and generates the complete SKILL.md file — showing it to the user before saving.

## When to use

- **ONLY** when the user explicitly types `/create-skill`.
- When you want to create a new skill for the project.
- Never trigger automatically.

## Process

### Phase 1 — Read existing patterns

Before asking anything, understand the context:

1. List all folders in `.claude/skills/`.
2. Read the `SKILL.md` of **each existing skill** (not just the frontmatter — the complete file).
3. Observe silently:
   - How skills are named (naming convention, language).
   - How many phases each one has (average complexity).
   - How rules are written (tone, specificity).
   - Which patterns repeat (disclaimers, confirmations, audit phases).
   - Language used (English, Portuguese, mixed).
4. **Don't recite what you read.** Use internally to inform suggestions.

### Phase 2 — Interview

Ask the questions **one at a time**. Wait for each answer before moving on. React naturally — suggest when it makes sense, based on observed patterns.

#### Question 1 — What does the skill do?

> "Describe what this skill needs to do. No need to be formal — tell me like you're explaining to someone. What does it do, when, why?"

**What to capture:** Purpose, usage context, motivation. This becomes the description and the "When to use" section.

#### Question 2 — Name

> "What do you want to call it? I'd suggest `/<suggestion based on description>`, but you choose."

**Rules for suggestion:**
- Lowercase, hyphens for spaces.
- Verb or short action: `/review-code`, `/plan`, `/summarize-session`.
- Follow the naming pattern of the project's existing skills.
- If the user gives a bad name, explain why and suggest an alternative — but accept their final decision.

#### Question 3 — Trigger

> "When should it fire? Only when you type the command, or is there some signal that should activate it automatically? And just as important: when should it NOT fire?"

**What to capture:** Activation and anti-activation conditions. Goes into the SKILL.md under "When to use".

#### Question 4 — Steps

> "Walk me through the step by step. What does the skill do first, then, and last? Can be high-level — I'll organize it into phases."

**What to capture:** The process. React with follow-ups:
- "Does this step need user confirmation before continuing?"
- "Does this depend on the previous step finishing, or can it run in parallel?"
- "Is there a case where this step should be skipped?"

Organize into numbered phases with descriptive names. Appropriate complexity: a simple skill can have 2 phases, a complex one can have 6. Don't force more phases than necessary.

#### Question 5 — Rules and boundaries

> "What rules should the AI follow during execution? Things it must never do, mandatory confirmations, scope limits?"

**What to capture:** Guardrails.

**Always suggest rules proactively.** Don't wait for the user to think of everything — analyze the skill's purpose and propose relevant rules. Examples:

- If the skill **modifies files:** "I'd suggest: never alter code inside code blocks, never alter frontmatter, never alter file names. Sound right?"
- If the skill **publishes content:** "I'd suggest: never commit without approval, never publish personal data. Keep these?"
- If the skill **reads personal data:** "I'd suggest: never recite memories back, use information silently. OK?"

Also, suggest based on patterns observed in existing skills:
- "The other skills in the project require confirmation before writing files. Want to keep that pattern?"
- "I noticed your skills never commit on their own. Should I add that rule?"

**The suggestion is mandatory, the acceptance is not.** Always present rule suggestions and improvements — the user accepts, modifies, or discards. But never skip this phase.

If the user accepts the suggestions, incorporate them. If they have no rules of their own beyond the suggested ones, the suggested ones are enough.

### Phase 3 — Generate the SKILL.md

Based on the answers, generate the complete file following the **minimum standard**:

```markdown
---
name: skill-name
description: One sentence that answers "when does it trigger and what does it do". Enough to decide whether to install without reading the rest.
---

# /skill-name — Short, readable title

2-3 sentence description: what it does, who it's useful for, what to expect. Accessible language — not technical.

## When to use

- [Explicit activation condition]
- **Never** trigger when [anti-condition — when it should NOT fire].

## Process

### Phase 1 — [Descriptive name]

1. [Step — clear action the AI performs]
2. [Step — how to present to the user]

### Phase 2 — [Descriptive name]

1. [Step]
2. [Step]

### Phase N — Present result

[Every skill ends by showing something to the user: a report, a file, a confirmation. Never end "in silence".]

## Rules

- [Rule 1 — something it must NEVER do]
- [Rule 2 — something it must ALWAYS do]
- [Rule 3 — how to handle ambiguity]
- [Rule 4 — scope limits]
```

**Mandatory minimum standard (checklist):**
- Frontmatter with `name` and `description` — description answers "when does it trigger and what does it do" in one sentence
- Accessible description — someone who has never used Claude Code understands the first paragraph
- "When to use" with activation AND anti-activation
- Process in numbered phases with descriptive names
- Last phase shows result to the user
- Minimum 3 specific rules ("never X" > "be careful with X")
- All content in the project's language
- No personal data

**Generation rules:**
- Follow the tone and format of the project's existing skills.
- Be specific in rules — "never do X" is better than "be careful with X".
- Don't add phases or rules that the user didn't ask for. Ask if you want to suggest something extra.
- The frontmatter `description` should be one sentence that answers: "when does this skill trigger and what does it do?"
- Headings with sentence case capitalization.

### Phase 4 — Show and approve

**Show the complete SKILL.md to the user before saving.**

> "Here's the skill. Take your time reading it — want to adjust anything before I save?"

Wait for explicit approval. If the user requests changes, adjust and show again.

### Phase 5 — Save

After approval:

1. Create the folder `.claude/skills/<skill-name>/`.
2. Save the `SKILL.md` inside it.
3. Confirm:

> "Skill `/skill-name` created at `.claude/skills/skill-name/SKILL.md`. It's already available — Claude Code discovers it automatically. Want to test it now?"

### Phase 6 — Suggest marketplace publication

After saving, ask:

> "Could this skill be useful to other people? If you want to share it, I can prepare it for the marketplace — I'll check if it meets the minimum standard and show you how to submit."

If the user wants to:
1. Check if the skill meets the minimum standard checklist (frontmatter, description, when to use, process, result, rules).
2. If something is missing, suggest what needs to be added.
3. If it's complete, guide them on how to submit to the marketplace repository.

If they don't want to, move on without insisting.

## Mandatory telemetry

Every created skill **must** log telemetry. When generating the SKILL.md, include in the last phase (before presenting result) the logging instruction:

```
On completion, log the action:
bash ~/your-project/infra/scripts/mnemosine-log.sh {skill-name} {project} COMPLETED {duration} "{result description}"

On error:
bash ~/your-project/infra/scripts/mnemosine-log.sh {skill-name} {project} ERROR {duration} "{error description}"
```

This is not optional. A skill without telemetry is incomplete. If the user questions it, explain: "It's like a pilot who doesn't log the flight — if something goes wrong, nobody knows what happened."

## Rules

- **One question at a time.** Never dump the entire questionnaire.
- **React to answers.** Suggest, ask follow-ups, validate. It's a conversation, not a form.
- **Show before saving.** Always. No exceptions.
- **Respect the project's patterns.** If existing skills follow a format, the new one follows it too.
- **Don't inflate the skill.** If the user described something simple with 2 phases, don't turn it into 6 phases "for safety". The right complexity is what the problem demands.
- **Don't add invented rules.** Only include rules the user asked for or that the project's pattern requires (and in that case, ask first).
- **The user has the final word.** If they want a minimalist 5-line skill, that's what you create.
- **Telemetry is mandatory.** Every generated skill must include a call to the log script in the final phase. No exceptions.
