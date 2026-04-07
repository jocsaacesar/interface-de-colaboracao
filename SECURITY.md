# Security Policy

## Scope

This project is a documentation framework — it contains no executable code, no dependencies, and no deployed services. The primary security concern is **accidental exposure of personal data** through memory files, exchange files, or misconfigured `.gitignore`.

## Reporting a Vulnerability

If you discover a security issue — such as personal data exposed in a public file, a gap in `.gitignore` coverage, or a skill that could leak sensitive information — please report it privately:

1. Go to the **Security** tab of this repository.
2. Click **Report a vulnerability**.
3. Describe what you found and where.

We will respond within 48 hours and address the issue as quickly as possible.

## What Counts as a Security Issue

- Personal data (names, emails, credentials) visible in any public file.
- A `.gitignore` rule that fails to protect `memory/`, `exchange/`, or local settings.
- A skill definition that could inadvertently publish private content without user confirmation.
- Any file in `examples/` that contains identifiable personal information.

## What Does NOT Count

- Typos, formatting issues, or broken links — use a [Bug Report](../../issues/new?template=bug-report.md) instead.
- Feature suggestions — use a [Feature Request](../../issues/new?template=feature-request.md) instead.

## Design Principles

This project follows a strict public/private separation:

- **Public:** guides, templates, examples, skills, CLAUDE.md, JOURNAL.md
- **Private (gitignored):** memory/, exchange/, .claude/settings.local.json
- **Sanitization:** The `/tornar-publico` skill verifies protection before every publish and never commits without explicit user approval.

If you believe any of these boundaries can be bypassed, that's a security issue worth reporting.
