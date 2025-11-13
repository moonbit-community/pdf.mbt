///|
/// Convert a String to Bytes suitable for PDF literal strings.
/// 
/// if Unicode Code Point not in the ASCII charset, replace it with '?'
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
fn pdf_bytes_of_string(non_escape : String) -> Bytes {
  let buffer = @buffer.new(size_hint=non_escape.length() * 2)
  for i in 0..<non_escape.length() {
    let code_unit = non_escape[i]
    if Char::is_ascii(code_unit.unsafe_to_char()) {
      let byte = code_unit.to_byte()
      // Escape PDF special characters for literal strings
      // ref: ISO 32000-2:2020 (PDF 2.0), section 7.3.4.2
      match byte {
        // Backslash - must be escaped
        '\\' => {
          buffer.write_byte(b'\\')
          buffer.write_byte(b'\\')
        }
        // Parentheses - must be escaped in literal strings
        '(' => {
          buffer.write_byte(b'\\')
          buffer.write_byte(b'(')
        }
        ')' => {
          buffer.write_byte(b'\\')
          buffer.write_byte(b')')
        }
        // Control characters - escape as named sequences
        '\n' => {
          buffer.write_byte(b'\\')
          buffer.write_byte(b'n')
        }
        '\r' => {
          buffer.write_byte(b'\\')
          buffer.write_byte(b'r')
        }
        '\t' => {
          buffer.write_byte(b'\\')
          buffer.write_byte(b't')
        }
        '\b' => {
          buffer.write_byte(b'\\')
          buffer.write_byte(b'b')
        }
        '\f' => {
          buffer.write_byte(b'\\')
          buffer.write_byte(b'f')
        }
        // All other ASCII characters pass through unchanged
        _ => buffer.write_byte(byte)
      }
    } else {
      // Non-ASCII characters are replaced with '?'
      buffer.write_byte(b'?')
    }
  }
  buffer.to_bytes()
}

///|
pub fn markdown_to_bytes(md_str : String) -> Bytes {
  let tm : @pdf.TransformMatrix = @pdf.TransformMatrix::{
    a: 1,
    b: 0,
    c: 0,
    d: 1,
    e: 50,
    f: 770,
  }
  let cmark_doc = @cmark.Doc::from_string(md_str)
  let doc = Doc::from_cmark(cmark_doc)
  let flat_headings = doc.to_flatheadings()
  let table_of_contents : ContentStream = [
    Op_cm(tm),
    Op_BT,
    ..FlatHeading::to_graphic_operators(flat_headings),
    Op_ET,
  ]
  let trim_doc = doc.remove_contiguous_blanklines()
  let split_doc = trim_doc.split(max_height=660)
  // let split_doc = doc 

  //   for doc in split_doc {
  // println    (doc)
  //   }
  let contents : Array[ContentStream] = split_doc.map(doc => [
    Op_cm(tm),
    Op_BT,
    ..doc.to_graphic_operators(),
    Op_ET,
  ])
  multiple_page_to_bytes([table_of_contents, ..contents])
}

///|
test "pdf_bytes_of_string - basic ASCII text" {
  let result = pdf_bytes_of_string("Hello World")
  let expected = b"Hello World"
  assert_eq(result, expected)
}

///|
test "pdf_bytes_of_string - backslash escape" {
  let result = pdf_bytes_of_string("path\\to\\file")
  let expected = b"path\\\\to\\\\file"
  assert_eq(result, expected)
}

///|
test "pdf_bytes_of_string - parentheses escape" {
  let result = pdf_bytes_of_string("text (with) parentheses")
  let expected = b"text \\(with\\) parentheses"
  assert_eq(result, expected)
}

///|
test "pdf_bytes_of_string - newline escape" {
  let result = pdf_bytes_of_string("line1\nline2")
  let expected = b"line1\\nline2"
  assert_eq(result, expected)
}

///|
test "pdf_bytes_of_string - carriage return escape" {
  let result = pdf_bytes_of_string("text\rmore")
  let expected = b"text\\rmore"
  assert_eq(result, expected)
}

///|
test "pdf_bytes_of_string - tab escape" {
  let result = pdf_bytes_of_string("text\ttab")
  let expected = b"text\\ttab"
  assert_eq(result, expected)
}

///|
test "pdf_bytes_of_string - backspace escape" {
  let result = pdf_bytes_of_string("text\bbackspace")
  let expected = b"text\\bbackspace"
  assert_eq(result, expected)
}

///|
test "pdf_bytes_of_string - form feed escape" {
  let result = pdf_bytes_of_string("text\fform")
  let expected = b"text\\fform"
  assert_eq(result, expected)
}

///|
test "pdf_bytes_of_string - all escape sequences combined" {
  let result = pdf_bytes_of_string("\\()test\n\r\t\b\f")
  let expected = b"\\\\\\(\\)test\\n\\r\\t\\b\\f"
  assert_eq(result, expected)
}

///|
test "pdf_bytes_of_string - non-ASCII replacement" {
  let result = pdf_bytes_of_string("Hello 世界")
  let expected = b"Hello ??"
  assert_eq(result, expected)
}

///|
test "pdf_bytes_of_string - mixed ASCII and non-ASCII" {
  let result = pdf_bytes_of_string("ASCII文字mixed")
  let expected = b"ASCII??mixed"
  assert_eq(result, expected)
}

///|
test "pdf_bytes_of_string - empty string" {
  let result = pdf_bytes_of_string("")
  let expected = b""
  assert_eq(result, expected)
}

///|
test "pdf_bytes_of_string - only special characters" {
  let result = pdf_bytes_of_string("\n\r\t\b\f\\()")
  let expected = b"\\n\\r\\t\\b\\f\\\\\\(\\)"
  assert_eq(result, expected)
}

///|
test "pdf_bytes_of_string - alphanumeric and symbols" {
  let result = pdf_bytes_of_string("abc123!@#$%^&*-_=+[]{}|;:'\",.<>?/~`")
  let expected = b"abc123!@#$%^&*-_=+[]{}|;:'\",.<>?/~`"
  assert_eq(result, expected)
}
