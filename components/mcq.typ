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
    e.field("prompt", e.types.union(str, content), named: true, required: true,
      doc: "multiple choice question prompt"),
    e.field("layout", str, default: "v",
      doc: "control layout of multiple choice options"),
    e.field("solution", e.types.option(int), default: none,
      doc: "index of correct choice"),
    e.field("choices", e.types.array(content), named: true, required: true,
      doc: "array of choices"),
  ),
)

#let bubble-letters(..args) = {
  let val = args.at(0);
  assert(
    val < 26 and val >= 0,
    message: strfmt("cannot convert {} to bubbled letter!", val),
  )
  text(size: 1.5em, str.from-unicode(0x24b6 + val))
}

// returns choices as layout
#let layout-choices(question) = {
  let args = if question.layout == "v" {
    // return enum(numbering: numbering, ..question.choices)
    arguments(
      columns: (1fr,),
      row-gutter: 0.5em,
      column-gutter: 2em,
    )
  } else if question.layout == "h" {
    arguments(
      columns: (1fr,) * question.choices.len(),
      gutter: 2em,
    )
  } else {
    // layout is number of columns as a string
    arguments(
      columns: (1fr,) * int(question.layout),
      gutter: 2em,
    )
  }
  let choices = ()
  for (i, choice) in question.choices.enumerate() {
    choices.push(grid(
      columns: 2,
      gutter: 1em,
      align: horizon,
      [#std.numbering(bubble-letters, i)], [#choice],
    ))
  }
  return grid(..args, ..choices)
}

// layout multiple choice problem
#let problem(
  id: none,
  title: none,
  seed: none,
  questions: (),
  points: 2.0,
  numbering: "1. ",
  show-solution: false,
  solution-color: red,
) = {
  let rng = gen-rng(seed)
  let subparts = ()
  for question in questions {
    let order = ()
    let correct = question.solution
    if question.solution == none {
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
      solution: [*#std.numbering("A", (correct + 1))* \ ],
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
