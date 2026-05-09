///|
pub impl Show for StandardFont with to_string(self) {
  match self {
    TimesRoman => "Times-Roman"
    TimesBold => "Times-Bold"
    TimesItalic => "Times-Italic"
    TimesBoldItalic => "Times-BoldItalic"
    Helvetica => "Helvetica"
    HelveticaBold => "Helvetica-Bold"
    HelveticaOblique => "Helvetica-Oblique"
    HelveticaBoldOblique => "Helvetica-BoldOblique"
    Courier => "Courier"
    CourierBold => "Courier-Bold"
    CourierOblique => "Courier-Oblique"
    CourierBoldOblique => "Courier-BoldOblique"
    Symbol => "Symbol"
    ZapfDingbats => "ZapfDingbats"
  }
}

///|
pub impl Show for StandardFont with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub fn StandardFont::to_pdf_name(self : StandardFont) -> Object {
  let text : Bytes = match self {
    TimesRoman => b"/Times-Roman"
    TimesBold => b"/Times-Bold"
    TimesItalic => b"/Times-Italic"
    TimesBoldItalic => b"/Times-BoldItalic"
    Helvetica => b"/Helvetica"
    HelveticaBold => b"/Helvetica-Bold"
    HelveticaOblique => b"/Helvetica-Oblique"
    HelveticaBoldOblique => b"/Helvetica-BoldOblique"
    Courier => b"/Courier"
    CourierBold => b"/Courier-Bold"
    CourierOblique => b"/Courier-Oblique"
    CourierBoldOblique => b"/Courier-BoldOblique"
    Symbol => b"/Symbol"
    ZapfDingbats => b"/ZapfDingbats"
  }
  Name(text)
}

///|
pub fn StandardFont::to_pdf_dictionary(self : StandardFont) -> Object {
  Dictionary([
    (b"/Type", Name(b"/Font")),
    (b"/Subtype", Name(b"/Type1")),
    (b"/BaseFont", self.to_pdf_name()),
  ])
}
