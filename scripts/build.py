#!/usr/bin/env python3
"""Generate LaTeX CV files from YAML data and Jinja2 template."""

import argparse
import shutil
import sys
from datetime import date
from pathlib import Path

import yaml
from jinja2 import Environment, FileSystemLoader


TEMPLATE_DIR = Path(__file__).resolve().parent.parent / "template"

TEMPLATES = {
    "cv": {"template": "cv.tex.j2", "cls": "developercv.cls"},
    "ats": {"template": "cv-ats.tex.j2", "cls": "developercv-ats.cls"},
}

LATEX_SPECIAL = {
    "&": r"\&",
    "%": r"\%",
    "$": r"\$",
    "#": r"\#",
    "_": r"\_",
    "~": r"\textasciitilde{}",
    "^": r"\^{}",
}


def escape_latex(value):
    """Escape LaTeX special characters in a string."""
    if not isinstance(value, str):
        return value
    for char, replacement in LATEX_SPECIAL.items():
        value = value.replace(char, replacement)
    return value


def create_jinja_env():
    """Configure Jinja2 with LaTeX-safe delimiters."""
    env = Environment(
        loader=FileSystemLoader(str(TEMPLATE_DIR)),
        variable_start_string="(((",
        variable_end_string=")))",
        block_start_string="((* ",
        block_end_string=" *))",
        comment_start_string="((# ",
        comment_end_string=" #))",
        trim_blocks=True,
        lstrip_blocks=True,
        autoescape=False,
        keep_trailing_newline=True,
    )
    env.filters["e"] = escape_latex
    return env


def format_period(start: date, end: date | None, lang: str) -> str:
    present = {"ru": "н.в.", "en": "present"}
    start_str = f"{start.month:02d}/{start.year}"
    end_str = present[lang] if end is None else f"{end.month:02d}/{end.year}"
    return f"{start_str} -- {end_str}"


def format_duration(start: date, end: date, lang: str) -> str:
    months = (end.year - start.year) * 12 + end.month - start.month + 1
    years, rem = divmod(months, 12)
    if lang == "ru":
        y_word = _ru_plural(years, "год", "года", "лет")
        m_word = _ru_plural(rem, "месяц", "месяца", "месяцев")
        parts = []
        if years:
            parts.append(f"{years} {y_word}")
        if rem:
            parts.append(f"{rem} {m_word}")
        return " ".join(parts) or "менее месяца"
    else:
        y_word = "year" if years == 1 else "years"
        m_word = "month" if rem == 1 else "months"
        parts = []
        if years:
            parts.append(f"{years} {y_word}")
        if rem:
            parts.append(f"{rem} {m_word}")
        return " ".join(parts) or "less than a month"


def _ru_plural(n: int, one: str, few: str, many: str) -> str:
    if 11 <= n % 100 <= 19:
        return many
    rem = n % 10
    if rem == 1:
        return one
    if 2 <= rem <= 4:
        return few
    return many


def _parse_date(val) -> date:
    if isinstance(val, date):
        return val
    return date.fromisoformat(str(val))


def compute_dates(data: dict) -> dict:
    today = date.today()
    for job in data.get("experience", []):
        positions = job.get("positions", [])
        for pos in positions:
            if "start_date" not in pos:
                continue
            start = _parse_date(pos["start_date"])
            end = _parse_date(pos["end_date"]) if "end_date" in pos else None
            effective_end = end or today
            pos["period"] = {
                lang: format_period(start, end, lang) for lang in ("ru", "en")
            }
            pos["duration"] = {
                lang: format_duration(start, effective_end, lang)
                for lang in ("ru", "en")
            }
        if len(positions) > 1:
            starts = [_parse_date(p["start_date"]) for p in positions if "start_date" in p]
            ends = [
                _parse_date(p["end_date"]) if "end_date" in p else None
                for p in positions
                if "start_date" in p
            ]
            total_start = min(starts)
            total_end = None if any(e is None for e in ends) else max(ends)
            effective_total_end = total_end or today
            job["total_period"] = {
                lang: format_period(total_start, total_end, lang)
                for lang in ("ru", "en")
            }
            job["total_duration"] = {
                lang: format_duration(total_start, effective_total_end, lang)
                for lang in ("ru", "en")
            }
        if "start_date" in job and "period" not in job:
            start = _parse_date(job["start_date"])
            end = _parse_date(job["end_date"]) if "end_date" in job else None
            effective_end = end or today
            job["period"] = {
                lang: format_period(start, end, lang) for lang in ("ru", "en")
            }
            job["duration"] = {
                lang: format_duration(start, effective_end, lang)
                for lang in ("ru", "en")
            }
    return data


def load_data(data_path):
    """Load CV data from YAML file."""
    with open(data_path, encoding="utf-8") as f:
        return yaml.safe_load(f)


def render_cv(env, data, lang, template_name):
    """Render CV template for a given language."""
    template = env.get_template(template_name)
    return template.render(lang=lang, **data)


def main():
    parser = argparse.ArgumentParser(description="Generate LaTeX CV from YAML data")
    parser.add_argument("--data", required=True, help="Path to cv-data.yaml")
    parser.add_argument("--lang", default="ru,en", help="Comma-separated languages (default: ru,en)")
    parser.add_argument("--output", default="output", help="Output directory (default: output)")
    parser.add_argument(
        "--template",
        default="cv",
        choices=TEMPLATES.keys(),
        help="Template variant (default: cv)",
    )
    args = parser.parse_args()

    data_path = Path(args.data)
    if not data_path.exists():
        print(f"Error: data file not found: {data_path}", file=sys.stderr)
        sys.exit(1)

    tpl_config = TEMPLATES[args.template]
    suffix = f"-{args.template}" if args.template != "cv" else ""

    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    cls_src = TEMPLATE_DIR / tpl_config["cls"]
    cls_dst = output_dir / tpl_config["cls"]
    if cls_src.exists():
        shutil.copy2(cls_src, cls_dst)

    data = compute_dates(load_data(data_path))
    if not data:
        print(f"Error: data file is empty or invalid: {data_path}", file=sys.stderr)
        sys.exit(1)

    env = create_jinja_env()
    langs = [l.strip() for l in args.lang.split(",")]

    for lang in langs:
        output_file = output_dir / f"CV-Timofey-Kondrashin{suffix}-{lang}.tex"
        rendered = render_cv(env, data, lang, tpl_config["template"])
        output_file.write_text(rendered, encoding="utf-8")
        print(f"Generated: {output_file}")


if __name__ == "__main__":
    main()
