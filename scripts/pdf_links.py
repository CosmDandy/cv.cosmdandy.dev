#!/usr/bin/env python3
"""Координаты ссылок внутри PDF — для кликабельного слоя поверх превью."""

import json
import sys
from pathlib import Path

from pypdf import PdfReader


def extract(pdf_path: Path) -> list[list[dict]]:
    """Ссылки каждой страницы PDF в процентах от её размера.

    Проценты, а не пункты и не пиксели: превью на странице тянется зумом и
    шириной экрана, а слой поверх него обязан ехать вместе с листом. Процент
    от размера страницы — единственная величина, которая при этом не врёт.

    PDF отсчитывает координаты снизу вверх, CSS — сверху вниз, поэтому top
    считается от верхней грани прямоугольника, а не от нижней.
    """
    pages = []
    for page in PdfReader(str(pdf_path)).pages:
        width = float(page.mediabox.width)
        height = float(page.mediabox.height)
        links = []
        annots = page.get("/Annots")
        for ref in annots.get_object() if annots is not None else []:
            annot = ref.get_object()
            if annot.get("/Subtype") != "/Link":
                continue
            action = annot.get("/A")
            action = action.get_object() if action is not None else None
            uri = action.get("/URI") if action is not None else None
            if uri is None:
                # Переходы внутри документа: на одностраничном превью им некуда вести.
                continue
            x0, y0, x1, y1 = (float(v) for v in annot["/Rect"])
            links.append(
                {
                    "url": str(uri),
                    "left": round(min(x0, x1) / width * 100, 3),
                    "top": round((height - max(y0, y1)) / height * 100, 3),
                    "width": round(abs(x1 - x0) / width * 100, 3),
                    "height": round(abs(y1 - y0) / height * 100, 3),
                }
            )
        pages.append(links)
    return pages


if __name__ == "__main__":
    print(json.dumps(extract(Path(sys.argv[1])), ensure_ascii=False, indent=2))
