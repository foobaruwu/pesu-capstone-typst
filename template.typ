// template.typ — PES University capstone project report template
// Tested with Typst 0.13+.

/// Report template for a PES University capstone project.
///
/// Apply it to the whole document with a show rule. Every field that varies
/// between reports is required; omitting one stops compilation with a message.
///
/// ```typ
/// #import "template.typ": capstone-report
/// #show: capstone-report.with(
///   title: "My Project",
///   course-code: "<Course code>",
///   course-name: "Capstone Project <Phase placeholder>",
///   academic-period: "<Academic period>",
///   footer-period: "<Footer period>",
///   semester: "<Semester word>",
///   semester-ordinal: "<Semester ordinal>",
///   logo-path: "logo.png",
///   students: ((name: "Student One", srn: "<SRN>"),),
///   guide: (name: "Guide Name", designation: "Professor"),
///   chairperson: "Chairperson Name",
///   registrar: "Registrar Name",
///   coordinator: "Coordinator Name",
///   founder: "Founder Name",
///   chancellor: "Chancellor Name",
///   vice-chancellor: "Vice-Chancellor Name",
///   pro-vice-chancellor: "Pro Vice-Chancellor Name",
/// )
///
/// = Introduction
/// ...
/// ```
///
/// The function emits the front matter (title page, certificate, declaration,
/// acknowledgement, abstract, contents and lists) and then `body`, which holds
/// the chapters. Chapters start on a fresh page, page numbering restarts at 1,
/// and the header/footer geometry is derived from the measured header height so
/// the header top and footer bottom sit exactly 2 cm from the page edge.
#let capstone-report(
  /// Report title. Used on the title page, certificate, declaration and in the
  /// running header of every chapter continuation page. Required.
  title: none,
  /// Course code printed on the title page, certificate and acknowledgement.
  /// Required.
  course-code: none,
  /// Full course name paired with `course-code`, e.g.
  /// "Capstone Project <Phase placeholder>". Required.
  course-name: none,
  /// Short academic period used by the front matter. Required.
  academic-period: none,
  /// Long period shown in the footer centre. Separate from `academic-period`
  /// because the two strings use different formats. Required.
  footer-period: none,
  /// Word form of the semester used in certificate prose. Required.
  semester: none,
  /// Ordinal form of the semester used in certificate prose. Required.
  semester-ordinal: none,
  /// Path to the logo, used on the title page, certificate and header. Required.
  /// Use the logo supplied in the university's official documents.
  logo-path: none,
  /// Array of `(name: ..., srn: ...)` dictionaries for the authors. Required.
  students: none,
  /// Guide's name and designation, shown on the title page and certificate.
  /// Required.
  guide: none,
  /// Chairperson's name, shown in the certificate signature block. Required.
  chairperson: none,
  /// Registrar's name, shown in the certificate signature block. Required.
  registrar: none,
  /// Project coordinator's name, thanked in the default acknowledgement.
  /// Required.
  coordinator: none,
  /// Founder's name, including honorific, used in the default acknowledgement.
  /// Required.
  founder: none,
  /// Chancellor's name, including honorific, used in the default acknowledgement.
  /// Required.
  chancellor: none,
  /// Vice-Chancellor's name, including honorific, used in the default
  /// acknowledgement. Required.
  vice-chancellor: none,
  /// Pro Vice-Chancellor's name, including honorific, used in the default
  /// acknowledgement. Required.
  pro-vice-chancellor: none,
  /// Custom acknowledgement body. When `none`, a standard acknowledgement is
  /// generated from `guide`, `coordinator`, `chairperson`, `registrar`,
  /// `founder`, `chancellor`, `vice-chancellor` and `pro-vice-chancellor`.
  acknowledgement-body: none,
  /// Abstract body (aim for two paragraphs, at most 150 words, 14 pt).
  abstract-body: [],
  /// The chapters and back matter, placed after the front matter.
  body,
) = context {
  // Values that differ between reports must be supplied by the caller.
  let required = (
    (title, "title"),
    (course-code, "course-code"),
    (course-name, "course-name"),
    (academic-period, "academic-period"),
    (footer-period, "footer-period"),
    (semester, "semester"),
    (semester-ordinal, "semester-ordinal"),
    (logo-path, "logo-path"),
    (students, "students"),
    (guide, "guide"),
    (chairperson, "chairperson"),
    (registrar, "registrar"),
    (coordinator, "coordinator"),
    (founder, "founder"),
    (chancellor, "chancellor"),
    (vice-chancellor, "vice-chancellor"),
    (pro-vice-chancellor, "pro-vice-chancellor"),
  )
  for (value, name) in required {
    if value == none or value == "" {
      panic("capstone-report: " + name + " is required")
    }
  }

  // ---- Constants ---------------------------------------------------------
  // One place for every geometric/typographic value used more than once.
  let paper = "a4"
  let page-width = 21cm
  let margin = 2cm
  let text-width = page-width - 2 * margin
  let edge-gap = 2cm
  // Gap between running header/footer and body: shared by the page geometry
  // and the chapter-opener compensation so the two cannot drift apart.
  let gap = 0.3cm
  let body-size = 12pt              // report text
  let small-size = 10pt             // header, footer and fine print
  let subheading-size = 13pt        // course line, guide name, faculty line
  let lead-size = 14pt              // lead-ins, acknowledgement, abstract
  let degree-size = 15pt            // degree lines and the CERTIFICATE title
  let chapter-size = 18pt
  let section-size = 16pt
  let subsection-size = 14pt
  let level4-size = 12pt
  let act-line = "(Established under Karnataka Act No. 16 of 2013)"
  let address-line = "Electronic City, Hosur Road, Bengaluru – 560 100, Karnataka, India"

  // Fixed base style: every measurement below is taken under the same text
  // settings, independent of the style active where the result is used.
  set text(font: "Times New Roman", size: body-size, lang: "en")
  let logo(..args) = image(logo-path, ..args)
  let student-rows = students.map(s => (text(weight: "bold", s.name), text(weight: "bold", s.srn))).flatten()

  set document(title: title, author: students.map(s => s.name))

  // Chapter-wise numbering, shared by figure captions and the list tables.
  let chapter-number(ch, n) = numbering("1.1", ch, n)
  // Built once, then measured at the real text width. Its height drives both
  // the top margin and the extra space removed on header-less chapter pages.
  let header-content = {
    set par(leading: 0.5em, spacing: 0pt)
    grid(
      columns: (10fr, 5fr, auto),
      align: (left, right),
      column-gutter: 1em,
      text(size: small-size, title), [], logo(height: 0.9cm),
    )
    v(10pt)
    line(length: 100%, stroke: 0.5pt)
  }
  let hh = measure(header-content, width: text-width).height

  // Numbered section/subsection headings differ only in size and block spacing.
  let numbered-heading(size, above, below) = it => block(above: above, below: below, sticky: true, {
    set text(size: size, weight: "bold")
    if it.numbering != none {
      numbering(it.numbering, ..counter(heading).at(it.location()))
      h(0.6em)
    }
    it.body
  })

  let signature-block(name, role) = [*Signature* \ #v(2em) *#name* \ #role]

  // The borderless name/SRN table used on the title and certificate pages.
  let student-table(col-gutter, row-gutter) = align(center, table(
    columns: (auto, auto),
    stroke: none,
    align: left,
    column-gutter: col-gutter,
    row-gutter: row-gutter,
    ..student-rows
  ))
  // An empty list is omitted entirely; a non-empty one gets its own page.
  let list-table(kind, list-title, column-title) = context {
    let items = query(figure.where(kind: kind))
    if items.len() > 0 {
      pagebreak()
      align(center, text(size: section-size, weight: "bold")[#list-title])
      v(0.8em)
      table(
        columns: (auto, 1fr, auto),
        stroke: 0.5pt,
        inset: 6pt,
        align: (left, left, right),
        table.header([#column-title], [Title], [Page No.]),
        ..items.map(f => {
          let n = counter(figure.where(kind: kind)).at(f.location()).first()
          let ch = counter(heading).at(f.location()).first()
          ([#chapter-number(ch, n)], f.caption.body, [#counter(page).at(f.location()).first()])
        }).flatten(),
      )
    }
  }

  // ---- Page: front matter has no header/footer -------------------------
  set page(paper: paper, margin: margin, header: none, footer: none)

  // ---- Typography: Times New Roman 12pt, 1.5 spacing, justified --------
  // Typst's `leading` is the gap between lines, not the pitch. A 1.06em gap
  // plus the line box gives 1.5-line spacing.
  set par(justify: true, leading: 1.06em, spacing: 1.06em)

  // ---- Headings ---------------------------------------------------------
  set heading(numbering: "1.1")
  show heading: set text(hyphenate: false)

  show heading.where(level: 1): it => {
    // Reset the page counter before the break so the chapter heading's own
    // outline entry lands on page 1 instead of the front-matter page.
    if counter(heading).get().first() == 1 {
      counter(page).update(1)
    }
    pagebreak(weak: true)
    // Chapter-wise numbering for figures, tables, equations
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)
    // Record this chapter's opening page. The page counter restarts at the
    // first chapter, so heading locations cannot reliably identify openers.
    context [#metadata(here().page()) <chapter-start>]
    // Chapter openers have no header, so cancel the header band: the title
    // then starts 2 cm from the page edge.
    v(-(gap + hh))

    v(0.5em)
    if it.numbering != none {
      align(left, text(size: chapter-size, weight: "bold")[CHAPTER #counter(heading).display("1")])
      v(0.8em)
    }
    // Keep a long chapter title centered rather than justified.
    {
      set par(justify: false)
      align(center, text(size: chapter-size, weight: "bold", upper(it.body)))
    }
    v(0.6em)
  }

  show heading.where(level: 2): numbered-heading(section-size, 1.2em, 1.2em)
  show heading.where(level: 3): numbered-heading(subsection-size, 1.1em, 0.7em)
  show heading.where(level: 4): numbered-heading(level4-size, 1em, 0.6em)

  // ---- Figures / tables / equations: numbered 1.1, 1.2, ... per chapter --
  set figure(numbering: n => chapter-number(counter(heading).get().first(), n))
  set figure.caption(separator: [: ])
  show figure.where(kind: table): set figure.caption(position: top)
  set math.equation(numbering: n => numbering("(1.1)", counter(heading).get().first(), n))

  // ---- References: IEEE ---------------------------------------------------
  set bibliography(title: none, style: "ieee")

  // =======================================================================
  // TITLE PAGE
  // =======================================================================
  // Black border around the title page.
  block(width: 100%, stroke: 2pt, inset: 0.4cm, breakable: false)[
    #align(center)[
    #set text(hyphenate: false)
    #set par(justify: false)
    #logo(width: 4.2cm)
    #v(0.6em)
    #text(size: lead-size, style: "italic", weight: "bold")[Dissertation on]
    #v(0.4em)
    #text(size: chapter-size, weight: "bold")[“#title”]
    #v(0.7em)
    #text(size: body-size, style: "italic")[Submitted in partial fulfilment of the requirements for the award of degree of]
    #v(0.3em)
    #text(size: degree-size, weight: "bold")[Bachelor of Technology] \
    in \
    #text(size: degree-size, weight: "bold")[Computer Science & Engineering] \
    #v(0.3em)
    #text(size: subheading-size, weight: "bold")[#course-code – #course-name]
    #v(0.7em)
    #text(style: "italic", weight: "bold")[Submitted by:]
    #v(0.4em)
    #student-table(2em, 0.4em)
    #v(0.8em)
    #text(style: "italic")[Under the guidance of] \
    #v(0.3em)
    #text(size: subheading-size, weight: "bold")[#guide.name] \
    #guide.designation \
    PES University
    #v(0.8em)
    #text(weight: "bold")[#academic-period]
    #v(0.7em)
    #text(weight: "bold")[
      DEPARTMENT OF COMPUTER SCIENCE AND ENGINEERING \
      FACULTY OF ENGINEERING \
      PES UNIVERSITY
    ] \
    #text(size: small-size)[#act-line] \
    #text(size: 11pt, weight: "bold")[#address-line]
    ]
  ]

  pagebreak()

  // =======================================================================
  // CERTIFICATE
  // =======================================================================
  align(center)[
    #logo(width: 3.2cm)
    #v(0.3em)
    #text(size: lead-size, weight: "bold")[PES UNIVERSITY] \
    #text(size: small-size)[#act-line] \
    #text(size: small-size)[#address-line]
    #v(0.4em)
    #text(size: subheading-size, weight: "bold")[FACULTY OF ENGINEERING]
    #v(0.4em)
    #text(size: degree-size, weight: "bold", [CERTIFICATE])
  ]

  v(0.8em)
  text(style: "italic")[This is to certify that the dissertation entitled ]
  text(weight: "bold")["#title"]
  h(0.25em)
  text(style: "italic")[is a bonafide work carried out by]

  student-table(2.5em, 0.35em)

  v(0.5em)
  [
    In partial fulfilment for the completion of #semester semester #course-name (#course-code) in the Program of Study – Bachelor of Technology in Computer Science and Engineering under rules and regulations of PES University, Bengaluru during the period #academic-period. It is certified that all corrections / suggestions indicated for internal assessment have been incorporated in the report. The dissertation has been approved as it satisfies the #semester-ordinal semester academic requirements in respect of project work.
  ]

  v(1.5em)
  grid(
    columns: (1fr, 1fr, 1fr),
    align: center,
    signature-block(guide.name, guide.designation),
    signature-block(chairperson, [Chairperson]),
    signature-block(registrar, [Registrar]),
  )

  v(1.2em)
  align(center)[*External Viva*]
  v(0.5em)
  table(
    columns: (1fr, 1fr),
    stroke: none,
    align: left,
    [*Name of the Examiners*], [*Signature with Date*],
    [1. #box(width: 85%, height: 1em, stroke: (bottom: 0.5pt))],
    [#box(width: 85%, height: 1em, stroke: (bottom: 0.5pt))],

    [2. #box(width: 85%, height: 1em, stroke: (bottom: 0.5pt))],
    [#box(width: 85%, height: 1em, stroke: (bottom: 0.5pt))],
  )

  pagebreak()

  // =======================================================================
  // DECLARATION
  // =======================================================================
  align(center, text(size: section-size, weight: "bold", [DECLARATION]))
  v(1em)
  [
    We hereby declare that the #course-name entitled “*#title*” has been carried out by us under the guidance of *#guide.name, #guide.designation* and submitted in partial fulfilment of the course requirements for the award of degree of Bachelor of Technology in Computer Science and Engineering of PES University, Bengaluru during the academic semester #academic-period. The matter embodied in this report has not been submitted to any other university or institution for the award of any degree.
  ]

  v(2em)
  table(
    columns: (1.2fr, 1.5fr, 1.3fr),
    stroke: 0.5pt,
    inset: 8pt,
    align: (left, left, center),
    [*SRN*], [*Name*], [*Signature*],
    ..students.map(s => ([#s.srn], [#s.name], [])).flatten(),
  )

  pagebreak()

  // =======================================================================
  // ACKNOWLEDGEMENT
  // =======================================================================
  align(center, text(size: lead-size, weight: "bold", [ACKNOWLEDGEMENT]))
  v(1em)
  if acknowledgement-body != none {
    acknowledgement-body
  } else [
    I would like to express my gratitude to *#guide.name*, #guide.designation, Department of Computer Science and Engineering, PES University, for continuous guidance, assistance, and encouragement throughout the development of this #course-code #course-name.

    I am grateful to the Capstone Project Coordinator, *#coordinator*, Associate Professor, Department of Computer Science and Engineering, PES University for organizing, managing, and helping with the entire process.

    I take this opportunity to thank *#chairperson*, Chairperson, Department of Computer Science and Engineering, PES University, for all the knowledge and support I have received from the department. I would like to thank *#registrar*, Registrar, PES University for his help.

    I am deeply grateful to *#founder*, Founder, PES University, whose vision and dedication continue to inspire generations of learners. I would like to express my sincere gratitude to *#chancellor*, Chancellor, PES University, *#vice-chancellor*, Vice-Chancellor, PES University, and *#pro-vice-chancellor*, Pro Vice-Chancellor, PES University for providing various opportunities and enlightenment every step of the way.

    Finally, this project could not have been completed without the continual support and encouragement I have received from my parents, family, and friends.
  ]

  pagebreak()

  // =======================================================================
  // ABSTRACT (max 150 words, 2 paragraphs, 14pt)
  // =======================================================================
  align(center, text(size: section-size, weight: "bold", [ABSTRACT]))
  v(1em)
  {
    set text(size: lead-size)
    abstract-body
  }

  pagebreak()

  // =======================================================================
  // TABLE OF CONTENTS, LIST OF FIGURES, LIST OF TABLES
  // =======================================================================
  align(center, text(size: section-size, weight: "bold", [TABLE OF CONTENTS]))
  v(0.8em)
  outline(title: none, indent: auto, depth: 4)

  list-table(image, [LIST OF FIGURES], [Figure No.])
  list-table(table, [LIST OF TABLES], [Table No.])

  // =======================================================================
  // MAIN CHAPTERS: new page, page numbering restarts at 1, header + footer on
  // =======================================================================
  // Chapter openers get a footer but no header; continuation pages get both.
  let header = context {
    let starts = query(<chapter-start>).map(m => m.value)
    if here().page() not in starts {
      header-content
    }
  }
  // The footer appears on every chapter page, including openers.
  let footer-content = grid(
    columns: (1fr, 1fr, 1fr),
    align: (left, center, right),
    inset: (top: 10pt),
    stroke: (top: 0.5pt),
    text(size: small-size)[Dept of CSE],
    text(size: small-size)[#footer-period],
    text(size: small-size, context counter(page).display("1")),
  )

  context {
    let fh = measure(footer-content, width: text-width).height
    // Header top  = top margin - ascent - header height = 2 cm.
    // Footer bottom = page height - bottom margin + descent + footer height
    //               = page height - 2 cm.
    set page(
      paper: paper,
      margin: (top: edge-gap + gap + hh, bottom: edge-gap + gap + fh, left: margin, right: margin),
      header-ascent: gap,
      footer-descent: gap,
      header: header,
      footer: footer-content,
    )
    body
  }
}

/// Start an unnumbered chapter-like section (References, Appendices, ...).
/// It gets a fresh page, a footer (but no header) and an entry in the contents,
/// just like a numbered chapter, without incrementing the chapter counter.
#let back-matter-heading(title) = heading(level: 1, numbering: none, title)

