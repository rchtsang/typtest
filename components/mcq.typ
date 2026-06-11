#import "@preview/elembic:1.1.1" as e
#import "@preview/oxifmt:1.0.0": strfmt
#import "@preview/suiji:0.5.1": *

#import "base.typ" as base

// multiple choice question type
#let question = e.types.declare(
  "question",
  prefix: "@preview/typtest:0.0.1:mcq",
  fields: (
    e.field("space", e.types.union(relative, fraction), default: 0%,
      doc: "spacing after this multiple choice question"),
    e.field("prompt", e.types.union(str, content), named: true,
      doc: "multiple choice question prompt"),
    e.field("layout", str, default: "v",
      doc: "control layout of multiple choice options"),
    e.field("solution", e.types.union(none, int), default: none,
      doc: "index of correct choice"),
    e.field("choices", e.types.array(content), named: true,
      doc: "array of choices"),
  ),
)

// returns choices as layout
#let layout-choices(question, numbering: "(A)") = {
  if question.layout == "v" {
    return enum(numbering: numbering, ..question.choices)
  }
  let args = if question.layout == "h" {
    arguments(columns: (1fr,) * question.choices.len(), gutter: 2em)
  } else {
    // layout is number of columns as a string
    arguments(columns: (1fr,) * int(question.layout), gutter: 2em)
  }
  let choices = ()
  for (i, choice) in question.choices.enumerate() {
    choices.push(grid(
      columns: 2,
      gutter: 1em,
      [#numbering(numbering: numbering, i+1)], [#choice],
    ))
  }
  return grid(..args, ..choices)
}

// layout multiple choice problem
#let problem(
  id,
  title,
  seed,
  questions,
  points,
  numbering: "1. ",
  show-solution: false,
  solution-color: red,
) = {
  let rng = gen-rng(seed)
  let subparts = ()
  for question in questions {
    let order = ()
    if quesiton.solution == none {
      (rng, order) = shuffle(rng, range(question.choices.len()))
      correct = order.position(v => v == 0)
    } else {
      order = range(question.choices.len())
    }
    let choices = order.map(i => question.choices.at(i))

    subparts.push(base.subpart(
      numbering: numbering,
      space: question.space,
      points: points,
      prompt: [
        #question.prompt

        #layout-choices(question)
      ],
      solution: [*#numbering("A", (correct + 1))* \ ],
    ))
  }

  base.problem(
    id: id,
    title: title,
    breakable: true,
    show-solution: show-solution,
    solution-color: red,
    main: [Complete the following multiple choice questions: ],
    subparts: subparts,
  )
}
