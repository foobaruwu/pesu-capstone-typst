#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["pymupdf>=1.25"]
# ///
"""Flatten the shared boilerplate of a Typst-generated report PDF into images.

Every page before the first one with a footer rule (the front matter) is
replaced by a single raster image. On later pages, only the running header
and footer strips are rasterised — the body text stays selectable.

Rules are detected as full-width vector lines (Typst draws them with `line()`,
not underscore characters), so the geometry comes from the PDF itself rather
than from hard-coded page numbers or dotted text.

Usage:
    uv run flatten.py main.pdf final.pdf [--dpi 200]
"""

import argparse

import pymupdf

# A rule spans most of the text width and is effectively zero-height.
RULE_MIN_WIDTH = 0.5
RULE_MAX_HEIGHT = 1.0
# Header/footer rules live within this distance of the page edge (points).
EDGE_SEARCH = 150


def horizontal_rules(page: pymupdf.Page) -> list[float]:
    width = page.rect.width
    return [
        d["rect"].y0
        for d in page.get_drawings()
        if d["rect"].width >= width * RULE_MIN_WIDTH
        and d["rect"].height <= RULE_MAX_HEIGHT
    ]


def text_bboxes(page: pymupdf.Page) -> list[pymupdf.Rect]:
    return [
        pymupdf.Rect(line["bbox"])
        for block in page.get_text("dict")["blocks"]
        for line in block.get("lines", [])
        if any(span["text"].strip() for span in line["spans"])
    ]


def strip_cuts(page: pymupdf.Page) -> tuple[float | None, float | None]:
    """Return (header cut, footer cut); None means that strip is absent."""
    height = page.rect.height
    rules = horizontal_rules(page)
    header_rule = min((y for y in rules if y < EDGE_SEARCH), default=None)
    footer_rule = max((y for y in rules if y > height - EDGE_SEARCH), default=None)
    boxes = text_bboxes(page)

    header_cut = None
    if header_rule is not None:
        below = [b.y0 for b in boxes if b.y0 > header_rule + 1]
        if below:
            header_cut = (header_rule + min(below)) / 2

    footer_cut = None
    if footer_rule is not None:
        above = [b.y1 for b in boxes if b.y1 < footer_rule - 1]
        if above:
            footer_cut = (max(above) + footer_rule) / 2

    return header_cut, footer_cut


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", help="PDF produced by `typst compile`")
    parser.add_argument("output", help="flattened PDF to write")
    parser.add_argument("--dpi", type=int, default=200, help="raster resolution")
    args = parser.parse_args()

    src = pymupdf.open(args.input)
    cuts = [strip_cuts(page) for page in src]
    # The first page with a footer rule is the first chapter page.
    first_chapter = next((i for i, (_, f) in enumerate(cuts) if f is not None), len(src))

    out = pymupdf.open()
    for i, page in enumerate(src):
        size = page.rect
        if i < first_chapter:
            pix = page.get_pixmap(dpi=args.dpi)
            out.new_page(width=size.width, height=size.height).insert_image(size, pixmap=pix)
            kind = "full page"
        else:
            header_cut, footer_cut = cuts[i]
            strips: list[tuple[pymupdf.Rect, str]] = []
            if header_cut is not None:
                strips.append((pymupdf.Rect(0, 0, size.width, header_cut), "header"))
            if footer_cut is not None:
                strips.append((pymupdf.Rect(0, footer_cut, size.width, size.height), "footer"))
            if not strips:
                out.insert_pdf(src, from_page=i, to_page=i)
                kind = "unchanged"
            else:
                images = [page.get_pixmap(dpi=args.dpi, clip=rect) for rect, _ in strips]
                for rect, _ in strips:
                    page.add_redact_annot(rect, fill=False)
                page.apply_redactions(
                    images=pymupdf.PDF_REDACT_IMAGE_REMOVE,
                    graphics=pymupdf.PDF_REDACT_LINE_ART_REMOVE_IF_COVERED,
                    text=pymupdf.PDF_REDACT_TEXT_REMOVE,
                )
                for (rect, _), image in zip(strips, images):
                    page.insert_image(rect, pixmap=image)
                out.insert_pdf(src, from_page=i, to_page=i)
                kind = " + ".join(name for _, name in strips)
        print(f"page {i + 1}: {kind}")

    out.save(args.output, garbage=4, deflate=True)


if __name__ == "__main__":
    main()
