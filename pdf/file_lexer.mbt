///|
suberror LexError String derive(Show)

///|
pub(all) struct LexResult[T] {
  value : T
  start_bytes_offset : Int
  end_bytes_offset : Int
  rest : BytesView
} derive(Show)

///|
pub fn tokenize_header(
  input : BytesView,
  start_bytes_offset~ : Int,
) -> LexResult[LexHeader] raise LexError {
  lexmatch input with longest {
    (
      ("%PDF-" ("\d+" as major) "." ("\d+" as minor) "(\r\n)|\r|\n") as all,
      rest
    ) => {
      let (major, _) = try! @lexer_bytes.tokenize_int(major)
      let (minor, _) = try! @lexer_bytes.tokenize_int(minor)
      LexResult::{
        value: LexHeader::{ major, minor },
        start_bytes_offset,
        end_bytes_offset: start_bytes_offset + all.length(),
        rest,
      }
    }
    _ => raise LexError("invalid PDF header")
  }
}

///|
const EndObj = b"endobj"

///|
fn skip_space(input : BytesView) -> Int {
  lexmatch input with longest {
    ("[ \r\n]+" as all, _) => all.length()
    _ => 0
  }
}

///|
pub fn tokenize_body(
  input : BytesView,
  start_bytes_offset~ : Int,
) -> LexResult[LexBody] {
  let mut offset = start_bytes_offset
  let mut rest = input
  let body_buffer = []
  for {
    // in `ISO 32000-2:2020 (PDF 2.0)`, section 7.3.10
    // 
    // The definition of and indirect object in a PDF file **shall** consist of its object number
    // and generation number(separated by white-space), followed by the value of the object bracketed
    // between the keywords `obj` and `endobj`
    //
    lexmatch rest with longest {
      (
        (("\d+" as obj_num) "[ ]+" ("\d+" as gen_num) "[ ]+" "obj") as header,
        rest_after_header
      ) =>
        match rest_after_header.find(EndObj) {
          Some(endobj_start_idx) => {
            let obj_bytes = rest_after_header[0:endobj_start_idx]
            let (object_num, _) = try! @lexer_bytes.tokenize_int(obj_num)
            let (generation_num, _) = try! @lexer_bytes.tokenize_int(gen_num)
            let obj = LexObj::{
              start_bytes_offset: offset,
              object_num,
              generation_num,
              obj_bytes,
            }
            body_buffer.push(obj)
            let endobj_end_idx = endobj_start_idx + EndObj.length()
            rest = rest_after_header[endobj_end_idx:]
            offset += header.length() + endobj_end_idx
            let skip_len = skip_space(rest)
            rest = rest[skip_len:]
            offset += skip_len
          }
          None => break
        }
      _ => break
    }
  }
  LexResult::{
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
  lexmatch input with longest {
    (
      (
        ("\d+" as offset_str)
        " "
        ("\d+" as gen_str)
        " "
        "n"
        "[ ]*"
        "( \r)|( \n)|(\r\n)|\n|\r"
      ) as all,
      rest
    ) => {
      let (bytes_offset, _) = try! @lexer_bytes.tokenize_int(offset_str)
      let (generation_num, _) = try! @lexer_bytes.tokenize_int(gen_str)
      let state = LexEntryState::InUse
      LexResult::{
        value: LexXRefEntry::{ bytes_offset, generation_num, state },
        start_bytes_offset,
        end_bytes_offset: start_bytes_offset + all.length(),
        rest,
      }
    }
    (
      (
        ("\d+" as offset_str)
        " "
        ("\d+" as gen_str)
        " "
        "f"
        "[ ]*"
        "( \r)|( \n)|(\r\n)|\n|\r"
      ) as all,
      rest
    ) => {
      let (bytes_offset, _) = try! @lexer_bytes.tokenize_int(offset_str)
      let (generation_num, _) = try! @lexer_bytes.tokenize_int(gen_str)
      let state = LexEntryState::Free
      LexResult::{
        value: LexXRefEntry::{ bytes_offset, generation_num, state },
        start_bytes_offset,
        end_bytes_offset: start_bytes_offset + all.length(),
        rest,
      }
    }
    _ =>
      raise LexError(
        "Invalid xref entry format in \{start_bytes_offset}, input `\{try! @encoding/utf8.decode(input)}`",
      )
  }
}

///|
pub fn tokenize_xref_table(
  input : BytesView,
  start_bytes_offset : Int,
) -> LexResult[LexXRefTable] raise LexError {
  lexmatch input with longest {
    (
      (
        "xref"
        "(\r\n)|\r|\n"
        ("\d+" as start_num_str)
        " "
        ("\d+" as count_str)
        "(\r\n)|\r|\n"
      ) as header,
      rest
    ) => {
      let (start_num, _) = try! @lexer_bytes.tokenize_int(start_num_str)
      let (count, _) = try! @lexer_bytes.tokenize_int(count_str)
      let mut current_rest = rest
      let mut current_offset = start_bytes_offset + header.length()
      let entries = []
      for i = 0; i < count; i = i + 1 {
        let entry_result = tokenize_xref_entry(
          current_rest,
          start_bytes_offset=current_offset,
        )
        entries.push(entry_result.value)
        current_rest = entry_result.rest
        current_offset = entry_result.end_bytes_offset
      }
      LexResult::{
        value: LexXRefTable::{ entries, start_num },
        start_bytes_offset,
        end_bytes_offset: current_offset,
        rest: current_rest,
      }
    }
    _ =>
      raise LexError(
        (
          $| Invalid xref table format in \{start_bytes_offset}
          $|
          $| input: \{try! @encoding/utf8.decode(input)}
        ),
      )
  }
}

///|
pub fn tokenize_trailer(
  input : BytesView,
  start_bytes_offset : Int,
) -> LexResult[BytesView] raise LexError {
  lexmatch input with longest {
    (("trailer" "(\r\n)|\r|\n") as header, rest_after_header) => {
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
              if prev_char == '\n' || prev_char == '\r' {
                found_startxref = true
                break
              }
            }
          }
        }
        trailer_content_end += 1
      }
      if not(found_startxref) {
        raise LexError("No 'startxref' found after trailer")
      }
      let mut dict_end = trailer_content_end
      if dict_end > 0 {
        let last_char = rest_after_header[dict_end - 1]
        if last_char == '\n' || last_char == '\r' {
          dict_end -= 1
          if dict_end > 0 &&
            last_char == '\n' &&
            rest_after_header[dict_end - 1] == '\r' {
            dict_end -= 1
          }
        }
      }
      let trailer_dict = rest_after_header[:dict_end]
      let rest_at_newline = rest_after_header[dict_end:]
      lexmatch rest_at_newline with longest {
        ("(\r\n)|\r|\n" as newline, rest) => {
          let all_length = header.length() + dict_end + newline.length()
          LexResult::{
            value: trailer_dict,
            start_bytes_offset,
            end_bytes_offset: start_bytes_offset + all_length,
            rest,
          }
        }
        _ => raise LexError("Expected newline before 'startxref'")
      }
    }
    _ => raise LexError("Invalid trailer format")
  }
}

///|
pub fn tokenize_startxref(
  input : BytesView,
  start_bytes_offset : Int,
) -> LexResult[Int] raise LexError {
  lexmatch input with longest {
    (
      ("startxref" "(\r\n)|\r|\n" ("\d+" as offset_str) "(\r\n)|\r|\n" "%%EOF") as all,
      rest
    ) => {
      let (xref_offset, _) = try! @lexer_bytes.tokenize_int(offset_str)
      LexResult::{
        value: xref_offset,
        start_bytes_offset,
        end_bytes_offset: start_bytes_offset + all.length(),
        rest,
      }
    }
    _ => raise LexError("Invalid startxref format")
  }
}

///|
/// return advance offset
pub fn skip_comment(input : BytesView) -> Int {
  lexmatch input with longest {
    ("%" as _percent, rest_after_percent) => {
      let max_comment_length = 1024
      let mut comment_content_end = 0
      let mut found_newline = false
      let mut is_eof_comment = false
      while comment_content_end < rest_after_percent.length() &&
            comment_content_end < max_comment_length {
        let char = rest_after_percent[comment_content_end]
        if char == '\r' || char == '\n' {
          found_newline = true
          break
        }
        comment_content_end += 1
      }
      if not(found_newline) &&
        comment_content_end == rest_after_percent.length() {
        is_eof_comment = true
      }
      if is_eof_comment {
        1 + comment_content_end
      } else if found_newline {
        let rest_at_newline = rest_after_percent[comment_content_end:]
        lexmatch rest_at_newline with longest {
          ("(\r\n)|\r|\n" as newline, _rest) =>
            1 + comment_content_end + newline.length()
          _ => 0
        }
      } else {
        1 + comment_content_end
      }
    }
    _ => 0
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
  LexResult::{
    value: LexFile::{
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
