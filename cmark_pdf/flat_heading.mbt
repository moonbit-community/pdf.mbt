///|
fn FlatHeading::to_strings(fhs : Array[FlatHeading]) -> Array[(String, String)] {
  let result = []
  for f in fhs {
    let num = f.num.map(Show::to_string).join(".")
    let text = f.text
    result.push((num, text))
  }
  result
}

///|
fn FlatHeading::to_graphic_operators(xs : Array[FlatHeading]) -> ContentStream {
  let result = []
  result.push(@pdf.Op_Tf("/F0", font_size_h1))
  result.push(@pdf.Op_TL(font_size_h1))
  let offset = 40.0
  result.push(@pdf.Op_single_quote(b"Table of Contents"))
  result.push(@pdf.Op_Tf("/F0", font_size_body))
  result.push(@pdf.Op_TL(font_size_body))
  result.push(@pdf.Op_T_star)
  for s in FlatHeading::to_strings(xs) {
    result.push(@pdf.Op_single_quote(s.0 |> pdf_bytes_of_string))
    result.push(@pdf.Op_TL(0))
    result.push(@pdf.Op_Td(offset, 0))
    result.push(@pdf.Op_Tj(pdf_bytes_of_string(s.1)))
    result.push(@pdf.Op_Td(-offset, 0))
    result.push(@pdf.Op_TL(font_size_body))
  }
  result.push(@pdf.Op_TL(font_size_body * 3))
  result.push(@pdf.Op_T_star)
  result
}
