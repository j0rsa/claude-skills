# Add a Skill to an Existing Marketplace

## Prerequisites

The repo already has `.claude-plugin/marketplace.json`. If not, see [convert-to-marketplace.md](convert-to-marketplace.md) first.

## Steps

### 1. Create the skill folder and SKILL.md

Check `CLAUDE.md` or the existing skill folders to determine which structure the repo uses, then follow that convention.

**Flat** (skills at repo root):
```
<skill-name>/
├── SKILL.md
└── references/        ← optional
    └── <framework>.md
```

**Hierarchical** (namespaced):
```
<namespace>/skills/<skill-name>/
├── SKILL.md
└── references/        ← optional
    └── <framework>.md
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

The `description` field is what Claude reads to decide when to invoke the skill — make it specific and include all trigger phrases.

To bootstrap the folder with the correct structure, use the skill-creator's init script if available:

```bash
python3 <path-to-skill-creator>/scripts/init_skill.py <skill-name> --path <namespace>/skills/
```

### 2. Register the skill in `marketplace.json`

Open `.claude-plugin/marketplace.json` and add the new skill path to the `skills` array of the relevant plugin:

```json
"skills": [
  "./existing-skill-a",
  "./existing-skill-b",
  "./<skill-name>"                        ← flat structure
  "./<namespace>/skills/<skill-name>"     ← hierarchical structure
]
```

The path must point to the folder containing `SKILL.md`, relative to `source` (usually the repo root). Use whichever pattern matches the repo's established structure.

### 3. Update `CLAUDE.md` Existing Skills table

If the repo has a CLAUDE.md with an Existing Skills table, add a row:

```markdown
| `skill-name` | `/slash-command` | Framework (if any) | One-line purpose |
```

### 4. Update `README.md` skills table

Add the skill to the skills table in README.md with its slash command and description.

### 5. Verify

Push to GitHub and test in a Claude Code session:

```
/plugin install <plugin-name>@<marketplace-name>
```

Confirm the new skill triggers on the expected phrases.

## Checklist

- [ ] `<skill-name>/SKILL.md` created with valid frontmatter (`name` + `description`)
- [ ] Skill path added to `marketplace.json` `skills` array
- [ ] `CLAUDE.md` Existing Skills table updated (if present)
- [ ] `README.md` skills table updated (if present)
- [ ] Pushed to GitHub and install tested
