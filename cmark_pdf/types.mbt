///|
pub(all) enum Block {
  Heading(level~ : Int, text~ : String)
  Paragraph(Array[Inline])
  BlankLine
  CodeBlock(language~ : String, code~ : Array[Bytes])
  MoonBitCodeBlock(Array[Array[ColorSpaned]])
  Blocks(Array[Block])
  List(Array[Block])
} derive(Debug, ToJson)

///|
pub(all) enum TokenStyle {
  Keyword
  Num
  Str
  Other
} derive(Debug, ToJson)

///|
pub(all) enum Inline {
  Plain(String)
  StrongEmphasis(String)
  Emphasis(String)
  StrongEmphasis_Emphasis(String)
  CodeSpan(String)
} derive(Debug, ToJson)

///|
pub(all) struct FlatHeading {
  num : Array[Int]
  text : String
} derive(Debug, ToJson)

///|
pub(all) struct Doc(Array[Block]) derive(Debug, ToJson)

///|
pub using @pdf {type ContentStream}

///|
struct Canvas(Array[@pdf.GraphicOperator])
