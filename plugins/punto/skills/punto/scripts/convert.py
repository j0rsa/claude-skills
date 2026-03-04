#!/usr/bin/env python3
"""
Punto keyboard layout converter.

Converts text typed on the wrong keyboard layout between English,
Russian (standard ЙЦУКЕН + phonetic), and Ukrainian layouts.

Usage:
  python convert.py "текст"                          # auto-detect and show all conversions
  python convert.py "текст" --from ru --to en        # explicit conversion
  python convert.py "ghbdtn" --from en --to ru       # en gibberish → Russian
"""

import sys
import argparse

# Keyboard layout strings from Raycast Punto extension (Dict.ts)
# Each character at position i maps to the same position in paired layout
EN_LAYOUT           = "`1234567890-=~!@#$%^&*()_+qwertyuiop[]\\QWERTYUIOP{}|asdfghjkl;'ASDFGHJKL:\"zxcvbnm,./ZXCVBNM<>?"
RU_LAYOUT           = "]1234567890-=[!\"№%:,.;()_+йцукенгшщзхъёЙЦУКЕНГШЩЗХЪЁфывапролджэФЫВАПРОЛДЖЭячсмитьбю/ЯЧСМИТЬБЮ?"
RU_PHONETIC_LAYOUT  = "щ1234567890ьъЩ!@#$%^&*()ЬЪяшертыуиопюжэЯШЕРТЫУИОПЮЖЭасдфгчйкл;'АСДФГЧЙКЛ:\"зхцвбнм,./ЗХЦВБНМ<>?"
UK_LAYOUT           = "ґ1234567890-=Ґ!\"№;%:?*()_+йцукенгшщзхїʼЙЦУКЕНГШЩЗХЇ₴фівапролджєФІВАПРОЛДЖЄячсмитьбю.ЯЧСМИТЬБЮ,"
UK_PHONETIC_LAYOUT  = "ь1234567890-=Ь!@#$%^&*()_+яшертиуіопюжєЯШЕРТИУІОПЮЖЄасдфгчйкл;'АСДФГЧЙКЛ:\"зхцвбнм,./ЗХЦВБНМ<>?"


def generate_map(src: str, dst: str) -> dict[str, str]:
    return {s: d for s, d in zip(src, dst) if s != d}


# Bidirectional maps for all layout pairs
MAPS: dict[str, dict[str, str]] = {
    "en→ru":           generate_map(EN_LAYOUT, RU_LAYOUT),
    "ru→en":           generate_map(RU_LAYOUT, EN_LAYOUT),
    "en→ru-phonetic":  generate_map(EN_LAYOUT, RU_PHONETIC_LAYOUT),
    "ru-phonetic→en":  generate_map(RU_PHONETIC_LAYOUT, EN_LAYOUT),
    "en→uk":           generate_map(EN_LAYOUT, UK_LAYOUT),
    "uk→en":           generate_map(UK_LAYOUT, EN_LAYOUT),
    "en→uk-phonetic":  generate_map(EN_LAYOUT, UK_PHONETIC_LAYOUT),
    "uk-phonetic→en":  generate_map(UK_PHONETIC_LAYOUT, EN_LAYOUT),
}


def convert(text: str, mapping: dict[str, str]) -> str:
    return "".join(mapping.get(c, c) for c in text)


def is_cyrillic(c: str) -> bool:
    return "\u0400" <= c <= "\u04FF"


def detect_dominant(text: str) -> str:
    """Return 'cyrillic', 'latin', or 'mixed'."""
    cyrillic = sum(1 for c in text if is_cyrillic(c))
    latin = sum(1 for c in text if c.isalpha() and c.isascii())
    total = cyrillic + latin
    if total == 0:
        return "unknown"
    ratio = cyrillic / total
    if ratio >= 0.8:
        return "cyrillic"
    if ratio <= 0.2:
        return "latin"
    return "mixed"


def auto_convert(text: str) -> dict[str, str]:
    """Return all plausible conversions based on detected character type."""
    dominant = detect_dominant(text)
    if dominant == "cyrillic":
        # Typed in Cyrillic layout, meant to type in English
        return {k: convert(text, v) for k, v in MAPS.items() if k.endswith("→en")}
    if dominant == "latin":
        # Typed in English layout, meant to type in Cyrillic/Ukrainian
        return {k: convert(text, v) for k, v in MAPS.items() if k.startswith("en→")}
    return {}


def main() -> None:
    parser = argparse.ArgumentParser(description="Punto keyboard layout converter")
    parser.add_argument("text", help="Text to convert")
    parser.add_argument(
        "--from", dest="from_layout",
        choices=["en", "ru", "ru-phonetic", "uk", "uk-phonetic"],
        help="Source keyboard layout",
    )
    parser.add_argument(
        "--to", dest="to_layout",
        choices=["en", "ru", "ru-phonetic", "uk", "uk-phonetic"],
        help="Target keyboard layout",
    )
    args = parser.parse_args()

    if args.from_layout and args.to_layout:
        key = f"{args.from_layout}→{args.to_layout}"
        if key not in MAPS:
            print(f"Error: no mapping for {key}. Supported: {', '.join(MAPS)}", file=sys.stderr)
            sys.exit(1)
        print(convert(args.text, MAPS[key]))
    else:
        results = auto_convert(args.text)
        if not results:
            dominant = detect_dominant(args.text)
            print(f"Could not auto-convert: text appears {dominant}.", file=sys.stderr)
            sys.exit(1)
        for name, converted in results.items():
            print(f"{name}: {converted}")


if __name__ == "__main__":
    main()
