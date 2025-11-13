///|
using @pdf {type Object, type File}

///|
/// C language style escaped sequence spec.
/// 
/// Warning: this escaped function not equal to PDF literal string escaped sequence.
///
/// This function is intended to be used in debugging, logging, etc.
///
pub fn ascii_string_of_bytesview(non_escape : BytesView) -> String {
  let buffer = StringBuilder::new(size_hint=non_escape.length() * 2)
  for b in non_escape {
    // if b is non printable, please escape it
    match b {
      '\\' => buffer.write_string("\\\\")
      '\n' => buffer.write_string("\\n")
      '\r' => buffer.write_string("\\r")
      '\t' => buffer.write_string("\\t")
      '\b' => buffer.write_string("\\b")
      '\x0c' => buffer.write_string("\\f") // form feed
      c if c.to_int() < 32 || c.to_int() > 126 => {
        // Non-printable ASCII: use octal escape sequence
        let code = c.to_int()
        buffer.write_string("\\")
        buffer.write_string((code / 64).to_string())
        buffer.write_string((code % 64 / 8).to_string())
        buffer.write_string((code % 8).to_string())
      }
      c => buffer.write_char(c.to_char())
    }
  }
  buffer.to_string()
}

///|
pub fn string_of_memory(mem : @fmt.Memory, len : Int) -> String {
  let buf = StringBuilder::new(size_hint=len)
  for i in 0..<len {
    buf.write_char(mem[i].to_char())
  }
  buf.to_string()
}

///|
pub fn bytes_of_memory(mem : @fmt.Memory, len : Int) -> Bytes {
  Bytes::makei(len, i => mem[i])
}

///|
pub fn make_pdf(catalog : Object, objects : Array[Object]) -> File {
  File::{
    major: 1,
    minor: 4,
    trailer: Dictionary([("/Size", Integer(5)), ("/Root", catalog)]),
    objects,
  }
}

///|
pub fn define_font_item(name~ : Bytes, font~ : Object) -> (Bytes, Object) {
  (name, font)
}

///|
pub fn define_fonts(fonts~ : Array[(Bytes, Object)]) -> (Bytes, Object) {
  ("/Font", Dictionary(fonts))
}

///|
pub fn define_pages(pages~ : Array[Object]) -> Object {
  Dictionary([
    ("/Type", Name("/Pages")),
    ("/Kids", Array(pages)),
    ("/Count", Integer(pages.length())),
  ])
}

///|
pub fn define_page(
  contents~ : Object,
  parent~ : Object,
  resources~ : Array[(Bytes, Object)],
) -> Object {
  Dictionary([
    ("/Type", Name("/Page")),
    ("/Contents", contents),
    ("/Parent", parent),
    (
      "/MediaBox",
      Array([Integer(0), Integer(0), Real(595.2765), Real(841.89105)]),
    ),
    ("/Resources", Dictionary(resources)),
  ])
}

///|
pub fn define_catalog(pages~ : Object) -> Object {
  Dictionary([("/Type", Name("/Catalog")), ("/Pages", pages)])
}

///|
/// 
/// PDF object stream 
/// 
/// `/Filter` schemas:
/// 
///   FILTER name         Parameters     Description
/// - `/ASCIIHexDecode`   no             ASCII hexadecimal encoding
/// - `/ASCII85Decode`    no             ASCII base-85 encoding
/// - `/LZWDecode`        no             LZW compression
/// - `/FlateDecode`      yes            Flate (zlib/deflate) compression
/// - `/CCITTFaxDecode`   yes            CCITT Group 3 or 4 compression for monochrome images(1 bit per pixel)
/// - `/JBIG2Decode`      yes            JBIG2 compression for monochrome images(1 bit per pixel)
/// - `/DCTDecode`        no             JPEG compression 
/// - `/JPXDecode`        no             JPEG 2000 compression
/// - `/Crypt`            yes            Decryption filter

///|
/// 
/// PDF Font types:
/// 
/// Subtype Value 
/// `Type0` 
/// `Type1`
/// `MMType1`
/// `Type3`
/// `TrueType`  A font based on the TrueType font format.
/// `CIDFontType0`
/// `CIDFontType2`

///| ToUnicode CMaps:
/// 
/// ISO 32000-2:2020(E) 9.10.3 ToUnicode CMaps
/// 
/// CMap has special syntax embedded in PDF stream object.
/// 
/// you can find full examples via following partial example:
/// 
/// <n> 0 obj 
/// <cmap-dictionary>
/// stream
/// /CIDInit /ProcSet findresource begin
/// ... CMap content ...
/// end 
/// endstream
/// endobj
///

///|
pub fn define_xobject(xobjs~ : Array[(Bytes, Object)]) -> (Bytes, Object) {
  ("/XObject", Dictionary(xobjs))
}

///|
pub fn define_jpeg_image(
  image~ : Bytes,
  width~ : Int,
  height~ : Int,
  bpc~ : Int,
  icc~ : Int,
) -> Object {
  let obj = @pdf.Dictionary([
    ("/Type", Name("/XObject")),
    ("/Subtype", Name("/Image")),
    ("/Width", Integer(width)),
    ("/Height", Integer(height)),
    ("/ColorSpace", Array([Name("/ICCBased"), Indirect(icc)])),
    ("/BitsPerComponent", Integer(bpc)),
    ("/Filter", Name("/DCTDecode")),
    ("/Length", Integer(image.length())),
  ])
  Stream(obj, Stream(image))
}

///|
pub fn define_icc(icc~ : Bytes) -> Object {
  Stream(
    Dictionary([
      ("/Length", Integer(icc.length())),
      ("/N", Integer(3)),
      ("/Range", Array([0, 1, 0, 1, 0, 1].map(Integer(_)))),
    ]),
    icc,
  )
}
