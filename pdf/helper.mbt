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
      b'\\' => buffer.write_string("\\\\")
      b'\n' => buffer.write_string("\\n")
      b'\r' => buffer.write_string("\\r")
      b'\t' => buffer.write_string("\\t")
      b'\b' => buffer.write_string("\\b")
      b'\x0c' => buffer.write_string("\\f") // form feed
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
    trailer: Dictionary([(b"/Size", Integer(5)), (b"/Root", catalog)]),
    objects,
  }
}

///|
pub fn define_font_item(name~ : Bytes, font~ : Object) -> (Bytes, Object) {
  (name, font)
}

///|
pub fn define_fonts(fonts~ : Array[(Bytes, Object)]) -> (Bytes, Object) {
  (b"/Font", Dictionary(fonts))
}

///|
pub fn define_pages(pages~ : Array[Object]) -> Object {
  Dictionary([
    (b"/Type", Name(b"/Pages")),
    (b"/Kids", Array(pages)),
    (b"/Count", Integer(pages.length())),
  ])
}

///|
pub fn define_page(
  contents~ : Object,
  parent~ : Object,
  resources~ : Array[(Bytes, Object)],
) -> Object {
  Dictionary([
    (b"/Type", Name(b"/Page")),
    (b"/Contents", contents),
    (b"/Parent", parent),
    (
      b"/MediaBox",
      Array([Integer(0), Integer(0), Real(595.2765), Real(841.89105)]),
    ),
    (b"/Resources", Dictionary(resources)),
  ])
}

///|
pub fn define_catalog(pages~ : Object) -> Object {
  Dictionary([(b"/Type", Name(b"/Catalog")), (b"/Pages", pages)])
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
  (b"/XObject", Dictionary(xobjs))
}

///|
pub fn define_jpeg_image(
  image~ : Bytes,
  width~ : Int,
  height~ : Int,
  bpc~ : Int,
  icc~ : Int,
) -> Object {
  let obj = Dictionary([
    (b"/Type", Name(b"/XObject")),
    (b"/Subtype", Name(b"/Image")),
    (b"/Width", Integer(width)),
    (b"/Height", Integer(height)),
    (b"/ColorSpace", Array([Name(b"/ICCBased"), Indirect(icc)])),
    (b"/BitsPerComponent", Integer(bpc)),
    (b"/Filter", Name(b"/DCTDecode")),
    (b"/Length", Integer(image.length())),
  ])
  Stream(obj, Stream(image))
}

///|
pub fn define_icc(icc~ : Bytes) -> Object {
  Stream(
    Dictionary([
      (b"/Length", Integer(icc.length())),
      (b"/N", Integer(3)),
      (b"/Range", Array([0, 1, 0, 1, 0, 1].map(x => Integer(x)))),
    ]),
    icc,
  )
}
