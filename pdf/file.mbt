///|
/// 
/// A PDF file is represented by a sequence of 8-bit bytes. 
/// if this byte is ASCII char encoding, it is represented as such.
/// other bytes is binary data.
///
/// PDF object stream can be encoding as UTF-8 or UTF-16BE.
/// 
/// 
/// PDF file structure:
/// 
/// 1. Header
/// 2. Body
/// 3. Cross-reference table
/// 4. Trailer
/// 
pub impl @fmt.Format for File with write(
  value : File,
  buffer : @fmt.Memory,
  start : Int,
) -> Int {
  try {
    let mut offset = start
    offset += write_pdf_header(value, buffer, offset)
    let xref_offsets = []
    for n, obj in value.objects.iter2() {
      let xref_offset = write_pdf_obj(obj, n + 1, buffer, offset)
      xref_offsets.push(xref_offset)
      offset += xref_offset
    }
    offset += write_pdf_xrefs(xref_offsets, buffer, offset)
    offset += write_pdf_trailer(value.trailer, buffer, offset)
    offset += @fmt.write(b"startxref\n", buffer, offset)
    let startxref_offset = offset
    offset += @fmt.format_write(
      b"{}\n%%EOF\n",
      [startxref_offset],
      buffer,
      offset,
    )
    offset - start
  } catch {
    _ => panic()
  }
}

///|
pub impl @fmt.Format for File with count(value : File) -> Int {
  let mut total = 0
  total += count_pdf_header(value)
  let xref_offsets = []
  for n, obj in value.objects.iter2() {
    let obj_size = count_pdf_obj(obj, n + 1)
    xref_offsets.push(total)
    total += obj_size
  }
  total += count_pdf_xrefs(xref_offsets)
  total += count_pdf_trailer(value.trailer)
  total += 11 // "startxref\n"
  let startxref_offset = total
  total += @fmt.count(startxref_offset)
  total += 7 // "\n%%EOF\n"
  total
}

///|
fn write_pdf_header(pdf : File, buf : @fmt.Memory, start : Int) -> Int {
  try {
    let mut offset = start
    offset += @fmt.format_write(
      "%PDF-{}.{}\n",
      [pdf.major, pdf.minor],
      buf,
      offset,
    )
    // write pdf binary comment for editors to recognize this is a binary file
    // 
    // PDF file should transport as binary file
    //
    offset += @fmt.format_write(
      "%{}\n",
      [@fmt.BigEndian(0x80818283)],
      buf,
      offset,
    )
    offset - start
  } catch {
    _ => panic()
  }
}

///|
fn count_pdf_header(pdf : File) -> Int {
  5 + // "%PDF-"
  @fmt.count(pdf.major) +
  1 + // "."
  @fmt.count(pdf.minor) +
  1 + // "\n"
  1 + // "%"
  4 + // BigEndian(0x80818283)
  1 // "\n"
}

///|
fn write_pdf_obj(obj : Object, n : Int, buf : @fmt.Memory, start : Int) -> Int {
  try {
    let mut offset = start
    offset += @fmt.format_write("{} 0 obj\n", [n], buf, offset)
    offset += @fmt.write(obj, buf, offset)
    offset += @fmt.write(b"\nendobj\n", buf, offset)
    offset - start
  } catch {
    _ => panic()
  }
}

///|
fn count_pdf_obj(obj : Object, n : Int) -> Int {
  @fmt.count(n) +
  7 + // " 0 obj\n"
  @fmt.count(obj) +
  8 // "\nendobj\n"
}

///|
/// 
/// `nnnnnnnnnn ggggg n <eol>`
/// 
/// `nnnnnnnnnn` is a 10-digit, zero-padded byte offset
/// 
/// `ggggg` is the generation number, which is always `00000` in this implementation
///
/// `n` is a keyword identifying this as an in-use entry
/// `f` is for free entry
///
///  two character end-of-line sequences 
///  SP CR, SP LF, or CR LF
/// 
/// 
/// In this implementation, we use CR LF (`\r\n`)
fn write_pdf_xref(xref_offset : Int, buf : @fmt.Memory, start : Int) -> Int {
  try! @fmt.format_write(
    b"{} 00000 n\r\n",
    [@fmt.Left(xref_offset, width=10, padding=b'0')],
    buf,
    start,
  )
}

///|
fn count_pdf_xref(_xref_offset : Int) -> Int {
  10 + // 10-digit zero-padded offset
  10 // " 00000 n \r\n"
}

///|
fn write_pdf_xrefs(
  xref_offsets : Array[Int],
  buf : @fmt.Memory,
  start : Int,
) -> Int {
  try {
    let mut offset = start
    offset += @fmt.write(b"xref\n", buf, offset)
    offset += @fmt.format_write(
      b"0 {}\n",
      [xref_offsets.length() + 1],
      buf,
      offset,
    )
    offset += @fmt.write(b"0000000000 65535 f \n", buf, offset)
    for xref_offset in xref_offsets {
      offset += write_pdf_xref(xref_offset, buf, offset)
    }
    offset - start
  } catch {
    _ => panic()
  }
}

///|
fn count_pdf_xrefs(xref_offsets : Array[Int]) -> Int {
  let mut total = 0
  total += 5 // "xref\n"
  total += 2 // "0 "
  total += @fmt.count(xref_offsets.length() + 1)
  total += 1 // "\n"
  total += 18 // "0000000000 65535 f \n"
  for xref_offset in xref_offsets {
    total += count_pdf_xref(xref_offset)
  }
  total
}

///|
fn write_pdf_trailer(
  trailer_dict : Object,
  buf : @fmt.Memory,
  start : Int,
) -> Int {
  let mut offset = start
  offset += @fmt.write(b"trailer\n", buf, offset)
  offset += @fmt.write(trailer_dict, buf, offset)
  offset += @fmt.write(b"\n", buf, offset)
  offset - start
}

///|
fn count_pdf_trailer(trailer_dict : Object) -> Int {
  8 + // "trailer\n"
  @fmt.count(trailer_dict) +
  1 // "\n"
}
