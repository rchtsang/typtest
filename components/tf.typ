#import "@preview/elembic:1.1.1" as e
#import "@preview/oxifmt:1.0.0": strfmt

#import "base.typ" as base

// true/false question type
#let question = e.types.declare(
  "question",
  prefix: "@preview/typtest:0.0.1:tf",
  fields: (
    e.field("prompt", e.types.union(str, content), named: true,
      doc: "true/false question prompt"),
    e.field("solution", str, named: true,
      doc: "solution"),
  ),
)

// layout true/false problem
#let problem(
  id,
  title,
  questions,
  points,
  numbering: "1. ",
  show-solution: false,
  solution-color: red,
) = {
  let subparts = ()
  for question in questions {
    subparts.push(base.subpart(
      numbering: numbering,
      space: 0%,
      points: points,
      prompt: grid(
        columns: (1fr, 5%, 5%),
        column-gutter: 5pt,
        align: left,
        question.prompt,
        [True], [False],
      ),
      solution: question.solution,
    ))
  }

  base.problem(
    id: id,
    title: title,
    breakable: true,
    show-solution: show-solution,
    solution-color: solution-color,
    main: [
      Indicate whether the following statements are true or false by circling the corresponding option:
    ],
    subparts: subparts,
  )
}
