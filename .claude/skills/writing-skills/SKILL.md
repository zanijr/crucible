---
name: writing-skills
version: 1.0.0
description: Use when creating a new Crucible skill — provides the skill structure, frontmatter format, and quality checklist for well-crafted skills
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: [skill name or topic]
---

# Writing Skills

Create new Crucible skills that follow the established patterns and enforce discipline effectively.

## When to Use

- Adding a new capability to Crucible
- User wants to create a custom skill for their workflow
- Adapting an external methodology into a skill

## Skill Structure

Every skill lives in `skills/{skill-name}/SKILL.md` with optional `references/` subdirectory.

### Required Frontmatter

```yaml
---
name: skill-name                              # lowercase, hyphenated
version: 1.0.0                                # semver
description: Use when [trigger condition]...  # drives auto-trigger matching
user-invocable: true                          # appears in / menu
allowed-tools: Read, Write, Edit, Bash        # comma-separated tool list
argument-hint: [optional input hint]          # shown to user
---
```

### Required Sections

1. **H1 Title** + 1-2 sentence overview
2. **When to Use** — explicit trigger conditions (list format)
3. **The Iron Law** — the ONE non-negotiable rule (in code block)
4. **Core Pattern** — step-by-step workflow with numbered phases
5. **Red Flags** — table of rationalizations and rebuttals
6. **Common Mistakes** — what NOT to do (list format)

### Optional Sections

- **References/** — supporting docs, templates, prompts
- **Quick Reference** — condensed cheat sheet
- **Escalation Rule** — when to stop and ask for help

## Quality Checklist

Before finalizing a skill:

- [ ] Frontmatter has all required fields
- [ ] Description starts with "Use when" and specifies trigger conditions
- [ ] The Iron Law is clear, specific, and non-negotiable
- [ ] Core pattern has numbered, actionable steps
- [ ] Red flags table addresses at least 5 common rationalizations
- [ ] Common mistakes list is specific, not generic
- [ ] Cross-references to related skills use `crucible:skill-name` format
- [ ] Skill is under 300 lines (excluding references)
- [ ] References are in a `references/` subdirectory, not inline

## Skill Types

**Rigid skills** (TDD, debugging, verification): Follow exactly. No adaptation.
- Iron Law is absolute
- Steps are sequential and mandatory
- Skipping any step = violation

**Flexible skills** (brainstorming, orchestrating): Adapt to context.
- Iron Law sets boundaries
- Steps can be reordered or skipped with justification
- Principles matter more than exact procedure

State which type your skill is in the overview.

## Common Mistakes

- Making the Iron Law too vague ("do good work") → not enforceable
- Writing steps that are too abstract ("implement the thing") → not actionable
- Forgetting Red Flags → users rationalize their way around the skill
- Not specifying trigger conditions → skill never gets invoked
- Making the skill too long → agent runs out of context reading it
