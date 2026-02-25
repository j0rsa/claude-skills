# Convert a Local Skills Folder to a Marketplace

## What "local skills" means

A local skills setup is a folder of SKILL.md files that Claude Code can load directly when pointed at the directory — but which cannot be installed by other users via `/plugin install`. It has no plugin metadata.

## Step 0: Choose a repo structure

Ask the user which layout they want before creating any files:

> "Which repo structure would you like?
> - **Flat** — skills sit directly at the repo root (`<skill-name>/SKILL.md`). Best for a small, single-purpose skills repo.
> - **Hierarchical** — skills live under a namespace (`<namespace>/skills/<skill-name>/SKILL.md`). Best when the repo groups multiple namespaces or mixes skills with agents."

**Flat** (skills only):
```
my-repo/
├── skill-a/
│   └── SKILL.md
└── skill-b/
    └── SKILL.md
```

**Hierarchical** (skills + namespace):
```
my-repo/
└── my-namespace/
    └── skills/
        ├── skill-a/
        │   └── SKILL.md
        └── skill-b/
            └── SKILL.md
```

Both structures support the same `marketplace.json` — only the skill paths differ.

## What a marketplace adds

A marketplace is the same repo with a `.claude-plugin/marketplace.json` file. This file registers the repo as a named plugin source and groups skills into installable plugins. Once pushed to GitHub, any user can add the marketplace and install from it.

## Steps

### 1. Create `.claude-plugin/marketplace.json`

Create the directory and file at the repo root:

```
.claude-plugin/
└── marketplace.json
```

Minimal working schema:

```json
{
  "name": "<marketplace-name>",
  "metadata": {
    "description": "<one-line description>",
    "version": "1.0.0"
  },
  "plugins": [
    {
      "name": "<plugin-name>",
      "description": "<what this plugin contains>",
      "source": "./",
      "strict": false,
      "skills": [
        "./<path-to-skill-a>",    // flat:         ./skill-a
        "./<path-to-skill-b>"     // hierarchical: ./my-namespace/skills/skill-b
      ]
    }
  ]
}
```

**Field notes:**
- `name` (top-level): identifier for the marketplace — used in the `/plugin marketplace add` URL, e.g. `<github-user>/<repo>` maps to this name
- `plugins[].name`: identifier for the installable plugin — used in `/plugin install <plugin-name>@<marketplace-name>`
- `plugins[].source`: almost always `"./"` (repo root)
- `plugins[].strict`: `false` unless you want strict validation — leave `false` to start
- `plugins[].skills`: array of relative paths, one per skill folder (the folder containing `SKILL.md`)

Multiple plugins in one marketplace are allowed — use this to group skills by audience or purpose (e.g. `document-skills` and `team-skills`).

### 2. Create a `README.md`

Users need to know how to install. Provide at minimum:

```markdown
## Installation

/plugin marketplace add <github-username>/<repo-name>
/plugin install <plugin-name>@<marketplace-name>
```

Also include a table of the available skills with their slash commands and a one-line description each.

### 3. Push to GitHub

The marketplace must be a public GitHub repository. The `/plugin marketplace add` command takes the form:

```
/plugin marketplace add <github-username>/<repo-name>
```

### 4. Test the installation

In a fresh Claude Code session:

```
/plugin marketplace add <github-username>/<repo-name>
/plugin install <plugin-name>@<marketplace-name>
```

Verify the skills appear and trigger correctly.

### 5. Update CLAUDE.md (if present)

Add a **Plugin Marketplace Setup** section documenting:
- The marketplace name
- The plugin name(s)
- The install command

Also add each skill to the **Existing Skills** table and add a step to the **Adding a New Skill** checklist requiring the developer to register the skill path in `marketplace.json`.

## Examples

### Hierarchical: this repository (`zalando-employee-skills`)

| File | Purpose |
|---|---|
| `.claude-plugin/marketplace.json` | Registers `zalando-employee-skills` marketplace with one plugin `zalando-employee` |
| `README.md` | Install instructions + skills table |
| `CLAUDE.md` | Marketplace setup section + Existing Skills table |

Skills registered with namespace paths:
```json
"skills": [
  "./zalando-employee/skills/feedback-giver",
  "./zalando-employee/skills/focus-area-composer"
]
```

### Flat: a single-purpose skills repo (`j0rsa-skills`)

Skills registered directly at repo root:
```json
"skills": [
  "./punto"
]
```

Install:
```
/plugin marketplace add j0rsa/claude-skills
/plugin install punto@j0rsa-skills
```
