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
    TimesRoman => "/Times-Roman"
    TimesBold => "/Times-Bold"
    TimesItalic => "/Times-Italic"
    TimesBoldItalic => "/Times-BoldItalic"
    Helvetica => "/Helvetica"
    HelveticaBold => "/Helvetica-Bold"
    HelveticaOblique => "/Helvetica-Oblique"
    HelveticaBoldOblique => "/Helvetica-BoldOblique"
    Courier => "/Courier"
    CourierBold => "/Courier-Bold"
    CourierOblique => "/Courier-Oblique"
    CourierBoldOblique => "/Courier-BoldOblique"
    Symbol => "/Symbol"
    ZapfDingbats => "/ZapfDingbats"
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
