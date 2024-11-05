// Template: https://typst.app/universe/package/supercharged-dhbw forked to maximized-thesis
// Reminder: Don't forget to install the neccecary fonts
#import "imports.typ": *
#show raw.where(lang: "bob"): it => bob-draw.render(it)
#let abstract         = include "chapters/abstract.typ"
#let appendix         = include "chapters/appendix.typ"
#let image-references = (
  "assets/images/typst.svg": "https://typst.app/assets/images/typst.svg",
)
// Make links blue
#show link: set text(fill: blue.darken(60%))
// Make enum work
#set enum(full: true)
// Setup Template
#show: maximized-thesis.with(
  title: "Thesis Title",
  authors: (
    (name: "Max Mustermann", student-id: "12345678", course: "Some Course", course-of-studies: "Some CoS", company: (
      (name: "Optional Company", post-code: "12345", city: "Some City", country: "Some Country")
    )),
  ),
  language: "en",
  at-dhbw: false,
  type-of-thesis: "Some kind of Thesis",
  show-confidentiality-statement: false,
  show-declaration-of-authorship: false,
  show-table-of-contents: true,
  show-acronyms: true,
  show-list-of-figures: true,
  show-list-of-tables: true,
  show-code-snippets: true,
  show-appendix: true,
  show-abstract: true,
  show-header: true,
  show-header-images: false,
  show-image-references: true,
  numbering-alignment: center,
  toc-depth: 3,
  abstract: abstract,
  appendix: appendix,
  acronyms: acronyms,
  image-references: image-references,
  university: "Some University",
  university-location: "some Location",
  supervisor: "Some Supervisor",
  date: datetime.today(),
  bibliography: bibliography("assets/bib/Bib.bib", style: "ieee"),
  logo-left: image("assets/images/logos/dhbwLogo.svg"),
  logo-right: image("assets/images/logos/dhbw.svg"),
  logo-size-ratio: "1:1",
)

#include "chapters/intro.typ"
#include "chapters/fundamentals.typ"
