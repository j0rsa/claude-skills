# Link Marketplace Plugin Locally

Use this when you want to develop and publish skills through a marketplace repo while also having them load live in your current Claude Code session — edits to the source files take effect immediately without reinstalling the plugin.

## Why

`/plugin install` copies skills into Claude Code's internal storage. Any change you make to the source repo requires another install cycle to be picked up. Symlinking bypasses this: Claude Code reads the skill directly from your checked-out repo on every invocation.

## How It Works

The script reads `.claude-plugin/marketplace.json` from the repo root, finds each registered skill path, and creates a symlink in `~/.claude/skills/`.

### Namespace detection

| Plugin condition | Target path |
|---|---|
| Plugin has **one** skill | `~/.claude/skills/<skill-name>` |
| Plugin has **multiple** skills | `~/.claude/skills/<plugin-name>/<skill-name>` |
| `--flat` flag used | `~/.claude/skills/<skill-name>` (always, no namespace folder) |

This matches the convention Claude Code uses when installing namespaced skills (e.g. `hookify:conversation-analyzer` lives at `~/.claude/skills/hookify/conversation-analyzer`).

## Prerequisites

- `jq` must be installed (`brew install jq` or `apt install jq`)
- The repo must have `.claude-plugin/marketplace.json`

## Usage

Run the script from the **root of your marketplace repo** (not from inside the skills folder):

```bash
# Link all skills in marketplace.json
bash /path/to/marketplace-skills-creator/scripts/link_skill_locally.sh

# Preview without making changes
bash /path/to/marketplace-skills-creator/scripts/link_skill_locally.sh --dry-run

# Link only specific skills
bash /path/to/marketplace-skills-creator/scripts/link_skill_locally.sh punto

# Force-replace existing symlinks
bash /path/to/marketplace-skills-creator/scripts/link_skill_locally.sh --force

# Skip namespace folders (flat layout)
bash /path/to/marketplace-skills-creator/scripts/link_skill_locally.sh --flat
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
| `--flat` | Links directly under `~/.claude/skills/<skill-name>` regardless of plugin size |

## Override an Existing Locally Developed Skill

If you have a skill you've been developing locally at `~/.claude/skills/<skill-name>` and you now want to replace it with the marketplace version (or make the marketplace version the live edit target), use `--force`:

```bash
bash ~/.claude/skills/marketplace-skills-creator/scripts/link_skill_locally.sh --force <skill-name>
```

**Before running `--force` on a real directory:**
1. Check if it's already a symlink: `ls -la ~/.claude/skills/<skill-name>`
2. If it's a real folder with unpublished changes, copy them into the repo first
3. Then run with `--force`

## Re-link After a Pull

After pulling upstream changes that add new skills to `marketplace.json`, re-run the script (without `--force`) to pick up the new skill paths. Already-linked skills are detected by their source path and skipped automatically.

## Verify

After linking, confirm the symlinks are in place:

```bash
ls -la ~/.claude/skills/
# or with a modern tool:
eza -la ~/.claude/skills/
```

Restart (or reload) your Claude Code session so it picks up the newly available skills.

## Example Walkthrough

**Repo:** `~/projects/claude-skills` (flat marketplace, one plugin `j0rsa-skills`, one skill `punto`)

```bash
cd ~/projects/claude-skills
bash ~/.claude/skills/marketplace-skills-creator/scripts/link_skill_locally.sh
```

Output:
```
Repo root  : /Users/user/projects/claude-skills
Skills dir : /Users/user/.claude/skills

Skill : punto  (plugin: j0rsa-skills)
  source → /Users/user/projects/claude-skills/punto
  target → /Users/user/.claude/skills/punto
  ✓ Linked

────────────────────────────────────────────
  Linked  : 1
  Skipped : 0
  Errors  : 0
```

**Repo:** `~/projects/zalando-skills` (hierarchical, plugin `zalando-employee`, skills `feedback-giver` + `focus-area-composer`)

```bash
cd ~/projects/zalando-skills
bash ~/.claude/skills/marketplace-skills-creator/scripts/link_skill_locally.sh
```

Creates:
```
~/.claude/skills/
└── zalando-employee/
    ├── feedback-giver     → /projects/zalando-skills/zalando-employee/skills/feedback-giver
    └── focus-area-composer → /projects/zalando-skills/zalando-employee/skills/focus-area-composer
```
