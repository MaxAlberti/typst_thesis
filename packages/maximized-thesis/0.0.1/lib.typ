#import "packages/acrostiche/0.3.1/acrostiche.typ" : *
#import "packages/codelst/2.0.1/codelst.typ" : *
#import "titlepage.typ": *
#import "confidentiality-statement.typ": *
#import "declaration-of-authorship.typ": *
#import "../../bob-draw/0.1.0/lib.typ" as bob-draw
#import "../../cmarker/0.1.0/lib.typ" as cmarker

// Workaround for the lack of an `std` scope.
#let std-bibliography = bibliography

#let maximized-thesis(
  title: "",
  authors: (:),
  language: "en",
  at-dhbw: false,
  type-of-thesis: "Studienarbeit",
  show-confidentiality-statement: true,
  show-declaration-of-authorship: true,
  show-table-of-contents: true,
  show-acronyms: true,
  show-list-of-figures: true,
  show-list-of-tables: true,
  show-code-snippets: true,
  show-appendix: false,
  show-abstract: true,
  show-header: true,
  show-header-images: true,
  show-image-references: false,
  numbering-alignment: center,
  toc-depth: 3,
  abstract: none,
  appendix: none,
  acronyms: none,
  image-references: none, // Dictionary of image_path: image source
  university: "",
  university-location: "",
  supervisor: "",
  date: datetime.today(),
  bibliography: none,
  logo-left: none,
  logo-right: none,
  logo-size-ratio: "1:1",
  body,
) = {
  // set the document's basic properties
  set document(title: title, author: authors.map(author => author.name))
  let author-count = authors.len()
  let many-authors = author-count > 4

  init-acronyms(acronyms)

  // define logo size with given ration
  let left-logo-height = 2.4cm // left logo is always 2.4cm high
  let right-logo-height = 2.4cm // right logo defaults to 1.2cm but is adjusted below
  let logo-ratio = logo-size-ratio.split(":")
  if (logo-ratio.len() == 2) {
    right-logo-height = right-logo-height * (float(logo-ratio.at(1)) / float(logo-ratio.at(0)))
  }

  // save heading and body font families in variables
  let body-font = "Open Sans"
  let heading-font = "Montserrat"
  
  // customize look of figure
  set figure.caption(separator: [ --- ], position: bottom)

  // set body font family
  set text(font: body-font, lang: language, 12pt)
  show heading: set text(weight: "semibold", font: heading-font)

  //heading numbering
  set heading(numbering: "1.1")
 
  // set link style
  show link: it => underline(text(it))
  
  show heading.where(level: 1): it => {
    pagebreak()
    v(2em) + it + v(1em)
  }
  show heading.where(level: 2): it => v(1em) + it + v(0.5em)
  show heading.where(level: 3): it => v(0.5em) + it + v(0.25em)

  titlepage(authors, title, language, date, at-dhbw, logo-left, logo-right, left-logo-height, right-logo-height, university, university-location, supervisor, heading-font, many-authors, type-of-thesis)

  set page(
    margin: (top: 8em, bottom: 8em),
    header: {
      if (show-header) {
        grid(
          columns: (1fr, auto),
          align: (left, right),
          gutter: 2em,
          emph(align(center + horizon,text(size: 10pt, title))),
          if (show-header-images) {
            stack(dir: ltr,
              spacing: 1em,
              if logo-left != none {
                set image(height: left-logo-height / 2)
                logo-left
              },
              if logo-right != none {
                set image(height: right-logo-height / 2)
                logo-right
              }
            )
          } else {
          }
        )
        v(-0.75em)
        line(length: 100%)
      }
    }
  )

  // set page numbering to roman numbering
  set page(
    numbering: "I",
    number-align: numbering-alignment,
  )
  counter(page).update(1)

  

  if (not at-dhbw and show-confidentiality-statement) {
    confidentiality-statement(authors, title, university, university-location, date, language, many-authors)
  }

  if (show-declaration-of-authorship) {
    declaration-of-authorship(authors, title, date, language, many-authors)
  }

  set par(justify: true, leading: 1em)
  set block(spacing: 2em)

  if (show-abstract and abstract != none) {
    align(center + horizon, heading(level: 1, numbering: none)[Abstract])
    text(abstract)
  }

  show outline.entry.where(
    level: 1,
  ): it => {
    v(18pt, weak: true)
    strong(it)
  }

  if (show-table-of-contents) {
    outline(title: [#if (language == "de") {
      [Inhaltsverzeichnis]
    } else {
      [Table of Contents]
    }], indent: auto, depth: toc-depth)
  }
  context {
    let elems = query(figure.where(kind: image), here())
    let count = elems.len()
    
    if (show-list-of-figures and count > 0) {
      outline(
        title: [#heading(level: 3)[#if (language == "de") {
          [Abbildungsverzeichnis]
        } else {
          [List of Figures]
        }]],
        target: figure.where(kind: image),
      )
    }
  }

  context {
    let elems = query(figure.where(kind: table), here())
    let count = elems.len()

    if (show-list-of-tables and count > 0) {
      outline(
        title: [#heading(level: 3)[#if (language == "de") {
          [Tabellenverzeichnis]
        } else {
          [List of Tables]
        }]],
        target: figure.where(kind: table),
      )
    }
  }

  context {
    let elems = query(figure.where(kind: raw), here())
    let count = elems.len()

    if (show-code-snippets and count > 0) {
      outline(
        title: [#heading(level: 3)[#if (language == "de") {
          [Codeverzeichnis]
        } else {
          [Code Snippets]
        }]],
        target: figure.where(kind: raw),
      )
    }
  }
    
  if (show-acronyms and acronyms.len() > 0) {
    heading(level: 1, outlined: false, numbering: none)[#if (language == "de") {
      [Abkürzungsverzeichnis]
    } else {
      [List of Acronyms]
    }]

    state("acronyms", none).display(acronyms => {

      let acr-sorted = (tst: "")
      acr-sorted.remove("tst")
      for acr in acronyms.keys() {
        acr-sorted.insert(upper(acr), acr)
      }

      // print the acronyms
      for acr-upper in acr-sorted.keys().sorted() {
        let acr = acr-sorted.at(acr-upper)
        let acr-cont = acronyms.at(acr)

        
        let acr-long = if type(acr-cont) == array {
          acr-cont.at(0)
        } else {
          acr-cont
        }

        let acr-desc = if type(acr-cont) == array and acr-cont.len() > 1 {
          acr-cont.at(1)
        } else {
          none
        }

        grid(
          columns: (0.8fr, 1.2fr),
          gutter: 0.5em,
          [*#acr*], [#acr-long],
        )
      }
    })
  }

  
  
  
  // reset page numbering and set to arabic numbering
  set page(
    numbering: "1",
    footer: context align(numbering-alignment, numbering(
    "1 / 1", 
    ..counter(page).get(),
    ..counter(page).at(<end>),
    ))
  )
  counter(page).update(1)

  body

  [#metadata(none)<end>]
  // reset page numbering and set to alphabetic numbering
  set page(
    numbering: "a",
    footer: context align(numbering-alignment, numbering(
      "a", 
      ..counter(page).get(),
    ))
  )
  counter(page).update(1)

  // Display bibliography.
  if bibliography != none {
    set std-bibliography(title: [#if (language == "de") {
      [Literatur]
    } else {
      [References]
    }], style: "ieee")
    bibliography
  }

  if (show-image-references and image-references != none and type(image-references) == dictionary) {
    heading(level: 1, numbering: none)[#if (language == "de") {
      [Bildquellen]
    } else {
      [Image References]
    }]
    context {
      let figures = query(figure.where(kind: image))
      for (i, fig) in figures.enumerate() [
        #let delimiter = [:]
        #let fparr = fig.body.path.split("/")
        #while fparr.len() > 3 {
          fparr = fparr.slice(1)
        }
        #let fpath = fparr.join("/")
        #if fpath in image-references.keys() [
          #table(
            columns: (20%,80%),
            stroke:none,
            inset: 0pt,
            [*#fig.caption.supplement #(i+1)#delimiter*], [#image-references.at(fpath)\ ],
          )
        ] else [
          #table(
            columns: (20%,80%),
            stroke:none,
            inset: 0pt,
            [*#fig.caption.supplement #(i+1)#delimiter*], [Unbekannte Quelle\ ]
          )
        ]
      ]
    }
  }

  let generate_apendix() = {
    // Automatisch generierte Anhänge
    // - Generiere Code Anhänge
    let code_data = json("../../../assets/code/code_data.json")
    for (code_repo, data) in code_data [
      #heading(level: 1)[#if (language == "de") {
        [Code Anhang - #code_repo]
      } else {
        [Code Appendix - #code_repo]
      }]
      #label("appendix_code_" + code_repo)

      #if (language == "de") {
        [Siehe angehängten Ordner '#code_repo' im Anhang-Archiv unter 'code.zip'] 
      } else {
        [See attached folder '#code_repo' in the Appendix archive under 'code.zip' ]
      }

      #set heading(
        numbering: none,
        outlined: false
      )
      #if data.at("readme").len() > 0 [
        #heading(level: 2)[#if (language == "de") {
          [Readme]
        } else {
          [Readme]
        }]
        #cmarker.render(read(data.at("readme")), h1-level: 3)
      ]
      
      #heading(level: 2)[#if (language == "de") {
        [Struktur]
      } else {
        [Structure]
      }]
      #bob-draw.render(data.at("tree"))
    ]
    // - Generiere Web Quellen
    let bib_data = json("../../../assets/bib/bib_data.json")
    for (bib_id_key, data) in bib_data [
      #heading(level: 1)[#if (language == "de") {
        [Web Quelle - #data.title #ref(label(bib_id_key))]
      } else {
        [Web Reference - #data.title #ref(label(bib_id_key))]
      }]
      #if (language == "de") {
        [Siehe angehängte Datei '#data.html.split("/").last()'] 
      } else {
        [See attatched file '#data.html.split("/").last()']
      }
      /*
      #for img in data.pages [
        #image(img, height: 93%)
      ]
      */
    ]
  }


  if (show-appendix and appendix != none) {
    heading(level: 1, numbering: none)[#if (language == "de") {
      [Anhang]
    } else {
      [Appendix]
    }]
    [\ ]
    // Set Apendix item numbering
    counter(heading).update(0)
    if (language == "de") {
      set heading(
        numbering: "A", 
        outlined: false,
        supplement: "Anhang"
      )
      appendix
      generate_apendix()
    } else {
      set heading(
        numbering: "A", 
        outlined: false,
        supplement: "Appendix"
      )
      appendix
      generate_apendix()
    }
  }
  
}