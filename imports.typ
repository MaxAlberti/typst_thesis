#import "packages/maximized-thesis/0.0.1/lib.typ": *
#import "acronyms.typ": acronyms
#import "packages/bob-draw/0.1.0/lib.typ" as bob-draw
#import "packages/cmarker/0.1.0/lib.typ"as cmarker

#let subfigure(body, pos: top + left, dx: 0%, dy: 0%, caption: "", numbering: "(a)", separator: none, lbl: none, supplement: none) = {
  let fig = figure(body, caption: none, kind: "subfigure", supplement: none, numbering: numbering, outlined: false)
  
  let number = locate(loc => {
    let fc = query(selector(figure).before(loc), loc).last().counter.display(numbering)
    return fc
  })
  if caption != "" and separator == none { separator = ":" }
  caption = [#set text(10pt); #supplement #number#separator #caption]

  return [ #fig #lbl #place(pos, dx: dx, dy: dy, caption)]
}
#show figure: it => {
  if it.kind != "subfigure" {
    locate(loc => {
      let q = query(figure.where(kind: "subfigure").after(loc), loc)
      q.first().counter.update(0) // reset the subfigure counter once out of the parent figure
    })
  }
  it
}
#show ref: it => {
  if it.element != none and it.element.func() == figure and it.element.kind == "subfigure" {
    locate(loc => {
      let q = query(figure.where(outlined: true).before(it.target), loc).last()
      ref(q.label)
    })
  }
  it
}