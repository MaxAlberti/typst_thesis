#import "../imports.typ": *

= Fundamentals

== Sorting

Sort a list of Items to display alphabeticaly.

#let Begriffe = (
  "Heading": [#lorem(10)],
  "Another Heading": [#lorem(10)],
  "Some Heading": [#lorem(10)],
)
#let SortierteTitel = (tst: "")
#SortierteTitel.remove("tst")
#for Titel in Begriffe.keys() [
  #SortierteTitel.insert(upper(Titel), Titel)
]
#for SortierterTitel in SortierteTitel.keys().sorted() [
  #let Titel = SortierteTitel.at(SortierterTitel)
  #heading(Titel, level: 3, numbering: none, outlined: false)
  #Begriffe.at(Titel)
]

== Figures

Figures can be referenced like this @table_ref

=== Tabes from CSV

#figure(
  table(
    columns: (auto, auto, auto), 
    inset: 5pt,
    align: horizon,
    table.header(
      [*Heading 1*], [*2*], [*3*]
    ),
    ..csv("../assets/tables/example/data.csv").flatten()
  ), 
  caption: [Table Name]
) <table_ref>

=== Images

#figure(
  image("../assets/images/typst.svg", width: 30%), 
  caption: [dhbw svg],
)

=== Code

#figure(
  sourcefile(
    read("../assets/code/example-code/src/main.c"), 
    file: "docker-compose.yml", lang: "yml"
  ),
  caption: "All Code",
  supplement: "Source Code",
)

=== Multi element figure

#figure(
  grid(columns: 1, gutter: 2em,
    subfigure(
      sourcefile(
        read("../assets/code/example-code/src/main.c"), 
        file: "docker-compose.yml", lang: "yml"
      ),
      caption: "All Code",
      pos: bottom + center,
      dy: 1em,
      numbering: "(A)",
      lbl: label("some_linkable_label")
    ),
    subfigure(
      sourcefile(
        showrange:(3,4),
        read("../assets/code/example-code/src/main.c"), 
        file: "docker-compose.yml", lang: "yml"
      ),
      caption: "Selective Code",
      pos: bottom + center,
      dy: 1em,
      numbering: "(A)",
      lbl: label("other_linkable_label")
    ),
    [],
  ),
  caption: [Multi element figure],
  supplement: "Source Code",
) 



