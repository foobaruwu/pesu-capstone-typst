# PES University capstone project report template (Typst)

A Typst template for the PES University capstone project report. It produces a
single A4 PDF with front matter, chapter layout, a running header/footer and
chapter-wise figure/table numbering.

The course code, academic period and all personal details are required fields.

`main.typ` is an example: every report-specific value is a placeholder.

## Features

- Times New Roman 12 pt body, 1.5 line spacing, justified paragraphs.
- Chapter number left-aligned and chapter title centred at 18 pt; sections at
  16 pt, subsections at 14 pt.
- Chapters start on a new page; page numbering restarts at 1. Chapter openers
  have a footer but no header; continuation pages have both.
- Header: project title on the left, logo on the right, rule below. Footer:
  department, the academic period and the page number.
- The header top and footer bottom are **exactly 2 cm** from the page edge. This
  is derived by measuring the rendered header/footer at the real text width, so
  it holds even when the title wraps to several lines.
- Table of contents, list of figures and list of tables. The two lists are
  proper bordered tables, each on its own page, and are omitted entirely when
  there is nothing to list.

## Files

| File | Purpose |
| --- | --- |
| `template.typ` | The reusable template (`capstone-report`, `back-matter-heading`). |
| `main.typ` | Example document and the entry point to compile. |
| `logo.png` | Neutral placeholder logo; replace it with your own. |
| `refs.bib` | Sample bibliography. |
| `main.pdf` | Built output of the example. |
| `flatten.py` | Optional post-processor that rasterises the front matter and header/footer strips. |

## Quick start

```sh
typst compile main.typ main.pdf
```

The example needs `template.typ`, `logo.png` and `refs.bib` beside it. Typst
0.13 or newer is required.

## Configuration

Everything is passed to `capstone-report.with(...)` in `main.typ`. Each parameter
is also documented inline with `///` doc comments in `template.typ`.

| Parameter | Meaning |
| --- | --- |
| `title` | Required. Title page, certificate, declaration and running header. |
| `course-code` | Required. Course code on title page, certificate, acknowledgement. |
| `course-name` | Required. Full course name, e.g. `Capstone Project <Phase placeholder>`. |
| `academic-period` | Required. Short period used in the front matter. |
| `footer-period` | Required. Long period in the footer centre. |
| `semester` | Required. Word form used in certificate prose. |
| `semester-ordinal` | Required. Ordinal form used in certificate prose. |
| `logo-path` | Required. Path to the logo used on the title page, certificate and header. |
| `students` | Required. Array of `(name: ..., srn: ...)` dictionaries. |
| `guide` | Required. Guide shown on the title page and certificate. |
| `chairperson` | Required. Certificate signature block. |
| `registrar` | Required. Certificate signature block. |
| `coordinator` | Required. Thanked in the default acknowledgement. |
| `founder` | Required. Founder's name in the default acknowledgement. |
| `chancellor` | Required. Chancellor's name in the default acknowledgement. |
| `vice-chancellor` | Required. Vice-Chancellor's name in the default acknowledgement. |
| `pro-vice-chancellor` | Required. Pro Vice-Chancellor's name in the default acknowledgement. |
| `acknowledgement-body` | Optional. Custom text; omit to generate the standard acknowledgement. |
| `abstract-body` | Optional. Abstract content (aim for 150 words, 14 pt). |
| `body` | The chapters and back matter. |

Notes:

- The academic period exists as two strings because the front matter and the
  footer use different formats. **Set both** when changing the year.
- `semester` and `semester-ordinal` are separate so you can write "eighth" and
  "8th" without the template guessing an ordinal.
- The department label and the page-number format are fixed in `template.typ`.
- `logo-path` should point at the logo from the university's supplied documents.
  The bundled `logo.png` is a neutral placeholder so the example compiles.

## Writing the report body

Use ordinary Typst headings after the show rule:

```typ
= Introduction
== Background
=== Scope of Work
```

`=` creates a chapter, `==` a section, `===` a subsection. Figures and tables
should be wrapped in `figure(...)` with a caption so they are numbered per
chapter and appear in the lists:

```typ
#figure(
  image("architecture.png", width: 85%),
  caption: [High-level system architecture],
) <fig:architecture>
```

For an unnumbered chapter-like section (References, Appendices), use
`back-matter-heading`:

```typ
#import "template.typ": back-matter-heading

#back-matter-heading[References / Bibliography]
#bibliography("refs.bib")
```

## Flattening shared content

`flatten.py` rasterises the shared parts of the report: front-matter pages
become images, and on the remaining pages the running header and footer strips
become images while the body stays as text. It is optional and runs after
`typst compile`:

```sh
typst compile main.typ main.pdf
uv run flatten.py main.pdf final.pdf          # --dpi 200 by default
```

`uv` installs PyMuPDF automatically from the PEP 723 dependency block at the
top of the script; no virtual environment setup is needed. The script detects
the header/footer rules as full-width vector lines in the PDF, so it does not
depend on fixed page numbers or on underscore text. It treats every page before
the first page with a footer rule as front matter, skips the header strip on
chapter openers, and prints what it did for each page.

Flattened pages lose selectable text and accessibility, and 200 dpi rasters are
slightly softer than vector text.

## Licensing

The reusable code (`template.typ`, `flatten.py`) is MIT licensed. The example
and documentation files (`main.typ`, `README.md`, `refs.bib`, `typst.toml`,
`logo.png`, `.gitignore`) are MIT-0, so reports produced from the example carry
no attribution obligation. See `LICENSE` for the full terms.

The real university logo supplied through `logo-path` is not covered by these
licenses and remains the institution's property. The bundled `logo.png` is a
neutral placeholder covered by MIT-0.

## Verification

The template is tested with Typst 0.15.1. When editing it, recompile the example
and check that the header begins 2 cm from the page edge, the chapter openers
have no header, and the figure/table lists behave correctly when empty or
populated.
