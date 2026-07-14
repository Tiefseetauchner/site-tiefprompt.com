#import "@preview/zebraw:0.4.6": *

#import "./metadata.typ": meta

#let teal = rgb("#1fb7b7")
#let dark-teal = rgb("#0d3d3d")
#let coral = rgb("#ff7a59")
#let ink = rgb("#11242e")
#let paper = rgb("#f3f7f8")

#let page-w = 21cm
#let margin-top = 2.25cm
#let margin-bottom = 1.75cm
#let margin-x = 2.5cm
#let banner-h = 3.6cm

#let wave-band(w, h, amp, wavelength, phase, fill) = {
  let n = 48
  let pts = ()
  for i in range(n + 1) {
    let x = w * i / n
    let y = amp * calc.sin(x / wavelength * 360deg + phase)
    pts.push((x, y))
  }
  pts.push((w, h))
  pts.push((0pt, h))
  polygon(fill: fill, ..pts)
}

#let banner-heading(it) = {
  place(top + left, dx: -margin-x, dy: -margin-top)[
    #box(width: page-w, height: banner-h - 10pt, fill: dark-teal)[
      #place(bottom + left, dy: 1pt)[
        #wave-band(page-w, banner-h * 0.32, 0.4cm, 20cm, 40deg, white)
      ]
      #place(left + horizon, dx: margin-x)[
        #text(fill: white)[#it]
      ]
    ]
  ]
  v(banner-h - margin-top, weak: false)
}

#let cover-page(title, author, date) = page(
  margin: 0pt,
  fill: paper,
  header: none,
  footer: none,
)[
  #let w = 21cm
  #let h = 29.7cm

  #place(bottom + left)[
    #box(width: w, height: h * 0.62)[
      #wave-band(w, h * 0.62, 1.5cm, 35cm, 0deg, rgb(31, 183, 183, 12%))
    ]
  ]
  #place(bottom + left)[
    #box(width: w, height: h * 0.4)[
      #wave-band(w, h * 0.4, 1.1cm, 30cm, 70deg, rgb(31, 183, 183, 20%))
    ]
  ]
  #place(bottom + left)[
    #box(width: w, height: h * 0.2)[
      #wave-band(w, h * 0.2, 0.75cm, 25cm, 160deg, rgb(31, 183, 183, 38%))
    ]
  ]

  #place(left + horizon, dy: -12%)[
    #block(width: 82%, inset: (left: 2.4cm))[
      #set text(hyphenate: false)
      #par(leading: 0.9em)[
        #text(font: "Exo", size: 3.2em, weight: "bold", fill: ink)[#title]
      ]

      #v(1.6em, weak: true)
      #text(font: "Roboto", size: 1.35em, fill: ink.lighten(15%))[#author]

      #v(0.6em, weak: true)
      #text(font: "Roboto", size: 1em, fill: ink.lighten(35%))[#date]
    ]
  ]
]

#set document(title: [TiefPrompt Documentation], author: "Tiefseetauchner")
#set page(paper: "a4", margin: (top: margin-top, bottom: margin-bottom, left: margin-x, right: margin-x))
#set text(font: "Roboto", size: 12pt, fill: ink)
#set par(
  first-line-indent: 1em,
  leading: 0.7em,
  spacing: 0.65em,
  justify: true,
  linebreaks: "optimized",
)

#show outline.entry.where(
  level: 0
): set block(above: 1.2em)

#show figure: set block(below: 1.2em)

// Matches the state key in Documentation/00Defs.typ's `cover-page` — that file
// is concatenated into output.typ and #include-d below, so it can't share a
// #let binding with this scope, but a state is addressed globally by key.
#let outline-split-state = state("tiefprompt-outline-split", none)

#show outline.entry: it => context {
  let split-title = outline-split-state.at(it.element.location())
  if split-title != none {
    block(above: 2em, below: 0.5em)[
      #link(it.element.location(), text(weight: "bold", fill: teal, split-title))
    ]
  } else {
    it
  }
}

#cover-page(
  [TiefPrompt Documentation],
  "Tiefseetauchner",
  datetime.today().display("[month repr:long] [day padding:zero], [year repr:full]"),
)

#outline()

#show: zebraw.with()

#show heading: set text(font: "Exo", hyphenate: false)
#show heading: it => {
  if it.level == 1 {
    banner-heading(it)
  } else {
    text(fill: teal)[#it]
    v(2%, weak: true)
  }
}

#show link: it => {
  underline(text(fill: coral)[#it])
  if type(it.dest) != label {
    sym.wj
    h(1.6pt)
    sym.wj
    super(box(height: 3.8pt, circle(radius: 1.2pt, stroke: 0.7pt + coral)))
  }
}

#show raw: set text(font: "Roboto Mono", size: 9pt)
#show raw.where(block: false): box.with(
  fill: paper.darken(2%),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
)
#show raw.where(block: true): block.with(inset: (x: 5pt))

#show figure.where(kind: table): set block(breakable: true)
#set table(
  inset: 7pt,
  stroke: (0.5pt + luma(200)),
)
#show table.cell.where(y: 0): smallcaps

#set page(
  footer: context {
    let i = counter(page).at(here()).first()
    let is-odd = calc.odd(i)
    let aln = if is-odd { right } else { left }

    let target = heading.where(level: 1)
    if query(target).any(it => it.location().page() == i) {
      align(aln)[#i]
    } else {
      let before = query(target.before(here()))
      if before.len() > 0 {
        let current = before.last()
        let gap = 1.75em
        let chapter = upper(text(size: 0.68em, current.body))
        if is-odd {
          align(aln)[#chapter #h(gap) #i]
        } else {
          align(aln)[#i #h(gap) #chapter]
        }
      }
    }
  },
)

#set heading(numbering: "1.")
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  it
}

#include "output.typ"

