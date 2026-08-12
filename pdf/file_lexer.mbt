///|
suberror LexError {
  LexError(String)
} derive(Debug)

///|
pub(all) struct LexResult[T] {
  value : T
  start_bytes_offset : Int
  end_bytes_offset : Int
  rest : BytesView
} derive(Debug)

///|
pub fn tokenize_header(
  input : BytesView,
  start_bytes_offset~ : Int,
) -> LexResult[LexHeader] raise LexError {
  guard input.has_prefix(b"%PDF-") else { raise LexError("invalid PDF header") }
  let major_start = b"%PDF-".length()
  let major_end = scan_ascii_digits(input, major_start)
  guard major_end > major_start &&
    major_end < input.length() &&
    input[major_end] == b'.' else {
    raise LexError("invalid PDF header")
  }
  let minor_start = major_end + 1
  let minor_end = scan_ascii_digits(input, minor_start)
  guard minor_end > minor_start &&
    pdf_eol_length(input[minor_end:]) is Some(eol_length) else {
    raise LexError("invalid PDF header")
  }
  let end = minor_end + eol_length
  let (major, _) = try! @lexer_bytes.tokenize_int(input[major_start:major_end])
  let (minor, _) = try! @lexer_bytes.tokenize_int(input[minor_start:minor_end])
  {
    value: { major, minor },
    start_bytes_offset,
    end_bytes_offset: start_bytes_offset + end,
    rest: input[end:],
  }
}

///|
const EndObj = b"endobj"

///|
fn skip_space(input : BytesView) -> Int {
  for end = 0; end < input.length(); end = end + 1 {
    match input[end] {
      b' ' | b'\r' | b'\n' => ()
      _ => return end
    }
  }
  input.length()
}

///|
pub fn tokenize_body(
  input : BytesView,
  start_bytes_offset~ : Int,
) -> LexResult[LexBody] {
  let mut offset = start_bytes_offset
  let mut rest = input
  let body_buffer = []
  for ;; {
    // in `ISO 32000-2:2020 (PDF 2.0)`, section 7.3.10
    // 
    // The definition of and indirect object in a PDF file **shall** consist of its object number
    // and generation number(separated by white-space), followed by the value of the object bracketed
    // between the keywords `obj` and `endobj`
    //
    let obj_num_end = scan_ascii_digits(rest, 0)
    if obj_num_end == 0 {
      break
    }
    let first_space_end = scan_byte(rest, obj_num_end, b' ')
    if first_space_end == obj_num_end {
      break
    }
    let gen_num_start = first_space_end
    let gen_num_end = scan_ascii_digits(rest, gen_num_start)
    if gen_num_end == gen_num_start {
      break
    }
    let second_space_end = scan_byte(rest, gen_num_end, b' ')
    if second_space_end == gen_num_end ||
      !starts_with_at(rest, second_space_end, b"obj") {
      break
    }
    let header_length = second_space_end + b"obj".length()
    let rest_after_header = rest[header_length:]
    match rest_after_header.find(EndObj) {
      Some(endobj_start_idx) => {
        let obj_bytes = rest_after_header[0:endobj_start_idx]
        let (object_num, _) = try! @lexer_bytes.tokenize_int(
          rest[0:obj_num_end],
        )
        let (generation_num, _) = try! @lexer_bytes.tokenize_int(
          rest[gen_num_start:gen_num_end],
        )
        let obj = LexObj::{
          start_bytes_offset: offset,
          object_num,
          generation_num,
          obj_bytes,
        }
        body_buffer.push(obj)
        let endobj_end_idx = endobj_start_idx + EndObj.length()
        rest = rest_after_header[endobj_end_idx:]
        offset += header_length + endobj_end_idx
        let skip_len = skip_space(rest)
        rest = rest[skip_len:]
        offset += skip_len
      }
      None => break
    }
  }
  {
    value: LexBody::from(body_buffer),
    start_bytes_offset,
    end_bytes_offset: offset,
    rest,
  }
}

///|
/// Handle two character end-of-line sequences per PDF specification:
/// SP CR, SP LF, or CR LF
/// 
/// Also accepts single character sequences (\n, \r) for backward compatibility.
/// This not equals to end-of-line marker in PDF spec.
pub fn tokenize_xref_entry(
  input : BytesView,
  start_bytes_offset~ : Int,
) -> LexResult[LexXRefEntry] raise LexError {
  let offset_end = scan_ascii_digits(input, 0)
  guard offset_end > 0 &&
    offset_end < input.length() &&
    input[offset_end] == b' ' else {
    raise LexError(
      "Invalid xref entry format in \{start_bytes_offset}, input `\{try! @encoding/utf8.decode(input)}`",
    )
  }
  let generation_start = offset_end + 1
  let generation_end = scan_ascii_digits(input, generation_start)
  guard generation_end > generation_start &&
    generation_end + 1 < input.length() &&
    input[generation_end] == b' ' else {
    raise LexError(
      "Invalid xref entry format in \{start_bytes_offset}, input `\{try! @encoding/utf8.decode(input)}`",
    )
  }
  let state = match input[generation_end + 1] {
    b'n' => LexEntryState::InUse
    b'f' => Free
    _ =>
      raise LexError(
        "Invalid xref entry format in \{start_bytes_offset}, input `\{try! @encoding/utf8.decode(input)}`",
      )
  }
  let after_state = generation_end + 2
  let after_spaces = scan_byte(input, after_state, b' ')
  guard xref_eol_length(input[after_spaces:]) is Some(eol_length) else {
    raise LexError(
      "Invalid xref entry format in \{start_bytes_offset}, input `\{try! @encoding/utf8.decode(input)}`",
    )
  }
  let end = after_spaces + eol_length
  let (bytes_offset, _) = try! @lexer_bytes.tokenize_int(input[0:offset_end])
  let (generation_num, _) = try! @lexer_bytes.tokenize_int(
    input[generation_start:generation_end],
  )
  {
    value: { bytes_offset, generation_num, state },
    start_bytes_offset,
    end_bytes_offset: start_bytes_offset + end,
    rest: input[end:],
  }
}

///|
pub fn tokenize_xref_table(
  input : BytesView,
  start_bytes_offset : Int,
) -> LexResult[LexXRefTable] raise LexError {
  guard input.has_prefix(b"xref") &&
    pdf_eol_length(input[b"xref".length():]) is Some(first_eol_length) else {
    raise LexError(
      (
        $| Invalid xref table format in \{start_bytes_offset}
        $|
        $| input: \{try! @encoding/utf8.decode(input)}
      ),
    )
  }
  let start_num_start = b"xref".length() + first_eol_length
  let start_num_end = scan_ascii_digits(input, start_num_start)
  guard start_num_end > start_num_start &&
    start_num_end < input.length() &&
    input[start_num_end] == b' ' else {
    raise LexError(
      (
        $| Invalid xref table format in \{start_bytes_offset}
        $|
        $| input: \{try! @encoding/utf8.decode(input)}
      ),
    )
  }
  let count_start = start_num_end + 1
  let count_end = scan_ascii_digits(input, count_start)
  guard count_end > count_start &&
    pdf_eol_length(input[count_end:]) is Some(second_eol_length) else {
    raise LexError(
      (
        $| Invalid xref table format in \{start_bytes_offset}
        $|
        $| input: \{try! @encoding/utf8.decode(input)}
      ),
    )
  }
  let header_length = count_end + second_eol_length
  let (start_num, _) = try! @lexer_bytes.tokenize_int(
    input[start_num_start:start_num_end],
  )
  let (count, _) = try! @lexer_bytes.tokenize_int(input[count_start:count_end])
  let mut current_rest = input[header_length:]
  let mut current_offset = start_bytes_offset + header_length
  let entries = []
  for _ in 0..<count {
    let entry_result = tokenize_xref_entry(
      current_rest,
      start_bytes_offset=current_offset,
    )
    entries.push(entry_result.value)
    current_rest = entry_result.rest
    current_offset = entry_result.end_bytes_offset
  }
  {
    value: { entries, start_num },
    start_bytes_offset,
    end_bytes_offset: current_offset,
    rest: current_rest,
  }
}

///|
pub fn tokenize_trailer(
  input : BytesView,
  start_bytes_offset : Int,
) -> LexResult[BytesView] raise LexError {
  guard input.has_prefix(b"trailer") &&
    pdf_eol_length(input[b"trailer".length():]) is Some(header_eol_length) else {
    raise LexError("Invalid trailer format")
  }
  let header_length = b"trailer".length() + header_eol_length
  let rest_after_header = input[header_length:]
  let startxref_pattern = b"startxref"
  let mut trailer_content_end = 0
  let mut found_startxref = false
  while trailer_content_end + startxref_pattern.length() <=
        rest_after_header.length() {
    if trailer_content_end + startxref_pattern.length() <=
      rest_after_header.length() {
      let slice = rest_after_header[trailer_content_end:trailer_content_end +
        startxref_pattern.length()]
      if slice == startxref_pattern[:] {
        if trailer_content_end == 0 {
          found_startxref = true
          break
        } else {
          let prev_char = rest_after_header[trailer_content_end - 1]
          if prev_char == b'\n' || prev_char == b'\r' {
            found_startxref = true
            break
          }
        }
      }
    }
    trailer_content_end += 1
  }
  if !found_startxref {
    raise LexError("No 'startxref' found after trailer")
  }
  let mut dict_end = trailer_content_end
  if dict_end > 0 {
    let last_char = rest_after_header[dict_end - 1]
    if last_char == b'\n' || last_char == b'\r' {
      dict_end -= 1
      if dict_end > 0 &&
        last_char == b'\n' &&
        rest_after_header[dict_end - 1] == b'\r' {
        dict_end -= 1
      }
    }
  }
  let trailer_dict = rest_after_header[:dict_end]
  let rest_at_newline = rest_after_header[dict_end:]
  guard pdf_eol_length(rest_at_newline) is Some(newline_length) else {
    raise LexError("Expected newline before 'startxref'")
  }
  let all_length = header_length + dict_end + newline_length
  {
    value: trailer_dict,
    start_bytes_offset,
    end_bytes_offset: start_bytes_offset + all_length,
    rest: input[all_length:],
  }
}

///|
pub fn tokenize_startxref(
  input : BytesView,
  start_bytes_offset : Int,
) -> LexResult[Int] raise LexError {
  guard input.has_prefix(b"startxref") &&
    pdf_eol_length(input[b"startxref".length():]) is Some(first_eol_length) else {
    raise LexError("Invalid startxref format")
  }
  let offset_start = b"startxref".length() + first_eol_length
  let offset_end = scan_ascii_digits(input, offset_start)
  guard offset_end > offset_start &&
    pdf_eol_length(input[offset_end:]) is Some(second_eol_length) else {
    raise LexError("Invalid startxref format")
  }
  let eof_start = offset_end + second_eol_length
  guard starts_with_at(input, eof_start, b"%%EOF") else {
    raise LexError("Invalid startxref format")
  }
  let end = eof_start + b"%%EOF".length()
  let (xref_offset, _) = try! @lexer_bytes.tokenize_int(
    input[offset_start:offset_end],
  )
  {
    value: xref_offset,
    start_bytes_offset,
    end_bytes_offset: start_bytes_offset + end,
    rest: input[end:],
  }
}

///|
/// return advance offset
pub fn skip_comment(input : BytesView) -> Int {
  guard input is [b'%', .. rest_after_percent] else { return 0 }
  let max_comment_length = 1024
  let mut comment_content_end = 0
  let mut found_newline = false
  while comment_content_end < rest_after_percent.length() &&
        comment_content_end < max_comment_length {
    let char = rest_after_percent[comment_content_end]
    if char == b'\r' || char == b'\n' {
      found_newline = true
      break
    }
    comment_content_end += 1
  }
  if found_newline {
    let rest_at_newline = rest_after_percent[comment_content_end:]
    guard pdf_eol_length(rest_at_newline) is Some(newline_length) else {
      return 0
    }
    1 + comment_content_end + newline_length
  } else {
    1 + comment_content_end
  }
}

///|
pub fn tokenize_file(input : BytesView) -> LexResult[LexFile] raise LexError {
  let header_result = tokenize_header(input, start_bytes_offset=0)
  let mut current_rest = header_result.rest
  let mut current_offset = header_result.end_bytes_offset
  let comment_skip1 = skip_comment(current_rest)
  if comment_skip1 > 0 {
    current_rest = current_rest[comment_skip1:]
    current_offset += comment_skip1
  }
  let body_result = tokenize_body(
    current_rest,
    start_bytes_offset=current_offset,
  )
  current_rest = body_result.rest
  current_offset = body_result.end_bytes_offset
  let comment_skip2 = skip_comment(current_rest)
  if comment_skip2 > 0 {
    current_rest = current_rest[comment_skip2:]
    current_offset += comment_skip2
  }
  let xref_result = tokenize_xref_table(current_rest, current_offset)
  current_rest = xref_result.rest
  current_offset = xref_result.end_bytes_offset
  let comment_skip3 = skip_comment(current_rest)
  if comment_skip3 > 0 {
    current_rest = current_rest[comment_skip3:]
    current_offset += comment_skip3
  }
  let trailer_result = tokenize_trailer(current_rest, current_offset)
  current_rest = trailer_result.rest
  current_offset = trailer_result.end_bytes_offset
  let comment_skip4 = skip_comment(current_rest)
  if comment_skip4 > 0 {
    current_rest = current_rest[comment_skip4:]
    current_offset += comment_skip4
  }
  let startxref_result = tokenize_startxref(current_rest, current_offset)
  {
    value: {
      header: header_result.value,
      body: body_result.value,
      xref_table: xref_result.value,
      trailer: trailer_result.value,
      start_xref_bytes_offset: startxref_result.value,
    },
    start_bytes_offset: 0,
    end_bytes_offset: startxref_result.end_bytes_offset,
    rest: startxref_result.rest,
  }
}
