# Journal

Decisions, lessons, and insights from building the Mnemosine framework.

Each entry answers three questions:
- **What we decided**
- **Why**
- **What we learned**

---

## Green visuals are not real validation

**What we decided:** Treat visual CI signals (green badges, success icons) as fragile indicators and invest in executable checks that block automatically.

**Why:** Across four separate incidents, bugs were active and existing mechanisms didn't catch them: SKIPPED tests appeared green, textual rules existed but had no automated enforcement, a red CI workflow went unnoticed because another workflow appeared green, and a code rule (documented in CLAUDE.md) was violated during a mass audit because it depended on human attention.

**What we learned:** The difference between "written rule" and "enforced rule" is binary. As long as enforcement depends on human memory or visual attention, the rule is a wish — not a contract. The solution: **every fragile signal becomes an executable check** — automated tests covering the real contract, static checks that block PRs, observability with actively consumed alerts. Every time we find a rule that survives only because someone remembers it, it's because it hasn't been turned into a check yet.

---

## Document before you automate

**What we decided:** Create a written guide explaining how to install the framework in an existing project, instead of immediately building an automated skill.

**Why:** When installing the framework in an existing project, `.gitignore`, `CLAUDE.md`, `README.md`, and `.github/` would conflict. Before automating, we needed to understand and document exactly what conflicts, what to copy, and what to ignore.

**What we learned:** Not every problem needs a skill. Sometimes the best tool is a clear document. Automating a process you haven't documented yet is a recipe for silent bugs.

---

## CLAUDE.md belongs to the user, documentation belongs to the framework

**What we decided:** Separate framework documentation from the user's AI identity. The repository ships a placeholder in CLAUDE.md that `/get-started` replaces with the personalized identity.

**Why:** If the user clones the repository into a project that already has a CLAUDE.md, the file would be overwritten. Worse: even in a new project, the CLAUDE.md we shipped was framework documentation, not identity — Claude Code would be reading a manual instead of a personality.

**What we learned:** The file the system reads automatically should belong to the user, not the framework. Documentation is reference, not identity. Mixing the two creates a conflict that only surfaces when someone else uses it.

---

## First external feedback: the README needs to sell, not describe

**What we decided:** Completely rewrite the README. Replace the project structure as the centerpiece with a visual onboarding flow, a before/after table, and a practical section.

**Why:** The first external tester gave clear feedback: "I don't care about the project structure. I want to read the README and know what this is." They also pointed out that global vs. local skills weren't clear and raised legitimate concerns about skills modifying the system.

**What we learned:** A public repository README has one job: make a stranger understand the value in 30 seconds. Project structure is for contributors, not visitors. Security disclaimers aren't optional when you're asking someone to run commands on their machine. And the first external feedback is always humbling — what's obvious to the builder is invisible to the reader.

---

## All skills are local by default, global is optional

**What we decided:** Explicitly document that all skills in this repository are local to the project folder. Nothing touches `~/.claude/` globally. If the user wants a global skill, they copy it manually.

**Why:** External feedback raised fear of global skills ("It's like putting something in the BIOS"). A legitimate concern — a user cloning a repository shouldn't worry about their system being modified.

**What we learned:** When distributing skills, the default should always be the safest option. Local by default, global by choice is the only secure design. Advanced users will figure out how to go global. New users need to feel safe first.

---

## Bootstrap problem: skills need to work before /start

**What we decided:** Explicitly document that `/get-started` is the only skill that runs without `/start`. Claude Code auto-discovers skills from the `.claude/skills/` folder, so no bootstrap step is needed.

**Why:** A new user reads that `/start` loads skills and assumes they need it first. But `/get-started` needs to run in a clean environment — before CLAUDE.md or memories exist. The documentation created a chicken-and-egg problem.

**What we learned:** When you design a system with a "load everything" step, you need to explicitly document what happens *before* that step exists. The bootstrap case is always special.

---

## /get-started: onboarding as conversation, not manual

**What we decided:** Create an onboarding skill that interviews new users one question at a time — who they are, what they're building, how they work, what to avoid, and what to call the AI — and then builds a complete personalized configuration.

**Why:** A repository with great documentation still fails if the user doesn't know where to start. Templates require reading instructions and filling in fields. An interview requires only answering questions.

**What we learned:** The entry point of a framework shouldn't teach the framework — it should ask the right questions. Understanding comes later, with use.

---

## Publishing as a distinct phase from session closing

**What we decided:** Create a dedicated skill (`/make-public`) that audits the session's work, sanitizes personal data, and publishes content with pedagogical value — with mandatory user confirmation before any commit.

**Why:** Manually separating personal from public at each session is tedious and error-prone. But full automation without oversight is dangerous with personal data.

**What we learned:** The session lifecycle has three beats: `/start` (open), `/make-public` (publish), `/wrap-up` (close). Publishing requires conscious review — it's not something you do on autopilot while saying goodbye.

---

## Journal instead of daily log

**What we decided:** Use a decision-based journal instead of a chronological daily log.

**Why:** Daily logs become noise fast — thousands of lines nobody reads. Decision entries stay useful because they capture *why* something was chosen, not just *what* happened.

**What we learned:** The unit of documentation for a collaboration process is the **decision**, not the **day**.

---

## Memory lives in the project, not hidden in the system

**What we decided:** All memory files live in the project's `memory/` folder, visible and editable by the human. Mirrored in `.claude/projects/` for automatic loading.

**Why:** The creator needs full visibility and control over what the AI remembers. Hidden state breaks trust.

**What we learned:** Transparency is a design principle, not a feature. A collaboration interface where one side has hidden memory isn't a collaboration — it's a black box.
