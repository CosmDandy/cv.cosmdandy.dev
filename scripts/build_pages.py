#!/usr/bin/env python3
"""Generate index.html with language-specific content filtered by enabled languages."""

import argparse
import re
import sys
from pathlib import Path


MARKER_RE = re.compile(
    r"[ \t]*(?://|<!--)\s*LANG:(\w+):start\s*(?:-->)?\n"
    r"(.*?)"
    r"[ \t]*(?://|<!--)\s*LANG:\1:end\s*(?:-->)?\n",
    re.DOTALL,
)


def filter_langs(html: str, enabled: set[str]) -> str:
    def replacer(m: re.Match) -> str:
        tag = m.group(1)
        if tag == "multi":
            return m.group(2) if len(enabled) > 1 else ""
        if tag in enabled:
            return m.group(2)
        return ""

    result = MARKER_RE.sub(replacer, html)

    if len(enabled) == 1:
        lang = next(iter(enabled))
        result = result.replace(
            "let currentLang = 'en'",
            f"let currentLang = '{lang}'",
        )
        result = result.replace(
            f'href="CV-Timofey-Kondrashin-en.pdf"',
            f'href="CV-Timofey-Kondrashin-{lang}.pdf"',
        )
        result = result.replace(
            f'href="cv-en-1.webp"',
            f'href="cv-{lang}-1.webp"',
        )
        result = re.sub(
            r'style="display:none"',
            "",
            result,
        )

    return result


def main():
    parser = argparse.ArgumentParser(description="Generate index.html for enabled languages")
    parser.add_argument("--langs", required=True, help="Comma-separated enabled languages (e.g. en,ru)")
    parser.add_argument("--input", default="pages/index.html", help="Source HTML file")
    parser.add_argument("--output", default="_site/index.html", help="Output HTML file")
    args = parser.parse_args()

    enabled = {l.strip() for l in args.langs.split(",")}
    if not enabled:
        print("Error: at least one language must be enabled", file=sys.stderr)
        sys.exit(1)

    src = Path(args.input)
    if not src.exists():
        print(f"Error: {src} not found", file=sys.stderr)
        sys.exit(1)

    html = src.read_text(encoding="utf-8")
    result = filter_langs(html, enabled)

    dst = Path(args.output)
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(result, encoding="utf-8")
    print(f"Generated: {dst} (langs: {','.join(sorted(enabled))})")


if __name__ == "__main__":
    main()
