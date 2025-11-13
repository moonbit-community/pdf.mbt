///|
pub(all) struct Stream(Bytes) derive(ToJson)

///|
/// pdf object 
pub(all) enum Object {
  /// `null` keyword
  Null
  /// `true` or `false` keyword
  Boolean(Bool)
  Integer(Int)
  Real(Double)
  /// PDF string can be represented in two ways:
  /// - `Literal string`: enclosed in parentheses `(...)`
  /// - `Hexadecimal string`: enclosed in angle brackets `<...>`
  ///
  /// those reprentations are for parsing.
  /// here all encoded as bytes sequence.
  ///
  /// Escape sequences in literal strings: ref to `ISO 32000-2:2020 (PDF 2.0)`, section 7.3.4.2
  /// 
  /// | Sequence | Measing                   |
  /// |----------|---------------------------|
  /// | `\n`     | LINE FEED                 |
  /// | `\r`     | CARRIAGE RETURN           |
  /// | `\t`     | HORIZONTAL TAB            |
  /// | `\b`     | BACKSPACE                 |
  /// | `\f`     | FORM FEED                 |
  /// | `\(`     | LEFT PARENTHESIS          |
  /// | `\)`     | RIGHT PARENTHESIS         |
  /// | `\\`     | REVERSE SOLIDUS           |
  /// | `\ddd`   | Character code ddd(octal) |
  ///
  String(Bytes)
  /// although SOLIDUS `/` is not considered as part of the name in PDF spec,
  /// But here we include it as part of the name.
  Name(Bytes)
  /// PDF array object is surrounded by square brackets, separated by whitespace.
  /// `[a b c ...]` 
  Array(Array[Object])
  /// PDF dictionary object is surrounded by double angle brackets.
  /// `<< /Key1 Value1 /Key2 Value2 ... >>`
  /// keys are PDF names, values are PDF objects.
  Dictionary(Array[(Bytes, Object)])
  /// PDF stream object is a sequence of binary bytes.
  /// 
  /// `
  /// <dictionary>
  /// stream
  /// ...
  /// endstream
  /// `
  ///
  /// dictionary: 
  ///
  /// - `/Length <n>` is **required**, where `<n>` is the length of the stream in bytes.
  ///
  /// - `/Filter <name|array>` is **optional**, if present, the stream data is encoded.
  ///
  /// - `/DecodeParms <dictionary|array>` is **optional**, if present, it specifies the parameters for the filters.
  ///
  /// other entries are optional and not listed here.
  ///
  Stream(Object, Stream)
  /// it should be positive integer, by default with 0 integer generation number
  ///
  /// `<n> <m> R`
  ///
  /// <n> is indirect object number
  /// <m> is generation number, by default 0
  ///
  /// indirect object definition:
  /// `
  /// <n> <m> obj
  /// ...
  /// endobj
  /// `
  Indirect(Int)
} derive(ToJson)

///|
/// 
/// [PDF – Graphic Operators – Cheat Sheet](https://pdfa.org/wp-content/uploads/2023/08/PDF-Operators-CheatSheet.pdf)
/// 
/// 
/// Text positioning operators:
/// - Td, TD, Tm, T*
/// 
/// Text showing operators:
/// - Tj, TJ, ', "
///
pub(all) enum GraphicOperator {
  /// set line width
  Op_w(Double)
  /// set line cap
  Op_J(Int)
  /// set line join 
  Op_j(Int)
  /// set miter limit
  Op_M(Double)
  /// set dash pattern
  Op_d(Array[Double], Double)
  /// set rendering intent 
  Op_ri(Bytes)
  /// set flatness
  Op_i(Double)
  /// set graphics state from dictionary 
  Op_gs(Bytes)
  /// save graphics state to stack 
  Op_q
  /// restore graphics state from stack 
  Op_Q
  /// modify CTM by concatenation 
  Op_cm(TransformMatrix)
  /// begin a new subpath 
  Op_m(Double, Double)
  /// append a straight segment 
  Op_l(Double, Double)
  /// cubic bezier 
  Op_c(Double, Double, Double, Double, Double, Double)
  /// cubic bezier 
  Op_v(Double, Double, Double, Double)
  /// cubic bezier  
  Op_y(Double, Double, Double, Double)
  /// close subpath  
  Op_h
  /// append rectangle 
  Op_re(Double, Double, Double, Double)
  /// stroke a path 
  Op_S
  /// close and stroke path 
  Op_s
  /// fill path, non-zero 
  Op_f
  /// fill path, non-zero 
  Op_F
  /// f* operator. fill path, even-odd 
  Op_f_star
  /// fill and stroke path, non-zero 
  Op_B
  /// B* operator. fill and stroke path, even-odd
  Op_B_star
  /// close fill and stroke, non-zero 
  Op_b
  /// b* operator. close fill and stroke, even-odd 
  Op_b_star
  /// path no-op
  Op_n
  /// clipping path, even-odd
  Op_W
  /// clipping path, non-zero 
  Op_W_star
  /// begin a text object 
  Op_BT
  /// end a text object 
  ///
  /// This operator will reset all state for text object
  ///
  ///  (1): `BT (hello world)Tj ET` 
  ///  (2): `BT (hello )Tj ET BT (world)Tj ET`
  /// 
  ///  (2) will write "hello " and "world" at the same start position. 
  ///  render effect is overlap.
  ///
  ///  (1) will render correctly.
  Op_ET
  /// set character spacing 
  Op_Tc(Double)
  /// set word spacing 
  Op_Tw(Double)
  /// set horizontal scaling 
  Op_Tz(Double)
  /// set leading 
  Op_TL(Double)
  /// set font size 
  Op_Tf(Bytes, Double)
  /// set text rendering mode 
  Op_Tr(Int)
  /// set text rise 
  Op_Ts(Double)
  /// move to start of next line, offset from start of current line by (x, y)
  Op_Td(Double, Double)
  /// move to start of next line, offset from start of current line by (x, y).
  /// this operator also sets leading to -y
  /// 
  /// the same as `-y TL x y Td` 
  ///
  Op_TD(Double, Double)
  /// set the text matrix 
  Op_Tm(TransformMatrix)
  /// T* operator
  /// 
  /// move to start of the next line.
  ///
  /// the same as `0 -T1 TD`
  ///
  /// T1 is the current leading.
  Op_T_star
  /// show text string 
  ///
  /// `(hello) Tj ( world) tj` is the same as `(hello world) Tj`
  ///
  /// This operator will change the text position by the width of the string.
  ///
  /// when any operator move the next line, text position will be reset to the start of the line.
  ///
  Op_Tj(Bytes)
  /// show text string
  /// 
  /// parameters is an array of strings or numbers. 
  /// - string: show text
  /// - number: adjust text position 
  ///
  /// how to adjust text position depends on the `writing mode`:
  /// - horizontal 
  /// - vertical
  ///
  /// more details please refer to PDF spec.
  Op_TJ(Object)
  /// move to next line and show text 
  Op_single_quote(Bytes)
  /// move to next line and show text using `w` as the word spacing and `c` as the character spacing
  ///
  /// the same as `w Tw c Tc <string> '`
  Op_double_quote(Double, Double, Bytes)
  /// set glyph width info 
  Op_d0(Double, Double)
  /// set glyph width info 
  Op_d1(Double, Double, Double, Double, Double, Double)
  /// set color space 
  Op_CS(Bytes)
  /// set color space for nonstroking operations 
  Op_cs(Bytes)
  /// set color in current color space 
  Op_SC(Array[Double])
  /// set color in current color space for nonstroking operations 
  Op_sc(Array[Double])
  /// set color in current color space 
  Op_SCN(Array[Double])
  /// set color in current color space for nonstroking operations 
  Op_scn(Array[Double])
  /// set color in current color space with name 
  Op_SCNName(Bytes, Array[Double])
  ///  set color in current color space for nonstroking operations with name 
  Op_scnName(Bytes, Array[Double])
  /// set gray 
  Op_G(Double)
  /// set gray nonstroking 
  Op_g(Double)
  /// set stroking color 
  Op_RG(Double, Double, Double)
  /// set painting color 
  Op_rg(Double, Double, Double)
  /// set CMYK stroking 
  Op_K(Double, Double, Double, Double)
  /// set CMYK nonstroking 
  Op_k(Double, Double, Double, Double)
  /// shading pattern 
  Op_sh(Bytes)
  /// inline image dictionary, previous decodeparams if any, data 
  ///
  /// PDF Graphic operator syntax:
  ///
  /// ```plaintext
  /// BI 
  /// ...key-value-pairs...
  /// ID
  /// ...Image data... 
  /// EI 
  /// ```
  /// more details see `ISO 32000-2:2020 (PDF 2.0)` section 8.9.7 `Inline Images`
  InlineImage(Object, Bytes)
  /// introduce an XObject 
  Op_Do(Bytes)
  /// marked content point 
  Op_MP(Bytes)
  /// property list 
  Op_DP(Bytes, Object)
  /// begin marked content sequence 
  Op_BMC(Bytes)
  /// property list 
  Op_BDC(Bytes, Object)
  /// end of marked content sequence
  Op_EMC
  /// start compatibility mode 
  Op_BX
  /// end compatibility mode 
  OP_EX
  /// unknown operand / operator sequence 
  Op_Unknown(Bytes)
  /// comments are silently ignored when reading, but can be written for debug 
  Op_Comment(Bytes)
}

///|
pub(all) struct File {
  major : Int
  minor : Int
  objects : Array[Object]
  trailer : Object
}

///|
///  
pub(all) struct TransformMatrix {
  a : Double
  b : Double
  c : Double
  d : Double
  e : Double
  f : Double
}

///|
pub(all) struct ContentStream(Array[GraphicOperator])

///|
/// 
/// The PostScript language names of 14 Type 1 fonts, known as the 
/// standard 14 fonts.
/// 
/// in PDF 1.0 to PDF 1.7, some PDF dictionary object fields is optional.
/// 
/// - `FirstChar` 
/// - `LastChar`
/// - `Widths`
/// - `FontDescriptor`
/// 
pub(all) enum StandardFont {
  TimesRoman
  TimesBold
  TimesItalic
  TimesBoldItalic
  Helvetica
  HelveticaBold
  HelveticaOblique
  HelveticaBoldOblique
  Courier
  CourierBold
  CourierOblique
  CourierBoldOblique
  Symbol
  ZapfDingbats
}

///|
/// PDF file without parsed objects, only lexed structures and bytes
pub(all) struct LexFile {
  header : LexHeader
  body : LexBody
  /// FIXME: support multiple xref tables
  /// 
  /// in the `ISO 32000-2:2020 (PDF 2.0)`, section 7.5.8.3 and 7.5.8.4,
  ///
  /// it explains PDF has three kinds of xref table:
  ///
  /// - standard cross-reference table:
  ///
  ///   syntax: xref...trailer
  ///
  /// - cross-reference stream:
  ///
  ///   syntax: <<\Type \XRef...>> stream... endstream endobj,
  ///   stream data is three fields specified field bytes length by `/W` array of integers.
  ///
  /// - hybrid cross-reference table:
  /// 
  ///   syntax: xref<empty>trailer <<\XRefStm _ ...>>,
  ///   1. `/XRefStm` specifies the byte offset of cross-reference stream object,
  ///   2. standard cross-reference table is empty.
  /// 
  /// the compatibility design:
  /// *new* PDF writer generates the PDF file, the *old* PDF reader can read the *original* content but cannot read the *modified* content.
  /// *new* PDF reader can read the *modified* content, first this readers should handle the `/XRefStm` entry, then read the `/Prev` entry in the main standard cross-reference table.
  /// *old* PDF writer cannot modify the *new* PDF writer generated PDF file, because the *old* PDF writer ignore the `/XRefStm` entry any modification is *non-sense*.
  ///
  xref_table : LexXRefTable
  trailer : BytesView
  start_xref_bytes_offset : Int
} derive(Eq, Show)

///|
pub(all) struct LexHeader {
  major : Int
  minor : Int
} derive(Eq, Show)

///|
pub(all) struct LexObj {
  /// 0-based position in the file
  /// this is used to validate xref table entries
  start_bytes_offset : Int
  object_num : Int
  generation_num : Int
  obj_bytes : BytesView
} derive(Eq, Show)

///|
struct LexBody(FixedArray[LexObj]) derive(Eq, Show)

///|
pub fn LexBody::length(self : LexBody) -> Int = "%fixedarray.length"

///|
pub fn LexBody::op_get(self : LexBody, index : Int) -> LexObj = "%fixedarray.get"

///|
pub fn LexBody::from(array : Array[LexObj]) -> LexBody {
  LexBody(FixedArray::from_array(array))
}

///|
pub fn LexBody::iter(self : LexBody) -> Iter[LexObj] {
  FixedArray::iter(self.0)
}

///|
pub(all) struct LexXRefTable {
  entries : Array[LexXRefEntry]
  start_num : Int
} derive(Eq, Show)

///|
pub(all) struct LexXRefEntry {
  bytes_offset : Int
  /// most of cases is 0
  generation_num : Int
  state : LexEntryState
} derive(Eq, Show)

///|
pub(all) enum LexEntryState {
  InUse
  Free
} derive(Eq, Show)
