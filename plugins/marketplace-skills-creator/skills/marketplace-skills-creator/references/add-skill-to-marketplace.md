# Add a Skill to an Existing Plugin

## Prerequisites

The repo already has `.claude-plugin/marketplace.json` and at least one plugin under `plugins/`. If not, see [convert-to-marketplace.md](convert-to-marketplace.md) first.

## How skills are discovered

Skills are **auto-discovered** by Claude Code from the plugin's `skills/` directory. You do not register skill paths in `marketplace.json` or `plugin.json` — you only need to create the skill directory with a valid `SKILL.md` and it will be picked up automatically when the plugin is installed.

## Steps

### 1. Identify which plugin the skill belongs to

Check `CLAUDE.md` or the `plugins/` directory to find the right plugin. If the skill is conceptually unrelated to any existing plugin, you may need to create a new plugin directory first (see [convert-to-marketplace.md](convert-to-marketplace.md) for the plugin setup steps, then come back here).

### 2. Create the skill folder and SKILL.md

Add the skill under the plugin's `skills/` directory:

```
plugins/<plugin-name>/skills/<skill-name>/
├── SKILL.md
└── references/        ← optional: supporting docs the skill can load
    └── <topic>.md
```

**SKILL.md minimum requirements:**

```markdown
---
name: skill-name
description: "What it does and when to use it. Include trigger phrases and slash command."
---

# Skill Name

[Workflow or instructions here]
```

The `description` field is what Claude reads to decide when to invoke the skill automatically — make it specific and include all trigger phrases and the slash command.

### 3. Update `CLAUDE.md` Existing Plugins table

If the repo has a CLAUDE.md with an Existing Plugins table, add a row:

```markdown
| `plugin-name` | `skill-name` | `/slash-command` | One-line purpose |
```

### 4. Update `README.md` skills table

Add the skill to the skills table in README.md with its plugin, slash command, and description.

### 5. Verify

Push to GitHub and test in a Claude Code session:

```
/plugin install <plugin-name>@<marketplace-name>
```

Confirm the new skill triggers on the expected phrases.

## If the skill needs a companion agent

If the skill is complex enough to benefit from a dedicated agent (autonomous execution, its own context, tool restrictions), add an `agents/<agent-name>.md` alongside the `skills/` directory:

```
plugins/<plugin-name>/
├── agents/
│   └── <agent-name>.md
└── skills/
    └── <skill-name>/
        └── SKILL.md
```

The agent is also auto-discovered. In the agent's frontmatter, reference the skill name in the `skills` field so the agent has access to it:

```markdown
---
name: my-agent
description: "Use for X tasks..."
model: sonnet
skills:
  - skill-name
---
```

## Checklist

- [ ] `plugins/<plugin-name>/skills/<skill-name>/SKILL.md` created with valid frontmatter (`name` + `description`)
- [ ] `CLAUDE.md` Existing Plugins table updated (if present)
- [ ] `README.md` skills table updated (if present)
- [ ] Pushed to GitHub and install tested
