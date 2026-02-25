# j0rsa-skills

Personal Claude Code skills marketplace by j0rsa.

## Installation

```
/plugin marketplace add j0rsa/claude-skills
/plugin install punto@j0rsa-skills
/plugin install marketplace-skills-creator@j0rsa-skills
```

## Skills

| Skill | Plugin | Slash command | Description |
|-------|--------|--------------|-------------|
| `punto` | `punto` | auto-detected¹ | Fixes text typed on the wrong keyboard layout (EN ↔ RU/UK) |
| `marketplace-skills-creator` | `marketplace-skills-creator` | `/marketplace-skills-creator` | Sets up and maintains Claude Code plugin marketplaces |

¹ `punto` is designed to trigger automatically when Claude detects garbled text from a wrong keyboard layout. `/punto` works too but is just a side effect of how skills are registered — you don't need to invoke it explicitly.
