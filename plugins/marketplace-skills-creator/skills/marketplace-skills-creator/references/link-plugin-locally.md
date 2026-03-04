# Link Marketplace Plugin Locally

Use this when you want to develop and publish skills through a marketplace repo while also having them load live in your current Claude Code session — edits to the source files take effect immediately without reinstalling the plugin.

## Why

`/plugin install` copies skills into Claude Code's internal storage. Any change you make to the source repo requires another install cycle to be picked up. Symlinking bypasses this: Claude Code reads the skill directly from your checked-out repo on every invocation.

## How It Works

The script reads `.claude-plugin/marketplace.json` from the repo root, resolves each plugin's `source` path, finds all skill directories under `<plugin-source>/skills/`, and creates symlinks at `~/.claude/skills/<plugin-name>/<skill-name>` — always namespaced under the plugin.

> **Note:** This script links **skills only**. Plugin agents (in `agents/`) are not linked here — they must be installed via `/plugin install` or added manually to `~/.claude/agents/`.

## Prerequisites

- `jq` must be installed (`brew install jq` or `apt install jq`)
- The repo must have `.claude-plugin/marketplace.json`
- Plugins must follow the standard layout: `plugins/<name>/skills/<skill-name>/SKILL.md`

## Usage

Run the script from the **root of your marketplace repo**:

```bash
# Link all skills discovered across all plugins
bash /path/to/marketplace-skills-creator/scripts/link_skill_locally.sh

# Preview without making changes
bash /path/to/marketplace-skills-creator/scripts/link_skill_locally.sh --dry-run

# Link only specific skills (by skill name)
bash /path/to/marketplace-skills-creator/scripts/link_skill_locally.sh punto

# Force-replace existing symlinks
bash /path/to/marketplace-skills-creator/scripts/link_skill_locally.sh --force
```

If this skill is itself installed or symlinked locally:

```bash
bash ~/.claude/skills/marketplace-skills-creator/scripts/link_skill_locally.sh
```

## Flags

| Flag | Effect |
|---|---|
| `--force` | Replaces existing symlinks. If the target is a real directory (non-symlink), deletes it — **back up any local-only work first** |
| `--dry-run` | Prints what would happen without creating or removing anything |

## Override an Existing Locally Developed Skill

If you have a skill you've been developing locally at `~/.claude/skills/<plugin-name>/<skill-name>` and you now want to replace it with the marketplace version, use `--force`:

```bash
bash ~/.claude/skills/marketplace-skills-creator/scripts/link_skill_locally.sh --force <skill-name>
```

**Before running `--force` on a real directory:**
1. Check if it's already a symlink: `ls -la ~/.claude/skills/<plugin-name>/<skill-name>`
2. If it's a real folder with unpublished changes, copy them into the repo first
3. Then run with `--force`

## Re-link After a Pull

After pulling upstream changes that add new skills, re-run the script (without `--force`) to pick up the new skill directories. Already-linked skills are detected by their source path and skipped automatically.

## Verify

After linking, confirm the symlinks are in place:

```bash
ls -la ~/.claude/skills/
# or with a modern tool:
eza -la ~/.claude/skills/
```

Restart (or reload) your Claude Code session so it picks up the newly available skills.

## Example Walkthrough

**Repo:** `~/projects/claude-skills` (marketplace `j0rsa-skills`, plugin `punto`, skill `punto`)

```bash
cd ~/projects/claude-skills
bash ~/.claude/skills/marketplace-skills-creator/scripts/link_skill_locally.sh
```

Output:
```
Repo root  : /Users/user/projects/claude-skills
Skills dir : /Users/user/.claude/skills

Skill : punto  (plugin: punto)
  source → /Users/user/projects/claude-skills/plugins/punto/skills/punto
  target → /Users/user/.claude/skills/punto/punto
  ✓ Linked

────────────────────────────────────────────
  Linked  : 1
  Skipped : 0
  Errors  : 0
```

**Repo:** `~/projects/my-skills` (plugin `my-plugin` with two skills: `skill-a` and `skill-b`)

```bash
cd ~/projects/my-skills
bash ~/.claude/skills/marketplace-skills-creator/scripts/link_skill_locally.sh
```

Creates:
```
~/.claude/skills/
└── my-plugin/
    ├── skill-a   → /projects/my-skills/plugins/my-plugin/skills/skill-a
    └── skill-b   → /projects/my-skills/plugins/my-plugin/skills/skill-b
```
