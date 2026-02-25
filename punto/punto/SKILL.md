---
name: punto
description: >
  Detects and fixes text typed on the wrong keyboard layout (Punto Switcher-style).
  Use when a user sends gibberish that looks like it was typed with the wrong language active —
  e.g. Cyrillic characters when they meant English, or Latin gibberish when they meant Russian/Ukrainian.
  Triggers on "wrong layout", "typed in wrong language", "fix my layout", "/punto",
  text that is clearly garbled or gibberish due to keyboard layout mismatch,
  or when the user pastes random-looking Cyrillic or Latin strings and asks what it means or to fix it.
  Supports bidirectional conversion between EN and RU (standard ЙЦУКЕН), EN and RU phonetic, EN and UK (Ukrainian), EN and UK phonetic.
---

# Punto

Converts text typed on the wrong keyboard layout between English, Russian, and Ukrainian.

## Workflow

1. **Identify the input type**:
   - Mostly Cyrillic → user typed in Russian/Ukrainian layout, likely meant English
   - Mostly Latin gibberish → user typed in English layout, likely meant Cyrillic
   - Mixed or unclear → ask which direction they want

2. **Run the conversion script**:

```bash
# Auto-detect (shows all plausible conversions)
python3 ~/.claude/skills/punto/scripts/convert.py "input text"

# Explicit direction
python3 ~/.claude/skills/punto/scripts/convert.py "input text" --from ru --to en
python3 ~/.claude/skills/punto/scripts/convert.py "input text" --from en --to ru
```

Available `--from`/`--to` values: `en`, `ru`, `ru-phonetic`, `uk`, `uk-phonetic`

3. **Pick the correct result**: The `en→ru` and `ru→en` variants (standard ЙЦУКЕН) are almost always the right ones for Russian users. `ru-phonetic→en` gives Latin transliteration (e.g. "privet"), not the actual fix. Show the user only the meaningful result; don't dump all variants unless it's ambiguous.

4. **Present clearly**:

```
You typed on the wrong layout. Here's the fix:

"ghbdtn" → "привет"
```

## Examples

| Input | Direction | Output |
|-------|-----------|--------|
| `ghbdtn` | en→ru | `привет` |
| `Руддщ` | ru→en | `Hello` |
| `Привет` (when meant English) | ru→en | `Ghbdtn` → ask user |
| `yt,z` | en→ru | `нет,я` (нет, я) |

## Resources

- **`scripts/convert.py`** — conversion script, run it with the input text
- **`references/mappings.md`** — full character mapping tables for all four layout pairs (load if you need to explain a specific key or debug an edge case)
