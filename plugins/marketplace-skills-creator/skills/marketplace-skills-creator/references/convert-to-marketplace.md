# Convert a Local Skills Folder to a Marketplace

## What "local skills" means

A local skills setup is a folder of `SKILL.md` files that Claude Code can load directly when pointed at the directory — but which cannot be installed by other users via `/plugin install`. It has no plugin metadata.

## The Plugin-Based Marketplace Structure

A marketplace is a GitHub repository with a specific directory layout. This structure is the canonical format used by the official Anthropic plugin ecosystem:

```
my-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # Catalog: registers all plugins in this repo
├── README.md                     # Install instructions for users
├── CLAUDE.md                     # Developer conventions and plugin inventory
└── plugins/
    └── my-plugin/
        ├── .claude-plugin/
        │   └── plugin.json       # Plugin manifest (name, version, description)
        ├── skills/
        │   └── my-skill/
        │       ├── SKILL.md      # Skill definition (frontmatter + instructions)
        │       └── references/   # Optional supporting docs the skill can load
        ├── agents/               # Optional: specialized Claude instances
        │   └── my-agent.md
        ├── hooks/                # Optional: lifecycle event scripts
        │   └── PreToolUse.sh
        └── commands/             # Optional: explicit slash commands
            └── my-command.md
```

**Why this structure:** Each plugin is a self-contained unit. Skills, agents, hooks, and commands inside a plugin are **auto-discovered** by Claude Code from their standard subdirectory names — no manual registration inside the plugin is needed. The marketplace catalog (`marketplace.json`) only needs to know where each plugin lives (`source`); Claude Code handles the rest.

## Component Roles

| Component | What it does | Directory |
|---|---|---|
| `marketplace.json` | Lists all plugins and their source paths; entry point for `/plugin marketplace add` | `.claude-plugin/` |
| `plugin.json` | Declares the plugin's name, version, and description | `plugins/<name>/.claude-plugin/` |
| `SKILL.md` | Auto-invoked or command-invoked instructions injected into Claude's context | `plugins/<name>/skills/<skill>/` |
| `agents/*.md` | Defines a specialized Claude instance with its own system prompt and constraints | `plugins/<name>/agents/` |
| `hooks/*.sh` | Shell scripts that run unconditionally on lifecycle events | `plugins/<name>/hooks/` |
| `commands/*.md` | Explicit user-invoked slash commands | `plugins/<name>/commands/` |

## Steps

### 1. Create the `plugins/` directory and move skills

For each skill (or group of related skills), create a plugin directory:

```
plugins/
└── my-plugin/
    ├── .claude-plugin/
    │   └── plugin.json
    └── skills/
        └── my-skill/
            └── SKILL.md
```

Move existing `SKILL.md` files from the repo root into their plugin's `skills/<skill-name>/` directory. Keep any `references/` or `scripts/` subdirectories alongside the `SKILL.md` they belong to.

### 2. Create each `plugin.json`

Place this file at `plugins/<plugin-name>/.claude-plugin/plugin.json`:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "What this plugin does in one sentence"
}
```

**Field notes:**
- `name`: must match the plugin directory name and the `name` used in `marketplace.json`
- `version`: semver string; bump when releasing changes
- `description`: shown in plugin listings

### 3. Create `.claude-plugin/marketplace.json`

Create the directory and file at the repo root:

```
.claude-plugin/
└── marketplace.json
```

Official format:

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "<marketplace-name>",
  "version": "1.0.0",
  "description": "<one-line description>",
  "owner": {
    "name": "<your-github-username>"
  },
  "plugins": [
    {
      "name": "my-plugin",
      "description": "What this plugin does",
      "source": "./plugins/my-plugin"
    }
  ]
}
```

**Field notes:**
- `name` (top-level): identifier for the marketplace — used in `/plugin marketplace add <github-user>/<repo>` as the name Claude Code tracks the marketplace by
- `plugins[].name`: identifier for the installable plugin — used in `/plugin install <plugin-name>@<marketplace-name>`
- `plugins[].source`: relative path from the repo root to the plugin directory
- Multiple plugins in one marketplace are fine — one plugin per logical domain or audience

### 4. Update `CLAUDE.md`

Add or update:
- A **Plugin Marketplace Setup** section documenting the marketplace name, plugin names, and install commands
- An **Existing Plugins** table listing each plugin, its skills, and their slash commands
- An **Adding a New Skill** checklist

Minimal structure:

```markdown
# my-marketplace

## Plugin Marketplace Setup

- **Marketplace name**: `my-marketplace`
- **Install**:
  ```
  /plugin marketplace add <github-username>/<repo-name>
  /plugin install my-plugin@my-marketplace
  ```

## Existing Plugins

| Plugin | Skill | Slash command | Description |
|--------|-------|--------------|-------------|
| `my-plugin` | `my-skill` | `/my-skill` | Does X |

## Adding a New Skill

1. Create `plugins/<plugin-name>/skills/<skill-name>/SKILL.md`
2. Add a row to the **Existing Plugins** table above
3. Add a row to the skills table in `README.md`
4. Push to GitHub and test with `/plugin install <plugin-name>@<marketplace-name>`
```

### 5. Create a `README.md`

Users need to know how to install. Provide at minimum:

```markdown
## Installation

/plugin marketplace add <github-username>/<repo-name>
/plugin install <plugin-name>@<marketplace-name>
```

Also include a table of available plugins and their skills with slash commands.

### 6. Push to GitHub and test

The marketplace must be a public GitHub repository. In a fresh Claude Code session:

```
/plugin marketplace add <github-username>/<repo-name>
/plugin install <plugin-name>@<marketplace-name>
```

Verify skills appear and trigger correctly.

## Agents

Agents defined in `plugins/<name>/agents/*.md` are registered as Task tool subagent types automatically when the plugin is installed. No extra step is required — Claude Code discovers them from the `agents/` directory.

An agent file looks like:

```markdown
---
name: my-agent
description: "Use for X tasks. Triggered when..."
model: sonnet
color: blue
skills:
  - my-skill-name
---

You are a specialist in X. When given a task, you will...
```

The `description` field controls when Claude spawns this agent via the Task tool. The `skills` field lists the skill names the agent should have access to — without it, the agent runs without any plugin skills enabled.

## Example: This Repository (`j0rsa-skills`)

| File | Purpose |
|---|---|
| `.claude-plugin/marketplace.json` | Registers `j0rsa-skills` marketplace with three plugins |
| `plugins/punto/.claude-plugin/plugin.json` | Declares `punto` plugin v1.0.0 |
| `plugins/punto/skills/punto/SKILL.md` | Auto-invoked skill for keyboard layout fixing |
| `plugins/marketplace-skills-creator/.claude-plugin/plugin.json` | Declares `marketplace-skills-creator` plugin |
| `plugins/marketplace-skills-creator/skills/marketplace-skills-creator/SKILL.md` | This skill |

Install:
```
/plugin marketplace add j0rsa/claude-skills
/plugin install punto@j0rsa-skills
```
