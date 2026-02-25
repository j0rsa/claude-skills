# claude-skills

## Plugin Marketplace Setup

- **Marketplace name**: `j0rsa-skills`
- **Plugin name**: `punto`
- **Install**:
  ```
  /plugin marketplace add j0rsa/claude-skills
  /plugin install punto@j0rsa-skills
  ```

## Existing Skills

| Skill | Slash command | Description |
|-------|--------------|-------------|
| `punto` | `/punto` | Fixes text typed on the wrong keyboard layout (EN ↔ RU/UK) |
| `homeassistant-apps` | — | Home Assistant app development for j0rsa/home-assistant-apps |

## Adding a New Skill

1. Create `<skill-name>/SKILL.md` with valid frontmatter (`name` + `description`)
2. Add the skill path to `.claude-plugin/marketplace.json` → `plugins[0].skills`
3. Add a row to the **Existing Skills** table above
4. Add a row to the skills table in `README.md`
5. Push to GitHub and test with `/plugin install punto@j0rsa-skills`
