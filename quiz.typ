#import "@preview/elembic:1.1.1" as e
#import "@preview/oxifmt:1.0.0": strfmt
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *

#import "components/base.typ" as base

#let quiz = e.element.declare(
  "quiz",
  doc: "quiz template",
  prefix: "@preview/typtest:0.0.1:quiz",
  fields: (
    e.field("version", str, named: true,
      doc: "exam version"),
    e.field("date", datetime, named: true,
      doc: "exam date"),
    e.field("show-solution", bool, default: false,
      doc: "show exam solutions"),
    e.field("course", content, named: true,
      doc: "course title"),
    e.field("title", content, named: true,
      doc: "exam title"),
    e.field("problems", e.types.array(content), named: true,
      doc: "exam problems"),
    e.field("instructions", content, required: true,
      doc: "exam instructions"),
  ),

  display: it => {
    set page(
      paper: "us-letter",
      margin: (x: 1in, y: 1in),
      number-align: right + bottom,
      numbering: "1",
      header: [
        #it.date.display()
        #h(1fr)
        #it.course - #it.title
        #h(1fr)
        #it.version \
        #line(length: 100%, stroke: 2pt)
      ],
    )

    set raw(theme: "assets/infimum.tmTheme")
    show: codly-init.with()
    codly(
      zebra-fill: none,
      stroke: none,
      display-icon: false,
      display-name: false,
      breakable: false,
    )

    let box-args = arguments(
      width: 1fr,
      height: 2.25em,
      stroke: (bottom: 1pt),
      baseline: 4pt,
    )
    let title-section = [
      #set align(left)
      #grid(
        columns: (10%, 30%, 10%, 30%),
        gutter: 1em,
        text(size: 14pt)[Name:], box(..box-args),
        text(size: 14pt)[SID:], box(..box-args),
      )

      #it.instructions
    ]

    [
      #show: e.set_(base.problem, show-solution: it.show-solution)
      #title-section

      #for (i, problem) in it.problems.enumerate() [
        #if i > 0 { pagebreak() }
        #problem
      ]
    ]
  },
)
