#!/usr/bin/env python3
"""Generate index.html with language-specific content filtered by enabled languages."""

import argparse
import re
import sys
from html import escape
from pathlib import Path

from pdf_links import extract

MARKER_RE = re.compile(
    r"[ \t]*(?://|<!--)\s*LANG:(\w+):start\s*(?:-->)?\n"
    r"(.*?)"
    r"[ \t]*(?://|<!--)\s*LANG:\1:end\s*(?:-->)?\n",
    re.DOTALL,
)

LINKS_RE = re.compile(r"([ \t]*)<!--\s*LINKS:(\w+)\s*-->\n")


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
        # Имя картинки теперь встречается в preload трижды (href, imagesrcset с
        # двумя размерами), поэтому точечная замена по одной строке href больше
        # не годится. Блок LANG:en к этому моменту уже вырезан, так что всё
        # оставшееся «cv-en-1» — из preload, и заменять можно скопом.
        result = result.replace("cv-en-1", f"cv-{lang}-1")
        result = re.sub(
            r'style="display:none"',
            "",
            result,
        )

    return result


def inject_links(html: str, pdf_dir: Path) -> str:
    """Заменить маркеры LINKS:<lang> прозрачными ссылками поверх превью.

    Превью — растр, и все ссылки, ради которых резюме и раздают в PDF, на нём
    мертвы. Координаты берём из link-аннотаций самого PDF, поэтому слой не
    нужно подправлять руками после каждой правки резюме: он пересобирается
    вместе с ним и не может разъехаться с текстом.
    """

    def replacer(m: re.Match) -> str:
        indent, lang = m.group(1), m.group(2)
        pdf = pdf_dir / f"CV-Timofey-Kondrashin-{lang}.pdf"
        pages = extract(pdf)
        if not pages[0]:
            # В резюме ссылки есть всегда. Ноль означает, что сломался
            # hyperref или PDF собран не тем, чем мы думаем, — молча отдать
            # страницу без слоя хуже, чем не отдать её вовсе.
            print(f"Error: no links found in {pdf}", file=sys.stderr)
            sys.exit(1)
        if len(pages) > 1:
            print(f"Warning: {pdf.name} has {len(pages)} pages, linking only the first")

        out = []
        for link in pages[0]:
            url = escape(link["url"])
            # Почта открывается в почтовом клиенте, и target здесь оставил бы
            # после себя пустую вкладку.
            new_tab = "" if link["url"].startswith("mailto:") else ' target="_blank" rel="noopener"'
            pos = "left:{left}%;top:{top}%;width:{width}%;height:{height}%".format(**link)
            out.append(
                f'{indent}<a class="pdf-link" href="{url}"{new_tab} '
                f'aria-label="{url}" style="{pos}"></a>\n'
            )
        return "".join(out)

    return LINKS_RE.sub(replacer, html)


def main():
    parser = argparse.ArgumentParser(description="Generate index.html for enabled languages")
    parser.add_argument("--langs", required=True, help="Comma-separated enabled languages (e.g. en,ru)")
    parser.add_argument("--input", default="pages/index.html", help="Source HTML file")
    parser.add_argument("--output", default="_site/index.html", help="Output HTML file")
    parser.add_argument("--pdf-dir", required=True, type=Path, help="Directory with compiled CV PDFs")
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
    # Языки фильтруются первыми: у выключенного языка вместе с блоком уезжает
    # и маркер слоя, так что разбирать заведомо ненужный PDF не придётся.
    result = inject_links(filter_langs(html, enabled), args.pdf_dir)

    dst = Path(args.output)
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(result, encoding="utf-8")
    print(f"Generated: {dst} (langs: {','.join(sorted(enabled))})")


if __name__ == "__main__":
    main()
