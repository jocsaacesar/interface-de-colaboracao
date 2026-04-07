# Journal

Decisions, learnings, and insights from building a collaboration interface with Claude Code.

Each entry answers three questions:
- **What we decided**
- **Why**
- **What we learned**

---

## 2026-04-07 — First external feedback: README must sell, not describe

**What we decided:** Rewrote README completely. Replaced project structure as the centerpiece with a visual onboarding flow, a before/after table, and a "What This Changes on Your System" safety section. Moved file tree into a collapsible `<details>` block.

**Why:** First tester (Rafael Fidelis) gave clear feedback: "I don't care about the project structure. I want to read the README and know what this IS." He also flagged that global vs local skills were unclear and raised legitimate concerns about skills modifying the system.

**What we learned:** A README for a public repo has one job: make a stranger understand the value in 30 seconds. Project structure is for contributors, not visitors. Safety disclaimers are not optional when you're asking someone to run commands on their machine. And the first external feedback is always humbling — what's obvious to the builder is invisible to the reader.

---

## 2026-04-07 — All skills are local by default, global is opt-in

**What we decided:** Explicitly document that all skills shipped in this repo are local to the project folder. Nothing touches `~/.claude/` globally. If the user wants a skill globally, they copy it manually. The `/comece-por-aqui` onboarding now includes a mandatory scope disclaimer before closing.

**Why:** External feedback raised fear about global skills ("It's like putting something in the BIOS"). Legitimate concern — a user cloning a repo shouldn't worry about their system being modified. Default-local, opt-in-global is the only safe design.

**What we learned:** When distributing skills, the default must always be the safest option. Power users will figure out how to go global. New users need to feel safe first.

---

## 2026-04-07 — Bootstrap problem: skills need to work before /iniciar

**What we decided:** Document explicitly that `/comece-por-aqui` is the only skill that runs without `/iniciar`. Claude Code auto-discovers skills from `.claude/skills/`, so no bootstrap step is needed. Clarified this across CLAUDE.md, glossary, guides, and README.

**Why:** A new user reads that `/iniciar` loads skills and assumes they need it first. But `/comece-por-aqui` must run in a blank environment — before CLAUDE.md or memories exist. The documentation created a chicken-and-egg problem that would confuse the first-time user.

**What we learned:** When you design a system with a "load everything" step, you must explicitly address what happens *before* that step exists. The bootstrap case is always special and always needs documentation.

---

## 2026-04-07 — /comece-por-aqui: onboarding as a conversation, not a manual

**What we decided:** Create an onboarding skill that interviews new users one question at a time — who they are, what they're building, how they work, what to avoid, and what to call their AI — then builds a complete personalized setup from the answers.

**Why:** A repo with great documentation still fails if the user doesn't know where to start. Templates require reading instructions and filling blanks. An interview requires only answering questions. The difference: the user thinks about *themselves* instead of thinking about *the system*.

**What we learned:** The entry point to a framework shouldn't teach the framework — it should ask the right questions. Understanding comes later, through use. The onboarding skill doesn't explain memory types or skill anatomy. It just asks "who are you?" and builds from there.

---

## 2026-04-07 — /tornar-publico skill: automating the private-to-public bridge

**What we decided:** Create a dedicated skill that audits session work, sanitizes personal data, and publishes pedagogically valuable content to the public folders — with mandatory user confirmation before any commit.

**Why:** Manually separating personal from public every session is tedious and error-prone. But full automation without oversight is dangerous with personal data. The skill sits in the middle: it does the work, but the human approves the result.

**What we learned:** The session lifecycle now has three beats: `/iniciar` (open), `/tornar-publico` (publish), `/ate-a-proxima` (close). The publish step is distinct from the close step because publishing requires conscious review — it's not something you do on autopilot while saying goodbye.

---

## 2026-04-07 — Project restructured for public sharing

**What we decided:** Transform the private Jiim Hawkins workspace into a public repository documenting the collaboration interface framework. Added guides, templates, and a journal alongside the living project.

**Why:** The process of building identity, memory, and skills for Claude Code turned out to be valuable on its own — not just for us, but for any creator who wants deeper AI collaboration. Keeping it private would waste that.

**What we learned:** The best documentation is a working example. Instead of writing abstract guides, we kept the live project (Leland, memories, skills) as the reference implementation. Theory and practice in the same repo.

---

## 2026-04-07 — Journal over daily log

**What we decided:** Use a decision-based journal instead of a chronological daily log (HISTORY.md).

**Why:** Daily logs become noise fast — thousands of lines nobody reads. Decision entries stay useful because they capture *why* something was chosen, not just *what* happened on a given day.

**What we learned:** The unit of documentation for a collaboration process is the **decision**, not the **day**.

---

## 2026-04-07 — Memory lives in the project, not hidden in the system

**What we decided:** All memory files live in the project's `memory/` folder, visible and editable by the human. Mirrored to `.claude/projects/` for system auto-load.

**Why:** The creator needs full visibility and control over what the AI remembers. Hidden state breaks trust. If you can't see it, you can't fix it.

**What we learned:** Transparency is a design principle, not a feature. A collaboration interface where one side has hidden memory is not a collaboration — it's a black box.

---

## 2026-04-07 — Conversations in Portuguese, artifacts in English

**What we decided:** All files, code, comments, and documentation are written in English. All conversation with the user stays in Portuguese (BR).

**Why:** English maximizes reach and keeps technical content accessible to the global community. Portuguese keeps the working conversation comfortable and natural for the creator.

**What we learned:** Language convention is one of the first decisions to make — it touches everything. Define it early, enforce it always.
