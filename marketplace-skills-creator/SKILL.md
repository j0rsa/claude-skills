---
name: marketplace-skills-creator
description: "Manages Claude Code skills repositories as plugin marketplaces. Use when the user wants to convert a local skills folder into a Claude Code plugin marketplace, set up a new marketplace repo, add a new skill to an existing marketplace, or symlink marketplace skills locally for live development. Triggers on: 'create marketplace', 'convert to marketplace', 'add skill to marketplace', 'skills marketplace setup', 'publish skills', 'register plugin', 'link plugin locally', 'symlink skill', 'load skill locally', '/marketplace-skills-creator', '/link-plugin-locally'."
---

# Marketplace Skills Creator

Set up and maintain Claude Code plugin marketplaces — repositories that users can add via `/plugin marketplace add` and install skills from with `/plugin install`.

## Tasks

Identify which task the user needs and load the appropriate reference:

| Task | When to use | Reference |
|---|---|---|
| **Convert to marketplace** | User has a repo with skills folders and wants to publish it as an installable plugin | [references/convert-to-marketplace.md](references/convert-to-marketplace.md) |
| **Add a skill** | User already has a marketplace repo and wants to add a new skill to it | [references/add-skill-to-marketplace.md](references/add-skill-to-marketplace.md) |
| **Link plugin locally** (`/link-plugin-locally`) | User wants to symlink skills from a checked-out marketplace repo into `~/.claude/skills/` so edits take effect immediately without reinstalling | [references/link-plugin-locally.md](references/link-plugin-locally.md) |

If unclear which task applies, ask:

- "Do you already have a `.claude-plugin/marketplace.json` in your repo?"
  - **No** → Convert to marketplace
  - **Yes** → Add a skill
- "Do you want edits to your skill files to be picked up by Claude Code immediately, without reinstalling?"
  - **Yes** → Link plugin locally

## Conventions in This Repo

When working in a repository that uses this skill, follow the conventions established in `CLAUDE.md`.

Repos can use one of two structures — check `CLAUDE.md` or the existing layout to determine which applies:

| Structure | Layout | Best for |
|---|---|---|
| **Flat** | `<skill-name>/SKILL.md` at repo root | Single-purpose repos, skills only |
| **Hierarchical** | `<namespace>/skills/<skill-name>/SKILL.md` | Multi-namespace repos, skills + agents |

- Each skill that relies on a framework keeps its documentation in `<skill-name>/references/*.md`
- When a new skill is added, the **Existing Skills** table in `CLAUDE.md` and the skills table in `README.md` must both be updated
