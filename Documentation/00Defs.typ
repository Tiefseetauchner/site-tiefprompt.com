#let teal = rgb("#1fb7b7")
#let dark-teal = rgb("#0d3d3d")
#let coral = rgb("#ff7a59")
#let ink = rgb("#11242e")
#let paper = rgb("#f3f7f8")

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

// Solid fill flush against the top edge, wavy transition at the bottom —
// the mirror image of wave-band, which is flush against the bottom edge.
#let wave-band-top(w, h, amp, wavelength, phase, fill) = {
  let n = 48
  let pts = ((0pt, 0pt), (w, 0pt))
  for i in range(n, -1, step: -1) {
    let x = w * i / n
    let y = h + amp * calc.sin(x / wavelength * 360deg + phase)
    pts.push((x, y))
  }
  polygon(fill: fill, ..pts)
}

#let banner-heading(title, kicker: none) = place(
  left + horizon,
  dy: -12%,
  [
    #block(width: 82%, inset: (left: 2.4cm))[
      #set text(hyphenate: false)
      #if kicker != none [
        #text(font: "Roboto", size: 1em, weight: "bold", fill: coral, tracking: 2pt)[#upper(kicker)]
        #v(0.5em)
      ]
      #par(leading: 0.9em, justify: false)[
        #text(font: "Exo", size: 2.6em, weight: "bold", fill: ink)[#title]
      ]
    ]
  ],
)

// Keyed (not lexically imported) so it reaches across the include boundary into
// bundle.typ, which concatenates this file into output.typ *after* already
// having built its own handle to the same state via a matching key.
#let outline-split-state = state("tiefprompt-outline-split", none)

#let section-counter = counter("tiefprompt-section")

#let cover-page(title) = page(
  margin: 0pt,
  fill: coral.lighten(88%),
  header: none,
  footer: none,
)[
  // A hidden, unnumbered heading so #outline() picks this title up in the
  // right document position; the state pulse around it tags that exact
  // location so bundle.typ's outline show rule can single it out.
  #outline-split-state.update(title)
  #hide(heading(level: 90, outlined: true, numbering: none)[#title])
  #outline-split-state.update(none)

  #counter(heading).update(0)
  #section-counter.step()

  #place(top + left)[
    #box(width: 21cm, height: 3.4cm)[
      #wave-band-top(21cm, 3.4cm, 0.65cm, 22cm, 200deg, rgb(255, 122, 89, 22%))
    ]
  ]

  #context banner-heading(title, kicker: [Section #section-counter.display()])
]
