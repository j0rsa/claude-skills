# j0rsa-skills

Personal Claude Code plugin marketplace by j0rsa.

## Installation

```
/plugin marketplace add j0rsa/claude-skills
/plugin install punto@j0rsa-skills
/plugin install marketplace-skills-creator@j0rsa-skills
/plugin install homeassistant-apps@j0rsa-skills
```

## Plugins

| Plugin | Skill | Slash command | Description |
|--------|-------|--------------|-------------|
| `punto` | `punto` | auto-detected¹ | Fixes text typed on the wrong keyboard layout (EN ↔ RU/UK) |
| `marketplace-skills-creator` | `marketplace-skills-creator` | `/marketplace-skills-creator` | Sets up and maintains Claude Code plugin marketplaces |
| `homeassistant-apps` | `homeassistant-apps` | — | Home Assistant app development for j0rsa/home-assistant-apps (+ agent) |

¹ `punto` is designed to trigger automatically when Claude detects garbled text from a wrong keyboard layout.
