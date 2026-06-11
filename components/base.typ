#import "@preview/elembic:1.1.1" as e

// a subpart type
#let subpart = e.types.declare(
  "subpart",
  prefix: "@preview/typtest:0.0.1:base",
  fields: (
    e.field("numbering", e.types.union(none, str), default: none,
      doc: "whether the subpart is numbered"),
    e.field("space", e.types.union(relative, fraction), default: 10%,
      doc: "vertical blank space for solutions"),
    e.field("points", float, default: 0.0,
      doc: "subpart point value"),
    e.field("prompt", e.types.union(str, content), named: true,
      doc: "subpart question prompt"),
    e.field("solution", e.types.union(str, content), default: "",
      doc: "solution to display in answer key"),
  ),
)

// a problem element
#let problem = e.element.declare(
  "problem",
  prefix: "@preview/typtest:0.0.1:base",
  fields: (
    e.field("id", str, named: true,
      doc: "a unique string identifier for the problem"),
    e.field("title", str, named: true,
      doc: "the problem title"),
    e.field("breakable", bool, default: true,
      doc: "allow subparts to be broken over pages"),
    e.field("main", content, named: true,
      doc: "the problem's main prompt"),
    e.field("points", float, synthesized: true,
      doc: "the problem's point value"),
    e.field("subparts", e.types.array(subpart), default: (),
      doc: "a list of the subpart elements the problem contains"),
    e.field("show-solution", bool, default: false,
      doc: "show the solution"),
    e.field("solution-color", color, default: red,
      doc: "displayed solution color"),
  ),
  synthesize: it => {
    it.points = it.subparts.fold(0.0, (acc, pts) => acc + pts)
    it
  },
  count: counter => counter.step(),
  display: it => {
    block(breakable: it.breakable)[
      #if it.points > 0.0 [
        == (_#it.points points_) #it.title
      ] else [
        == #it.title
      ]

      #it.main

      #for (i, subpart) in it.subparts.enumerate() {
        block(breakable: it.show-solution)[
          #if subpart.points > 0.0 [
            #if subpart.numbering != none [#numbering(subpart.numbering, i+1)]
            (_#subpart.points points_) #subpart.prompt \
          ] else [
            #subpart.prompt \
          ]
          #if sol and subpart.points > 0.0 {
            text(fill: it.solution-color)[
              *Solution*: \
              #subpart.solution \
            ]
          } else { v(subpart.space) }
        ]
      }
    ]
  },
)
