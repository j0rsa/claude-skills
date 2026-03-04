---
name: marketplace-skills-creator
description: "Manages Claude Code skills repositories as plugin marketplaces. Use when the user wants to convert a local skills folder into a Claude Code plugin marketplace, set up a new marketplace repo, add a new skill to an existing marketplace, add a plugin to an existing marketplace, or symlink marketplace skills locally for live development. Triggers on: 'create marketplace', 'convert to marketplace', 'add skill to marketplace', 'add plugin to marketplace', 'skills marketplace setup', 'publish skills', 'register plugin', 'link plugin locally', 'symlink skill', 'load skill locally', '/marketplace-skills-creator', '/link-plugin-locally'."
---

# Marketplace Skills Creator

Set up and maintain Claude Code plugin marketplaces — repositories that users can add via `/plugin marketplace add` and install plugins from with `/plugin install`.

## Plugin System Concepts

Understanding the hierarchy is essential before working in any marketplace repo:

**Marketplace** — a GitHub repository acting as a catalog. It contains a `.claude-plugin/marketplace.json` that lists plugins and where to find them. Users register a marketplace once (`/plugin marketplace add owner/repo`) and then install individual plugins from it. One repo = one marketplace.

**Plugin** — the distributable unit. A plugin is a subdirectory under `plugins/` that groups related functionality together. It has its own `.claude-plugin/plugin.json` manifest and can contain any combination of skills, agents, hooks, commands, and MCP server configs. Users install a plugin with `/plugin install <name>@<marketplace>`.

**Skill** — a context-aware instruction set defined in a `SKILL.md` file inside a plugin's `skills/<skill-name>/` directory. A skill can be:
- *Auto-invoked*: Claude reads the `description` frontmatter and activates the skill when the context matches — no slash command needed.
- *Command-invoked*: Added as a slash command when `disable-model-invocation: true` is set, requiring explicit user invocation (`/skill-name`).
Skills inject instructions and domain knowledge into Claude's context for a specific task or domain.

**Agent** — a specialized Claude instance defined in a `agents/<agent-name>.md` file inside a plugin. Agents have a system prompt, optional tool restrictions, a model choice, memory settings, and an optional list of skills to enable. They are spawned via the Task tool (subagents) or set as the default Claude Code personality via `settings.json`. Agents are best for autonomous, focused subtasks that need their own context and constraints.

**Hook** — a shell script in a plugin's `hooks/` directory that runs automatically at specific lifecycle events (e.g. `PreToolUse`, `PostToolUse`, `SessionStart`, `Stop`). Hooks are deterministic and always fire — use them for guardrails, linting, logging, or blocking unwanted behavior. Unlike skills, hooks are not context-aware; they run unconditionally.

**Command** — an explicit slash command defined in a plugin's `commands/` directory. Commands are always user-invoked and are best for one-off actions with well-defined inputs (e.g. `/deploy`, `/review-pr`).

**MCP server** — a connection to an external tool or data source, configured in a plugin's `mcp/` directory. MCP servers give Claude real-time access to services (GitHub, databases, APIs) it cannot reach otherwise.

## Plugin Directory Layout

Every marketplace follows this canonical structure:

```
my-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # Catalog: lists all plugins
├── README.md
├── CLAUDE.md
└── plugins/
    └── my-plugin/
        ├── .claude-plugin/
        │   └── plugin.json       # Plugin manifest
        ├── skills/
        │   └── my-skill/
        │       ├── SKILL.md      # Skill definition
        │       └── references/   # Optional supporting docs
        ├── agents/               # Optional
        │   └── my-agent.md
        ├── hooks/                # Optional
        │   └── PreToolUse.sh
        └── commands/             # Optional
            └── my-command.md
```

Each plugin is self-contained. Skills and other components inside a plugin are auto-discovered by Claude Code from their standard subdirectory names — no manual registration within the plugin is needed.

## Tasks

Identify which task the user needs and load the appropriate reference:

| Task | When to use | Reference |
|---|---|---|
| **Convert to marketplace** | User has a repo with skill/agent files and wants to publish it as an installable marketplace | [references/convert-to-marketplace.md](references/convert-to-marketplace.md) |
| **Add a skill to a plugin** | User already has a marketplace repo and wants to add a new skill inside an existing plugin | [references/add-skill-to-marketplace.md](references/add-skill-to-marketplace.md) |
| **Link plugin locally** (`/link-plugin-locally`) | User wants to symlink skills from a checked-out marketplace repo into `~/.claude/skills/` so edits take effect immediately without reinstalling | [references/link-plugin-locally.md](references/link-plugin-locally.md) |

If unclear which task applies, ask:

- "Do you already have a `.claude-plugin/marketplace.json` in your repo?"
  - **No** → Convert to marketplace
  - **Yes** → Add a skill to an existing plugin (or add a new plugin)
- "Do you want edits to your skill files to be picked up by Claude Code immediately, without reinstalling?"
  - **Yes** → Link plugin locally

## Conventions in This Repo

When working in a repository that uses this skill, follow the conventions established in `CLAUDE.md`.

- Each skill that relies on a framework or workflow keeps its supporting documentation in `references/*.md` next to its `SKILL.md`
- When a new plugin or skill is added, the **Existing Plugins** table in `CLAUDE.md` and the plugins table in `README.md` must both be updated
