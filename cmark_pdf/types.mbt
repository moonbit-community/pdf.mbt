///|
pub(all) enum Block {
  Heading(level~ : Int, text~ : String)
  Paragraph(Array[Inline])
  BlankLine
  CodeBlock(language~ : String, code~ : Array[Bytes])
  MoonBitCodeBlock(Array[Array[ColorSpaned]])
  Blocks(Array[Block])
  List(Array[Block])
} derive(Show, ToJson)

///|
pub(all) enum TokenStyle {
  Keyword
  Num
  Str
  Other
} derive(Show, ToJson)

///|
pub(all) enum Inline {
  Plain(String)
  StrongEmphasis(String)
  Emphasis(String)
  StrongEmphasis_Emphasis(String)
  CodeSpan(String)
} derive(Show, ToJson)

///|
pub(all) struct FlatHeading {
  num : Array[Int]
  text : String
} derive(Show, ToJson)

///|
pub(all) struct Doc(Array[Block]) derive(Show, ToJson)

///|
pub using @pdf {type ContentStream}

///|
struct Canvas(Array[@pdf.GraphicOperator])
