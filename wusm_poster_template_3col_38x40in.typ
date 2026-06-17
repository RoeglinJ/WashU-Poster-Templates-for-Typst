// ============================================================================
//  This is an unofficial Typst template for WashU poster presentations, configured
//  to display the WashU Medicine logo (images/WashU logo white.png). RoeglinJ does 
//  not own or hold any rights to the use of the Washington University name or logo.
//  Anyone using this template must comply with all of Washington University's policies
//  for use of its branding. 
//
//  Portrait, 38 in x 40 in, 0.75 in margins, three-column vertical layout.
//
//  Compile with Typst >= 0.12. Replace the sample title, authors, section
//  content, and the fig-placeholder() / logo-slot() / dummy-qr() calls.
//  References are pulled from bibliography.bib (same folder); see the
//  References section near the end of this file.
// ============================================================================

// ---------------------------------------------------------------------------
//  Color Palette
// ---------------------------------------------------------------------------
#let washu-maroon = rgb("#942431") // section-header bars
#let washu-cream  = rgb("#F5F2EE") // title-band background
#let ink          = rgb("#1A1A1A") // body text
#let panel-rule   = rgb("#D8D2CC") // placeholder borders
#let panel-fill   = rgb("#CCCCCC") // figure-placeholder fill
#let panel-text   = rgb("#5C5B5B") // placeholder captions
#let section-stroke = 2.5pt + black

// ---------------------------------------------------------------------------
//  Fonts
// ---------------------------------------------------------------------------
#let title-font   = ("TeX Gyre Termes", "Noto Serif")
#let heading-font = ("Noto Sans", "Liberation Sans")
#let body-font    = ("Noto Sans", "Liberation Sans")

// ---------------------------------------------------------------------------
//  Page
// ---------------------------------------------------------------------------
#let poster-w         = 38in
#let poster-h         = 40in
#let poster-margin    = 0.75in
#let poster-content-h = poster-h - 2 * poster-margin 

#set page(width: poster-w, height: poster-h, margin: poster-margin, fill: washu-cream)

#let box-spacing  = 0.26in
#let body-size    = 30pt
#let heading-size = 42pt
#let head-inset   = (x: 0.55em, y: 0.4em)
#let body-inset   = (x: 0.9em, top: 0.8em, bottom: 0.8em)

#set columns(gutter: box-spacing)
#set block(spacing: box-spacing)
#set par(justify: true, leading: 0.46em, spacing: 0.9em)
#set text(font: body-font, size: body-size, fill: ink)

// ---------------------------------------------------------------------------
//  Placeholders
// ---------------------------------------------------------------------------

#let fig-placeholder(height, caption) = block(width: 100%, breakable: false)[
  #box(width: 100%, height: height, fill: panel-fill, stroke: 2pt + black)[
    #set align(center + horizon)
    #text(size: 24pt, fill: panel-text, style: "italic")[#caption]
  ]
]

#let logo-slot(label, ..sizing) = box(
  ..sizing, fill: white, stroke: 2pt + panel-rule, inset: 8pt,
)[
  #set align(center + horizon)
  #text(size: 22pt, fill: panel-text, style: "italic")[#label]
]

#let dummy-qr(label, size) = {
  let n = 21
  let cell = size / n
  box(width: size, height: size, fill: white, stroke: 2pt + black)[
    #for y in range(n) {
      for x in range(n) {
        let tl = x < 7 and y < 7
        let tr = x >= n - 7 and y < 7
        let bl = x < 7 and y >= n - 7
        let dark = if tl or tr or bl {
          let fx = if x >= n - 7 { x - (n - 7) } else { x }
          let fy = if y >= n - 7 { y - (n - 7) } else { y }
          (fx == 0 or fx == 6 or fy == 0 or fy == 6) or (fx >= 2 and fx <= 4 and fy >= 2 and fy <= 4)
        } else {
          calc.rem(x * 73 + y * 51 + x * y * 17 + 5, 7) < 3
        }
        if dark {
          place(top + left, dx: x * cell, dy: y * cell,
            rect(width: cell, height: cell, fill: black, stroke: none))
        }
      }
    }
    #place(center + horizon, rect(fill: white, stroke: 1pt + black, inset: (x: 6pt, y: 4pt))[
      #text(size: 18pt, weight: "bold", fill: black)[#label]
    ])
  ]
}

// ---------------------------------------------------------------------------
//  Functions for sections
// ---------------------------------------------------------------------------

#let heading-bar(title) = block(
  width: 100%, fill: washu-maroon, stroke: section-stroke, inset: head-inset, breakable: false,
)[
  #set text(font: heading-font, weight: "bold", fill: white, size: heading-size)
  #align(center, title)
]

// fill-height: true makes the panel fill its grid cell so the frame reaches the
// column bottom. No clipping: real content that exceeds the panel stays visible.
#let body-panel(body, fill-height: false) = {
  let args = (width: 100%, fill: white, stroke: section-stroke, inset: body-inset, breakable: false)
  if fill-height { args.insert("height", 100%) }
  block(..args)[
    #set text(font: body-font, size: body-size, fill: ink)
    #body
  ]
}

// Section function for sections above the last in each column.
#let section(title, body) = grid(
  rows: (auto, auto), row-gutter: 0pt,
  heading-bar(title),
  body-panel(body),
)

// Space-filling section for the last box in a column.
#let section-fill(title, body) = block(height: 100%, breakable: false)[
  #grid(
    rows: (auto, 1fr), row-gutter: 0pt,
    heading-bar(title),
    body-panel(body, fill-height: true),
  )
]

// Space-filling placeholder text.
#let lorem-fill(step: 25, max-words: 1600) = block(
  width: 100%, height: 1fr, breakable: false, clip: true,
)[
  #layout(size => {
    let chosen = step
    let words = step
    while words <= max-words {
      if measure(width: size.width, lorem(words)).height >= size.height { break }
      chosen = words
      words += step
    }
    lorem(chosen)
  })
]

// Lay out one column top-to-bottom with space-filling.
#let column-body(..items) = {
  let a = items.pos()
  let n = a.len()
  grid(rows: (..((auto,) * (n - 1)), 1fr), row-gutter: box-spacing, ..a)
}

// ---------------------------------------------------------------------------
//  Title band
// ---------------------------------------------------------------------------
#let title-gutter = 0.2in
#let title-col-w  = 22in // controls the width of the center block
#let side-col-w   = (poster-w - 2 * poster-margin - title-col-w - 2 * title-gutter) / 2

#let left-logo-h = 3in
#let lab-logo-h  = 1.8in
#let qr-gap      = 0.4in
#let qr-size     = (side-col-w - qr-gap) / 2.25

#let title-band(title: [], authors: [], affiliations: []) = block(
  width: 100%, fill: washu-cream, inset: (top: 0.26in, bottom: 0.26in),
)[
  #grid(
    columns: (side-col-w, title-col-w, side-col-w),
    column-gutter: title-gutter,
    align: center + horizon,

    // left: WashU Logo
    box(width: side-col-w, height: left-logo-h, inset: 0pt)[
      #image("images/WashU logo white.png", width: 100%, height: 100%, fit: "contain")
    ],

    // center: title / authors / affiliations
    {
      set align(center)
      set par(spacing: 0em)
      {
        set par(justify: false, leading: 0.26em)
        set text(font: title-font, size: 86pt, weight: "bold", fill: black)
        title
      }
      v(2em)
      {
        set par(justify: false)
        set text(font: title-font, size: 48pt, weight: "semibold", fill: ink)
        authors
      }
      v(0.6em)
      {
        set par(justify: false)
        set text(font: heading-font, size: 27pt, fill: ink)
        affiliations
      }
    },

    // right: space for lab logo and QR codes
    stack(
      dir: ttb,
      spacing: 0.26in,
      logo-slot([Lab Logo], width: side-col-w, height: lab-logo-h),
      box(width: side-col-w)[
        #stack(
          dir: ltr,
          spacing: qr-gap,
          dummy-qr([Lab\ Website], qr-size),
          dummy-qr([author\ ORCiD], qr-size),
        )
      ],
    ),
  )
]

// ---------------------------------------------------------------------------
//  Scale-reference ruler.
// ---------------------------------------------------------------------------
#let ruler-12in() = {
  let h     = 1.30in
  let t-in  = 0.60in
  let t-half = 0.42in
  let t-qtr = 0.30in
  let t-8th = 0.18in
  let lblW  = 1.0in
  let pad   = 0.28in // prevents clipping 0 and 12

  box(width: 12in + 2 * pad, height: h, fill: white, stroke: 2pt + black)[
    #for i in range(0, 97) {
      let x = pad + i / 8 * 1in
      let (tl, tw) = if calc.rem(i, 8) == 0 { (t-in, 2pt) }
        else if calc.rem(i, 4) == 0 { (t-half, 1.2pt) }
        else if calc.rem(i, 2) == 0 { (t-qtr, 1pt) }
        else { (t-8th, 0.8pt) }
      place(top + left, dx: x, dy: 0pt,
        line(start: (0pt, 0pt), end: (0pt, tl), stroke: tw + black))
      if calc.rem(i, 8) == 0 {
        place(top + left, dx: x - lblW / 2, dy: t-in + 6pt,
          box(width: lblW, align(center, text(font: body-font, size: 30pt, fill: black)[#calc.quo(i, 8)])))
      }
    }
  ]
}


// Matches the poster width so both share scale at the same zoom.
#let ruler-page() = page(
  width: 38in, height: 3.5in,
  margin: (top: 0.2in, bottom: 0.1in, x: 0.75in),
  fill: washu-cream,
)[
  #set par(justify: false)
  #set align(center)
  #text(font: body-font, size:36pt, weight: "bold", fill: washu-maroon, )[Reference Scale]
  #v(-0.1in)
  #text(font: body-font, size: 24pt, fill: ink)[
    12-in ruler scaled to true size of document below.\ 12.0 in = 30.5 cm
  ]
  #v(-0.1in)
  #ruler-12in()
]

// ===========================================================================
//  POSTER BODY
// ===========================================================================

#ruler-page()

#block(height: poster-content-h, width: 100%, breakable: false)[
  #grid(
    rows: (auto, 1fr),
    row-gutter: box-spacing,

    title-band(
      title:        [Sample Title for Scientific Poster: \ May Span One or Two Lines],
      authors:      [First A. Author#super[1,2],
                     Second B. Author#super[1,2],
                     Third C. Author#super[1],
                     Fourth D. Author#super[1]],
      affiliations: [#super[1]Department of Psychiatry, Washington University in St. Louis;
                     #super[2]Division of Biology & Biomedical Sciences, Neurosciences Graduate Program],
    ),

    grid(
      columns: (1fr, 1fr, 1fr),
      column-gutter: box-spacing,

      // ===================== COLUMN 1 =====================
      column-body(
        section([Background])[
          #lorem(55)
          #fig-placeholder(2.6in, [schematic / overview])
          #lorem(75)
        ],
        section([Summary of Findings])[
          #lorem(100)
        ],
        section-fill([Result 1])[
          #fig-placeholder(4.2in, [Figure 1])
          #lorem-fill()
        ],
      ),

      // ===================== COLUMN 2 =====================
      column-body(
        section([Result 2])[
          #fig-placeholder(5.5in, [Figure 2])
          #lorem(200)
        ],
        section-fill([Result 3])[
          #fig-placeholder(5.5in, [Figure 3])
          #lorem-fill()
        ],
      ),

      // ===================== COLUMN 3 =====================
      column-body(
        section([Result 4])[
          #fig-placeholder(6.0in, [Figure 4])
          #lorem(34)
        ],
        section([Discussion])[
          #lorem(42)
          #fig-placeholder(3.0in, [model / diagram])
        ],
        section([Next Steps])[
          #lorem(60)
        ],
        section-fill([References])[
          // Entries come from bibliography.bib (same folder). `full: true`
          // lists every entry in the file; drop it to show only works cited
          // in the body with @key (e.g. @wee2024). Change `style:` to another
          // CSL name to reformat, e.g. "ieee", "american-medical-association",
          // "vancouver", or "nature".
          #set text(size: 19pt)
          #set par(justify: false, leading: 0.5em)
          #bibliography("bibliography.bib", title: none, full: true, style: "cell")
        ],
      ),
    ),
  )
]


