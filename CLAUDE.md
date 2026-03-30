# claude-skills

## Plugin Marketplace Setup

- **Marketplace name**: `j0rsa-skills`
- **Install**:
  ```
  /plugin marketplace add j0rsa/claude-skills
  /plugin install <plugin-name>@j0rsa-skills
  ```

## Existing Plugins

| Plugin | Skill | Slash command | Description |
|--------|-------|--------------|-------------|
| `punto` | `punto` | auto-detected¹ | Fixes text typed on the wrong keyboard layout (EN ↔ RU/UK) |
| `marketplace-skills-creator` | `marketplace-skills-creator` | `/marketplace-skills-creator` | Sets up and maintains Claude Code plugin marketplaces |
| `homeassistant-apps` | `homeassistant-apps` | — | Home Assistant app development for j0rsa/home-assistant-apps (+ agent) |

¹ `punto` is designed to trigger automatically when Claude detects garbled text from a wrong keyboard layout.

## Adding a New Skill

1. Create `plugins/<plugin-name>/skills/<skill-name>/SKILL.md` with valid frontmatter (`name` + `description`)
2. Add a row to the **Existing Plugins** table above
3. Add a row to the plugins table in `README.md`
4. Push to GitHub and test with `/plugin install <plugin-name>@j0rsa-skills`

## Adding a New Plugin

1. Create `plugins/<plugin-name>/.claude-plugin/plugin.json` with `name`, `version`, `description`
2. Create `plugins/<plugin-name>/skills/<skill-name>/SKILL.md`
3. Add a `plugins[]` entry to `.claude-plugin/marketplace.json` with `name` and `source`
4. Add rows to the **Existing Plugins** table above and to `README.md`
5. Push to GitHub and test with `/plugin install <plugin-name>@j0rsa-skills`
